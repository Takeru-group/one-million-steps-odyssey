import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:health/health.dart';
import 'step_notification_service.dart';

class StepTrackerService {
  static final Health _health = Health();
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static Timer? _timer;
  static int _lastCheckedDay = -1;

  static Future<void> initialize() async {
    if (kIsWeb) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings: settings);
  }

  /// 定期トラッキング（30秒おき）
  static void startForegroundTracking({
    required BuildContext context,
    required DateTime stepFetchedAt,
    required Function(int incrementalSteps, int todaySteps) onStepsUpdated,
    required Function(List<Map<String, dynamic>> weeklySteps) onWeeklyUpdated,
  }) {
    if (kIsWeb) return;

    _timer?.cancel();
    _lastCheckedDay = DateTime.now().day;

    // 初回フェッチ
    _fetchStepData(stepFetchedAt, onStepsUpdated);

    // 30秒おきに繰り返し更新
    _timer = Timer.periodic(const Duration(seconds: 30), (_) async {
      final now = DateTime.now();

      // 1. 今日の歩数 ＆ 保存日時からの増分歩数
      _fetchStepData(stepFetchedAt, onStepsUpdated);

      // 2. 日付を跨いだ時のみ「過去7日間の歩数」を更新
      if (now.day != _lastCheckedDay) {
        _lastCheckedDay = now.day;
        print('📅 [StepTracker] 日時跨ぎを検知。過去7日間の歩数を再取得します。');
        final weekly = await fetchPastWeeklySteps();
        onWeeklyUpdated(weekly);
      }
    });
  }

  static void stopTracking() {
    _timer?.cancel();
  }

  /// 1. 本日の歩数（保存なし） ＆ 2. 保存日時からの増分歩数を算出
  // 変更後: lib/utils/step_tracker_service.dart の _fetchStepData メソッド
  static Future<void> _fetchStepData(
    DateTime stepFetchedAt,
    Function(int incrementalSteps, int todaySteps) onStepsUpdated,
  ) async {
    if (kIsWeb) return;

    try {
      final now = DateTime.now();
      final todayMidnight = DateTime(now.year, now.month, now.day, 0, 0, 0);

      // ① 1日の歩数: 本日 00:00:00 〜 現在
      final today =
          await _health.getTotalStepsInInterval(todayMidnight, now) ?? 0;

      // ② 増分歩数
      final fetchFrom = stepFetchedAt.isAfter(now) ? now : stepFetchedAt;
      final incremental =
          await _health.getTotalStepsInInterval(fetchFrom, now) ?? 0;

      onStepsUpdated(incremental, today);

      // 🌟 6,000歩 / 10,000歩の到達チェック＆本日1回限りの通知発行
      await StepNotificationService.checkAndSendStepNotifications(today);

    } catch (e) {
      print('⚠️ [StepTracker] 歩数取得エラー: $e');
    }
  }

  /// 3. 過去7日間の歩数 (アプリ開いた時・日跨ぎ時のみ取得)
  static Future<List<Map<String, dynamic>>> fetchPastWeeklySteps() async {
    if (kIsWeb) return [];

    final List<Map<String, dynamic>> weeklyData = [];
    final now = DateTime.now();

    try {
      for (int i = 6; i >= 0; i--) {
        final targetDate = now.subtract(Duration(days: i));
        
        final startOfDay =
            DateTime(targetDate.year, targetDate.month, targetDate.day, 0, 0, 0);

        final endOfDay = (i == 0)
            ? now
            : DateTime(targetDate.year, targetDate.month, targetDate.day, 23, 59, 59);

        final steps =
            await _health.getTotalStepsInInterval(startOfDay, endOfDay) ?? 0;

        weeklyData.add({
          'dayLabel': '${targetDate.month}/${targetDate.day}',
          'steps': steps,
        });
      }
    } catch (e) {
      print('⚠️ [StepTracker] 過去7日間の歩数取得エラー: $e');
    }

    return weeklyData;
  }
}