import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final DateTime? appStartDate;
  final DateTime? stepFetchedAt;
  final String startEra;
  final int startYear;
  final int startMonth;
  final int startDay;
  final bool isCleared;
  final int gameMode;
  final int steps;
  final int totalSteps;
  final DateTime? scheduledDeletionAt;
  final DateTime? lastArtifactUnlockedAt;

  // 🌟 6,000歩 / 10,000歩マイルストーン達成タイムスタンプ
  final DateTime? steps6kUnlockedAt;
  final DateTime? steps10kUnlockedAt;

  final Map<String, dynamic> unlockedArtifacts;
  final Map<String, dynamic> unlockedEras;

  UserModel({
    required this.userId,
    this.appStartDate,
    this.stepFetchedAt,
    required this.startEra,
    required this.startYear,
    required this.startMonth,
    required this.startDay,
    required this.isCleared,
    required this.gameMode,
    required this.steps,
    required this.totalSteps,
    this.scheduledDeletionAt,
    this.lastArtifactUnlockedAt,
    this.steps6kUnlockedAt,
    this.steps10kUnlockedAt,
    required this.unlockedArtifacts,
    required this.unlockedEras,
  });

  factory UserModel.fromDocument(String id, Map<String, dynamic> doc) {
    DateTime? parseTimestamp(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return UserModel(
      userId: id,
      appStartDate: parseTimestamp(doc['appStartDate']),
      stepFetchedAt: parseTimestamp(doc['stepFetchedAt']),
      startEra: doc['startEra'] as String? ?? '紀元前',
      startYear: (doc['startYear'] as num?)?.toInt() ?? 3000,
      startMonth: (doc['startMonth'] as num?)?.toInt() ?? 1,
      startDay: (doc['startDay'] as num?)?.toInt() ?? 1,
      isCleared: doc['isCleared'] as bool? ?? false,
      gameMode: (doc['gameMode'] as num?)?.toInt() ?? 0,
      steps: (doc['steps'] as num?)?.toInt() ?? 0,
      totalSteps: (doc['totalSteps'] as num?)?.toInt() ?? 0,
      scheduledDeletionAt: parseTimestamp(doc['scheduledDeletionAt']),
      lastArtifactUnlockedAt: parseTimestamp(doc['lastArtifactUnlockedAt']),
      steps6kUnlockedAt: parseTimestamp(doc['steps6kUnlockedAt']),
      steps10kUnlockedAt: parseTimestamp(doc['steps10kUnlockedAt']),
      unlockedArtifacts:
          (doc['unlockedArtifacts'] as Map<String, dynamic>?) ?? {},
      unlockedEras: (doc['unlockedEras'] as Map<String, dynamic>?) ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (appStartDate != null)
        'appStartDate': Timestamp.fromDate(appStartDate!),
      if (stepFetchedAt != null)
        'stepFetchedAt': Timestamp.fromDate(stepFetchedAt!),
      'startEra': startEra,
      'startYear': startYear,
      'startMonth': startMonth,
      'startDay': startDay,
      'isCleared': isCleared,
      'gameMode': gameMode,
      'steps': steps,
      'totalSteps': totalSteps,
      if (scheduledDeletionAt != null)
        'scheduledDeletionAt': Timestamp.fromDate(scheduledDeletionAt!),
      if (lastArtifactUnlockedAt != null)
        'lastArtifactUnlockedAt': Timestamp.fromDate(lastArtifactUnlockedAt!),
      if (steps6kUnlockedAt != null)
        'steps6kUnlockedAt': Timestamp.fromDate(steps6kUnlockedAt!),
      if (steps10kUnlockedAt != null)
        'steps10kUnlockedAt': Timestamp.fromDate(steps10kUnlockedAt!),
      'unlockedArtifacts': unlockedArtifacts,
      'unlockedEras': unlockedEras,
    };
  }
}