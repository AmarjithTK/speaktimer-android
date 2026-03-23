import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ml.dart';

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
    Locale('ml'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Lifer'**
  String get appTitle;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'Help / Working'**
  String get helpTitle;

  /// No description provided for @timerTab.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get timerTab;

  /// No description provided for @clockTab.
  ///
  /// In en, this message translates to:
  /// **'Clock'**
  String get clockTab;

  /// No description provided for @settingsTab.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTab;

  /// No description provided for @presetTab.
  ///
  /// In en, this message translates to:
  /// **'Presets'**
  String get presetTab;

  /// No description provided for @startButton.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startButton;

  /// No description provided for @pauseButton.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pauseButton;

  /// No description provided for @resumeButton.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resumeButton;

  /// No description provided for @stopButton.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopButton;

  /// No description provided for @resetButton.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetButton;

  /// No description provided for @skipButton.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipButton;

  /// No description provided for @addTimeButton.
  ///
  /// In en, this message translates to:
  /// **'Add Time'**
  String get addTimeButton;

  /// No description provided for @chainModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Chain Mode'**
  String get chainModeLabel;

  /// No description provided for @chainModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Run preset timers in sequence'**
  String get chainModeDescription;

  /// No description provided for @timerNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Timer Running'**
  String get timerNotificationTitle;

  /// No description provided for @clockNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Time Check'**
  String get clockNotificationTitle;

  /// No description provided for @focusMode.
  ///
  /// In en, this message translates to:
  /// **'Focus Mode'**
  String get focusMode;

  /// No description provided for @fullscreenMode.
  ///
  /// In en, this message translates to:
  /// **'Fullscreen'**
  String get fullscreenMode;

  /// No description provided for @soundLabel.
  ///
  /// In en, this message translates to:
  /// **'Background Sound'**
  String get soundLabel;

  /// No description provided for @volumeLabel.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volumeLabel;

  /// No description provided for @voiceLabel.
  ///
  /// In en, this message translates to:
  /// **'Voice Selection'**
  String get voiceLabel;

  /// No description provided for @darkThemeLabel.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get darkThemeLabel;

  /// No description provided for @motivationLabel.
  ///
  /// In en, this message translates to:
  /// **'Show Motivation'**
  String get motivationLabel;

  /// No description provided for @motivationCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Motivation Category'**
  String get motivationCategoryLabel;

  /// No description provided for @motivationDelayLabel.
  ///
  /// In en, this message translates to:
  /// **'Quote Delay (seconds)'**
  String get motivationDelayLabel;

  /// No description provided for @clockIntervalLabel.
  ///
  /// In en, this message translates to:
  /// **'Clock Interval (minutes)'**
  String get clockIntervalLabel;

  /// No description provided for @timerAnnouncementLabel.
  ///
  /// In en, this message translates to:
  /// **'Announce Every (minutes)'**
  String get timerAnnouncementLabel;

  /// No description provided for @nightMuteMode.
  ///
  /// In en, this message translates to:
  /// **'Night Mute Mode'**
  String get nightMuteMode;

  /// No description provided for @sleepStartLabel.
  ///
  /// In en, this message translates to:
  /// **'Sleep Start Time'**
  String get sleepStartLabel;

  /// No description provided for @sleepEndLabel.
  ///
  /// In en, this message translates to:
  /// **'Sleep End Time'**
  String get sleepEndLabel;

  /// No description provided for @longPressToDone.
  ///
  /// In en, this message translates to:
  /// **'Long press timer to mark done'**
  String get longPressToDone;

  /// No description provided for @sessionCompleted.
  ///
  /// In en, this message translates to:
  /// **'Session Completed!'**
  String get sessionCompleted;

  /// No description provided for @motivationQuote.
  ///
  /// In en, this message translates to:
  /// **'Motivation'**
  String get motivationQuote;
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
      <String>['en', 'ml'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ml':
      return AppLocalizationsMl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
