import 'package:cloud_firestore/cloud_firestore.dart';

/// artifacts/{artifactId} のモデルクラス
class ArtifactModel {
  final String id; // ドキュメントID
  final String backgroundImagePath;
  final String category;
  final int century;
  final String descEn;
  final String descJa;
  final String nameEn;
  final String nameJa;
  final String prompt;
  final String rarity;
  final String thumbnailPath;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ArtifactModel({
    required this.id,
    required this.backgroundImagePath,
    required this.category,
    required this.century,
    required this.descEn,
    required this.descJa,
    required this.nameEn,
    required this.nameJa,
    required this.prompt,
    required this.rarity,
    required this.thumbnailPath,
    this.createdAt,
    this.updatedAt,
  });

  /// 言語設定に応じた名前を返却
  String getName(String languageCode) {
    if (languageCode == 'en' && nameEn.isNotEmpty) {
      return nameEn;
    }
    return nameJa;
  }

  /// 言語設定に応じた説明文を返却
  String getDescription(String languageCode) {
    if (languageCode == 'en' && descEn.isNotEmpty) {
      return descEn;
    }
    return descJa;
  }

  factory ArtifactModel.fromDocument(String id, Map<String, dynamic> data) {
    DateTime? parseTimestamp(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return ArtifactModel(
      id: id,
      backgroundImagePath: data['backgroundImagePath'] as String? ?? '',
      category: data['category'] as String? ?? '',
      century: (data['century'] as num?)?.toInt() ?? 0,
      descEn: data['desc_en'] as String? ?? data['descriptionEn'] as String? ?? '',
      descJa: data['desc_ja'] as String? ?? data['descriptionJp'] as String? ?? '',
      nameEn: data['name_en'] as String? ?? '',
      nameJa: data['name_ja'] as String? ?? '',
      prompt: data['prompt'] as String? ?? '',
      rarity: data['rarity'] as String? ?? 'C',
      thumbnailPath: data['thumbnailPath'] as String? ?? '',
      createdAt: parseTimestamp(data['createdAt']),
      updatedAt: parseTimestamp(data['updatedAt']),
    );
  }
}