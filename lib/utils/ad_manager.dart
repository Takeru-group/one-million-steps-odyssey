import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  RewardedAd? _rewardedAd;
  bool _isAdLoading = false;

  /// 🌟 本番用リワード広告ユニットID
  static const String _iosAdUnitId = 'ca-app-pub-9172596977110438/6924880812';
  static const String _androidAdUnitId = 'ca-app-pub-9172596977110438/9628819791';

  String get _adUnitId {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _iosAdUnitId;
    } else {
      return _androidAdUnitId;
    }
  }

  /// 🌟 広告が利用可能状態かどうかの単一真実（Single Source of Truth）
  bool get isAdReady => _rewardedAd != null;

  /// 🌟 広告の安全なロード要求
  void loadRewardedAd({
    required VoidCallback onAdLoaded,
    required VoidCallback onAdFailed,
  }) {
    if (_rewardedAd != null) {
      onAdLoaded();
      return;
    }

    if (_isAdLoading) return;

    _isAdLoading = true;
    print('🎬 [AdManager] 広告ロード開始: $_adUnitId');

    RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          print('✅ [AdManager] 広告ロード成功');
          _rewardedAd = ad;
          _isAdLoading = false;
          _setupAdCallbacks();
          onAdLoaded();
        },
        onAdFailedToLoad: (error) {
          print('❌ [AdManager] 広告ロード失敗: Code ${error.code}, Message: ${error.message}');
          _rewardedAd = null;
          _isAdLoading = false;
          onAdFailed();
        },
      ),
    );
  }

  void _setupAdCallbacks() {
    _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        print('👋 [AdManager] 広告が閉じられました');
        ad.dispose();
        _rewardedAd = null;
        _isAdLoading = false;
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('❌ [AdManager] 広告表示失敗: ${error.message}');
        ad.dispose();
        _rewardedAd = null;
        _isAdLoading = false;
      },
    );
  }

  /// 🌟 広告表示処理
  void showRewardedAd({
    required VoidCallback onUserEarnedReward,
    required Function(String) onAdFailed,
  }) {
    if (_rewardedAd == null) {
      onAdFailed('広告の準備ができていません');
      return;
    }

    _rewardedAd!.show(
      onUserEarnedReward: (adWithoutView, reward) {
        onUserEarnedReward();
      },
    );
    _rewardedAd = null;
    _isAdLoading = false;
  }

  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isAdLoading = false;
  }
}