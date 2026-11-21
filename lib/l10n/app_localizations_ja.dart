// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => '100万歩の旅';

  @override
  String get onboardingTitle1 => '100万歩の旅へようこそ';

  @override
  String get onboardingDesc1 =>
      '現実の1歩がアプリでは1日で計算されます！「100万日前」から現在までの人類の旅に出かけましょう!';

  @override
  String get onboardingTitle2 => 'アーティファクトを集めよう';

  @override
  String get onboardingDesc2 => '100万歩つまり100万日は何世紀にも渡ります。その年代のアーティファクトを集めましょう。';

  @override
  String get onboardingTitle3 => 'あなたの冒険をスタート';

  @override
  String get onboardingDesc3 =>
      'アプリを開始したら後は歩くだけ。時々アプリを見てどの年代まで進んだか確認してみてください！ログインまたはユーザー登録して始めます。';

  @override
  String get btnNext => '次へ';

  @override
  String get btnStartAuth => 'ログイン / アカウント作成';

  @override
  String get changeLanguage => '言語変更 / Change Language';

  @override
  String get tabHome => 'ホーム';

  @override
  String get tabHistory => '歴史';

  @override
  String figureMet(String name) {
    return '$name と出会いました。';
  }

  @override
  String get hintHomeTitle => 'ホーム画面の旅の進め方';

  @override
  String get hintHomeDesc =>
      '【歩数と歴史の進行】\nあなたが歩いた歩数に応じて、アプリ内で1歩を1日換算として、アプリをスタートした日から100万日前の古代から現代へと進んでいきます。\nアプリを開いていない間もバックグラウンドで自動同期されます。\n\n【年代と背景グラフィック】\n・上部の日付ボタンをタップすると、現在滞在している年代の歴史的解説や画像タイトルを閲覧できます。\n・10年毎に次の年代へ到達し、背景グラフィックが自動的に切り替わります。\n・100年単位で「世紀」が進んでいきます。節目の世紀ではアプリ内レビューや広告が表示されることがあります。\n\n【アーティファクトの収集】\n・右下の★ボタン：短い動画広告を視聴することで、滞在中の年代にまつわる未獲得のアーティファクト（技術・偉人・歴史的出来事）を1つ獲得できます。（約4時間に1回）\n・1日に6,000歩以上と10,000歩以上歩行して、その日のうちにアプリを開いた際もアーティファクトを獲得できます。';

  @override
  String get hintHistoryTitle => '歴史画面の見方';

  @override
  String get hintHistoryDesc =>
      '【年代とアーティファクト】\n旅の途中で到達した「年代」と、獲得した「アーティファクト」が世紀ごとにまとめられて記録されています。\n\n【詳細の確認】\n・各世紀のパネルをタップすると一覧で表示されます。\n・各アイテムをタップすると、詳細が表示されます。\n\n【歴史の殿堂との違い】\n・このアプリは周回が可能です。この歴史画面では現在の周回で解放した「年代」と「アーティファクト」のみが表示されます。\n・サイドメニューの「歴史の殿堂」ではこれまでのすべての周回を通じて獲得した全ての「年代」と「アーティファクト」が表示されます。';

  @override
  String get tabSteps => '歩数';

  @override
  String get homeDefaultDescription =>
      '紀元前750年頃、地中海地域ではフェニキア人による海上貿易が活発化し、イタリア半島では古代ローマの萌芽となるエトルリア文化が発展し始めた。ギリシャでは都市国家ポリスの形成が進む黎明期であった。';

  @override
  String historyCenturyBce(int century) {
    return '紀元前$century世紀';
  }

  @override
  String historyCenturyCe(int century) {
    return '$century世紀';
  }

  @override
  String eraReachedMessage(String eraLabel) {
    return '$eraLabelに到達しました';
  }

  @override
  String artifactDiscoveredMessage(String artifactName) {
    return '$artifactNameを発見しました。';
  }

  @override
  String stepsToday(int steps) {
    return '今日の歩数 : $steps歩';
  }

  @override
  String stepsUpdatedAt(String dateTime) {
    return 'アップデート: $dateTime';
  }

  @override
  String stepsTotal(int steps) {
    return '総歩数: $steps歩';
  }

  @override
  String stepsStartDate(String date) {
    return 'アプリ開始日: $date';
  }

  @override
  String get stepsPast7Days => '過去 7 日間の歩数';

  @override
  String stepsChartTooltip(int steps) {
    return '$steps 歩';
  }

  @override
  String get hintStepsTitle => '歩数画面の見方';

  @override
  String get hintStepsDesc =>
      '【歩数】\n端末のヘルスケアアプリと連携し、本日および過去7日間の歩数をリアルタイムに取得・記録します。\n\n【歩数概要と推移】\n・「本日の歩数」および開始日時からの「累計歩数」が上部に表示されます。\n・下部の棒グラフでは過去7日間の推移を確認でき、各バーをタップするとその歩数がポップアップします。\n\n【歩数報酬】\n・6,000歩達成・10,000歩達成：それぞれでその世紀のアーティファクトを1個獲得できます。';

  @override
  String dateBceFormat(int year, int month, int day) {
    return '紀元前$year年$month月$day日';
  }

  @override
  String dateCeFormat(int year, int month, int day) {
    return '西暦$year年$month月$day日';
  }

  @override
  String get menuChangeNicknameTitle => 'ニックネームの変更';

  @override
  String get menuChangeNicknameHint => '新しいニックネームを入力';

  @override
  String get menuCancel => 'キャンセル';

  @override
  String get menuSave => '保存';

  @override
  String get menuNicknameUpdated => 'ニックネームを更新しました';

  @override
  String menuNicknameUpdateFailed(String error) {
    return '更新に失敗しました: $error';
  }

  @override
  String get menuNotLoggedIn => '未ログイン';

  @override
  String get menuThemeSection => 'テーマ';

  @override
  String get menuDarkMode => 'ダークモード';

  @override
  String get menuLanguageSection => '言語';

  @override
  String get menuLogOut => 'ログアウト';

  @override
  String get artifactDialogTitle => 'アーティファクトの発見';

  @override
  String artifactDialogDesc(String eraLabel) {
    return '短い動画を見て現在の世紀（$eraLabel）のアーティファクト（技術・偉人・歴史的出来事）を獲得しますか？';
  }

  @override
  String get artifactDialogNotice => '※ この世紀の未獲得アーティファクトから均等な確率で選ばれます。';

  @override
  String get artifactDialogCancel => 'キャンセル';

  @override
  String get artifactDialogWatchAd => '獲得';

  @override
  String get welcomeTitle => '100万歩の歴史旅へようこそ！';

  @override
  String get welcomeHydrationNotice =>
      '屋外でウォーキングを楽しむ際は、しっかりと水分を補給し、安全に気をつけて旅をお楽しみください。\n歩きながらのアプリ閲覧はお控えください。';

  @override
  String get welcomeBackgroundTitle => 'バックグラウンド連携';

  @override
  String get welcomeBackgroundNotice =>
      '本アプリはヘルスケア機能と自動連携するため、常にアプリを開いておく必要はありません。\n普段通り生活し、時々アプリを開くことで次の時代への到達や新しい歴史の発見が楽しめます！';

  @override
  String get welcomeButtonStart => '旅を始める';

  @override
  String get logoutDialogTitle => 'ログアウトの確認';

  @override
  String get logoutDialogMessage =>
      '本当にログアウトしますか？\n\n※ ログアウト期間中は歩数がカウント・加算されませんのでご注意ください。';

  @override
  String get logoutConfirmButton => 'ログアウト';

  @override
  String get logoutCancelButton => 'キャンセル';

  @override
  String get notification6kTitle => '👟 6,000歩達成！';

  @override
  String get notification6kBody => '本日6,000歩に達成しました！アプリを確認してみましょう！';

  @override
  String get notification10kTitle => '🎉 10,000歩達成！';

  @override
  String get notification10kBody => '10,000歩に到達しました！アプリを確認してみましょう！';

  @override
  String get milestone6kTitle => '👟 6,000歩達成！';

  @override
  String get milestone6kDesc => '本日6,000歩に到達しました！\nアーティファクトを獲得できます！';

  @override
  String get milestone10kTitle => '🎉 10,000歩達成！';

  @override
  String get milestone10kDesc => '素晴らしい！本日10,000歩に到達しました！\nアーティファクトを獲得できます！';

  @override
  String get milestoneGetArtifact => '獲得する';

  @override
  String get hallOfFameTitle => '歴史の殿堂';

  @override
  String get hallOfFameEras => '年代';

  @override
  String get hallOfFameArtifacts => 'アーティファクト';

  @override
  String get hallOfFameEmpty => '獲得したアイテムはありません';
}
