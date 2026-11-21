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
  /// **'Every real-world step counts as 1 day in the app! Embark on a journey through human history from 1,000,000 days ago to today!'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Collect Artifacts'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'1,000,000 steps—1,000,000 days—span across many centuries. Collect artifacts from each era you visit along the way.'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Start Your Odyssey'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In en, this message translates to:
  /// **'Once you start, all you have to do is walk. Check the app from time to time to see which era you\'ve reached! Log in or sign up to begin.'**
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
  /// **'[Steps & Timeline Progression]\nWith every step counting as 1 day in the app, your journey advances from ancient times—1,000,000 days before the date you started the app—toward the modern era.\nSteps sync automatically in the background even when the app is closed.\n\n[Eras & Scenery]\n• Tap the top date button to read in-depth historical context and image titles for your current era.\n• Every 10 years, you reach a new era and the background scenery automatically updates.\n• Centuries advance every 100 years. At milestone centuries, an in-app review prompt or an ad may appear.\n\n[Collecting Artifacts]\n• Bottom-Right ★ Button: Watch a short video ad to discover an uncollected artifact (technology, historical figure, or event) from your current era (available roughly once every 4 hours).\n• Daily Step Milestones: You also earn an artifact when you walk 6,000+ and 10,000+ steps in a day and open the app on that same day.'**
  String get hintHomeDesc;

  /// No description provided for @hintHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'How to View History'**
  String get hintHistoryTitle;

  /// No description provided for @hintHistoryDesc.
  ///
  /// In en, this message translates to:
  /// **'[Eras & Artifacts]\nThe \"Eras\" you have reached and the \"Artifacts\" you have discovered during your journey are organized and recorded century by century.\n\n[Viewing Details]\n• Tap each century panel to expand and view the list of items.\n• Tap any item to view its details.\n\n[Difference from Hall of Fame]\n• This app supports multiple playthroughs (rounds). This History screen displays only the \"Eras\" and \"Artifacts\" unlocked in your current round.\n• The \"Hall of Fame\" in the side menu displays all \"Eras\" and \"Artifacts\" collected across all your rounds so far.'**
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
  /// **'How to View Steps'**
  String get hintStepsTitle;

  /// No description provided for @hintStepsDesc.
  ///
  /// In en, this message translates to:
  /// **'[Step Tracking]\nConnects with your device\'s health app to retrieve and record your step counts for today and the past 7 days in real time.\n\n[Step Summary & Trends]\n• \"Today\'s Steps\" and \"Total Steps\" since your start date are displayed at the top.\n• The bar chart below shows your progress over the past 7 days—tap any bar to view the exact step count in a pop-up.\n\n[Step Rewards]\n• Reaching 6,000 & 10,000 Steps: You earn 1 artifact from your current century for each milestone achieved.'**
  String get hintStepsDesc;

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

  /// No description provided for @menuNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Not logged in'**
  String get menuNotLoggedIn;

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
  /// **'Would you like to watch a short video to discover an artifact (technology, figure, or historical event) from the current century ({eraLabel})?'**
  String artifactDialogDesc(String eraLabel);

  /// No description provided for @artifactDialogNotice.
  ///
  /// In en, this message translates to:
  /// **'* Selected at random with equal probability from uncollected artifacts of this century.'**
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
  /// **'When walking outdoors, please stay well hydrated and keep safe on your journey.\nPlease refrain from looking at the app while walking.'**
  String get welcomeHydrationNotice;

  /// No description provided for @welcomeBackgroundTitle.
  ///
  /// In en, this message translates to:
  /// **'Background Sync'**
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
  /// **'You reached 6,000 steps today! Open the app to check your progress!'**
  String get notification6kBody;

  /// No description provided for @notification10kTitle.
  ///
  /// In en, this message translates to:
  /// **'🎉 10,000 Steps Reached!'**
  String get notification10kTitle;

  /// No description provided for @notification10kBody.
  ///
  /// In en, this message translates to:
  /// **'You reached 10,000 steps today! Open the app to check your progress!'**
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

  /// No description provided for @menuRoundCount.
  ///
  /// In en, this message translates to:
  /// **'Round: {count}'**
  String menuRoundCount(int count);

  /// No description provided for @menuStartDate.
  ///
  /// In en, this message translates to:
  /// **'Started: {date}'**
  String menuStartDate(String date);

  /// No description provided for @menuInquiry.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get menuInquiry;

  /// No description provided for @menuTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get menuTermsOfService;

  /// No description provided for @menuPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get menuPrivacyPolicy;

  /// No description provided for @menuOssLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open Source Licenses'**
  String get menuOssLicenses;

  /// No description provided for @menuDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get menuDeleteAccount;

  /// No description provided for @deleteAccountDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountDialogTitle;

  /// No description provided for @deleteAccountDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Deleting your account will permanently erase all your step history, unlocked eras, and collected artifacts. This action cannot be undone.\n\nTo continue, please type \"delete\" below.'**
  String get deleteAccountDialogMessage;

  /// No description provided for @deleteAccountConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAccountConfirmButton;

  /// No description provided for @deleteAccountFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete account (re-authentication may be required): {error}'**
  String deleteAccountFailed(String error);

  /// No description provided for @logoutFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to log out: {error}'**
  String logoutFailed(String error);

  /// No description provided for @urlOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the page.'**
  String get urlOpenFailed;

  /// No description provided for @artifactRewardTitle.
  ///
  /// In en, this message translates to:
  /// **'Artifact Discovered!'**
  String get artifactRewardTitle;

  /// No description provided for @btnClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get btnClose;

  /// No description provided for @centuryEnteredTitle.
  ///
  /// In en, this message translates to:
  /// **'Entered the {century}!'**
  String centuryEnteredTitle(String century);

  /// No description provided for @eraEnteredTitle.
  ///
  /// In en, this message translates to:
  /// **'Entered a New Era!'**
  String get eraEnteredTitle;

  /// No description provided for @centuryEnteredDesc.
  ///
  /// In en, this message translates to:
  /// **'You have reached a new era ({eraLabel}s) and entered the {century}!\nBackground scenery and historical info have been updated.'**
  String centuryEnteredDesc(String eraLabel, String century);

  /// No description provided for @eraEnteredDesc.
  ///
  /// In en, this message translates to:
  /// **'You have reached a new era ({eraLabel}s)!\nBackground scenery and historical info have been updated.'**
  String eraEnteredDesc(String eraLabel);

  /// No description provided for @btnContinueJourney.
  ///
  /// In en, this message translates to:
  /// **'Continue Journey'**
  String get btnContinueJourney;

  /// No description provided for @endingAchievedTitle.
  ///
  /// In en, this message translates to:
  /// **'1,000,000 Steps Achieved!'**
  String get endingAchievedTitle;

  /// No description provided for @endingAchievedDesc.
  ///
  /// In en, this message translates to:
  /// **'You have walked through 2,700 years of human history and reached the present day.\n\nWould you like to start a new adventure?'**
  String get endingAchievedDesc;

  /// No description provided for @btnLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get btnLater;

  /// No description provided for @btnStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get btnStart;

  /// No description provided for @endingMainTitle.
  ///
  /// In en, this message translates to:
  /// **'ONE MILLION STEPS ODYSSEY'**
  String get endingMainTitle;

  /// No description provided for @endingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A Chronicle of Your 1,000,000 Steps'**
  String get endingSubtitle;

  /// No description provided for @endingEmptyFallback.
  ///
  /// In en, this message translates to:
  /// **'Your journey has reached the modern era.'**
  String get endingEmptyFallback;

  /// No description provided for @endingFinaleTitle.
  ///
  /// In en, this message translates to:
  /// **'THANK YOU FOR WALKING'**
  String get endingFinaleTitle;

  /// No description provided for @endingFinaleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Every step you took carved a new page in history.'**
  String get endingFinaleSubtitle;

  /// No description provided for @endingFastForward.
  ///
  /// In en, this message translates to:
  /// **'Fast Forward'**
  String get endingFastForward;

  /// No description provided for @endingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get endingSkip;

  /// No description provided for @artifactAllCollected.
  ///
  /// In en, this message translates to:
  /// **'You have already collected all artifacts from this century!'**
  String get artifactAllCollected;

  /// No description provided for @hintTooltip.
  ///
  /// In en, this message translates to:
  /// **'View Hint'**
  String get hintTooltip;

  /// No description provided for @adNotReady.
  ///
  /// In en, this message translates to:
  /// **'Ad is not ready yet.'**
  String get adNotReady;

  /// No description provided for @legalLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load document.'**
  String get legalLoadFailed;

  /// No description provided for @hallOfFameCenturyCe.
  ///
  /// In en, this message translates to:
  /// **'{century}th Century'**
  String hallOfFameCenturyCe(int century);
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
