# One Million Steps Odyssey (1MSO / 100万歩の旅)

「1歩 ＝ 1日」として、約2700年前（紀元前700年代〜）の古代から現代までの人類の歴史を歩数とともに旅する、ヘルスケア連動型歴史体験モバイルアプリケーションです。

---

## 📱 アプリ概要

日々の歩数計測（iOS HealthKit / Android Activity Recognition）と連動し、歩いた歩数に応じて滞在する時代（年代・世紀）が進行します。
歩くことで歴史的背景の解説や背景グラフィックが変化し、道中で世界中の偉人やアーティファクト（歴史的遺物・出来事）をコレクションしていくことができます。

---

## 🌟 主要機能とゲームシステム

### 1. タイムライン進行システム
- **歩数換算**: 1歩 ＝ 1日。日々のウォーキングを通じて約100万歩（約2,700年分の人類史）の踏破を目指します。
- **年代・世紀の判定**: 天文学的紀年法およびユリウス日（JDN）に基づき、紀元前（BC）から西暦（AD）への遷移も含め正確に日付と世紀（Century）を算出します。

### 2. 厳格なイベントチェーン（優先順位制御）
歩数同期や年代クリア時には、ダイアログの重なりや処理のデッドロックを防ぐため、以下の順序でイベントを直列実行します。
1. **年代達成イベント (Era Transition)**: 新しい年代への到達ダイアログ表示および背景グラフィックの更新。
2. **世紀跨ぎアクション (Century Transition)**:
   - 特定の節目世紀（**紀元前6世紀[-6]、1世紀[1]、8世紀[8]、16世紀[16]**）: アプリ内レビュー（In-App Review）の促進。
   - 上記以外の世紀: インタースティシャル広告の表示。
3. **歩数マイルストーン (Step Milestones)**:
   - 当日 **6,000歩** 到達: 確定アーティファクトリワード獲得。
   - 当日 **10,000歩** 到達: 確定アーティファクトリワード獲得（一括同期時も 6,000歩 → 10,000歩 の順で順次獲得）。
4. **動画リワード広告（★ボタン）**: クールダウン（4時間）経過後に、任意視聴で年代に応じたアーティファクトを獲得。

### 3. コレクション・図鑑
- **歴史の殿堂 (Hall of Fame)**: これまでに到達した年代と獲得したアーティファクトを世紀ごとに整理して閲覧可能。
- **多言語対応 (i18n / l10n)**: 日本語・英語に対応し、端末設定またはアプリ内設定からリアルタイムに切り替え可能。
- **テーマ切り替え**: ライトモード / ダークモード対応。

---

## 🏗 ディレクトリ・アーキテクチャ

関心事の分離（Separation of Concerns）に基づき、機能・役割ごとにディレクトリを整理しています。

- lib/
  - firebase_options.dart: Firebase プラットフォーム設定
  - l10n/: 多言語リソース (.arb)
  - main.dart: アプリエントリーポイント・初期化
  - models/: データモデル (UserModel, ArtifactModel, HistoryMasterModel)
  - pages/: 画面単位 (MainPage, HallOfFamePage, InitialPage)
  - theme/: カラーパレット・デザインテーマ
  - utils/: 各種サービスクラス (AdManager, StepTrackerService, UserRepository 等)
  - widgets/: 再利用可能なUIコンポーネント (AppDialogs, AppBottomSheet 等)

---

## 🛠 技術スタック

- Framework: Flutter (Dart 3.x)
- Backend / DB: Cloud Firestore, Firebase Authentication, Firebase Storage
- Analytics / Notification: Firebase Analytics, FCM, Local Notifications
- Monetization: Google Mobile Ads (AdMob - Rewarded / Interstitial)
- Health / Activity: HealthKit / Health Connect, Background Fetch
- Store Review: in_app_review
- Charts: fl_chart

---

## 🤖 AIエージェント開発環境・運用ツール

- AGENTS.md: Cursor / Antigravity 用開発ガイドライン。
- repomix.config.json: LLMコンテキスト向け軽量化設定。
- pack.sh: 軽量リポジトリ出力スクリプト。

---

## 🚀 ビルド＆開発手順

1. パッケージ取得とネイティブ同期:
   flutter pub get
   cd ios && pod install && cd ..

2. 静的解析:
   flutter analyze

3. 実機ビルド:
   flutter run --release
