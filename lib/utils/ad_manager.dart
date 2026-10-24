import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  RewardedAd? _rewardedAd;
  bool _isRewardedAdLoading = false;

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoading = false;

  /// 🌟 AdMob リワード広告ユニットID
  static const String _rewardedIosAdUnitId =
      'ca-app-pub-9172596977110438/6924880812';
  static const String _rewardedAndroidAdUnitId =
      'ca-app-pub-9172596977110438/9628819791';

  /// 🌟 AdMob インタースティシャル広告ユニットID
  static const String _interstitialIosAdUnitId =
      'ca-app-pub-9172596977110438/2863986923';
  static const String _interstitialAndroidAdUnitId =
      'ca-app-pub-9172596977110438/7292074680';

  String get _rewardedAdUnitId => defaultTargetPlatform == TargetPlatform.iOS
      ? _rewardedIosAdUnitId
      : _rewardedAndroidAdUnitId;

  String get _interstitialAdUnitId =>
      defaultTargetPlatform == TargetPlatform.iOS
          ? _interstitialIosAdUnitId
          : _interstitialAndroidAdUnitId;

  /// リワード広告が準備できているかの単一真実判定
  bool get isAdReady => _rewardedAd != null;

  // ==========================================
  // 1. リワード広告（★ボタン用）
  // ==========================================

  void loadRewardedAd({
    required VoidCallback onAdLoaded,
    required VoidCallback onAdFailed,
  }) {
    if (_rewardedAd != null) {
      onAdLoaded();
      return;
    }

    if (_isRewardedAdLoading) return;

    _isRewardedAdLoading = true;
    print('🎬 [AdManager] リワード広告ロード開始: $_rewardedAdUnitId');

    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          print('✅ [AdManager] リワード広告ロード成功');
          _rewardedAd = ad;
          _isRewardedAdLoading = false;
          _setupRewardedAdCallbacks();
          onAdLoaded();
        },
        onAdFailedToLoad: (error) {
          print('❌ [AdManager] リワード広告ロード失敗: Code ${error.code}, Message: ${error.message}');
          _rewardedAd = null;
          _isRewardedAdLoading = false;
          onAdFailed();
        },
      ),
    );
  }

  void _setupRewardedAdCallbacks() {
    _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        print('👋 [AdManager] リワード広告が閉じられました');
        ad.dispose();
        _rewardedAd = null;
        _isRewardedAdLoading = false;
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('❌ [AdManager] リワード広告表示失敗: ${error.message}');
        ad.dispose();
        _rewardedAd = null;
        _isRewardedAdLoading = false;
      },
    );
  }

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
    _isRewardedAdLoading = false;
  }

  // ==========================================
  // 2. インタースティシャル広告（世紀判定用）
  // ==========================================

  /// インタースティシャル広告のロード
  void loadInterstitialAd({
    VoidCallback? onAdLoaded,
    VoidCallback? onAdFailed,
  }) {
    if (_interstitialAd != null) {
      onAdLoaded?.call();
      return;
    }

    if (_isInterstitialAdLoading) return;

    _isInterstitialAdLoading = true;
    print('🎬 [AdManager] インタースティシャル広告ロード開始: $_interstitialAdUnitId');

    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          print('✅ [AdManager] インタースティシャル広告ロード成功');
          _interstitialAd = ad;
          _isInterstitialAdLoading = false;
          onAdLoaded?.call();
        },
        onAdFailedToLoad: (error) {
          print('❌ [AdManager] インタースティシャル広告ロード失敗: Code ${error.code}, Message: ${error.message}');
          _interstitialAd = null;
          _isInterstitialAdLoading = false;
          onAdFailed?.call();
        },
      ),
    );
  }

  /// 🌟 インタースティシャル広告の表示（閉じたら onAdClosed が走る）
  void showInterstitialAd({
    required VoidCallback onAdClosed,
  }) {
    if (_interstitialAd == null) {
      print('⚠️ [AdManager] インタースティシャル広告が準備できていないためスキップします');
      onAdClosed();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        print('👋 [AdManager] インタースティシャル広告が閉じられました');
        ad.dispose();
        _interstitialAd = null;
        _isInterstitialAdLoading = false;
        onAdClosed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('❌ [AdManager] インタースティシャル広告表示失敗: ${error.message}');
        ad.dispose();
        _interstitialAd = null;
        _isInterstitialAdLoading = false;
        onAdClosed();
      },
    );

    _interstitialAd!.show();
    _interstitialAd = null;
    _isInterstitialAdLoading = false;
  }

  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isRewardedAdLoading = false;

    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialAdLoading = false;
  }
}