import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/user_model.dart';
import '../utils/user_repository.dart';
import '../utils/timeline_calculator.dart';
import '../widgets/animated_background.dart';
import '../widgets/home_view.dart';
import '../widgets/history_view.dart';
import '../widgets/steps_view.dart';
import '../widgets/side_menu_view.dart';
import '../widgets/hint_icon_button.dart';
import '../widgets/app_dialogs.dart';
import '../utils/app_init_service.dart';
import '../utils/step_tracker_service.dart';
import '../utils/master_data_repository.dart';
import '../utils/ad_manager.dart';

class MainPage extends StatefulWidget {
  final bool isJustLoggedIn;

  const MainPage({
    super.key,
    this.isJustLoggedIn = false,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  final UserRepository _userRepository = UserRepository();
  final MasterDataRepository _masterDataRepository = MasterDataRepository();
  final AdManager _adManager = AdManager();

  UserDetailedData? _detailedData;
  bool _isLoading = true;

  int _incrementalSteps = 0;
  int _todaySteps = 0;
  String? _currentEraKey;

  // 🌟 ダイアログ排他制御
  bool _isUpdatingEra = false;
  bool _isShowingDialog = false;

  String? _resolvedBgUrl;
  List<Map<String, dynamic>> _pastWeeklySteps = [];
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserDataFast();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    StepTrackerService.stopTracking();
    _adManager.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _detailedData != null) {
      StepTrackerService.startForegroundTracking(
        context: context,
        stepFetchedAt: _detailedData!.user.stepFetchedAt ?? DateTime.now(),
        onStepsUpdated: _onStepsUpdated,
        onWeeklyUpdated: (weekly) {
          if (mounted) setState(() => _pastWeeklySteps = weekly);
        },
      );

      _checkAndPrepareAd();
    }
  }

  Future<void> _loadUserDataFast() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      StepTrackerService.initialize();

      if (widget.isJustLoggedIn) {
        await _userRepository.updateStepFetchTimestamp(user.uid);
      }

      final data = await _userRepository.getUserWithDetails(user.uid);

