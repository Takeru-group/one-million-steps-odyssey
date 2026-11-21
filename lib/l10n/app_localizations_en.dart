// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'One Million Steps Odyssey';

  @override
  String get onboardingTitle1 => 'Welcome to One Million Steps Odyssey';

  @override
  String get onboardingDesc1 =>
      'Every real-world step counts as 1 day in the app! Embark on a journey through human history from 1,000,000 days ago to today!';

  @override
  String get onboardingTitle2 => 'Collect Artifacts';

  @override
  String get onboardingDesc2 =>
      '1,000,000 steps—1,000,000 days—span across many centuries. Collect artifacts from each era you visit along the way.';

  @override
  String get onboardingTitle3 => 'Start Your Odyssey';

  @override
  String get onboardingDesc3 =>
      'Once you start, all you have to do is walk. Check the app from time to time to see which era you\'ve reached! Log in or sign up to begin.';

  @override
  String get btnNext => 'Next';

  @override
  String get btnStartAuth => 'Log In / Sign Up';

  @override
  String get changeLanguage => 'Language / 言語変更';

  @override
  String get tabHome => 'Home';

  @override
  String get tabHistory => 'History';

  @override
  String figureMet(String name) {
    return 'Met $name.';
  }

  @override
  String get hintHomeTitle => 'How to Journey on Home';

  @override
  String get hintHomeDesc =>
      '[Steps & Timeline Progression]\nWith every step counting as 1 day in the app, your journey advances from ancient times—1,000,000 days before the date you started the app—toward the modern era.\nSteps sync automatically in the background even when the app is closed.\n\n[Eras & Scenery]\n• Tap the top date button to read in-depth historical context and image titles for your current era.\n• Every 10 years, you reach a new era and the background scenery automatically updates.\n• Centuries advance every 100 years. At milestone centuries, an in-app review prompt or an ad may appear.\n\n[Collecting Artifacts]\n• Bottom-Right ★ Button: Watch a short video ad to discover an uncollected artifact (technology, historical figure, or event) from your current era (available roughly once every 4 hours).\n• Daily Step Milestones: You also earn an artifact when you walk 6,000+ and 10,000+ steps in a day and open the app on that same day.';

  @override
  String get hintHistoryTitle => 'How to View History';

  @override
  String get hintHistoryDesc =>
      '[Eras & Artifacts]\nThe \"Eras\" you have reached and the \"Artifacts\" you have discovered during your journey are organized and recorded century by century.\n\n[Viewing Details]\n• Tap each century panel to expand and view the list of items.\n• Tap any item to view its details.\n\n[Difference from Hall of Fame]\n• This app supports multiple playthroughs (rounds). This History screen displays only the \"Eras\" and \"Artifacts\" unlocked in your current round.\n• The \"Hall of Fame\" in the side menu displays all \"Eras\" and \"Artifacts\" collected across all your rounds so far.';

  @override
  String get tabSteps => 'Steps';

  @override
  String get homeDefaultDescription =>
      'Around 750 BCE, maritime trade by Phoenicians flourished in the Mediterranean, while Etruscan culture began developing in the Italian Peninsula.';

  @override
  String historyCenturyBce(int century) {
    return '${century}th Century BCE';
  }

  @override
  String historyCenturyCe(int century) {
    return '${century}th Century';
  }

  @override
  String eraReachedMessage(String eraLabel) {
    return 'Reached $eraLabel';
  }

  @override
  String artifactDiscoveredMessage(String artifactName) {
    return 'Discovered $artifactName';
  }

  @override
  String stepsToday(int steps) {
    return 'Today\'s Steps: $steps';
  }

  @override
  String stepsUpdatedAt(String dateTime) {
    return 'Updated: $dateTime';
  }

  @override
  String stepsTotal(int steps) {
    return 'Total Steps: $steps';
  }

  @override
  String stepsStartDate(String date) {
    return 'Started: $date';
  }

  @override
  String get stepsPast7Days => 'Past 7 Days';

  @override
  String stepsChartTooltip(int steps) {
    return '$steps steps';
  }

  @override
  String get hintStepsTitle => 'How to View Steps';

  @override
  String get hintStepsDesc =>
      '[Step Tracking]\nConnects with your device\'s health app to retrieve and record your step counts for today and the past 7 days in real time.\n\n[Step Summary & Trends]\n• \"Today\'s Steps\" and \"Total Steps\" since your start date are displayed at the top.\n• The bar chart below shows your progress over the past 7 days—tap any bar to view the exact step count in a pop-up.\n\n[Step Rewards]\n• Reaching 6,000 & 10,000 Steps: You earn 1 artifact from your current century for each milestone achieved.';

  @override
  String dateBceFormat(int year, int month, int day) {
    return '$year BCE $month/$day';
  }

  @override
  String dateCeFormat(int year, int month, int day) {
    return '$year CE $month/$day';
  }

  @override
  String get menuChangeNicknameTitle => 'Change Nickname';

  @override
  String get menuChangeNicknameHint => 'Enter new nickname';

  @override
  String get menuCancel => 'Cancel';

  @override
  String get menuSave => 'Save';

  @override
  String get menuNicknameUpdated => 'Nickname updated successfully.';

  @override
  String menuNicknameUpdateFailed(String error) {
    return 'Failed to update nickname: $error';
  }

  @override
  String get menuNotLoggedIn => 'Not logged in';

  @override
  String get menuThemeSection => 'Theme';

  @override
  String get menuDarkMode => 'Dark Mode';

  @override
  String get menuLanguageSection => 'Language';

  @override
  String get menuLogOut => 'Log Out';

  @override
  String get artifactDialogTitle => 'Discover Artifact';

  @override
  String artifactDialogDesc(String eraLabel) {
    return 'Would you like to watch a short video to discover an artifact (technology, figure, or historical event) from the current century ($eraLabel)?';
  }

  @override
  String get artifactDialogNotice =>
      '* Selected at random with equal probability from uncollected artifacts of this century.';

  @override
  String get artifactDialogCancel => 'Cancel';

  @override
  String get artifactDialogWatchAd => 'Discover';

  @override
  String get welcomeTitle => 'Welcome to One Million Steps Odyssey!';

  @override
  String get welcomeHydrationNotice =>
      'When walking outdoors, please stay well hydrated and keep safe on your journey.\nPlease refrain from looking at the app while walking.';

  @override
  String get welcomeBackgroundTitle => 'Background Sync';

  @override
  String get welcomeBackgroundNotice =>
      'This app syncs with your health app automatically, so you don\'t need to keep it open.\nJust walk normally and open the app occasionally to explore new historical eras!';

  @override
  String get welcomeButtonStart => 'Start Journey';

  @override
  String get logoutDialogTitle => 'Confirm Log Out';

  @override
  String get logoutDialogMessage =>
      'Are you sure you want to log out?\n\n* Please note that your steps will NOT be tracked or accumulated while logged out.';

  @override
  String get logoutConfirmButton => 'Log Out';

  @override
  String get logoutCancelButton => 'Cancel';

  @override
  String get notification6kTitle => '👟 6,000 Steps Reached!';

  @override
  String get notification6kBody =>
      'You reached 6,000 steps today! Open the app to check your progress!';

  @override
  String get notification10kTitle => '🎉 10,000 Steps Reached!';

  @override
  String get notification10kBody =>
      'You reached 10,000 steps today! Open the app to check your progress!';

  @override
  String get milestone6kTitle => '👟 6,000 Steps Milestone!';

  @override
  String get milestone6kDesc =>
      'You reached 6,000 steps today!\nYou earned an artifact!';

  @override
  String get milestone10kTitle => '🎉 10,000 Steps Milestone!';

  @override
  String get milestone10kDesc =>
      'Amazing! You reached 10,000 steps today!\nYou earned an artifact!';

  @override
  String get milestoneGetArtifact => 'Discover';

  @override
  String get hallOfFameTitle => 'Hall of Fame';

  @override
  String get hallOfFameEras => 'Eras';

  @override
  String get hallOfFameArtifacts => 'Artifacts';

  @override
  String get hallOfFameEmpty => 'No collected items yet';

  @override
  String menuRoundCount(int count) {
    return 'Round: $count';
  }

  @override
  String menuStartDate(String date) {
    return 'Started: $date';
  }

  @override
  String get menuInquiry => 'Contact Us';

  @override
  String get menuTermsOfService => 'Terms of Service';

  @override
  String get menuPrivacyPolicy => 'Privacy Policy';

  @override
  String get menuOssLicenses => 'Open Source Licenses';

  @override
  String get menuDeleteAccount => 'Delete Account';

  @override
  String get deleteAccountDialogTitle => 'Delete Account';

  @override
  String get deleteAccountDialogMessage =>
      'Deleting your account will permanently erase all your step history, unlocked eras, and collected artifacts. This action cannot be undone.\n\nTo continue, please type \"delete\" below.';

  @override
  String get deleteAccountConfirmButton => 'Delete';

  @override
  String deleteAccountFailed(String error) {
    return 'Failed to delete account (re-authentication may be required): $error';
  }

  @override
  String logoutFailed(String error) {
    return 'Failed to log out: $error';
  }

  @override
  String get urlOpenFailed => 'Could not open the page.';

  @override
  String get artifactRewardTitle => 'Artifact Discovered!';

  @override
  String get btnClose => 'Close';

  @override
  String centuryEnteredTitle(String century) {
    return 'Entered the $century!';
  }

  @override
  String get eraEnteredTitle => 'Entered a New Era!';

  @override
  String centuryEnteredDesc(String eraLabel, String century) {
    return 'You have reached a new era (${eraLabel}s) and entered the $century!\nBackground scenery and historical info have been updated.';
  }

  @override
  String eraEnteredDesc(String eraLabel) {
    return 'You have reached a new era (${eraLabel}s)!\nBackground scenery and historical info have been updated.';
  }

  @override
  String get btnContinueJourney => 'Continue Journey';

  @override
  String get endingAchievedTitle => '1,000,000 Steps Achieved!';

  @override
  String get endingAchievedDesc =>
      'You have walked through 2,700 years of human history and reached the present day.\n\nWould you like to start a new adventure?';

  @override
  String get btnLater => 'Later';

  @override
  String get btnStart => 'Start';

  @override
  String get endingMainTitle => 'ONE MILLION STEPS ODYSSEY';

  @override
  String get endingSubtitle => 'A Chronicle of Your 1,000,000 Steps';

  @override
  String get endingEmptyFallback => 'Your journey has reached the modern era.';

  @override
  String get endingFinaleTitle => 'THANK YOU FOR WALKING';

  @override
  String get endingFinaleSubtitle =>
      'Every step you took carved a new page in history.';

  @override
  String get endingFastForward => 'Fast Forward';

  @override
  String get endingSkip => 'Skip';

  @override
  String get artifactAllCollected =>
      'You have already collected all artifacts from this century!';

  @override
  String get hintTooltip => 'View Hint';

  @override
  String get adNotReady => 'Ad is not ready yet.';

  @override
  String get legalLoadFailed => 'Failed to load document.';

  @override
  String hallOfFameCenturyCe(int century) {
    return '${century}th Century';
  }
}
