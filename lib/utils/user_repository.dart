import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/artifact_model.dart';
import '../models/history_master_model.dart';
import '../models/user_model.dart';
import 'master_data_repository.dart';
import 'timeline_calculator.dart';

class UserDetailedData {
  final UserModel user;
  final Map<String, HistoryMasterModel> unlockedHistories;
  final Map<String, ArtifactModel> unlockedArtifacts;

  UserDetailedData({
    required this.user,
    required this.unlockedHistories,
    required this.unlockedArtifacts,
  });
}

class UserRepository {
  final FirebaseFirestore _firestore;
  final MasterDataRepository _masterDataRepository;

  UserRepository({
    FirebaseFirestore? firestore,
    MasterDataRepository? masterDataRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _masterDataRepository = masterDataRepository ?? MasterDataRepository();

  Future<UserModel> getOrCreateUser(String userId) async {
    final docRef = _firestore.collection('user').doc(userId);

    DocumentSnapshot<Map<String, dynamic>>? docSnap;
    try {
      docSnap = await docRef.get().timeout(const Duration(seconds: 3));
    } catch (_) {
      docSnap = await docRef.get(const GetOptions(source: Source.cache));
    }

    if (docSnap.exists && docSnap.data() != null) {
      return UserModel.fromDocument(userId, docSnap.data()!);
    }

    final now = DateTime.now().toUtc();
    final startAppDate = TimelineCalculator.calculateAppStartDate(now);

    final scheduledDeletionAt = DateTime(
      now.year + 1,
      now.month,
      now.day,
      now.hour,
      now.minute,
      now.second,
    );

    final initialEraKey = calculateEraKey(startAppDate.era, startAppDate.year);
    final initialMaster = await _masterDataRepository.getHistoryMaster(initialEraKey);

    final initialEras = <String, Map<String, dynamic>>{
      initialEraKey: {
        'unlockedAt': Timestamp.fromDate(now),
        'eraLabel': startAppDate.eraLabel,
        'yearLabelJp': initialMaster?.yearLabelJp ?? startAppDate.eraLabel,
        'yearLabelEn': initialMaster?.yearLabelEn ?? startAppDate.eraLabel,
        'backgroundImagePath': initialMaster?.backgroundImagePath ?? '',
        'thumbnailPath': initialMaster?.thumbnailPath ?? '',
        'descriptionJp': initialMaster?.descriptionJp ?? '',
        'descriptionEn': initialMaster?.descriptionEn ?? '',
        'century': startAppDate.century,
        'gameMode': 0,
      }
    };

    final newUserData = <String, dynamic>{
      'appStartDate': Timestamp.fromDate(now),
      'stepFetchedAt': Timestamp.fromDate(now),
      'startEra': startAppDate.era,
      'startYear': startAppDate.year,
      'startMonth': startAppDate.month,
      'startDay': startAppDate.day,
      'isCleared': false,
      'gameMode': 0,
      'steps': 0,
      'totalSteps': 0,
      'scheduledDeletionAt': Timestamp.fromDate(scheduledDeletionAt),
      'unlockedArtifacts': <String, dynamic>{},
      'unlockedEras': initialEras,
    };

    try {
      await docRef.set(newUserData).timeout(const Duration(seconds: 3));
    } catch (e) {
      print('⚠ [UserRepository] ネットワーク接続がないためローカル保存のみ行いました');
    }

    return UserModel.fromDocument(userId, newUserData);
  }

  Future<void> updateStepFetchTimestamp(String userId) async {
    final now = DateTime.now().toUtc();
    try {
      await _firestore.collection('user').doc(userId).update({
        'stepFetchedAt': Timestamp.fromDate(now),
      }).timeout(const Duration(seconds: 2));
    } catch (_) {}
  }

  Future<void> saveStepsOnLogout({
    required String userId,
    required int todaySteps,
    required int totalSteps,
  }) async {
    final now = DateTime.now().toUtc();
    try {
      await _firestore.collection('user').doc(userId).update({
        'steps': todaySteps,
        'totalSteps': totalSteps,
        'stepFetchedAt': Timestamp.fromDate(now),
      }).timeout(const Duration(seconds: 4));
      print('💾 [UserRepository] ログアウト前の最終歩数保存完了 (Today: $todaySteps, Total: $totalSteps)');
    } catch (e) {
      print('❌ [UserRepository] ログアウト歩数保存エラー: $e');
      rethrow;
    }
  }

  /// 🌟 6,000歩 / 10,000歩マイルストーンの達成タイムスタンプを保存
  Future<void> updateMilestoneUnlockedAt({
    required String userId,
    required int milestoneType, // 6000 または 10000
    required DateTime unlockedAt,
  }) async {
    final fieldName = milestoneType == 6000 ? 'steps6kUnlockedAt' : 'steps10kUnlockedAt';
    try {
      await _firestore.collection('user').doc(userId).update({
        fieldName: Timestamp.fromDate(unlockedAt.toUtc()),
      }).timeout(const Duration(seconds: 3));
      print('✅ [UserRepository] $fieldName を更新しました: $unlockedAt');
    } catch (e) {
      print('❌ [UserRepository] $fieldName の更新エラー: $e');
    }
  }

  /// 🌟 ユーザーデータ内メタデータのみを参照（Firestore読み込み数最小化）
  Future<UserDetailedData> getUserWithDetails(String userId) async {
    final user = await getOrCreateUser(userId);

    final unlockedHistories = <String, HistoryMasterModel>{};
    final unlockedArtifacts = <String, ArtifactModel>{};
    final Map<String, Map<String, dynamic>> missingEraKeys = {};
    final Map<String, Map<String, dynamic>> missingArtifactKeys = {};

    // 1. unlockedEras の構築
    for (final entry in user.unlockedEras.entries) {
      final key = entry.key;
      final map = entry.value;

      final hasYearLabelJp = map['yearLabelJp'] != null && (map['yearLabelJp'] as String).isNotEmpty;
      if (!hasYearLabelJp) {
        missingEraKeys[key] = map;
      }

      unlockedHistories[key] = HistoryMasterModel(
        id: key,
        backgroundImagePath: map['backgroundImagePath'] as String? ?? '',
        descriptionEn: map['descriptionEn'] as String? ?? '',
        descriptionJp: map['descriptionJp'] as String? ?? '',
        imagePromptBackground: '',
        imageTitleEn: '',
        imageTitleJp: '',
        step: 0,
        targetYear: 0,
        thumbnailPath: map['thumbnailPath'] as String? ?? '',
        yearLabelJp: map['yearLabelJp'] as String? ?? map['eraLabel'] as String? ?? '',
        yearLabelEn: map['yearLabelEn'] as String? ?? map['eraLabel'] as String? ?? '',
      );
    }

    // 2. unlockedArtifacts の構築
    for (final entry in user.unlockedArtifacts.entries) {
      final key = entry.key;
      final map = entry.value;

      final hasNameJa = map['nameJa'] != null && (map['nameJa'] as String).isNotEmpty;
      if (!hasNameJa) {
        missingArtifactKeys[key] = map;
      }

      unlockedArtifacts[key] = ArtifactModel(
        id: key,
        backgroundImagePath: map['backgroundImagePath'] as String? ?? '',
        category: map['category'] as String? ?? '',
        century: (map['century'] as num?)?.toInt() ?? 0,
        descEn: map['descEn'] as String? ?? '',
        descJa: map['descJa'] as String? ?? '',
        nameEn: map['nameEn'] as String? ?? '',
        nameJa: map['nameJa'] as String? ?? '',
        prompt: map['prompt'] as String? ?? '',
        rarity: map['rarity'] as String? ?? 'C',
        thumbnailPath: map['thumbnailPath'] as String? ?? '',
      );
    }

    // 不足データがある場合のみバックグラウンドで自動同期
    if (missingEraKeys.isNotEmpty || missingArtifactKeys.isNotEmpty) {
      _syncMissingMetadata(
        userId: userId,
        missingEraKeys: missingEraKeys,
        missingArtifactKeys: missingArtifactKeys,
        memoryHistories: unlockedHistories,
        memoryArtifacts: unlockedArtifacts,
      );
    }

    return UserDetailedData(
      user: user,
      unlockedHistories: unlockedHistories,
      unlockedArtifacts: unlockedArtifacts,
    );
  }

  void _syncMissingMetadata({
    required String userId,
    required Map<String, Map<String, dynamic>> missingEraKeys,
    required Map<String, Map<String, dynamic>> missingArtifactKeys,
    required Map<String, HistoryMasterModel> memoryHistories,
    required Map<String, ArtifactModel> memoryArtifacts,
  }) async {
    print('🔄 [MigrationSync] ユーザーデータの未補填メタデータ同期を開始します...');

    final updates = <String, dynamic>{};

    for (final eraKey in missingEraKeys.keys) {
      try {
        final master = await _masterDataRepository.getHistoryMaster(eraKey);
        if (master != null) {
          final existingMap = missingEraKeys[eraKey] ?? {};
          existingMap['yearLabelJp'] = master.yearLabelJp;
          existingMap['yearLabelEn'] = master.yearLabelEn;
          existingMap['backgroundImagePath'] = master.backgroundImagePath;
          existingMap['thumbnailPath'] = master.thumbnailPath;
          existingMap['descriptionJp'] = master.descriptionJp;
          existingMap['descriptionEn'] = master.descriptionEn;

          updates['unlockedEras.$eraKey'] = existingMap;
          memoryHistories[eraKey] = master;
        }
      } catch (_) {}
    }

    for (final artifactId in missingArtifactKeys.keys) {
      try {
        final artifact = await _masterDataRepository.getArtifact(artifactId);
        if (artifact != null) {
          final existingMap = missingArtifactKeys[artifactId] ?? {};
          existingMap['nameJa'] = artifact.nameJa;
          existingMap['nameEn'] = artifact.nameEn;
          existingMap['descJa'] = artifact.descJa;
          existingMap['descEn'] = artifact.descEn;
          existingMap['category'] = artifact.category;
          existingMap['century'] = artifact.century;
          existingMap['backgroundImagePath'] = artifact.backgroundImagePath;
          existingMap['thumbnailPath'] = artifact.thumbnailPath;
          existingMap['rarity'] = artifact.rarity;

          updates['unlockedArtifacts.$artifactId'] = existingMap;
          memoryArtifacts[artifactId] = artifact;
        }
      } catch (_) {}
    }

    if (updates.isNotEmpty) {
      try {
        await _firestore.collection('user').doc(userId).update(updates);
      } catch (_) {}
    }
  }

  Future<UserDetailedData> updateUserEraProgress({
    required String userId,
    required int newTotalSteps,
    required String newEraKey,
    required String eraLabel,
    required int century,
    required int currentGameMode,
  }) async {
    final docRef = _firestore.collection('user').doc(userId);
    final now = DateTime.now().toUtc();

    final master = await _masterDataRepository.getHistoryMaster(newEraKey);

    final newScheduledDeletionAt = DateTime(
      now.year + 1,
      now.month,
      now.day,
      now.hour,
      now.minute,
      now.second,
    );

    final eraData = {
      'unlockedAt': Timestamp.fromDate(now),
      'eraLabel': eraLabel,
      'yearLabelJp': master?.yearLabelJp ?? eraLabel,
      'yearLabelEn': master?.yearLabelEn ?? eraLabel,
      'backgroundImagePath': master?.backgroundImagePath ?? '',
      'thumbnailPath': master?.thumbnailPath ?? '',
      'descriptionJp': master?.descriptionJp ?? '',
      'descriptionEn': master?.descriptionEn ?? '',
      'century': century,
      'gameMode': currentGameMode,
    };

    try {
      await docRef.update({
        'stepFetchedAt': Timestamp.fromDate(now),
        'totalSteps': newTotalSteps,
        'scheduledDeletionAt': Timestamp.fromDate(newScheduledDeletionAt),
        'unlockedEras.$newEraKey': eraData,
      }).timeout(const Duration(seconds: 3));
    } catch (_) {}

    return await getUserWithDetails(userId);
  }

  /// 🌟 アーティファクト獲得処理
  /// [isFromAd] が true（動画広告経由）の場合のみ lastArtifactUnlockedAt（4時間クーリング）を更新
  Future<ArtifactModel?> unlockRandomArtifactForEra({
    required String userId,
    required String currentEraKey,
    required UserDetailedData currentDetails,
    bool isFromAd = true,
  }) async {
    final user = currentDetails.user;
    final currentDate = TimelineCalculator.addStepsToDate(
      era: user.startEra,
      year: user.startYear,
      month: user.startMonth,
      day: user.startDay,
      steps: user.totalSteps,
      stepsPerDay: 1,
    );
    final targetCentury = currentDate.century;

    QuerySnapshot<Map<String, dynamic>> snapshot;
    try {
      snapshot = await _firestore
          .collection('artifacts')
          .where('century', isEqualTo: targetCentury)
          .get()
          .timeout(const Duration(seconds: 3));
    } catch (_) {
      snapshot = await _firestore
          .collection('artifacts')
          .where('century', isEqualTo: targetCentury)
          .get(const GetOptions(source: Source.cache));
    }

    if (snapshot.docs.isEmpty) return null;

    final unlockedIds = currentDetails.user.unlockedArtifacts.keys.toSet();
    final uncollectedDocs = snapshot.docs.where((doc) {
      return !unlockedIds.contains(doc.id);
    }).toList();

    if (uncollectedDocs.isEmpty) return null;

    final random = Random();
    final selectedDoc = uncollectedDocs[random.nextInt(uncollectedDocs.length)];
    final artifactId = selectedDoc.id;

    final artifactMaster = await _masterDataRepository.getArtifact(artifactId);
    if (artifactMaster == null) return null;

    final now = DateTime.now().toUtc();
    final artifactData = {
      'unlockedAt': Timestamp.fromDate(now),
      'eraKey': currentEraKey,
      'gameMode': currentDetails.user.gameMode,
      'nameJa': artifactMaster.nameJa,
      'nameEn': artifactMaster.nameEn,
      'descJa': artifactMaster.descJa,
      'descEn': artifactMaster.descEn,
      'category': artifactMaster.category,
      'century': artifactMaster.century,
      'backgroundImagePath': artifactMaster.backgroundImagePath,
      'thumbnailPath': artifactMaster.thumbnailPath,
      'rarity': artifactMaster.rarity,
    };

    final updates = <String, dynamic>{
      'unlockedArtifacts.$artifactId': artifactData,
    };

    if (isFromAd) {
      updates['lastArtifactUnlockedAt'] = Timestamp.fromDate(now);
    }

    try {
      await _firestore.collection('user').doc(userId).update(updates).timeout(const Duration(seconds: 3));
    } catch (_) {}

    return artifactMaster;
  }

  static String calculateEraKey(String era, int year) {
    final isBce = (era == '紀元前' || era == 'BCE');
    final roundedYear = (year ~/ 10) * 10;

    final prefix = isBce ? 'bc_' : 'ad_';
    final paddedYear = roundedYear.toString().padLeft(4, '0');
    return '$prefix$paddedYear';
  }
}