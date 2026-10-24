import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../l10n/app_localizations.dart';
import '../models/artifact_model.dart';

class AppDialogs {
  /// 🥛 ログイン成功時の「旅の心得（水分補給＆ヘルスケア連携案内）」モーダル
  static void showWelcomeHealthNoticeDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final dialogBgColor = isDarkMode
        ? Colors.black.withOpacity(0.80)
        : Colors.white.withOpacity(0.90);
    final borderColor = isDarkMode
        ? Colors.white.withOpacity(0.20)
        : Colors.white.withOpacity(0.50);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.white70 : Colors.black54;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: AlertDialog(
            backgroundColor: dialogBgColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: borderColor),
            ),
            title: Column(
              children: [
                const Icon(
                  Icons.directions_walk,
                  color: Colors.amberAccent,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.welcomeTitle,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.asset(
                        'assets/images/mainback1.jpeg',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey.withOpacity(0.3),
                          child: const Icon(Icons.local_drink,
                              size: 48, color: Colors.amber),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.welcomeHydrationNotice,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.08)
                          : Colors.black.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.sync,
                                size: 16, color: Colors.purpleAccent),
                            const SizedBox(width: 6),
                            Text(
                              l10n.welcomeBackgroundTitle,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.welcomeBackgroundNotice,
                          style: TextStyle(
                            color: subTextColor,
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n.welcomeButtonStart,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// ✨ アーティファクト獲得演出ダイアログ
  static void showArtifactRewardModal(
      BuildContext context, ArtifactModel artifact) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final langCode = Localizations.localeOf(context).languageCode;

    final dialogBgColor = isDarkMode
        ? Colors.black.withOpacity(0.75)
        : Colors.white.withOpacity(0.85);
    final borderColor = isDarkMode
        ? Colors.white.withOpacity(0.20)
        : Colors.white.withOpacity(0.50);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.white70 : Colors.black54;

    final itemName = artifact.getName(langCode);
    final description = artifact.getDescription(langCode);
    final imagePath = artifact.backgroundImagePath;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: AlertDialog(
            backgroundColor: dialogBgColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: borderColor),
            ),
            title: Column(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: Colors.amberAccent,
                  size: 36,
                ),
                const SizedBox(height: 8),
                Text(
                  'アーティファクト獲得！',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: imagePath.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: imagePath,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                color: Colors.grey.withOpacity(0.3),
                                child: const Center(
                                    child: CircularProgressIndicator()),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                color: Colors.grey.withOpacity(0.3),
                                child: Icon(Icons.museum,
                                    size: 48, color: textColor),
                              ),
                            )
                          : Container(
                              color: Colors.grey.withOpacity(0.3),
                              child: Icon(Icons.museum,
                                  size: 48, color: textColor),
                            ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      langCode == 'en'
                          ? '* Image generated by AI'
                          : '※ この画像は生成AIにより作成されています',
                      style: TextStyle(
                        fontSize: 10,
                        color: subTextColor.withOpacity(0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    itemName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    '閉じる',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 🎬 広告視聴確認ダイアログ
  static void showArtifactConfirmationDialog({
    required BuildContext context,
    required AppLocalizations l10n,
    required String eraLabel,
    required VoidCallback onWatchAd,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final dialogBgColor = isDarkMode
        ? Colors.black.withOpacity(0.70)
        : Colors.white.withOpacity(0.80);
    final borderColor = isDarkMode
        ? Colors.white.withOpacity(0.20)
        : Colors.white.withOpacity(0.50);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.white70 : Colors.black54;

    showDialog(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: AlertDialog(
            backgroundColor: dialogBgColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: borderColor),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: isDarkMode ? Colors.amberAccent : Colors.deepPurple,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.artifactDialogTitle,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.artifactDialogDesc(eraLabel),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.artifactDialogNotice,
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  l10n.artifactDialogCancel,
                  style: TextStyle(color: subTextColor),
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.ondemand_video, size: 18),
                label: Text(
                  l10n.artifactDialogWatchAd,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  onWatchAd();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// 🧭 新年代到達（＋世紀突入）ダイアログ
  static Future<void> showEraUnlockedDialog({
    required BuildContext context,
    required String eraLabel,
    int? newCentury,
  }) async {
    final l10n = AppLocalizations.of(context);
    final langCode = Localizations.localeOf(context).languageCode;

    String? centuryText;
    if (newCentury != null) {
      final absC = newCentury.abs();
      if (newCentury < 0) {
        centuryText = l10n != null ? l10n.historyCenturyBce(absC) : '紀元前$absC世紀';
      } else {
        centuryText = l10n != null
            ? (langCode == 'ja' ? '$absC世紀' : l10n.historyCenturyCe(absC))
            : '$absC世紀';
      }
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final dialogBgColor = isDarkMode
        ? Colors.black.withOpacity(0.80)
        : Colors.white.withOpacity(0.90);
    final borderColor = isDarkMode
        ? Colors.white.withOpacity(0.20)
        : Colors.white.withOpacity(0.50);
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: dialogBgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: borderColor),
          ),
          title: Row(
            children: [
              Icon(
                newCentury != null ? Icons.auto_awesome : Icons.explore,
                color: Colors.amberAccent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  newCentury != null
                      ? '$centuryTextに突入しました！'
                      : '次の年代に入りました！',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Text(
            newCentury != null
                ? '新しい時代「${eraLabel}年代」に到達し、$centuryTextに突入しました！\n背景と歴史情報が更新されます。'
                : '新しい時代「${eraLabel}年代」に到達しました！\n背景と歴史情報が更新されます。',
            style: TextStyle(color: textColor, fontSize: 14, height: 1.5),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('旅を続ける'),
            ),
          ],
        ),
      ),
    );
  }
  /// 🏆 歩数マイルストーン（6,000歩 / 10,000歩）達成ダイアログ（キャンセル無し・確定獲得）
  static Future<void> showMilestoneStepDialog({
    required BuildContext context,
    required String title,
    required String description,
    required String buttonText,
  }) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final dialogBgColor = isDarkMode
        ? Colors.black.withOpacity(0.80)
        : Colors.white.withOpacity(0.90);
    final borderColor = isDarkMode
        ? Colors.white.withOpacity(0.20)
        : Colors.white.withOpacity(0.50);
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    await showDialog<void>(
      context: context,
      barrierDismissible: false, // 外部タップでの閉じるも不可
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: AlertDialog(
            backgroundColor: dialogBgColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: borderColor),
            ),
            title: Row(
              children: [
                const Icon(Icons.stars, color: Colors.amberAccent, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              description,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}