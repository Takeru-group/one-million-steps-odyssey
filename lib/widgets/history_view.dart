import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../l10n/app_localizations.dart';
import '../utils/user_repository.dart';
import '../utils/master_data_repository.dart';
import 'app_bottom_sheet.dart';

class HistoryView extends StatefulWidget {
  final UserDetailedData? detailedData;

  const HistoryView({
    super.key,
    required this.detailedData,
  });

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  /// 世紀ごとの開閉状態を保持するマップ (key: century, value: bool)
  final Map<int, bool> _expandedStates = {};

  String _formatDate(dynamic date) {
    if (date == null) return '----/--/--';
    DateTime dt;
    if (date is DateTime) {
      dt = date.toLocal();
    } else {
      try {
        dt = (date as dynamic).toDate().toLocal();
      } catch (_) {
        return '----/--/--';
      }
    }
    return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
  }

  /// 世紀ヘッダーの多言語出力 (l10n参照)
  String _formatCenturyHeader(AppLocalizations l10n, int century) {
    final absCentury = century.abs();
    if (century < 0) {
      return l10n.historyCenturyBce(absCentury);
    } else {
      return l10n.historyCenturyCe(absCentury);
    }
  }

  /// 📜 タップ時のボトムシート表示（AppBottomSheet で共通化＆事前解決でカクつき防止）
  Future<void> _showDetailBottomSheet({
    required BuildContext context,
    required String title,
    required String description,
    required String imagePath,
    required dynamic unlockedAt,
    String? imageTitle,
    String? itemType,
    String? itemId,
  }) async {
    final langCode = Localizations.localeOf(context).languageCode;
    String resolvedImageTitle = imageTitle ?? '';

    // 🌟 画像タイトルが空の場合はマスターデータから事前に取得
    if (resolvedImageTitle.isEmpty && itemId != null && itemId.isNotEmpty) {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;

      if (itemType == 'era' && currentUserId != null) {
        final master = await UserRepository().fetchAndRepairEraMetadata(
          userId: currentUserId,
          eraKey: itemId,
        );
        if (master != null) {
          resolvedImageTitle = master.getTitle(langCode);
        }
      } else if (itemType == 'artifact') {
        final artifact = await MasterDataRepository().getArtifact(itemId);
        if (artifact != null) {
          resolvedImageTitle = artifact.getName(langCode);
        }
      } else {
        final master = await MasterDataRepository().getHistoryMaster(itemId);
        if (master != null) {
          resolvedImageTitle = master.getTitle(langCode);
        }
      }
    }

    if (!context.mounted) return;

    AppBottomSheet.show(
      context: context,
      title: title,
      subtitle: _formatDate(unlockedAt),
      description: description,
      imagePath: imagePath,
      imageTitle: resolvedImageTitle,
      showAiNotice: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final currentLocale = Localizations.localeOf(context).languageCode;

    if (widget.detailedData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final user = widget.detailedData!.user;
    final userGameMode = user.gameMode;
    final unlockedEras = user.unlockedEras;
    final unlockedArtifacts = user.unlockedArtifacts;

    final Map<int, List<Map<String, dynamic>>> centuryGroups = {};

    // 1. 年代（Eras）の処理
    unlockedEras.forEach((eraKey, eraData) {
      final eraGameMode = (eraData['gameMode'] as num?)?.toInt() ?? 0;
      if (eraGameMode != userGameMode) return;

      final century = (eraData['century'] as num?)?.toInt() ?? 1;
      final unlockedAt = eraData['unlockedAt'];

      final labelJp = eraData['yearLabelJp'] as String? ?? eraData['eraLabel'] as String? ?? '';
      final labelEn = eraData['yearLabelEn'] as String? ?? eraData['eraLabel'] as String? ?? '';
      final label = currentLocale == 'en' ? labelEn : labelJp;

      final descJp = eraData['descriptionJp'] as String? ?? '';
      final descEn = eraData['descriptionEn'] as String? ?? '';
      final description = currentLocale == 'en' ? descEn : descJp;

      final imageTitleJp = eraData['imageTitleJp'] as String? ?? '';
      final imageTitleEn = eraData['imageTitleEn'] as String? ?? '';
      final imageTitle = currentLocale == 'en'
          ? (imageTitleEn.isNotEmpty ? imageTitleEn : imageTitleJp)
          : imageTitleJp;

      final displayTitle = l10n.eraReachedMessage(label);
      final imagePath = eraData['thumbnailPath'] as String? ?? eraData['backgroundImagePath'] as String? ?? '';
      final fullImagePath = eraData['backgroundImagePath'] as String? ?? imagePath;

      final item = {
        'type': 'era',
        'id': eraKey,
        'unlockedAt': unlockedAt,
        'title': displayTitle,
        'description': description,
        'imagePath': imagePath,
        'fullImagePath': fullImagePath,
        'imageTitle': imageTitle,
      };

      centuryGroups.putIfAbsent(century, () => []).add(item);
    });

    // 2. アーティファクト（Artifacts）の処理
    unlockedArtifacts.forEach((artifactId, artifactData) {
      final artifactGameMode = (artifactData['gameMode'] as num?)?.toInt() ?? 0;
      if (artifactGameMode != userGameMode) return;

      final unlockedAt = artifactData['unlockedAt'];

      final nameJa = artifactData['nameJa'] as String? ?? '';
      final nameEn = artifactData['nameEn'] as String? ?? '';
      final artifactName = currentLocale == 'en' ? (nameEn.isNotEmpty ? nameEn : nameJa) : nameJa;

      final descJa = artifactData['descJa'] as String? ?? '';
      final descEn = artifactData['descEn'] as String? ?? '';
      final description = currentLocale == 'en' ? (descEn.isNotEmpty ? descEn : descJa) : descJa;

      final category = (artifactData['category'] as String? ?? '').toLowerCase();
      final century = (artifactData['century'] as num?)?.toInt() ?? 1;

      final imagePath = artifactData['thumbnailPath'] as String? ?? artifactData['backgroundImagePath'] as String? ?? '';
      final fullImagePath = artifactData['backgroundImagePath'] as String? ?? imagePath;

      final bool isPerson = category == 'figure' ||
          category == 'person' ||
          category == '偉人' ||
          category == '人物' ||
          category.contains('figure') ||
          category.contains('person');

      final displayTitle = isPerson
          ? l10n.figureMet(artifactName)
          : l10n.artifactDiscoveredMessage(artifactName);

      final item = {
        'type': 'artifact',
        'id': artifactId,
        'unlockedAt': unlockedAt,
        'title': displayTitle,
        'description': description,
        'imagePath': imagePath,
        'fullImagePath': fullImagePath,
        'imageTitle': artifactName,
      };

      centuryGroups.putIfAbsent(century, () => []).add(item);
    });

    final sortedCenturies = centuryGroups.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    if (sortedCenturies.isEmpty) {
      return Center(
        child: Text(
          l10n.tabHistory,
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
      );
    }

    final cardBgColor = isDarkMode
        ? Colors.black.withValues(alpha: 0.40)
        : Colors.white.withValues(alpha: 0.40);
    final borderColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.white.withValues(alpha: 0.50);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.white70 : Colors.black54;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: sortedCenturies.length,
      itemBuilder: (context, index) {
        final century = sortedCenturies[index];
        final items = centuryGroups[century]!;

        // デフォルトは一番最新の世紀のみ展開、それ以外は閉じた状態に初期化
        _expandedStates.putIfAbsent(century, () => index == 0);

        items.sort((a, b) {
          final dtA = a['unlockedAt'];
          final dtB = b['unlockedAt'];
          if (dtA == null || dtB == null) return 0;
          try {
            return (dtB as dynamic).compareTo(dtA);
          } catch (_) {
            return 0;
          }
        });

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                    ),
                    child: ExpansionTile(
                      // 🌟 世紀（century）ごとに固定Keyを渡して独立したStateを保持
                      key: PageStorageKey<int>(century),
                      initiallyExpanded: _expandedStates[century] ?? false,
                      onExpansionChanged: (bool isExpanded) {
                        setState(() {
                          _expandedStates[century] = isExpanded;
                        });
                      },
                      title: Text(
                        _formatCenturyHeader(l10n, century),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      children: items.map((item) {
                        final title = item['title'] as String;
                        final description = item['description'] as String? ?? '';
                        final unlockedAt = item['unlockedAt'];
                        final imagePath = item['imagePath'] as String;
                        final fullImagePath = item['fullImagePath'] as String? ?? imagePath;

                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 48,
                              height: 48,
                              color: Colors.black12,
                              child: imagePath.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: imagePath,
                                      fit: BoxFit.cover,
                                      memCacheWidth: 160,
                                      placeholder: (_, _) => const SizedBox.shrink(),
                                      errorWidget: (_, _, _) => const Icon(
                                        Icons.history_edu,
                                        color: Colors.white54,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.history_edu,
                                      color: Colors.white54,
                                    ),
                            ),
                          ),
                          title: Text(
                            _formatDate(unlockedAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: subTextColor,
                            ),
                          ),
                          subtitle: Text(
                            title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: subTextColor,
                          ),
                          onTap: () {
                            _showDetailBottomSheet(
                              context: context,
                              title: title,
                              description: description,
                              imagePath: fullImagePath,
                              unlockedAt: unlockedAt,
                              imageTitle: item['imageTitle'] as String?,
                              itemType: item['type'] as String?,
                              itemId: item['id'] as String?,
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}