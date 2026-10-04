import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class AppInitService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final Health _health = Health();

  static Future<void> initSilentServices() async {
    if (kIsWeb) return;
    await MobileAds.instance.initialize();
    await _analytics.logAppOpen();
  }

  /// 各種権限をリクエストし、ヘルスケア（歩数）の許可結果を返す
  static Future<bool> requestPermissionsAfterLogin() async {
    if (kIsWeb) return false;

    // 1. iOS App Tracking Transparency (ATT)
    if (Platform.isIOS) {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        await Future.delayed(const Duration(milliseconds: 800));
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    }

    // 2. プッシュ通知の権限リクエスト
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      try {
        if (Platform.isIOS) {
          String? apnsToken = await _messaging.getAPNSToken();
          int retryCount = 0;
          while (apnsToken == null && retryCount < 6) {
            await Future.delayed(const Duration(milliseconds: 500));
            apnsToken = await _messaging.getAPNSToken();
            retryCount++;
          }
        }

        String? token = await _messaging.getToken();
        print('🔔 [FCM Token]: $token');
      } catch (e) {
        print('⚠️ [FCM Token Error]: $e');
      }
    }

    if (Platform.isAndroid) {
      await Permission.notification.request();
    }

    // 3. ヘルスケア（歩数）の権限リクエストを行い、結果を返却
    return await _requestHealthPermissions();
  }

  static Future<bool> _requestHealthPermissions() async {
    if (kIsWeb) return false;

    try {
      if (Platform.isAndroid) {
        await Permission.activityRecognition.request();
      }

      final types = [HealthDataType.STEPS];
      final permissions = [HealthDataAccess.READ];

      bool requested = await _health.requestAuthorization(
        types,
        permissions: permissions,
      );

      print('🏥 [Health Permission Granted]: $requested');
      return requested;
    } catch (e) {
      print('❌ [Health Permission Error]: $e');
      return false;
    }
  }
}