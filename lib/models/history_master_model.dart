import 'package:cloud_firestore/cloud_firestore.dart';

/// history_master/{docId} のモデルクラス
class HistoryMasterModel {
  final String id; // ドキュメントID (例: "ad_2030")
  final String backgroundImagePath;
  final String descriptionEn;
  final String descriptionJp;
  final String imagePromptBackground;
  final String imageTitleEn;
  final String imageTitleJp;
  final int step; // 1からの通し番号
  final int targetYear;
  final String thumbnailPath;
  final String yearLabelJp; // 👈 多言語対応
  final String yearLabelEn; // 👈 多言語対応
  final DateTime? updatedAt;

  HistoryMasterModel({
    required this.id,
    required this.backgroundImagePath,
    required this.descriptionEn,
    required this.descriptionJp,
    required this.imagePromptBackground,
    required this.imageTitleEn,
    required this.imageTitleJp,
    required this.step,
    required this.targetYear,
    required this.thumbnailPath,
    required this.yearLabelJp,
    required this.yearLabelEn,
    this.updatedAt,
  });

  /// 言語設定に応じたタイトルを返却
  String getTitle(String languageCode) {
    if (languageCode == 'en' && imageTitleEn.isNotEmpty) {
      return imageTitleEn;
    }
    return imageTitleJp;
  }

  /// 言語設定に応じた説明文を返却
  String getDescription(String languageCode) {
    if (languageCode == 'en' && descriptionEn.isNotEmpty) {
      return descriptionEn;
    }
    return descriptionJp;
  }

  /// 🌟 言語設定に応じた年代ラベル（yearLabelJp / yearLabelEn）を返却
  String getYearLabel(String languageCode) {
    if (languageCode == 'en' && yearLabelEn.isNotEmpty) {
      return yearLabelEn;
    }
    return yearLabelJp;
  }

  factory HistoryMasterModel.fromDocument(String id, Map<String, dynamic> data) {
    DateTime? parseTimestamp(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    // 移行期間用の旧 yearLabel の互換処理
    final legacyYearLabel = data['yearLabel'] as String? ?? '';

    return HistoryMasterModel(
      id: id,
      backgroundImagePath: data['backgroundImagePath'] as String? ?? '',
      descriptionEn: data['descriptionEn'] as String? ?? '',
      descriptionJp: data['descriptionJp'] as String? ?? data['description'] as String? ?? '',
      imagePromptBackground: data['imagePromptBackground'] as String? ?? '',
      imageTitleEn: data['imageTitleEn'] as String? ?? '',
      imageTitleJp: data['imageTitleJp'] as String? ?? '',
      step: (data['step'] as num?)?.toInt() ?? 0,
      targetYear: (data['targetYear'] as num?)?.toInt() ?? 0,
      thumbnailPath: data['thumbnailPath'] as String? ?? '',
      yearLabelJp: data['yearLabelJp'] as String? ?? legacyYearLabel,
      yearLabelEn: data['yearLabelEn'] as String? ?? legacyYearLabel,
      updatedAt: parseTimestamp(data['updatedAt']),
    );
  }
}