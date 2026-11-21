import 'dart:async';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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
  List _timelineItems = [];
  String? _currentBgUrl;
  bool _isDialogShown = false;

  @override
  void initState() {
    super.initState();
    _currentBgUrl = widget.fallbackBgUrl;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prepareTimelineData();
      _startAutoScroll();
    });
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
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
      final bool isPerson = category.contains('figure') || category.contains('person') || category.contains('偉人') || category.contains('人物');
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
      if (_timelineItems.isNotEmpty) {
        final firstImg = _timelineItems.first['imageUrl'] as String?;
        if (firstImg != null && firstImg.isNotEmpty) {
          _currentBgUrl = firstImg;
        }
      }
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

  /// エンドロール自動スクロールと背景切り替え監視
  void _startAutoScroll() {
    const tick = Duration(milliseconds: 30);
    const double scrollSpeedPerTick = 1.6; // スクロール速度

    _scrollTimer = Timer.periodic(tick, (timer) {
      if (!_scrollController.hasClients) return;

      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;

      if (currentScroll >= maxScroll) {
        timer.cancel();
        _showNewAdventureDialog();
        return;
      }

      _scrollController.jumpTo(currentScroll + scrollSpeedPerTick);
      _updateBackgroundByScroll(currentScroll, maxScroll);
    });
  }

  /// スクロール進行度に合わせて表示する背景画像をフェード切り替え
  void _updateBackgroundByScroll(double currentScroll, double maxScroll) {
    if (_timelineItems.isEmpty || maxScroll <= 0) return;

    final progress = (currentScroll / maxScroll).clamp(0.0, 0.999);
    final index = (progress * _timelineItems.length).floor();
    final targetImg = _timelineItems[index]['imageUrl'] as String?;

    if (targetImg != null && targetImg.isNotEmpty && targetImg != _currentBgUrl) {
      setState(() {
        _currentBgUrl = targetImg;
      });
    }
  }

  /// スキップ押下またはスクロール完了時の確認ダイアログ
  Future<void> _showNewAdventureDialog() async {
    if (_isDialogShown || !mounted) return;
    _isDialogShown = true;
    _scrollTimer?.cancel();

    final langCode = Localizations.localeOf(context).languageCode;
    final isEn = langCode == 'en';

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: AlertDialog(
            backgroundColor: Colors.black.withValues(alpha: 0.80),
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
                  // TODO: 次の周回（gameMode + 1、リセット処理）は次回実装
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

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. フェードイン・フェードアウトする背景画像
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 1200),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              child: (_currentBgUrl != null && _currentBgUrl!.isNotEmpty)
                  ? CachedNetworkImage(
                      key: ValueKey(_currentBgUrl),
                      imageUrl: _currentBgUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorWidget: (_, __, ___) => Image.asset(
                        'assets/images/mainback1.jpeg',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    )
                  : Image.asset(
                      'assets/images/mainback1.jpeg',
                      key: const ValueKey('fallback_ending_bg'),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
            ),
          ),

          // 2. テキスト視認性確保用のダークグラデーションオーバーレイ
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.75),
                    Colors.black.withValues(alpha: 0.50),
                    Colors.black.withValues(alpha: 0.80),
                  ],
                ),
              ),
            ),
          ),

          // 3. 古い順からのエンドロールスクロールビュー
          ListView(
            controller: _scrollController,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 28),
            children: [
              // 画面下から文字がせり上がってくるための上部余白
              SizedBox(height: screenHeight * 0.85),

              // オープニングタイトル
              Column(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 36),
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 12),
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

              const SizedBox(height: 80),

              // 獲得した年代・アーティファクトのリスト（古い順）
              if (_timelineItems.isEmpty)
                Center(
                  child: Text(
                    isEn ? 'Your journey has reached the modern era.' : '長い歴史の旅を経て、現代へと到達しました。',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                )
              else
                ..._timelineItems.map((item) {
                  final isEra = item['type'] == 'era';
                  final dateStr = _formatDate(item['unlockedAt']);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 64),
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
                        const SizedBox(height: 6),
                        Text(
                          item['title'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item['description'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.7,
                          ),
                        ),
                      ],
                    ),
                  );
                }),

              const SizedBox(height: 60),

              // フィナーレメッセージ
              Column(
                children: [
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 32),
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
                  const SizedBox(height: 12),
                  Text(
                    isEn
                        ? 'Every step you took carved a new page in history.'
                        : 'あなたの確かな一歩一歩が、壮大な歴史を紡ぎました。',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),

              // 最後まで画面上部に流れ切るための下部余白
              SizedBox(height: screenHeight * 0.90),
            ],
          ),

          // 4. 右下のスキップボタン
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
                            const Icon(Icons.fast_forward_rounded, color: Colors.white, size: 18),
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
