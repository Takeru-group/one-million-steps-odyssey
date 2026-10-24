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
  String get onboardingDesc1 => '1歩を1日として「100万日前」から現在までの人類の旅に出かけましょう!';

  @override
  String get onboardingTitle2 => 'アーティファクトを集めよう';

  @override
  String get onboardingDesc2 => '世紀を巡る旅の中で、世界中の「物語」にまつわる アーティファクトを集めましょう。';

  @override
  String get onboardingTitle3 => 'あなたの冒険をスタート';

  @override
  String get onboardingDesc3 => 'さあ、シューズを履いて古くて新しい旅の始まりです！ログインまたはユーザー登録して始めます。';

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
  String historyReached(String name) {
    return '$name に到達しました。';
  }

  @override
  String artifactDiscovered(String name) {
    return '$name を発見しました。';
  }

  @override
  String figureMet(String name) {
    return '$name と出会いました。';
  }

  @override
  String get hintHomeTitle => 'ホーム画面の旅の進め方';

  @override
  String get hintHomeDesc =>
      'あなたが歩いた歩数（1歩＝約1日）に応じて歴史の時間が進みます。\n\n・上部の日付ボタンをタップすると、現在滞在している時代の歴史的背景を読むことができます。\n・時代が進むと背景画像が自動的に変化します。\n・右下の★ボタンからは偉人やアーティファクトを獲得できます。';

  @override
  String get hintHistoryTitle => 'History図鑑の見方';

  @override
  String get hintHistoryDesc =>
      'これまで歩みを進めて解放された年代やアーティファクトのコレクションです。\n\n・世紀ごとに折りたたまれて記録されています。\n・タップして展開すると、到達・獲得した日付や詳細メッセージを確認できます。';

  @override
  String get tabSteps => '歩数';

  @override
  String get homeDefaultDescription =>
      '紀元前750年頃、地中海地域ではフェニキア人による海上貿易が活発化し、イタリア半島では古代ローマの萌芽となるエトルリア文化が発展し始めた。ギリシャでは都市国家ポリスの形成が進む黎明期であった。';

  @override
  String get historyEmptyCurrentRound => 'この周回で獲得した歴史はまだありません';

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
  String get hintStepsTitle => '歩数データの見方';

  @override
  String get hintStepsDesc =>
      '本日の歩数やこれまでの累計歩数、および過去7日間の歩数推移を確認できます。\n\n・グラフの棒をタップすると詳細な歩数が表示されます。';

  @override
  String historyReachedEra(Object eraLabel) {
    return '$eraLabel年代に到達しました';
  }

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
  String menuStartPoint(String era, int year) {
    return '開始地点: $era$year年';
  }

  @override
  String get menuNotLoggedIn => '未ログイン';

  @override
  String get menuTodaySteps => '本日の歩数';

  @override
  String get menuTotalSteps => '累計歩数';

  @override
  String get menuAllConquered => '全歴史制覇！ (総歩数)';

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
    return '短い動画を見て現在の年代（$eraLabel）のアーティファクト（技術・偉人・歴史的出来事）を獲得しますか？';
  }

  @override
  String get artifactDialogNotice => '※ この時代の未獲得アーティファクトから均等な確率で選ばれます。';

  @override
  String get artifactDialogCancel => 'キャンセル';

  @override
  String get artifactDialogWatchAd => '獲得';

  @override
  String get welcomeTitle => '100万歩の歴史旅へようこそ！';

  @override
  String get welcomeHydrationNotice =>
      '人類の長い歴史の旅には、常にこまめな水分補給が不可欠でした。\n屋外でウォーキングを楽しむ際は、しっかりと水分を補給し、安全に気をつけて旅をお楽しみください。';

  @override
  String get welcomeBackgroundTitle => '自動バックグラウンド連携';

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
  String get notification6kBody => '本日の目標6,000歩を達成しました！歴史の旅が着実に進んでいます。';

  @override
  String get notification10kTitle => '🎉 10,000歩大達成！';

  @override
  String get notification10kBody => '素晴らしい！10,000歩に到達しました！1万日分の歴史を駆け抜けました！';

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
