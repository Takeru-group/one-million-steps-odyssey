import 'package:background_fetch/background_fetch.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:health/health.dart';
import 'step_notification_service.dart'; // 👈 このインポートを追加

class BackgroundFetchService {
  static final Health _health = Health();
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// 初期化と設定
  static Future<void> initialize() async {
    if (kIsWeb) return;

    print('⚙️ [BackgroundFetch] 初期化処理を開始します...');

    try {
      int status = await BackgroundFetch.configure(
        BackgroundFetchConfig(
          minimumFetchInterval: 15,
          stopOnTerminate: false,
          enableHeadless: true,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
        _onBackgroundFetch,
        _onBackgroundFetchTimeout,
      );

      print('✅ [BackgroundFetch] configure 成功! ステータスコード: $status');
    } catch (e) {
      print('❌ [BackgroundFetch] configure エラー: $e');
    }
  }

  /// フォアグラウンド・バックグラウンド動作時のイベント受信用
  static void _onBackgroundFetch(String taskId) async {
    print("🚀 [BackgroundFetch] イベント受信: $taskId");
    await executeBackgroundStepCheck();
    BackgroundFetch.finish(taskId);
  }

  /// タイムアウトハンドラ
  static void _onBackgroundFetchTimeout(String taskId) {
    print("⏰ [BackgroundFetch] タイムアウト: $taskId");
    BackgroundFetch.finish(taskId);
  }

  /// バックグラウンドで行う実際の歩数チェック＆通知処理
  // 変更後: lib/utils/background_fetch_service.dart の executeBackgroundStepCheck メソッド
  static Future<void> executeBackgroundStepCheck() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('🔒 [BackgroundFetch] ユーザー未ログインのためスキップしました');
      return;
    }

    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      final steps = await _health.getTotalStepsInInterval(midnight, now) ?? 0;

      print('🌙 [BackgroundFetch] バックグラウンド歩数チェック: $steps 歩');

      // 🌟 6,000歩 / 10,000歩の到達チェック＆本日1回限りの通知発行
      await StepNotificationService.checkAndSendStepNotifications(steps);

    } catch (e) {
      print('❌ [BackgroundFetch] 歩数取得エラー: $e');
    }
  }

  /// ローカル通知の発行
  static Future<void> _showAchievementNotification(int steps) async {
    const androidDetails = AndroidNotificationDetails(
      'step_achievement_channel',
      'Step Achievements',
      channelDescription: 'Notifications for daily step achievements',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentSound: true,
      presentAlert: true,
      presentBadge: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id: 999,
      title: '🎉 今日の目標達成！',
      body: '本日の歩数が $steps 歩に達しました！オデッセイの旅を進めましょう！',
      notificationDetails: details,
    );
  }

  static Future<void> stop() async {
    if (kIsWeb) return;
    try {
      await BackgroundFetch.stop();
      print('🛑 [BackgroundFetch] 停止完了');
    } catch (e) {
      print('❌ [BackgroundFetch] 停止エラー: $e');
    }
  }
}