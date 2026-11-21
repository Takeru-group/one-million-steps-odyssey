import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'One Million Steps Odyssey'**
  String get appTitle;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Welcome to One Million Steps Odyssey'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'Embark on a journey of human history from \'1,000,000 days ago\' to today, counting 1 step as 1 day!'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Collect Artifacts'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'Discover and collect artifacts associated with stories from around the world throughout the centuries.'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Start Your Odyssey'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In en, this message translates to:
  /// **'Lace up your shoes and step into a timeless journey. Log in or sign up to begin!'**
  String get onboardingDesc3;

  /// No description provided for @btnNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get btnNext;

  /// No description provided for @btnStartAuth.
  ///
  /// In en, this message translates to:
  /// **'Log In / Sign Up'**
  String get btnStartAuth;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language / 言語変更'**
  String get changeLanguage;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get tabHistory;

  /// No description provided for @historyReached.
  ///
  /// In en, this message translates to:
  /// **'Reached {name}.'**
  String historyReached(String name);

  /// No description provided for @artifactDiscovered.
  ///
  /// In en, this message translates to:
  /// **'Discovered {name}.'**
  String artifactDiscovered(String name);

  /// No description provided for @figureMet.
  ///
  /// In en, this message translates to:
  /// **'Met {name}.'**
  String figureMet(String name);

  /// No description provided for @hintHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'How to Journey on Home'**
  String get hintHomeTitle;

  /// No description provided for @hintHomeDesc.
  ///
  /// In en, this message translates to:
  /// **'[Steps & Timeline Progression]\nYour steps advance human history from antiquity (700s BCE) toward the modern era at the rate of 1 step = approx. 1 day. Steps sync automatically in the background even when closed.\n\n[Eras & Scenery]\n• Tap the top date button to read in-depth historical context and image titles for your current era.\n• As you accumulate steps, you will advance to new eras, automatically updating the background scenery.\n• Crossing a 100-year century mark triggers a special celebration, offering store reviews on milestone centuries and interstitial ads on others.\n\n[Collecting Artifacts]\n• Bottom-Right ★ Button: After a 4-hour cooldown, watch a short video to discover an uncollected artifact from your current era.\n• Daily Step Milestones: Reaching 6,000 and 10,000 steps each day also guarantees an artifact reward.'**
  String get hintHomeDesc;

  /// No description provided for @hintHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'How to View History Collection'**
  String get hintHistoryTitle;

  /// No description provided for @hintHistoryDesc.
  ///
  /// In en, this message translates to:
  /// **'[Collection Layout]\nAll unlocked eras and discovered artifacts from your odyssey are neatly cataloged century by century.\n\n[Item Details]\n• Tap any century header to expand or collapse the item cards.\n• Tap an item to open a detailed modal showing discovery dates, full images, and rich historical stories.\n\n[History vs. Hall of Fame]\n• This History tab displays items collected during your current journey (round).\n• The Hall of Fame in the side menu provides an encyclopedia of all discoveries made across every journey.'**
  String get hintHistoryDesc;

  /// No description provided for @tabSteps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get tabSteps;

  /// No description provided for @homeDefaultDescription.
  ///
  /// In en, this message translates to:
  /// **'Around 750 BCE, maritime trade by Phoenicians flourished in the Mediterranean, while Etruscan culture began developing in the Italian Peninsula.'**
  String get homeDefaultDescription;

  /// No description provided for @historyEmptyCurrentRound.
  ///
  /// In en, this message translates to:
  /// **'No history unlocked in this round yet.'**
  String get historyEmptyCurrentRound;

  /// No description provided for @historyCenturyBce.
  ///
  /// In en, this message translates to:
  /// **'{century}th Century BCE'**
  String historyCenturyBce(int century);

  /// No description provided for @historyCenturyCe.
  ///
  /// In en, this message translates to:
  /// **'{century}th Century'**
  String historyCenturyCe(int century);

  /// Message displayed when an era is reached
  ///
  /// In en, this message translates to:
  /// **'Reached {eraLabel}'**
  String eraReachedMessage(String eraLabel);

  /// Message displayed when an artifact is discovered
  ///
  /// In en, this message translates to:
  /// **'Discovered {artifactName}'**
  String artifactDiscoveredMessage(String artifactName);

  /// No description provided for @stepsToday.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Steps: {steps}'**
  String stepsToday(int steps);

  /// No description provided for @stepsUpdatedAt.
  ///
  /// In en, this message translates to:
  /// **'Updated: {dateTime}'**
  String stepsUpdatedAt(String dateTime);

  /// No description provided for @stepsTotal.
  ///
  /// In en, this message translates to:
  /// **'Total Steps: {steps}'**
  String stepsTotal(int steps);

  /// No description provided for @stepsStartDate.
  ///
  /// In en, this message translates to:
  /// **'Started: {date}'**
  String stepsStartDate(String date);

  /// No description provided for @stepsPast7Days.
  ///
  /// In en, this message translates to:
  /// **'Past 7 Days'**
  String get stepsPast7Days;

  /// No description provided for @stepsChartTooltip.
  ///
  /// In en, this message translates to:
  /// **'{steps} steps'**
  String stepsChartTooltip(int steps);

  /// No description provided for @hintStepsTitle.
  ///
  /// In en, this message translates to:
  /// **'Step Data & Milestones'**
  String get hintStepsTitle;

  /// No description provided for @hintStepsDesc.
  ///
  /// In en, this message translates to:
  /// **'[Tracking Mechanism]\nConnected directly to device health sensors (iOS HealthKit / Android Activity Recognition) to track your daily and overall activity.\n\n[Step Metrics & Charts]\n• View your Today\'s Steps alongside your overall Total Steps from day one.\n• The interactive bar chart illustrates your activity over the past 7 days—tap any bar to inspect specific daily counts.\n\n[Milestone Rewards]\n• 6,000 Steps: Hitting this daily fitness goal awards one guaranteed artifact.\n• 10,000 Steps: Advancing nearly 27 years of history in a single day awards a second guaranteed artifact.\n* Even if synced in batches above 10,000 steps, rewards for 6,000 and 10,000 steps are processed sequentially.'**
  String get hintStepsDesc;

  /// No description provided for @historyReachedEra.
  ///
  /// In en, this message translates to:
  /// **'Reached the {eraLabel}s'**
  String historyReachedEra(Object eraLabel);

  /// No description provided for @dateBceFormat.
  ///
  /// In en, this message translates to:
  /// **'{year} BCE {month}/{day}'**
  String dateBceFormat(int year, int month, int day);

  /// No description provided for @dateCeFormat.
  ///
  /// In en, this message translates to:
  /// **'{year} CE {month}/{day}'**
  String dateCeFormat(int year, int month, int day);

  /// No description provided for @menuChangeNicknameTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Nickname'**
  String get menuChangeNicknameTitle;

  /// No description provided for @menuChangeNicknameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter new nickname'**
  String get menuChangeNicknameHint;

  /// No description provided for @menuCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get menuCancel;

  /// No description provided for @menuSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get menuSave;

  /// No description provided for @menuNicknameUpdated.
  ///
  /// In en, this message translates to:
  /// **'Nickname updated successfully.'**
  String get menuNicknameUpdated;

  /// No description provided for @menuNicknameUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update nickname: {error}'**
  String menuNicknameUpdateFailed(String error);

  /// No description provided for @menuStartPoint.
  ///
  /// In en, this message translates to:
  /// **'Start Era: {era}{year}'**
  String menuStartPoint(String era, int year);

  /// No description provided for @menuNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Not logged in'**
  String get menuNotLoggedIn;

  /// No description provided for @menuTodaySteps.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Steps'**
  String get menuTodaySteps;

  /// No description provided for @menuTotalSteps.
  ///
  /// In en, this message translates to:
  /// **'Total Steps'**
  String get menuTotalSteps;

  /// No description provided for @menuAllConquered.
  ///
  /// In en, this message translates to:
  /// **'All History Conquered! (Total Steps)'**
  String get menuAllConquered;

  /// No description provided for @menuThemeSection.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get menuThemeSection;

  /// No description provided for @menuDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get menuDarkMode;

  /// No description provided for @menuLanguageSection.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get menuLanguageSection;

  /// No description provided for @menuLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get menuLogOut;

  /// No description provided for @artifactDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Discover Artifact'**
  String get artifactDialogTitle;

  /// No description provided for @artifactDialogDesc.
  ///
  /// In en, this message translates to:
  /// **'Would you like to watch a short video to discover an artifact (technology, figure, or historical event) from the current era ({eraLabel})?'**
  String artifactDialogDesc(String eraLabel);

  /// No description provided for @artifactDialogNotice.
  ///
  /// In en, this message translates to:
  /// **'* Selected at random with equal probability from uncollected artifacts of this era.'**
  String get artifactDialogNotice;

  /// No description provided for @artifactDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get artifactDialogCancel;

  /// No description provided for @artifactDialogWatchAd.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get artifactDialogWatchAd;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to One Million Steps Odyssey!'**
  String get welcomeTitle;

  /// No description provided for @welcomeHydrationNotice.
  ///
  /// In en, this message translates to:
  /// **'Throughout the long journey of human history, proper hydration has always been essential.\nPlease stay hydrated and keep safe while walking outdoors.'**
  String get welcomeHydrationNotice;

  /// No description provided for @welcomeBackgroundTitle.
  ///
  /// In en, this message translates to:
  /// **'Automatic Background Sync'**
  String get welcomeBackgroundTitle;

  /// No description provided for @welcomeBackgroundNotice.
  ///
  /// In en, this message translates to:
  /// **'This app syncs with your health app automatically, so you don\'t need to keep it open.\nJust walk normally and open the app occasionally to explore new historical eras!'**
  String get welcomeBackgroundNotice;

  /// No description provided for @welcomeButtonStart.
  ///
  /// In en, this message translates to:
  /// **'Start Journey'**
  String get welcomeButtonStart;

  /// No description provided for @logoutDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Log Out'**
  String get logoutDialogTitle;

  /// No description provided for @logoutDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?\n\n* Please note that your steps will NOT be tracked or accumulated while logged out.'**
  String get logoutDialogMessage;

  /// No description provided for @logoutConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logoutConfirmButton;

  /// No description provided for @logoutCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get logoutCancelButton;

  /// No description provided for @notification6kTitle.
  ///
  /// In en, this message translates to:
  /// **'👟 6,000 Steps Reached!'**
  String get notification6kTitle;

  /// No description provided for @notification6kBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached your daily goal of 6,000 steps! Your journey through history progresses steadily.'**
  String get notification6kBody;

  /// No description provided for @notification10kTitle.
  ///
  /// In en, this message translates to:
  /// **'🎉 10,000 Steps Milestone!'**
  String get notification10kTitle;

  /// No description provided for @notification10kBody.
  ///
  /// In en, this message translates to:
  /// **'Amazing! You hit 10,000 steps today, advancing nearly 27 years through human history!'**
  String get notification10kBody;

  /// No description provided for @milestone6kTitle.
  ///
  /// In en, this message translates to:
  /// **'👟 6,000 Steps Milestone!'**
  String get milestone6kTitle;

  /// No description provided for @milestone6kDesc.
  ///
  /// In en, this message translates to:
  /// **'You reached 6,000 steps today!\nYou earned an artifact!'**
  String get milestone6kDesc;

  /// No description provided for @milestone10kTitle.
  ///
  /// In en, this message translates to:
  /// **'🎉 10,000 Steps Milestone!'**
  String get milestone10kTitle;

  /// No description provided for @milestone10kDesc.
  ///
  /// In en, this message translates to:
  /// **'Amazing! You reached 10,000 steps today!\nYou earned an artifact!'**
  String get milestone10kDesc;

  /// No description provided for @milestoneGetArtifact.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get milestoneGetArtifact;

  /// No description provided for @hallOfFameTitle.
  ///
  /// In en, this message translates to:
  /// **'Hall of Fame'**
  String get hallOfFameTitle;

  /// No description provided for @hallOfFameEras.
  ///
  /// In en, this message translates to:
  /// **'Eras'**
  String get hallOfFameEras;

  /// No description provided for @hallOfFameArtifacts.
  ///
  /// In en, this message translates to:
  /// **'Artifacts'**
  String get hallOfFameArtifacts;

  /// No description provided for @hallOfFameEmpty.
  ///
  /// In en, this message translates to:
  /// **'No collected items yet'**
  String get hallOfFameEmpty;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
