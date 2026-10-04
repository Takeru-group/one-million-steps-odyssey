import 'dart:ui';
import 'package:flutter/material.dart';

/// 💡 各ビューごとのヒントを表示する共通アイコンボタン
class HintIconButton extends StatelessWidget {
  /// ヒントのタイトル（例: 「Home画面の使い方」）
  final String title;

  /// ヒントの本文
  final String description;

  const HintIconButton({
    super.key,
    required this.title,
    required this.description,
  });

  /// ボトムシートでヒントを表示
  void _showHintBottomSheet(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final sheetBgColor = isDarkMode
        ? Colors.black.withOpacity(0.60)
        : Colors.white.withOpacity(0.70);
    final borderColor = isDarkMode
        ? Colors.white.withOpacity(0.15)
        : Colors.white.withOpacity(0.50);
    final handleColor = isDarkMode
        ? Colors.white.withOpacity(0.30)
        : Colors.black.withOpacity(0.20);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final iconColor = isDarkMode ? Colors.amberAccent : Colors.deepPurple;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              decoration: BoxDecoration(
                color: sheetBgColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ドラッグハンドル
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: handleColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // タイトル（電球アイコン付き）
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: iconColor, size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 説明本文
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: textColor.withOpacity(0.9),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return IconButton(
      icon: Icon(
        Icons.help_outline_rounded,
        color: isDarkMode ? Colors.white : Colors.black87,
      ),
      tooltip: 'ヒントを見る',
      onPressed: () => _showHintBottomSheet(context),
    );
  }
}