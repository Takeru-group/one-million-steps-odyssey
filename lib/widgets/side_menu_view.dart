import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../l10n/app_localizations.dart';
import '../main.dart';
import '../models/user_model.dart';
import '../utils/background_fetch_service.dart';
import '../pages/hall_of_fame_page.dart';
import '../pages/initial_page.dart';
import '../utils/step_tracker_service.dart';
import '../utils/user_repository.dart';

class SideMenuView extends StatefulWidget {
  final User? user;
  final UserModel? userData;
  final UserDetailedData? detailedData;
  final String? bgImageUrl;

  const SideMenuView({
    super.key,
    required this.user,
    required this.userData,
    this.detailedData,
    this.bgImageUrl,
  });

  @override
  State<SideMenuView> createState() => _SideMenuViewState();
}

class _SideMenuViewState extends State<SideMenuView> {
  late String _displayName;
  final UserRepository _userRepository = UserRepository();

  @override
  void initState() {
    super.initState();
    _displayName = widget.user?.displayName ?? 'Traveler';
  }

  Future<void> _showEditDisplayNameDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: _displayName);

    final newName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.menuChangeNicknameTitle),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: l10n.menuChangeNicknameHint,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.menuCancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: Text(l10n.menuSave),
            ),
          ],
        );
      },
    );

    if (newName != null && newName.isNotEmpty && newName != _displayName) {
      try {
        await widget.user?.updateDisplayName(newName);
        await widget.user?.reload();
        setState(() {
          _displayName = newName;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.menuNicknameUpdated)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.menuNicknameUpdateFailed(e.toString()))),
          );
        }
      }
    }
  }

  /// 🚪 ログアウト確認ダイアログ＆安全なログアウト処理（厳格な保存確認つき）
  Future<void> _handleLogout(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final dialogBgColor = isDarkMode
        ? Colors.black.withOpacity(0.80)
        : Colors.white.withOpacity(0.90);
    final borderColor = isDarkMode
        ? Colors.white.withOpacity(0.20)
        : Colors.white.withOpacity(0.50);
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    final navigator = Navigator.of(context, rootNavigator: true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AlertDialog(
            backgroundColor: dialogBgColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: borderColor),
            ),
            title: Text(
              l10n.logoutDialogTitle,
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
            content: Text(
              l10n.logoutDialogMessage,
              style: TextStyle(color: textColor, fontSize: 13, height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.logoutCancelButton),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.logoutConfirmButton),
              ),
            ],
          ),
        );
      },
    );

    if (shouldLogout != true) return;
    if (!mounted) return;

    // ローディング表示（rootNavigator を使用して確実に管理）
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(child: CircularProgressIndicator()),
      ),
    );

    try {
      // 1. 歩数保存を厳格に実行（タイムアウト4秒）
      if (widget.user != null && widget.userData != null) {
        print('⏳ [Logout] 歩数データの保存を開始します...');
        await _userRepository.saveStepsOnLogout(
          userId: widget.user!.uid,
          todaySteps: widget.userData!.steps,
          totalSteps: widget.userData!.totalSteps,
        ).timeout(const Duration(seconds: 4));
        print('✅ [Logout] 歩数データの保存に成功しました！');
      }

      // 2. トラッキングの安全停止
      StepTrackerService.stopTracking();
      await BackgroundFetchService.stop();

      // 3. サインアウト処理
      await Future.wait([
        FirebaseAuth.instance.signOut(),
        GoogleSignIn().signOut(),
      ]).timeout(const Duration(seconds: 4));

      // 4. ローディングモーダルを閉じる
      navigator.pop();

      // 5. ログイン・初期画面へ完全に画面スタックを一掃して遷移
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const InitialPage()),
        (route) => false,
      );
    } catch (e) {
      print('❌ [Logout Failure] 保存またはサインアウト失敗: $e');

      // エラー発生時はローディングを解除して失敗メッセージを表示
      navigator.pop(); // ローディングポップアップを閉じる

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('データの保存に失敗したためログアウトを中止しました。通信環境をご確認ください: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final currentTheme = themeModeNotifier.value;
    final currentLocale =
        localeNotifier.value ?? Localizations.localeOf(context);

    final drawerBgColor = isDarkMode
        ? Colors.black.withOpacity(0.55)
        : Colors.white.withOpacity(0.65);
    final borderColor = isDarkMode
        ? Colors.white.withOpacity(0.15)
        : Colors.white.withOpacity(0.40);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.white70 : Colors.black54;

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: drawerBgColor,
              border: Border(right: BorderSide(color: borderColor)),
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _displayName,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit, size: 18, color: textColor),
                              onPressed: () => _showEditDisplayNameDialog(context),
                              tooltip: l10n.menuChangeNicknameTitle,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        if (widget.userData?.startEra != null)
                          Text(
                            l10n.menuStartPoint(
                              widget.userData!.startEra,
                              widget.userData!.startYear,
                            ),
                            style: TextStyle(fontSize: 12, color: subTextColor),
                          ),
                        const SizedBox(height: 4),

                        SelectableText(
                          'UserID: ${widget.user?.uid ?? l10n.menuNotLoggedIn}',
                          style: TextStyle(fontSize: 11, color: subTextColor),
                        ),
                      ],
                    ),
                  ),
                ),

                Divider(color: borderColor),

                ListTile(
                  leading: Icon(Icons.directions_walk, color: textColor),
                  title: Text(l10n.menuTodaySteps, style: TextStyle(color: textColor)),
                  trailing: Text(
                    '${widget.userData?.steps ?? 0}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: textColor),
                  ),
                ),

                if (widget.userData?.isCleared == true)
                  ListTile(
                    leading: const Icon(Icons.emoji_events, color: Colors.amber),
                    title: Text(l10n.menuAllConquered,
                        style: const TextStyle(color: Colors.amber)),
                    trailing: Text(
                      '${widget.userData?.totalSteps ?? 0}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.amber),
                    ),
                  )
                else
                  ListTile(
                    leading: Icon(Icons.timeline, color: textColor),
                    title: Text(l10n.menuTotalSteps, style: TextStyle(color: textColor)),
                    trailing: Text(
                      '${widget.userData?.totalSteps ?? 0}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: textColor),
                    ),
                  ),

                Divider(color: borderColor),

                ListTile(
                  leading: const Icon(Icons.account_balance, color: Colors.amberAccent),
                  title: Text(
                    l10n.hallOfFameTitle,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: subTextColor,
                  ),
                  onTap: () {
                    Navigator.pop(context); // サイドメニューを閉じる
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HallOfFamePage(
                          detailedData: widget.detailedData,
                          bgImageUrl: widget.bgImageUrl,
                        ),
                      ),
                    );
                  },
                ),

                Divider(color: borderColor),

                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    l10n.menuThemeSection,
                    style: TextStyle(color: subTextColor, fontSize: 12),
                  ),
                ),
                ListTile(
                  leading: Icon(
                    currentTheme == ThemeMode.dark
                        ? Icons.dark_mode
                        : Icons.light_mode,
                    color: textColor,
                  ),
                  title: Text(l10n.menuDarkMode, style: TextStyle(color: textColor)),
                  trailing: Switch(
                    value: isDarkMode,
                    onChanged: (bool value) {
                      setState(() {
                        themeModeNotifier.value =
                            value ? ThemeMode.dark : ThemeMode.light;
                      });
                    },
                  ),
                ),

                Divider(color: borderColor),

                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    l10n.menuLanguageSection,
                    style: TextStyle(color: subTextColor, fontSize: 12),
                  ),
                ),
                RadioListTile<String>(
                  title: Text('日本語', style: TextStyle(color: textColor)),
                  value: 'ja',
                  groupValue: currentLocale.languageCode,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        localeNotifier.value = Locale(value);
                      });
                    }
                  },
                ),
                RadioListTile<String>(
                  title: Text('English', style: TextStyle(color: textColor)),
                  value: 'en',
                  groupValue: currentLocale.languageCode,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        localeNotifier.value = Locale(value);
                      });
                    }
                  },
                ),

                Divider(color: borderColor),

                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: Text(l10n.menuLogOut,
                      style: const TextStyle(color: Colors.redAccent)),
                  onTap: () => _handleLogout(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}