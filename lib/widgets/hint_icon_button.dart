import 'package:flutter/material.dart';
import 'app_bottom_sheet.dart';

/// 💡 各ビューごとの詳細な利用ガイドを表示する共通アイコンボタン
class HintIconButton extends StatelessWidget {
  /// ヒントのタイトル（例: 「Home画面の旅の進め方」）
  final String title;

  /// ヒントの本文（複数項目・改行込みの詳細解説）
  final String description;

  const HintIconButton({
    super.key,
    required this.title,
    required this.description,
  });

  /// 年代・アーティファクト紹介と同じ高さ・すりガラス仕様のボトムシートを表示
  void _showHintBottomSheet(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDarkMode ? Colors.amberAccent : Colors.deepPurple;

    AppBottomSheet.show(
      context: context,
      title: title,
      titleIcon: Icon(Icons.lightbulb_outline, color: iconColor, size: 24),
      description: description,
      showAiNotice: false,
      maxHeightFraction: 0.82,
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
