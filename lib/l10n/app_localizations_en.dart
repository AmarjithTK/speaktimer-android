// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Lifer';

  @override
  String get helpTitle => 'Help / Working';

  @override
  String get timerTab => 'Timer';

  @override
  String get clockTab => 'Clock';

  @override
  String get settingsTab => 'Settings';

  @override
  String get presetTab => 'Presets';

  @override
  String get startButton => 'Start';

  @override
  String get pauseButton => 'Pause';

  @override
  String get resumeButton => 'Resume';

  @override
  String get stopButton => 'Stop';

  @override
  String get resetButton => 'Reset';

  @override
  String get skipButton => 'Skip';

  @override
  String get addTimeButton => 'Add Time';

  @override
  String get chainModeLabel => 'Chain Mode';

  @override
  String get chainModeDescription => 'Run preset timers in sequence';

  @override
  String get timerNotificationTitle => 'Timer Running';

  @override
  String get clockNotificationTitle => 'Time Check';

  @override
  String get focusMode => 'Focus Mode';

  @override
  String get fullscreenMode => 'Fullscreen';

  @override
  String get soundLabel => 'Background Sound';

  @override
  String get volumeLabel => 'Volume';

  @override
  String get voiceLabel => 'Voice Selection';

  @override
  String get darkThemeLabel => 'Dark Theme';

  @override
  String get motivationLabel => 'Show Motivation';

  @override
  String get motivationCategoryLabel => 'Motivation Category';

  @override
  String get motivationDelayLabel => 'Quote Delay (seconds)';

  @override
  String get clockIntervalLabel => 'Clock Interval (minutes)';

  @override
  String get timerAnnouncementLabel => 'Announce Every (minutes)';

  @override
  String get nightMuteMode => 'Night Mute Mode';

  @override
  String get sleepStartLabel => 'Sleep Start Time';

  @override
  String get sleepEndLabel => 'Sleep End Time';

  @override
  String get longPressToDone => 'Long press timer to mark done';

  @override
  String get sessionCompleted => 'Session Completed!';

  @override
  String get motivationQuote => 'Motivation';
}