      if (mounted) {
        setState(() {
          _detailedData = data;
          _isLoading = false;
          _currentEraKey = _calculateCurrentEraKey(data.user.totalSteps);
        });

        _resolveBgUrlAsync();
        _initPermissionsAndStepTracking(data);
        _checkAndPrepareAd();

        if (widget.isJustLoggedIn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            AppDialogs.showWelcomeHealthNoticeDialog(context);
          });
        }
      }
    } catch (e) {
      print('❌ [MainPage] ユーザーデータ読み込みエラー: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// 🌟 広告ロード要求（UI表示条件とは完全に切り離して安全にロード）
  void _checkAndPrepareAd() {
    final user = _detailedData?.user;
    if (user == null) return;

    if (!_isCooldownExpired(user.lastArtifactUnlockedAt)) return;

    _adManager.loadRewardedAd(
      onAdLoaded: () {
        if (mounted) setState(() {}); // 広告準備完了時に描画更新
      },
      onAdFailed: () {
        if (mounted) setState(() {});
      },
    );
  }

  bool _isCooldownExpired(DateTime? lastUnlockedAt) {
    if (lastUnlockedAt == null) return true;
    final nowUtc = DateTime.now().toUtc();
    final lastUtc = lastUnlockedAt.toUtc();
    return nowUtc.difference(lastUtc).inHours >= 4;
  }

  bool _isSameDayAsToday(DateTime? timestamp) {
    if (timestamp == null) return false;
    final localTime = timestamp.toLocal();
    final now = DateTime.now();
    return localTime.year == now.year &&
        localTime.month == now.month &&
        localTime.day == now.day;
  }

  Future<void> _initPermissionsAndStepTracking(UserDetailedData data) async {
    AppInitService.requestPermissionsAfterLogin();

    StepTrackerService.startForegroundTracking(
      context: context,
      stepFetchedAt: data.user.stepFetchedAt ?? DateTime.now(),
      onStepsUpdated: _onStepsUpdated,
      onWeeklyUpdated: (weekly) {
        if (mounted) setState(() => _pastWeeklySteps = weekly);
      },
    );

    final weekly = await StepTrackerService.fetchPastWeeklySteps();
    if (mounted && weekly.isNotEmpty) {
      setState(() {
        _pastWeeklySteps = weekly;
      });
    }
  }

  Future<void> _resolveBgUrlAsync() async {
    if (_detailedData == null || _currentEraKey == null) return;

    final eraMap = _detailedData!.user.unlockedEras[_currentEraKey];
    if (eraMap == null) return;

    final rawPath = eraMap['backgroundImagePath'] as String? ?? '';
    if (rawPath.isNotEmpty) {
      final resolved = await _masterDataRepository.resolveImageUrl(rawPath);
      if (mounted && resolved.isNotEmpty && resolved != _resolvedBgUrl) {
        setState(() {
          _resolvedBgUrl = resolved;
        });
      }
    }
  }

  void _onStepsUpdated(int incrementalSteps, int todaySteps) async {
    if (!mounted || _detailedData == null) return;

    setState(() {
      _incrementalSteps = incrementalSteps;
      _todaySteps = todaySteps;

      if (_pastWeeklySteps.isNotEmpty) {
        _pastWeeklySteps.last['steps'] = todaySteps;
      }
    });

    final currentTotalSteps =
        _detailedData!.user.totalSteps + _incrementalSteps;
    final calculatedEraKey = _calculateCurrentEraKey(currentTotalSteps);

    // 1. 年代到達イベント判定（最優先）
    if (_currentEraKey != null &&
        calculatedEraKey != _currentEraKey &&
        !_isUpdatingEra) {
      _isUpdatingEra = true;
      await _handleEraUnlocked(calculatedEraKey, currentTotalSteps);
      return;
    }

    // 2. 6,000歩 / 10,000歩マイルストーンポップアウト判定
    if (!_isUpdatingEra && !_isShowingDialog) {
      _checkAndShowStepMilestoneDialog(todaySteps);
    }

    // 3. 広告ロード確認
    _checkAndPrepareAd();
  }

  Future<void> _checkAndShowStepMilestoneDialog(int todaySteps) async {
    if (todaySteps < 6000 || _detailedData == null) return;

    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userModel = _detailedData!.user;
    final is6kUnlockedToday = _isSameDayAsToday(userModel.steps6kUnlockedAt);
    final is10kUnlockedToday = _isSameDayAsToday(userModel.steps10kUnlockedAt);

    // ① 6,000歩達成判定 (本日未取得の場合)
    if (todaySteps >= 6000 && !is6kUnlockedToday) {
      _isShowingDialog = true;

      if (mounted) {
        await AppDialogs.showMilestoneStepDialog(
          context: context,
          title: l10n.milestone6kTitle,
          description: l10n.milestone6kDesc,
          buttonText: l10n.milestoneGetArtifact,
        );

        final now = DateTime.now();
        await _userRepository.updateMilestoneUnlockedAt(
          userId: user.uid,
          milestoneType: 6000,
          unlockedAt: now,
        );

        await _handleArtifactDiscovery(fromAd: false);
      }
      _isShowingDialog = false;
      return;
    }

    // ② 10,000歩達成判定 (6,000歩取得済み ＆ 10,000歩が本日未取得の場合)
    if (todaySteps >= 10000 && is6kUnlockedToday && !is10kUnlockedToday) {
      _isShowingDialog = true;

      if (mounted) {
        await AppDialogs.showMilestoneStepDialog(
          context: context,
          title: l10n.milestone10kTitle,
          description: l10n.milestone10kDesc,
          buttonText: l10n.milestoneGetArtifact,
        );

        final now = DateTime.now();
        await _userRepository.updateMilestoneUnlockedAt(
          userId: user.uid,
          milestoneType: 10000,
          unlockedAt: now,
        );

        await _handleArtifactDiscovery(fromAd: false);
      }
      _isShowingDialog = false;
    }
  }

  String _calculateCurrentEraKey(int totalSteps) {
    final user = _detailedData!.user;
    final currentDate = TimelineCalculator.addStepsToDate(
      era: user.startEra,
      year: user.startYear,
      month: user.startMonth,
      day: user.startDay,
      steps: totalSteps,
      stepsPerDay: 1,
    );

    return UserRepository.calculateEraKey(currentDate.era, currentDate.year);
  }

  Future<void> _handleEraUnlocked(String newEraKey, int newTotalSteps) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _detailedData == null) return;

    _isShowingDialog = true;
    final userData = _detailedData!.user;
    final currentDate = TimelineCalculator.addStepsToDate(
      era: userData.startEra,
      year: userData.startYear,
      month: userData.startMonth,
      day: userData.startDay,
      steps: newTotalSteps,
      stepsPerDay: 1,
    );

    final eraLabel = currentDate.eraLabel;

    if (mounted) {
      await AppDialogs.showEraUnlockedDialog(context, eraLabel);
    }

    try {
      final updatedDetails = await _userRepository.updateUserEraProgress(
        userId: user.uid,
        newTotalSteps: newTotalSteps,
        newEraKey: newEraKey,
        eraLabel: eraLabel,
        century: currentDate.century,
        currentGameMode: userData.gameMode,
      );

      if (mounted) {
        setState(() {
          _detailedData = updatedDetails;
          _incrementalSteps = 0;
          _currentEraKey = newEraKey;
          _isUpdatingEra = false;
          _isShowingDialog = false;
        });

        _resolveBgUrlAsync();

        StepTrackerService.startForegroundTracking(
          context: context,
          stepFetchedAt: updatedDetails.user.stepFetchedAt ?? DateTime.now(),
          onStepsUpdated: _onStepsUpdated,
          onWeeklyUpdated: (weekly) {
            if (mounted) setState(() => _pastWeeklySteps = weekly);
          },
        );
      }
    } catch (e) {
      print('❌ [MainPage] 年代更新保存エラー: $e');
      _isUpdatingEra = false;
      _isShowingDialog = false;
    }
  }

  /// 🌟 アーティファクト獲得処理
  Future<void> _handleArtifactDiscovery({bool fromAd = true}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _detailedData == null || _currentEraKey == null) return;

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
    }

    try {
      final acquiredArtifact = await _userRepository.unlockRandomArtifactForEra(
        userId: user.uid,
        currentEraKey: _currentEraKey!,
        currentDetails: _detailedData!,
        isFromAd: fromAd,
      );

      if (mounted) Navigator.pop(context);

      if (acquiredArtifact == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('この年代のアーティファクトはすべて獲得済みです！'),
              backgroundColor: Colors.orangeAccent,
            ),
          );
        }
        return;
      }

      final updatedDetails =
          await _userRepository.getUserWithDetails(user.uid);
      if (mounted) {
        setState(() {
          _detailedData = updatedDetails;
        });

        // 獲得後の広告再評価
        _checkAndPrepareAd();

        AppDialogs.showArtifactRewardModal(context, acquiredArtifact);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      print('❌ [MainPage] アーティファクト獲得エラー: $e');
    }
  }

  void _onWatchAdTriggered(AppLocalizations l10n) {
    final currentLocale = Localizations.localeOf(context).languageCode;
    final eraMap = _detailedData?.user.unlockedEras[_currentEraKey];

    String eraLabel = '';
    if (eraMap != null) {
      final labelJp = eraMap['yearLabelJp'] as String? ?? eraMap['eraLabel'] as String? ?? '';
      final labelEn = eraMap['yearLabelEn'] as String? ?? eraMap['eraLabel'] as String? ?? '';
      eraLabel = currentLocale == 'en' ? (labelEn.isNotEmpty ? labelEn : labelJp) : labelJp;
    }

    AppDialogs.showArtifactConfirmationDialog(
      context: context,
      l10n: l10n,
      eraLabel: eraLabel,
      onWatchAd: () {
        _adManager.showRewardedAd(
          onUserEarnedReward: () {
            _handleArtifactDiscovery(fromAd: true);
          },
          onAdFailed: (reason) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(reason),
                backgroundColor: Colors.redAccent,
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;

    final rawUser = _detailedData?.user;
    final currentTotalSteps = (rawUser?.totalSteps ?? 0) + _incrementalSteps;

    final displayUser = rawUser != null
        ? UserModel(
            userId: rawUser.userId,
            appStartDate: rawUser.appStartDate,
            stepFetchedAt: rawUser.stepFetchedAt,
            startEra: rawUser.startEra,
            startYear: rawUser.startYear,
            startMonth: rawUser.startMonth,
            startDay: rawUser.startDay,
            isCleared: rawUser.isCleared,
            gameMode: rawUser.gameMode,
            steps: _todaySteps,
            totalSteps: currentTotalSteps,
            scheduledDeletionAt: rawUser.scheduledDeletionAt,
            lastArtifactUnlockedAt: rawUser.lastArtifactUnlockedAt,
            steps6kUnlockedAt: rawUser.steps6kUnlockedAt,
            steps10kUnlockedAt: rawUser.steps10kUnlockedAt,
            unlockedArtifacts: rawUser.unlockedArtifacts,
            unlockedEras: rawUser.unlockedEras,
          )
        : null;

    final currentAppDate = displayUser != null
        ? TimelineCalculator.addStepsToDate(
            era: displayUser.startEra,
            year: displayUser.startYear,
            month: displayUser.startMonth,
            day: displayUser.startDay,
            steps: displayUser.totalSteps,
            stepsPerDay: 1,
          )
        : null;

    final currentHistoryMaster = _currentEraKey != null
        ? _detailedData?.unlockedHistories[_currentEraKey]
        : null;

    final String? bgImageUrl = _resolvedBgUrl ??
        (currentHistoryMaster?.backgroundImagePath.startsWith('http') == true
            ? currentHistoryMaster!.backgroundImagePath
            : null);

    const String fallbackAssetImage = 'assets/images/mainback1.jpeg';

    final String appBarTitle = _selectedTabIndex == 0
        ? l10n.tabHome
        : _selectedTabIndex == 1
            ? l10n.tabHistory
            : l10n.tabSteps;

    // 🌟 ★ボタン表示条件の単一真実判定 (ホームタブ ＆ 4時間経過済み ＆ 広告ロード完了)
    final bool isShowAdButton = _selectedTabIndex == 0 &&
        _isCooldownExpired(displayUser?.lastArtifactUnlockedAt) &&
        _adManager.isAdReady;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(appBarTitle),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
        actions: [
          HintIconButton(
            title: _selectedTabIndex == 0
                ? l10n.hintHomeTitle
                : _selectedTabIndex == 1
                    ? l10n.hintHistoryTitle
                    : l10n.hintStepsTitle,
            description: _selectedTabIndex == 0
                ? l10n.hintHomeDesc
                : _selectedTabIndex == 1
                    ? l10n.hintHistoryDesc
                    : l10n.hintStepsDesc,
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: SideMenuView(user: user, userData: displayUser),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBackground(
              key: ValueKey(bgImageUrl ?? 'fallback'),
              imageUrl: bgImageUrl,
              fallbackAssetPath: fallbackAssetImage,
              isDarkMode: isDarkMode,
            ),
          ),
          SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      const SizedBox(height: 8),
                      _buildSegmentedControl(context, l10n),
                      const SizedBox(height: 16),
                      Expanded(
                        child: IndexedStack(
                          index: _selectedTabIndex,
                          children: [
                            HomeView(
                              appDate: currentAppDate,
                              historyMaster: currentHistoryMaster,
                            ),
                            HistoryView(detailedData: _detailedData),
                            StepsView(
                              userData: displayUser,
                              pastWeeklySteps: _pastWeeklySteps,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),

          if (isShowAdButton)
            Positioned(
              right: 20,
              bottom: 30,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: isShowAdButton ? 1.0 : 0.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Material(
                      color: isDarkMode
                          ? Colors.purple.withOpacity(0.40)
                          : Colors.white.withOpacity(0.50),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => _onWatchAdTriggered(l10n),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDarkMode
                                  ? Colors.white.withOpacity(0.20)
                                  : Colors.white.withOpacity(0.60),
                            ),
                          ),
                          child: Icon(
                            Icons.auto_awesome,
                            color: isDarkMode
                                ? Colors.amberAccent
                                : Colors.deepPurple,
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl(BuildContext context, AppLocalizations l10n) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final activeBgColor = isDarkMode
        ? Colors.purpleAccent.withOpacity(0.35)
        : Theme.of(context).colorScheme.primaryContainer.withOpacity(0.85);

    return Container(
      width: 320,
      height: 42,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.40),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          _buildSegmentItem(context, 0, l10n.tabHome, activeBgColor),
          _buildSegmentItem(context, 1, l10n.tabHistory, activeBgColor),
          _buildSegmentItem(context, 2, l10n.tabSteps, activeBgColor),
        ],
      ),
    );
  }

  Widget _buildSegmentItem(
      BuildContext context, int index, String label, Color activeBgColor) {
    final isSelected = _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
          if (index == 0) {
            _checkAndPrepareAd();
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? activeBgColor : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}