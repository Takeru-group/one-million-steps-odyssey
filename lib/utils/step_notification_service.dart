import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../main.dart'; // localeNotifier 参照用

class StepNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// 本日の歩数に応じた到達通知チェック (6,000歩 / 10,000歩)
  static Future<void> checkAndSendStepNotifications(int todaySteps) async {
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final prefs = await SharedPreferences.getInstance();

    final key6k = 'notified_6000_$todayStr';
    final key10k = 'notified_10000_$todayStr';

    // 言語設定に応じた AppLocalizations の手動初期化（バックグラウンド動作時対応）
    final locale = localeNotifier.value ?? WidgetsBinding.instance.platformDispatcher.locale;
    final l10n = await AppLocalizations.delegate.load(locale);

    // 1. 6,000歩達成通知 (本日未送信かつ6,000歩以上)
    if (todaySteps >= 6000 && !(prefs.getBool(key6k) ?? false)) {
      await _showNotification(
        id: 6000,
        title: l10n.notification6kTitle,
        body: l10n.notification6kBody,
      );
      await prefs.setBool(key6k, true);
      print('🔔 [StepNotification] 6,000歩達成通知を送信しました ($todayStr / Locale: ${locale.languageCode})');
    }

    // 2. 10,000歩達成通知 (本日未送信かつ10,000歩以上)
    if (todaySteps >= 10000 && !(prefs.getBool(key10k) ?? false)) {
      await _showNotification(
        id: 10000,
        title: l10n.notification10kTitle,
        body: l10n.notification10kBody,
      );
      await prefs.setBool(key10k, true);
      print('🔔 [StepNotification] 10,000歩達成通知を送信しました ($todayStr / Locale: ${locale.languageCode})');
    }
  }

  /// ローカル通知の発行実行
  static Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'step_milestone_channel',
      'Step Milestones',
      channelDescription: 'Notifications for daily step milestone achievements',
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
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }
}