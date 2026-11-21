import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../l10n/app_localizations.dart';
import '../utils/user_repository.dart';

class OdysseyEndingPage extends StatefulWidget {
  final UserDetailedData? detailedData;
  final String? fallbackBgUrl;

  const OdysseyEndingPage({
    super.key,
    required this.detailedData,
    this.fallbackBgUrl,
  });

  @override
  State<OdysseyEndingPage> createState() => _OdysseyEndingPageState();
}

class _OdysseyEndingPageState extends State<OdysseyEndingPage> {
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollTimer;
  Timer? _imageFadeTimer;

  List _timelineItems = [];
  int _lastTriggeredIndex = -1;
  File? _activeLocalImageFile;
  double _bgOpacity = 0.0;
  bool _isFastForwarding = false;
  bool _isDialogShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prepareTimelineData();
      _startAutoScroll();
    });
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _imageFadeTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  /// 古い順（時系列順）に年代とアーティファクトを整理
  void _prepareTimelineData() {
    if (widget.detailedData == null) return;
    final l10n = AppLocalizations.of(context)!;
    final langCode = Localizations.localeOf(context).languageCode;
    final user = widget.detailedData!.user;
    final userGameMode = user.gameMode;

    final List items = [];

    // 1. 年代（Eras）
    user.unlockedEras.forEach((eraKey, eraData) {
      final eraGameMode = (eraData['gameMode'] as num?)?.toInt() ?? 0;
      if (eraGameMode != userGameMode) return;

      final labelJp = eraData['yearLabelJp'] as String? ?? eraData['eraLabel'] as String? ?? '';
      final labelEn = eraData['yearLabelEn'] as String? ?? eraData['eraLabel'] as String? ?? '';
      final label = langCode == 'en' ? (labelEn.isNotEmpty ? labelEn : labelJp) : labelJp;

      final descJp = eraData['descriptionJp'] as String? ?? '';
      final descEn = eraData['descriptionEn'] as String? ?? '';
      final desc = langCode == 'en' ? (descEn.isNotEmpty ? descEn : descJp) : descJp;

      final bgPath = eraData['backgroundImagePath'] as String? ?? '';
      final century = (eraData['century'] as num?)?.toInt() ?? 0;

      items.add({
        'type': 'era',
        'century': century,
        'unlockedAt': _parseDateTime(eraData['unlockedAt']),
        'title': l10n.eraReachedMessage(label),
        'description': desc,
        'imageUrl': bgPath,
      });
    });

    // 2. アーティファクト（Artifacts）
    user.unlockedArtifacts.forEach((artifactId, artifactData) {
      final artifactGameMode = (artifactData['gameMode'] as num?)?.toInt() ?? 0;
      if (artifactGameMode != userGameMode) return;

      final nameJa = artifactData['nameJa'] as String? ?? '';
      final nameEn = artifactData['nameEn'] as String? ?? '';
      final name = langCode == 'en' ? (nameEn.isNotEmpty ? nameEn : nameJa) : nameJa;

      final descJa = artifactData['descJa'] as String? ?? '';
      final descEn = artifactData['descEn'] as String? ?? '';
      final desc = langCode == 'en' ? (descEn.isNotEmpty ? descEn : descJa) : descJa;

      final category = (artifactData['category'] as String? ?? '').toLowerCase();
      final bool isPerson = category.contains('figure') ||
          category.contains('person') ||
          category.contains('偉人') ||
          category.contains('人物');
      final title = isPerson ? l10n.figureMet(name) : l10n.artifactDiscoveredMessage(name);

      final bgPath = artifactData['backgroundImagePath'] as String? ?? '';
      final century = (artifactData['century'] as num?)?.toInt() ?? 0;

      items.add({
        'type': 'artifact',
        'century': century,
        'unlockedAt': _parseDateTime(artifactData['unlockedAt']),
        'title': title,
        'description': desc,
        'imageUrl': bgPath,
      });
    });

    // 古い順（unlockedAt 昇順、同一時刻の場合は century 昇順）にソート
    items.sort((a, b) {
      final DateTime? dtA = a['unlockedAt'];
      final DateTime? dtB = b['unlockedAt'];
      if (dtA != null && dtB != null) {
        final cmp = dtA.compareTo(dtB);
        if (cmp != 0) return cmp;
      }
      return (a['century'] as int).compareTo(b['century'] as int);
    });

    setState(() {
      _timelineItems = items;
    });
  }

  DateTime? _parseDateTime(dynamic val) {
    if (val == null) return null;
    if (val is DateTime) return val;
    try {
      return (val as dynamic).toDate();
    } catch (_) {
      return null;
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    final local = dt.toLocal();
    return '${local.year}/${local.month.toString().padLeft(2, '0')}/${local.day.toString().padLeft(2, '0')}';
  }

  /// エンドロール自動スクロール（押下中は加速）
  void _startAutoScroll() {
    const tick = Duration(milliseconds: 25);

    _scrollTimer = Timer.periodic(tick, (timer) {
      if (!_scrollController.hasClients) return;

      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;

      if (currentScroll >= maxScroll) {
        timer.cancel();
        _showNewAdventureDialog();
        return;
      }

      // 通常速度もテンポアップ(3.2)、長押し加速中は約4.5倍(14.5)
      final double speed = _isFastForwarding ? 14.5 : 3.2;
      _scrollController.jumpTo((currentScroll + speed).clamp(0.0, maxScroll));
      _checkAndTriggerLocalImage(currentScroll, maxScroll);
    });
  }

  /// スクロール進行に合わせてローカル保存済み画像を1秒（加速中は0.25秒）だけフラッシュ表示
  Future<void> _checkAndTriggerLocalImage(double currentScroll, double maxScroll) async {
    if (_timelineItems.isEmpty || maxScroll <= 0) return;

    final progress = (currentScroll / maxScroll).clamp(0.0, 0.999);
    final index = (progress * _timelineItems.length).floor();

    if (index == _lastTriggeredIndex) return;
    _lastTriggeredIndex = index;

    final targetUrl = _timelineItems[index]['imageUrl'] as String?;
    if (targetUrl == null || targetUrl.isEmpty) return;

    try {
      // ネットワーク通信は一切せず、ローカルキャッシュにある場合のみ即座に取得
      final fileInfo = await DefaultCacheManager().getFileFromCache(targetUrl);
      if (fileInfo == null || !await fileInfo.file.exists()) {
        return; // ローカルに無い場合は黒背景のまま進行
      }

      if (!mounted || _isDialogShown) return;

      _imageFadeTimer?.cancel();
      setState(() {
        _activeLocalImageFile = fileInfo.file;
        _bgOpacity = 0.65; // テキストが読みやすい濃さでふわっと表示
      });

      // 表示時間: 通常時は1000ms(1秒)、加速中は250ms(0.25秒)で即フェードアウト
      final displayDuration = Duration(milliseconds: _isFastForwarding ? 250 : 1000);
      _imageFadeTimer = Timer(displayDuration, () {
        if (mounted) {
          setState(() {
            _bgOpacity = 0.0;
          });
        }
      });
    } catch (_) {
      // キャッシュ取得エラー時は黒背景のままスルー
    }
  }

  /// スキップ押下またはスクロール完了時の確認ダイアログ
  Future<void> _showNewAdventureDialog() async {
    if (_isDialogShown || !mounted) return;
    _isDialogShown = true;
    _scrollTimer?.cancel();
    _imageFadeTimer?.cancel();

    setState(() {
      _bgOpacity = 0.0;
      _isFastForwarding = false;
    });

    final langCode = Localizations.localeOf(context).languageCode;
    final isEn = langCode == 'en';

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: AlertDialog(
            backgroundColor: Colors.black.withValues(alpha: 0.85),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: Colors.amberAccent.withValues(alpha: 0.6)),
            ),
            title: Column(
              children: [
                const Icon(Icons.emoji_events, color: Colors.amberAccent, size: 42),
                const SizedBox(height: 12),
                Text(
                  isEn ? '1,000,000 Steps Achieved!' : '100万歩達成おめでとうございます！',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Text(
              isEn
                  ? 'You have walked through 2,700 years of human history and reached the present day.\n\nWould you like to start a new adventure?'
                  : '約2,700年にわたる人類の歴史を歩みきり、ついに現代へ追いつきました。\n\n新しい冒険を始めますか？',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.6,
              ),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogCtx);
                  if (mounted) Navigator.pop(context);
                },
                child: Text(
                  isEn ? 'Later' : 'あとで',
                  style: const TextStyle(color: Colors.white54),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amberAccent,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(dialogCtx);
                  if (mounted) Navigator.pop(context);
                },
                child: Text(
                  isEn ? 'Start' : '始める',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final langCode = Localizations.localeOf(context).languageCode;
    final isEn = langCode == 'en';

    // フェード速度も加速状態に連動
    final fadeDuration = Duration(milliseconds: _isFastForwarding ? 180 : 450);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. 基本は漆黒背景、ローカル保存画像がある時だけ1秒間浮かび上がってすぐフェードアウト
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: _bgOpacity,
              duration: fadeDuration,
              curve: Curves.easeInOut,
              child: _activeLocalImageFile != null
                  ? Image.file(
                      _activeLocalImageFile!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    )
                  : const SizedBox.shrink(),
            ),
          ),

          // 2. 画面タップ/長押しでスクロール加速できるインタラクション領域
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (_) {
                setState(() => _isFastForwarding = true);
              },
              onTapUp: (_) {
                setState(() => _isFastForwarding = false);
              },
              onTapCancel: () {
                setState(() => _isFastForwarding = false);
              },
              child: ListView(
                controller: _scrollController,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 28),
                children: [
                  SizedBox(height: screenHeight * 0.72),

                  // オープニングタイトル
                  Column(
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 34),
                      const SizedBox(height: 14),
                      Text(
                        isEn ? 'ONE MILLION STEPS ODYSSEY' : '100万歩の旅 完結',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.amberAccent,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isEn
                            ? 'A Chronicle of Your 1,000,000 Steps'
                            : 'あなたが歩んだ100万日・2,700年の軌跡',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 56),

                  // 獲得した年代・アーティファクトのリスト（古い順）
                  if (_timelineItems.isEmpty)
                    Center(
                      child: Text(
                        isEn
                            ? 'Your journey has reached the modern era.'
                            : '長い歴史の旅を経て、現代へと到達しました。',
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    )
                  else
                    ..._timelineItems.map((item) {
                      final isEra = item['type'] == 'era';
                      final dateStr = _formatDate(item['unlockedAt']);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 44),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (dateStr.isNotEmpty)
                              Text(
                                dateStr,
                                style: TextStyle(
                                  color: isEra ? Colors.amberAccent : Colors.purpleAccent[100],
                                  fontSize: 12,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            const SizedBox(height: 4),
                            Text(
                              item['title'] as String,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item['description'] as String,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13.5,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                  const SizedBox(height: 40),

                  // フィナーレメッセージ
                  Column(
                    children: [
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 28),
                      Text(
                        isEn ? 'THANK YOU FOR WALKING' : 'Thank you for walking.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.amberAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isEn
                            ? 'Every step you took carved a new page in history.'
                            : 'あなたの確かな一歩一歩が、壮大な歴史を紡ぎました。',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),

                  SizedBox(height: screenHeight * 0.78),
                ],
              ),
            ),
          ),

          // 3. 早送り中のインジケーター（左下にさりげなく表示）
          if (_isFastForwarding)
            Positioned(
              left: 24,
              bottom: 42,
              child: SafeArea(
                child: Row(
                  children: [
                    const Icon(Icons.fast_forward, color: Colors.amberAccent, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      isEn ? 'Fast Forward' : '早送り中',
                      style: const TextStyle(
                        color: Colors.amberAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 4. 右下のスキップボタン（画面全体のGestureDetectorより手前に配置して独立タップ可能）
          Positioned(
            right: 24,
            bottom: 36,
            child: SafeArea(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.15),
                    child: InkWell(
                      onTap: _showNewAdventureDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isEn ? 'Skip' : 'スキップ',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.skip_next_rounded, color: Colors.white, size: 18),
                          ],
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
}
