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
      'Embark on a journey of human history from \'1,000,000 days ago\' to today, counting 1 step as 1 day!';

  @override
  String get onboardingTitle2 => 'Collect Artifacts';

  @override
  String get onboardingDesc2 =>
      'Discover and collect artifacts associated with stories from around the world throughout the centuries.';

  @override
  String get onboardingTitle3 => 'Start Your Odyssey';

  @override
  String get onboardingDesc3 =>
      'Lace up your shoes and step into a timeless journey. Log in or sign up to begin!';

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
  String historyReached(String name) {
    return 'Reached $name.';
  }

  @override
  String artifactDiscovered(String name) {
    return 'Discovered $name.';
  }

  @override
  String figureMet(String name) {
    return 'Met $name.';
  }

  @override
  String get hintHomeTitle => 'How to Journey on Home';

  @override
  String get hintHomeDesc =>
      '[Steps & Timeline Progression]\nYour steps advance human history from antiquity (700s BCE) toward the modern era at the rate of 1 step = approx. 1 day. Steps sync automatically in the background even when closed.\n\n[Eras & Scenery]\n• Tap the top date button to read in-depth historical context and image titles for your current era.\n• As you accumulate steps, you will advance to new eras, automatically updating the background scenery.\n• Crossing a 100-year century mark triggers a special celebration, offering store reviews on milestone centuries and interstitial ads on others.\n\n[Collecting Artifacts]\n• Bottom-Right ★ Button: After a 4-hour cooldown, watch a short video to discover an uncollected artifact from your current era.\n• Daily Step Milestones: Reaching 6,000 and 10,000 steps each day also guarantees an artifact reward.';

  @override
  String get hintHistoryTitle => 'How to View History Collection';

  @override
  String get hintHistoryDesc =>
      '[Collection Layout]\nAll unlocked eras and discovered artifacts from your odyssey are neatly cataloged century by century.\n\n[Item Details]\n• Tap any century header to expand or collapse the item cards.\n• Tap an item to open a detailed modal showing discovery dates, full images, and rich historical stories.\n\n[History vs. Hall of Fame]\n• This History tab displays items collected during your current journey (round).\n• The Hall of Fame in the side menu provides an encyclopedia of all discoveries made across every journey.';

  @override
  String get tabSteps => 'Steps';

  @override
  String get homeDefaultDescription =>
      'Around 750 BCE, maritime trade by Phoenicians flourished in the Mediterranean, while Etruscan culture began developing in the Italian Peninsula.';

  @override
  String get historyEmptyCurrentRound =>
      'No history unlocked in this round yet.';

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
  String get hintStepsTitle => 'Step Data & Milestones';

  @override
  String get hintStepsDesc =>
      '[Tracking Mechanism]\nConnected directly to device health sensors (iOS HealthKit / Android Activity Recognition) to track your daily and overall activity.\n\n[Step Metrics & Charts]\n• View your Today\'s Steps alongside your overall Total Steps from day one.\n• The interactive bar chart illustrates your activity over the past 7 days—tap any bar to inspect specific daily counts.\n\n[Milestone Rewards]\n• 6,000 Steps: Hitting this daily fitness goal awards one guaranteed artifact.\n• 10,000 Steps: Advancing nearly 27 years of history in a single day awards a second guaranteed artifact.\n* Even if synced in batches above 10,000 steps, rewards for 6,000 and 10,000 steps are processed sequentially.';

  @override
  String historyReachedEra(Object eraLabel) {
    return 'Reached the ${eraLabel}s';
  }

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
  String menuStartPoint(String era, int year) {
    return 'Start Era: $era$year';
  }

  @override
  String get menuNotLoggedIn => 'Not logged in';

  @override
  String get menuTodaySteps => 'Today\'s Steps';

  @override
  String get menuTotalSteps => 'Total Steps';

  @override
  String get menuAllConquered => 'All History Conquered! (Total Steps)';

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
    return 'Would you like to watch a short video to discover an artifact (technology, figure, or historical event) from the current era ($eraLabel)?';
  }

  @override
  String get artifactDialogNotice =>
      '* Selected at random with equal probability from uncollected artifacts of this era.';

  @override
  String get artifactDialogCancel => 'Cancel';

  @override
  String get artifactDialogWatchAd => 'Discover';

  @override
  String get welcomeTitle => 'Welcome to One Million Steps Odyssey!';

  @override
  String get welcomeHydrationNotice =>
      'Throughout the long journey of human history, proper hydration has always been essential.\nPlease stay hydrated and keep safe while walking outdoors.';

  @override
  String get welcomeBackgroundTitle => 'Automatic Background Sync';

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
      'You\'ve reached your daily goal of 6,000 steps! Your journey through history progresses steadily.';

  @override
  String get notification10kTitle => '🎉 10,000 Steps Milestone!';

  @override
  String get notification10kBody =>
      'Amazing! You hit 10,000 steps today, advancing nearly 27 years through human history!';

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
}
