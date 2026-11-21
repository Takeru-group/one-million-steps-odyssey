import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../l10n/app_localizations.dart';
import '../models/history_master_model.dart';
import '../utils/timeline_calculator.dart';
import '../utils/user_repository.dart';
import '../utils/master_data_repository.dart';
import 'app_bottom_sheet.dart';

/// HOME タブビュー（AI生成表記＆画像ボトムシート対応）
class HomeView extends StatelessWidget {
  final AppDateResult? appDate;
  final HistoryMasterModel? historyMaster;

  const HomeView({
    super.key,
    required this.appDate,
    required this.historyMaster,
  });

  Future<void> _showDescriptionBottomSheet(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final langCode = Localizations.localeOf(context).languageCode;

    final descText = historyMaster != null
        ? historyMaster!.getDescription(langCode)
        : l10n.homeDefaultDescription;

    final dateTitle =
        appDate != null ? appDate!.toLocalizedFormattedString(context) : '';

    final imagePath = historyMaster?.backgroundImagePath ?? '';
    String imageTitle = historyMaster?.getTitle(langCode) ?? '';

    // 🌟 画像タイトルが未取得の場合はキャッシュ/マスターから事前に取得（ボトムシート表示中の不要な再ビルドとカクつきを完全防止）
    if (imageTitle.isEmpty && historyMaster != null && historyMaster!.id.isNotEmpty) {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      HistoryMasterModel? master;
      if (currentUserId != null) {
        master = await UserRepository().fetchAndRepairEraMetadata(
          userId: currentUserId,
          eraKey: historyMaster!.id,
        );
      } else {
        master = await MasterDataRepository().getHistoryMaster(historyMaster!.id);
      }
      if (master != null) {
        imageTitle = master.getTitle(langCode);
      }
    }

    if (!context.mounted) return;

    AppBottomSheet.show(
      context: context,
      title: dateTitle,
      description: descText,
      imagePath: imagePath,
      imageTitle: imageTitle,
      showAiNotice: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final dateLabel = appDate != null
        ? appDate!.toLocalizedFormattedString(context)
        : '720 BCE 06/28';

    final buttonBgColor = isDarkMode
        ? Colors.black.withValues(alpha: 0.40)
        : Colors.white.withValues(alpha: 0.40);
    final borderColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.20)
        : Colors.white.withValues(alpha: 0.50);
    final contentColor = isDarkMode ? Colors.white : Colors.black87;

    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: InkWell(
          onTap: () => _showDescriptionBottomSheet(context),
          borderRadius: BorderRadius.circular(20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: buttonBgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.directions_run,
                      color: isDarkMode
                          ? Colors.purpleAccent[100]
                          : Colors.deepPurple,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateLabel,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: contentColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}