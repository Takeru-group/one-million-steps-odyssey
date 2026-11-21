import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// 🏛 アプリ共通の洗練されたすりガラス半透明ボトムシート
class AppBottomSheet extends StatelessWidget {
  /// メインタイトル（例: 年代名、アーティファクト名、ヒントタイトル）
  final String? title;

  /// サブタイトル（例: 到達日、日付）
  final String? subtitle;

  /// 本文説明
  final String? description;

  /// 画像URL（未指定または空文字の場合は非表示）
  final String? imagePath;

  /// 画像の作品名・タイトル（未指定または空文字の場合は非表示）
  final String? imageTitle;

  /// EU AI Act 対応などの「生成AI表記」を表示するか
  final bool showAiNotice;

  /// タイトル横に表示するアイコン（例: ヒントの電球アイコン）
  final Widget? titleIcon;

  /// 説明文の下に追加表示する任意のカスタムウィジェット
  final Widget? customContent;

  /// 本文カラム全体を独自レイアウトに置き換える場合のウィジェット
  final Widget? customBody;

  /// 画面高に対する最大高さの割合（デフォルト: 0.82）
  final double maxHeightFraction;

  const AppBottomSheet({
    super.key,
    this.title,
    this.subtitle,
    this.description,
    this.imagePath,
    this.imageTitle,
    this.showAiNotice = true,
    this.titleIcon,
    this.customContent,
    this.customBody,
    this.maxHeightFraction = 0.82,
  });

  /// 🌟 共通ボトムシートのモーダル表示ヘルパー
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    String? subtitle,
    String? description,
    String? imagePath,
    String? imageTitle,
    bool showAiNotice = true,
    Widget? titleIcon,
    Widget? customContent,
    Widget? customBody,
    double maxHeightFraction = 0.82,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      useSafeArea: true,
      builder: (sheetContext) => AppBottomSheet(
        title: title,
        subtitle: subtitle,
        description: description,
        imagePath: imagePath,
        imageTitle: imageTitle,
        showAiNotice: showAiNotice,
        titleIcon: titleIcon,
        customContent: customContent,
        customBody: customBody,
        maxHeightFraction: maxHeightFraction,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final langCode = Localizations.localeOf(context).languageCode;
    final screenHeight = MediaQuery.of(context).size.height;

    final sheetBgColor = isDarkMode
        ? Colors.black.withValues(alpha: 0.60)
        : Colors.white.withValues(alpha: 0.70);
    final borderColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.18)
        : Colors.black.withValues(alpha: 0.15);
    final handleColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.30)
        : Colors.black.withValues(alpha: 0.20);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.white70 : Colors.black54;

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            constraints: BoxConstraints(maxHeight: screenHeight * maxHeightFraction),
            decoration: BoxDecoration(
              color: sheetBgColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🌟 上部ヘッダー（ドラッグハンドル & Close Xボタン）
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 12, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 32),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: handleColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: textColor.withValues(alpha: 0.8),
                          size: 22,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        splashRadius: 20,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                ),

                // 📜 スクロール可能な本文コンテンツ
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                    child: customBody ??
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 🖼 画像プレビュー
                            if (imagePath != null && imagePath!.isNotEmpty) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: CachedNetworkImage(
                                    imageUrl: imagePath!,
                                    fit: BoxFit.cover,
                                    placeholder: (_, _) => Container(
                                      color: Colors.grey.withValues(alpha: 0.3),
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                    errorWidget: (_, _, _) => Container(
                                      color: Colors.grey.withValues(alpha: 0.3),
                                      child: Icon(Icons.history_edu, size: 48, color: textColor),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),

                              // 🤖 AI 生成表記
                              if (showAiNotice) ...[
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    langCode == 'en'
                                        ? '* Image generated by AI'
                                        : '※ この画像は生成AIにより作成されています',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: subTextColor.withValues(alpha: 0.7),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 14),
                            ],

                            // 📅 サブタイトル（到達日等）
                            if (subtitle != null && subtitle!.isNotEmpty) ...[
                              Text(
                                subtitle!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: subTextColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],

                            // 🏷 メインタイトル（アイコン併用可能）
                            if (title != null && title!.isNotEmpty) ...[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  if (titleIcon != null) ...[
                                    titleIcon!,
                                    const SizedBox(width: 8),
                                  ],
                                  Expanded(
                                    child: Text(
                                      title!,
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
                            ],

                            // 📖 本文解説
                            if (description != null && description!.isNotEmpty) ...[
                              Text(
                                description!,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.6,
                                  color: subTextColor,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],

                            // 🖼 画像タイトル（バッジ表示）
                            if (imageTitle != null && imageTitle!.isNotEmpty) ...[
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : Colors.black.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.image_outlined, size: 16, color: subTextColor),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        langCode == 'en'
                                            ? 'Image: $imageTitle'
                                            : '画像：$imageTitle',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: textColor.withValues(alpha: 0.9),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            // 🧩 任意の追加コンテンツ
                            if (customContent != null) ...[
                              const SizedBox(height: 14),
                              customContent!,
                            ],
                          ],
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
