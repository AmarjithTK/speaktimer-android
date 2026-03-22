import 'dart:async';
import 'dart:math';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme/palette.dart';
import 'models/app_settings.dart';
import 'models/foreground_notification_state.dart';
import 'models/speech_item.dart';
import 'models/sound_option.dart';
import 'services/audio_service.dart';
import 'services/foreground_notification_service.dart';
import 'services/malayalam_tts_service.dart';
import 'services/settings_service.dart';
import 'services/speech_service.dart';
import 'services/timer_service.dart';
import 'core/pref_keys.dart';
import 'widgets/clock_panel.dart';
import 'widgets/fullscreen_focus_view.dart';
import 'widgets/timer_panel.dart';
import 'widgets/presets_panel.dart';
import 'widgets/settings_panel.dart';
import 'widgets/help_panel.dart';

final ValueNotifier<ThemeMode> appThemeModeNotifier = ValueNotifier(
  ThemeMode.light,
);

void setAppThemeMode(bool isDark) {
  appThemeModeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  setPaletteDarkMode(isDark);
}

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(DateTime timestamp, bool isForceRequest) async {}

  @override
  void onNotificationButtonPressed(String id) {
    FlutterForegroundTask.sendDataToMain(id);
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterForegroundTask.initCommunicationPort();
  runApp(const LiferApp());
}

class LiferApp extends StatelessWidget {
  const LiferApp({super.key});

  @override
  Widget build(BuildContext context) {
    return WithForegroundTask(
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: appThemeModeNotifier,
        builder: (context, themeMode, _) => MaterialApp(
          title: 'lifer',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4F46E5),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            textTheme: GoogleFonts.interTextTheme(),
            appBarTheme: AppBarTheme(
              centerTitle: false,
              titleTextStyle: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                textStyle: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4F46E5),
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
            appBarTheme: AppBarTheme(
              centerTitle: false,
              titleTextStyle: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                textStyle: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
          home: const MainScreen(),
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  final QuickActions _quickActions = const QuickActions();
  final AudioService _audioService = AudioService();
  final SettingsService _settingsService = SettingsService();
  final SpeechService _speechService = SpeechService();
  final MalayalamTtsService _malayalamTtsService = MalayalamTtsService();
  final TimerService _timerService = TimerService();
  final ForegroundNotificationService _foregroundNotificationService =
      const ForegroundNotificationService(
        notificationIconMetaDataName:
            'com.example.speakertimer.service.NOTIFICATION_ICON',
      );

  // TTS & Speech Queue
  FlutterTts flutterTts = FlutterTts();
  List<SpeechItem> speechQueue = [];
  bool isSpeechActive = false;
  List<Map<dynamic, dynamic>> voices = [];
  int voiceIndex = 0;
  String voiceListMode = 'pleasant';
  String? favoriteVoiceName;
  String? favoriteVoiceLocale;

  bool audioPlaying = false;

  // Timer State
  int sliderValue = 25;
  int seconds = 0;
  Timer? timerInterval;
  String timerValue = "00:00";

  // Clock State
  Timer? clockTimer;
  Timer? displayTick;
  String currentTimeDisplay = "";
  int lastNotificationSyncMs = 0;
  int currentTabIndex = 0;

  // 10s Gap enforcement
  int lastClockSpoke = 0;
  int lastTimerSpoke = 0;

  // Prefs state variables
  String soundChosen = "audio/rain.mp3";
  double noiseVolume = 0.6;
  double speakVolume = 0.8;
  bool clockOn = false;
  int clockIntervalMins = 30;
  bool motivationOn = true;
  String motivationCategory = 'General';
  int motivationDelaySeconds = 10;
  bool timerNoiseOn = true;
  bool appDarkTheme = false;
  bool muteSpeechAfterMidnight = false;
  String nightMuteMode = 'manual';
  int sleepStartMinutes = 0;
  int sleepEndMinutes = 360;
  bool autoNightMuteActive = false;
  Timer? nightIdleTimer;
  Timer? nightResumeSpeechTimer;
  Timer? speechStateSyncTimer;
  bool fullscreenDarkTheme = true;
  bool fullscreenDimBrightness = false;
  bool fullscreenStartLandscape = false;
  bool timerSpeakOn = true;
  int timerAnnounceEvery = 1;
  bool chainModeOn = false;
  String chainPresetKey = 'Pomodoro 25-5x4';
  int chainIndex = 0;

  final Map<String, List<int>> chainPresets = {
    'Pomodoro 25-5x4': [25, 5, 25, 5, 25, 5, 25, 15],
    'Sprint 50-10x2': [50, 10, 50, 10],
    'Quick 15-3x3': [15, 3, 15, 3, 15, 3],
  };

  final String notifySound = "audio/notify.mp3";
  final List<SoundOption> soundList = [
    SoundOption("audio/rain.mp3", "Rain"),
    SoundOption("audio/waterfall.mp3", "Waterfall"),
    SoundOption("audio/fire.mp3", "Fire"),
    SoundOption("audio/stream.mp3", "Stream"),
  ];

  final List<double> volumeLists = [0.1, 0.2, 0.6, 0.8, 1.0];
  final List<int> presetValues = [5, 10, 15, 20, 25, 30, 45, 60, 90, 120];
  final List<int> clockIntervalOptions = [1, 2, 5, 10, 15, 20, 30, 60];
  final List<int> timerAnnounceOptions = [1, 2, 5, 10, 15, 20, 30];
  final List<int> motivationDelayOptions = [5, 10, 20, 30, 40, 60];
  final List<String> motivationCategories = const [
    'General',
    'Focus',
    'Discipline',
    'Calm',
    'Positivity',
    'Historic Figures',
  ];
  static const String _lastTimerSecondsKey = 'QuickActionLastSeconds';

  final Map<String, List<String>> quotesByCategory = {
    'General': [
      "Use this moment well — it won't come back.",
      "Small steps every hour build the life you want.",
      "Time is the only resource you cannot earn back.",
      "Progress, not perfection, is what time rewards.",
      "Your work right now is compounding silently.",
    ],
    'Focus': [
      "Your attention is your most valuable currency.",
      "An hour of deep work is worth a day of distraction.",
      "One focused hour can change a whole day.",
      "Clarity comes to those who use their time with intention.",
      "Focused effort now creates freedom later.",
    ],
    'Discipline': [
      "Discipline is choosing what you want most over what you want now.",
      "Greatness is built minute by minute.",
      "The best time to start was yesterday. The second best is now.",
      "Consistency over time is unstoppable.",
      "Stay the course. The results are coming.",
    ],
    'Calm': [
      "Be present. This hour is a gift.",
      "Breathe, focus, and make this moment count.",
      "Each hour is a fresh canvas. Paint it well.",
      "You have enough time for what truly matters.",
      "Let this hour be better than the last.",
    ],
    'Positivity': [
      "What you do right now shapes who you become.",
      "Your future self will thank you for the work you do now.",
      "Do something today that your future self will be proud of.",
      "Momentum is built one intentional moment at a time.",
      "A year from now you'll wish you had started today.",
    ],
    'Historic Figures': [
      "Aristotle said: We are what we repeatedly do. Excellence, then, is a habit.",
      "Leonardo da Vinci said: Time stays long enough for anyone who will use it.",
      "Benjamin Franklin said: Lost time is never found again.",
      "Maya Angelou said: Nothing will work unless you do.",
      "Bruce Lee said: The successful warrior is the average person, with laser-like focus.",
    ],
  };
  final Map<String, int> quoteIndexByCategory = {};

  Future<void> _requestPermissions() async {
    if (await FlutterForegroundTask.isIgnoringBatteryOptimizations == false) {
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }
    final NotificationPermission status =
        await FlutterForegroundTask.checkNotificationPermission();
    if (status != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
  }

  void _initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'speaktimer_fg',
        channelName: 'Speak Timer',
        channelDescription: 'Keeps timer alive in background',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(1000),
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  String _formatCurrentTime(DateTime now) {
    return _timerService.formatCurrentTime(now);
  }

  ForegroundNotificationState _foregroundState() {
    final idleTime = currentTimeDisplay.isNotEmpty
        ? currentTimeDisplay
        : _formatCurrentTime(DateTime.now());

    return ForegroundNotificationState(
      isTimerRunning: timerInterval != null,
      timerValue: timerValue,
      currentTimeDisplay: idleTime,
      clockSpeechOn: clockOn,
    );
  }

  Future<void> _syncForegroundNotification({bool force = false}) async {
    lastNotificationSyncMs = await _foregroundNotificationService.sync(
      state: _foregroundState(),
      lastSyncMs: lastNotificationSyncMs,
      force: force,
    );
  }

  Future<void> _ensureForegroundServiceRunning() async {
    await _foregroundNotificationService.ensureRunning(
      state: _foregroundState(),
      callback: startCallback,
    );
  }

  Future<void> _initializeForegroundNotification() async {
    await _requestPermissions();
    await _ensureForegroundServiceRunning();
  }

  Future<void> _saveLastTimerSeconds(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastTimerSecondsKey, value);
  }

  void _startSpeechStateSync() {
    speechStateSyncTimer?.cancel();
    speechStateSyncTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      unawaited(_syncExternalWidgetControls());
    });
  }

  Future<void> _syncExternalWidgetControls() async {
    await _syncTimerSpeakFromPrefs();
    await _consumeWidgetCommandFromPrefs();
    await _publishWidgetStateToPrefs();
  }

  Future<void> _consumeWidgetCommandFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final command = prefs.getString(PrefKeys.widgetCommand);
    if (command == null || command.isEmpty || !mounted) return;

    await prefs.remove(PrefKeys.widgetCommand);

    switch (command) {
      case 'toggle_speech':
        setState(() {
          timerSpeakOn = !timerSpeakOn;
          if (!timerSpeakOn) {
            speechQueue.clear();
          }
          _lsSave();
        });
        break;
      case 'timer_toggle':
        if (timerInterval != null) {
          stopTimer();
        } else {
          startTimer();
        }
        break;
      case 'start_25m':
        setState(() {
          currentTabIndex = 1;
          chainModeOn = false;
          seconds = 25 * 60;
          timerValue = '25:00';
        });
        startTimer();
        break;
      case 'resume_last':
        final last = await _readLastTimerSeconds();
        if (!mounted) return;
        setState(() {
          currentTabIndex = 1;
          seconds = last;
          final mins = (last ~/ 60).toString().padLeft(2, '0');
          final secs = (last % 60).toString().padLeft(2, '0');
          timerValue = '$mins:$secs';
        });
        startTimer();
        break;
      default:
        break;
    }
  }

  Future<void> _publishWidgetStateToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefKeys.widgetSpeechOn, timerSpeakOn);
    await prefs.setBool(PrefKeys.widgetTimerRunning, timerInterval != null);
    await prefs.setString(PrefKeys.widgetTimerValue, timerValue);

    final nightStatus = () {
      if (!muteSpeechAfterMidnight) return 'Off';
      if (nightMuteMode == 'manual') return 'Manual';
      return autoNightMuteActive ? 'Auto (Muted)' : 'Auto (Armed)';
    }();
    await prefs.setString(PrefKeys.widgetNightStatus, nightStatus);
  }

  String _formatMinutesAs12Hour(int totalMinutes) {
    final normalized = totalMinutes % (24 * 60);
    final hour = normalized ~/ 60;
    final minute = normalized % 60;
    final ampm = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$hour12:$minuteStr $ampm';
  }

  Future<void> _pickSleepStartTime() async {
    final initial = TimeOfDay(
      hour: sleepStartMinutes ~/ 60,
      minute: sleepStartMinutes % 60,
    );
    final selected = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (selected == null) return;

    setState(() {
      sleepStartMinutes = selected.hour * 60 + selected.minute;
      _lsSave();
      if (_isSpeechMutedForSleep()) {
        speechQueue.clear();
      }
    });
    unawaited(_publishWidgetStateToPrefs());
  }

  Future<void> _pickSleepEndTime() async {
    final initial = TimeOfDay(
      hour: sleepEndMinutes ~/ 60,
      minute: sleepEndMinutes % 60,
    );
    final selected = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (selected == null) return;

    setState(() {
      sleepEndMinutes = selected.hour * 60 + selected.minute;
      _lsSave();
      if (_isSpeechMutedForSleep()) {
        speechQueue.clear();
      }
    });
    unawaited(_publishWidgetStateToPrefs());
  }

  Future<void> _syncTimerSpeakFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final externalTimerSpeak = prefs.getBool(PrefKeys.timerSpeakOn);
    if (externalTimerSpeak == null || !mounted) return;
    if (externalTimerSpeak == timerSpeakOn) return;

    setState(() {
      timerSpeakOn = externalTimerSpeak;
      if (!timerSpeakOn) {
        speechQueue.clear();
      }
    });
  }

  Future<int> _readLastTimerSeconds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lastTimerSecondsKey) ?? (sliderValue * 60);
  }

  Future<void> _handleQuickAction(String type) async {
    if (!mounted) return;
    switch (type) {
      case 'start_25m':
        setState(() {
          currentTabIndex = 1;
          chainModeOn = false;
          seconds = 25 * 60;
          timerValue = '25:00';
        });
        startTimer();
        break;
      case 'resume_last':
        final last = await _readLastTimerSeconds();
        if (!mounted) return;
        setState(() {
          currentTabIndex = 1;
          seconds = last;
          final mins = (last ~/ 60).toString().padLeft(2, '0');
          final secs = (last % 60).toString().padLeft(2, '0');
          timerValue = '$mins:$secs';
        });
        startTimer();
        break;
      case 'toggle_speech':
        setState(() {
          timerSpeakOn = !timerSpeakOn;
          _lsSave();
        });
        _syncForegroundNotification(force: true);
        break;
    }
  }

  void _initQuickActions() {
    _quickActions.initialize((type) {
      unawaited(_handleQuickAction(type));
    });

    _quickActions.setShortcutItems(<ShortcutItem>[
      const ShortcutItem(
        type: 'start_25m',
        localizedTitle: 'Start 25m',
        icon: 'icon_start',
      ),
      const ShortcutItem(
        type: 'resume_last',
        localizedTitle: 'Resume Last',
        icon: 'icon_resume',
      ),
      const ShortcutItem(
        type: 'toggle_speech',
        localizedTitle: 'Toggle Speech',
        icon: 'icon_speech',
      ),
    ]);
  }

  Future<void> _openFullscreenFocus() async {
    final startInTimer = timerInterval != null || currentTabIndex == 1;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullscreenFocusView(
          startInTimerMode: startInTimer,
          initialDarkTheme: fullscreenDarkTheme,
          initialDimBrightness: fullscreenDimBrightness,
          initialForceLandscape: fullscreenStartLandscape,
          onThemeChanged: (isDark) {
            if (!mounted) return;
            setState(() {
              fullscreenDarkTheme = isDark;
              _lsSave();
            });
          },
          onDimBrightnessChanged: (isDimmed) {
            if (!mounted) return;
            setState(() {
              fullscreenDimBrightness = isDimmed;
              _lsSave();
            });
          },
          onForceLandscapeChanged: (isLandscape) {
            if (!mounted) return;
            setState(() {
              fullscreenStartLandscape = isLandscape;
              _lsSave();
            });
          },
          clockTextBuilder: () => currentTimeDisplay,
          timerTextBuilder: () => timerValue,
          isTimerRunningBuilder: () => timerInterval != null,
        ),
      ),
    );
    await SystemChrome.setPreferredOrientations([]);
  }

  Future<void> _exitAppFully() async {
    try {
      stopClock();
      stopTimer();
      speechQueue.clear();
      await flutterTts.stop();
      await _audioService.stopBackground();
      await FlutterForegroundTask.stopService();
    } catch (_) {}

    if (!mounted) return;

    if (Platform.isAndroid || Platform.isIOS) {
      await SystemNavigator.pop();
      return;
    }
    exit(0);
  }

  void _onReceiveTaskData(Object data) {
    if (data is String) {
      switch (data) {
        case 'btn_timer_toggle':
          if (timerInterval != null) {
            stopTimer();
          } else {
            startTimer();
          }
          break;
        case 'btn_clock_speech':
          setState(() {
            clockOn = !clockOn;
            _lsSave();
            if (clockOn) {
              startClock();
            } else {
              stopClock();
            }
          });
          _syncForegroundNotification(force: true);
          break;
        case 'btn_exit':
          unawaited(_exitAppFully());
          break;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(SystemChrome.setPreferredOrientations([]));
    _initForegroundTask();
    _initPrefs();
    _initAudio();
    _initTts();
    _initializeForegroundNotification();
    _initQuickActions();
    _startSpeechStateSync();

    // Add callback to handle notification button presses
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);

    displayTick = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      final now = DateTime.now();
      final display = _formatCurrentTime(now);
      if (mounted) {
        setState(() {
          currentTimeDisplay = display;
        });
      }

      if (timerInterval == null) {
        _syncForegroundNotification();
      }
    });
  }

  Future<void> _initPrefs() async {
    final settings = await _settingsService.load(
      defaultSound: soundList.first.link,
    );
    setState(() {
      soundChosen = settings.soundChosen;
      noiseVolume = settings.noiseVolume;
      speakVolume = settings.speakVolume;
      clockOn = settings.clockOn;
      clockIntervalMins = settings.clockIntervalMins;
      motivationOn = settings.motivationOn;
      motivationCategory = settings.motivationCategory;
      motivationDelaySeconds = settings.motivationDelaySeconds;
      timerSpeakOn = settings.timerSpeakOn;
      timerAnnounceEvery = settings.timerAnnounceEvery;
      timerNoiseOn = settings.timerNoiseOn;
      appDarkTheme = settings.appDarkTheme;
      muteSpeechAfterMidnight = settings.muteSpeechAfterMidnight;
      nightMuteMode = settings.nightMuteMode;
      sleepStartMinutes = settings.sleepStartMinutes;
      sleepEndMinutes = settings.sleepEndMinutes;
      fullscreenDarkTheme = settings.fullscreenDarkTheme;
      fullscreenDimBrightness = settings.fullscreenDimBrightness;
      fullscreenStartLandscape = settings.fullscreenStartLandscape;
      voiceListMode = settings.voiceListMode;
      favoriteVoiceName = settings.favoriteVoiceName;
      favoriteVoiceLocale = settings.favoriteVoiceLocale;

      if (!motivationCategories.contains(motivationCategory)) {
        motivationCategory = 'General';
      }
      if (!motivationDelayOptions.contains(motivationDelaySeconds)) {
        motivationDelaySeconds = 10;
      }
      if (nightMuteMode != 'manual' && nightMuteMode != 'automatic') {
        nightMuteMode = 'manual';
      }
      sleepStartMinutes = sleepStartMinutes.clamp(0, 1439);
      sleepEndMinutes = sleepEndMinutes.clamp(0, 1439);
    });

    _applyAudioSettings();
    setAppThemeMode(appDarkTheme);
    if (clockOn) {
      Future.delayed(const Duration(milliseconds: 200), startClock);
    }
  }

  AppSettings _currentSettingsSnapshot() {
    return AppSettings(
      soundChosen: soundChosen,
      noiseVolume: noiseVolume,
      speakVolume: speakVolume,
      clockOn: clockOn,
      clockIntervalMins: clockIntervalMins,
      motivationOn: motivationOn,
      motivationCategory: motivationCategory,
      motivationDelaySeconds: motivationDelaySeconds,
      timerSpeakOn: timerSpeakOn,
      timerAnnounceEvery: timerAnnounceEvery,
      timerNoiseOn: timerNoiseOn,
      appDarkTheme: appDarkTheme,
      muteSpeechAfterMidnight: muteSpeechAfterMidnight,
      nightMuteMode: nightMuteMode,
      sleepStartMinutes: sleepStartMinutes,
      sleepEndMinutes: sleepEndMinutes,
      fullscreenDarkTheme: fullscreenDarkTheme,
      fullscreenDimBrightness: fullscreenDimBrightness,
      fullscreenStartLandscape: fullscreenStartLandscape,
      voiceListMode: voiceListMode,
      favoriteVoiceName: favoriteVoiceName,
      favoriteVoiceLocale: favoriteVoiceLocale,
    );
  }

  void _lsSave() {
    unawaited(_settingsService.save(_currentSettingsSnapshot()));
  }

  void _initAudio() {
    unawaited(_audioService.init());
  }

  void _applyAudioSettings() {
    if (audioPlaying && timerNoiseOn) {
      unawaited(
        _audioService.applyBackground(
          shouldPlay: true,
          assetPath: soundChosen,
          volume: noiseVolume,
        ),
      );
    } else {
      unawaited(_audioService.stopBackground());
    }
  }

  Future<void> _initTts() async {
    final v = await flutterTts.getVoices;
    if (v != null) {
      final loadedVoices = _speechService.parseSupportedVoices(v);
      if (mounted) {
        setState(() {
          voices = loadedVoices;
        });
      } else {
        voices = loadedVoices;
      }
    }
    await flutterTts.awaitSpeakCompletion(true);
  }

  List<Map<dynamic, dynamic>> _availableVoicesForSettings() {
    return _speechService.availableVoicesForSettings(
      voices: voices,
      voiceListMode: voiceListMode,
    );
  }

  Map<dynamic, dynamic>? getPreferredVoice() {
    return _speechService.preferredVoice(
      voices: voices,
      voiceListMode: voiceListMode,
      favoriteVoiceName: favoriteVoiceName,
      favoriteVoiceLocale: favoriteVoiceLocale,
    );
  }

  bool _isMalayalamActive(Map<dynamic, dynamic>? preferredVoice) {
    return _malayalamTtsService.isMalayalamMode(
      voiceListMode: voiceListMode,
      preferredVoice: preferredVoice,
    );
  }

  Future<void> drainQueue() async {
    if (_isSpeechMutedForSleep()) {
      speechQueue.clear();
      if (isSpeechActive && mounted) {
        setState(() {
          isSpeechActive = false;
        });
      }
      return;
    }

    if (isSpeechActive || speechQueue.isEmpty) return;
    setState(() {
      isSpeechActive = true;
    });

    final item = speechQueue.removeAt(0);

    if (item.delayMs > 0) {
      await Future.delayed(Duration(milliseconds: item.delayMs));
    }

    final pv = getPreferredVoice();
    final useMalayalam = _isMalayalamActive(pv);
    await _speechService.speakItem(
      flutterTts: flutterTts,
      item: item,
      speakVolume: speakVolume,
      preferredVoice: pv,
      useMalayalamNuance: useMalayalam,
    );

    // Done speaking
    setState(() {
      isSpeechActive = false;
    });
    drainQueue();
  }

  void speak(String text) {
    if (_isSpeechMutedForSleep()) {
      speechQueue.clear();
      return;
    }
    speechQueue.add(SpeechItem(text));
    drainQueue();
  }

  bool _isNightTime() {
    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;

    if (sleepStartMinutes == sleepEndMinutes) {
      return false;
    }

    if (sleepStartMinutes < sleepEndMinutes) {
      return nowMinutes >= sleepStartMinutes && nowMinutes < sleepEndMinutes;
    }

    return nowMinutes >= sleepStartMinutes || nowMinutes < sleepEndMinutes;
  }

  void _cancelNightIdleTimer() {
    nightIdleTimer?.cancel();
    nightIdleTimer = null;
  }

  void _startNightIdleTimerIfNeeded() {
    _cancelNightIdleTimer();
    if (!muteSpeechAfterMidnight ||
        nightMuteMode != 'automatic' ||
        !_isNightTime()) {
      return;
    }

    nightIdleTimer = Timer(const Duration(minutes: 5), () {
      autoNightMuteActive = true;
      speechQueue.clear();
    });
  }

  void _scheduleNightResumeAnnouncement() {
    nightResumeSpeechTimer?.cancel();
    if (!muteSpeechAfterMidnight ||
        nightMuteMode != 'automatic' ||
        !_isNightTime()) {
      return;
    }

    nightResumeSpeechTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      if (!muteSpeechAfterMidnight ||
          nightMuteMode != 'automatic' ||
          !_isNightTime()) {
        return;
      }
      final announcement = timeToWords();
      speakTimerMessage(announcement);
    });
  }

  void _handleNightUsageStateChange(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      autoNightMuteActive = false;
      _cancelNightIdleTimer();
      _scheduleNightResumeAnnouncement();
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused) {
      _startNightIdleTimerIfNeeded();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _handleNightUsageStateChange(state);
  }

  bool _isSpeechMutedForSleep() {
    if (!muteSpeechAfterMidnight) return false;
    if (!_isNightTime()) {
      autoNightMuteActive = false;
      return false;
    }
    if (nightMuteMode == 'manual') {
      return true;
    }
    return autoNightMuteActive;
  }

  String timeToWords() {
    final preferredVoice = getPreferredVoice();
    if (_isMalayalamActive(preferredVoice)) {
      return _malayalamTtsService.clockAnnouncement(DateTime.now());
    }
    return _timerService.timeToWords(DateTime.now());
  }

  void startClock() {
    stopClock();
    speakClock(timeToWords());
    clockTimer = Timer.periodic(Duration(minutes: clockIntervalMins), (timer) {
      speakClock(timeToWords());
    });
  }

  void stopClock() {
    clockTimer?.cancel();
    clockTimer = null;
  }

  void toggleClock() {
    setState(() {
      clockOn = !clockOn;
      _lsSave();
      if (clockOn) {
        startClock();
      } else {
        stopClock();
      }
    });
  }

  void speakClock(String text) {
    if (_isSpeechMutedForSleep()) {
      speechQueue.clear();
      return;
    }

    const gap = 10000;
    final waitMs = max(
      0,
      gap - (DateTime.now().millisecondsSinceEpoch - lastTimerSpoke),
    );
    Future.delayed(Duration(milliseconds: waitMs), () {
      lastClockSpoke = DateTime.now().millisecondsSinceEpoch;
      speak(text);

      if (motivationOn) {
        final quoteText = _nextQuoteForCategory(motivationCategory);
        final delayMs = motivationDelaySeconds * 1000;
        speechQueue.add(SpeechItem(quoteText, isQuote: true, delayMs: delayMs));
      }
      drainQueue();
    });
  }

  String _nextQuoteForCategory(String category) {
    final preferredVoice = getPreferredVoice();
    final useMalayalam = _isMalayalamActive(preferredVoice);

    if (useMalayalam) {
      final categoryQuotes = _malayalamTtsService.quotesForCategory(category);
      if (categoryQuotes.isEmpty) {
        return _malayalamTtsService.defaultQuote();
      }
      final currentIndex = quoteIndexByCategory[category] ?? 0;
      final selected = categoryQuotes[currentIndex % categoryQuotes.length];
      quoteIndexByCategory[category] = currentIndex + 1;
      return selected;
    }

    final normalizedCategory = quotesByCategory.containsKey(category)
        ? category
        : 'General';
    final categoryQuotes = quotesByCategory[normalizedCategory] ?? const [];
    if (categoryQuotes.isEmpty) {
      return "Stay steady and use this moment well.";
    }
    final currentIndex = quoteIndexByCategory[normalizedCategory] ?? 0;
    final selected = categoryQuotes[currentIndex % categoryQuotes.length];
    quoteIndexByCategory[normalizedCategory] = currentIndex + 1;
    return selected;
  }

  void speakTimerMessage(String text) {
    if (_isSpeechMutedForSleep()) {
      speechQueue.clear();
      return;
    }

    const gap = 10000;
    final waitMs = max(
      0,
      gap - (DateTime.now().millisecondsSinceEpoch - lastClockSpoke),
    );
    Future.delayed(Duration(milliseconds: waitMs), () {
      lastTimerSpoke = DateTime.now().millisecondsSinceEpoch;
      speak(text);
    });
  }

  void tick(Timer timer) {
    setState(() {
      final tickResult = _timerService.tick(
        seconds: seconds,
        timerSpeakOn: timerSpeakOn,
        timerAnnounceEvery: timerAnnounceEvery,
      );

      seconds = tickResult.nextSeconds;
      timerValue = tickResult.timerValue;

      _syncForegroundNotification(force: true);

      if (tickResult.shouldAnnounceRemaining) {
        final mins = tickResult.announceMinutes;
        final preferredVoice = getPreferredVoice();
        final useMalayalam = _isMalayalamActive(preferredVoice);
        final message = useMalayalam
            ? _malayalamTtsService.timerRemaining(mins)
            : "$mins minute${mins != 1 ? 's' : ''} remaining";
        speakTimerMessage(message);
      }

      if (tickResult.isFinished) {
        if (chainModeOn) {
          final sequence = chainPresets[chainPresetKey] ?? const [25];
          if (chainIndex < sequence.length - 1) {
            chainIndex++;
            final nextMinutes = sequence[chainIndex];
            seconds = nextMinutes * 60;
            timerValue = '${nextMinutes.toString().padLeft(2, '0')}:00';
            if (timerSpeakOn) {
              final preferredVoice = getPreferredVoice();
              final useMalayalam = _isMalayalamActive(preferredVoice);
              speakTimerMessage(
                useMalayalam
                    ? _malayalamTtsService.nextTimerStarting(nextMinutes)
                    : 'Starting next timer: $nextMinutes minute${nextMinutes != 1 ? 's' : ''}',
              );
            }
            _syncForegroundNotification(force: true);
            return;
          }
          chainIndex = 0;
        }

        resetTimer();
        if (timerSpeakOn) {
          final preferredVoice = getPreferredVoice();
          final useMalayalam = _isMalayalamActive(preferredVoice);
          speakTimerMessage(
            useMalayalam
                ? _malayalamTtsService.timerFinished()
                : 'Timer finished',
          );
        }

        if (Platform.isAndroid) {
          FlutterRingtonePlayer().playAlarm(looping: true);
          Future.delayed(const Duration(seconds: 10), () {
            FlutterRingtonePlayer().stop();
          });
        } else {
          unawaited(_audioService.playNotification(assetPath: notifySound));
        }
      }
    });
  }

  void startTimer() async {
    _lsSave();
    if (seconds == 0) {
      if (chainModeOn) {
        final sequence = chainPresets[chainPresetKey] ?? const [25];
        if (chainIndex >= sequence.length) {
          chainIndex = 0;
        }
        seconds = sequence[chainIndex] * 60;
      } else {
        seconds = sliderValue * 60;
      }
    }
    if (timerInterval != null) return;

    try {
      await _ensureForegroundServiceRunning();
    } catch (e) {
      debugPrint('FOREGROUND TASK ERROR: $e');
    }

    setState(() {
      timerInterval = Timer.periodic(const Duration(seconds: 1), tick);
      audioPlaying = timerNoiseOn;
    });
    unawaited(_saveLastTimerSeconds(seconds > 0 ? seconds : sliderValue * 60));
    unawaited(_publishWidgetStateToPrefs());
    _applyAudioSettings();
    _syncForegroundNotification(force: true);
  }

  void stopTimer() {
    if (seconds > 0) {
      unawaited(_saveLastTimerSeconds(seconds));
    }
    timerInterval?.cancel();
    timerInterval = null;
    setState(() {
      audioPlaying = false;
    });
    unawaited(_audioService.stopBackground());
    unawaited(_publishWidgetStateToPrefs());
    _syncForegroundNotification(force: true);
  }

  void resetTimer() {
    stopTimer();
    setState(() {
      seconds = 0;
      timerValue = "00:00";
      chainIndex = 0;
    });
    unawaited(_publishWidgetStateToPrefs());
  }

  void choosePreset(int val) {
    setState(() {
      sliderValue = val;
    });
    resetTimer();
    startTimer();
  }

  Widget _buildSpeakClockTab() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            ClockPanel(
              clockOn: clockOn,
              currentTimeDisplay: currentTimeDisplay,
              clockIntervalMins: clockIntervalMins,
              motivationOn: motivationOn,
              motivationCategory: motivationCategory,
              motivationDelaySeconds: motivationDelaySeconds,
              clockIntervalOptions: clockIntervalOptions,
              motivationCategories: motivationCategories,
              motivationDelayOptions: motivationDelayOptions,
              toggleClock: toggleClock,
              onIntervalChanged: (val) {
                setState(() {
                  clockIntervalMins = val!;
                  _lsSave();
                });
                if (clockOn) startClock();
              },
              onMotivationChanged: (val) {
                setState(() {
                  motivationOn = val!;
                  _lsSave();
                });
              },
              onMotivationCategoryChanged: (val) {
                if (val == null) return;
                setState(() {
                  motivationCategory = val;
                  _lsSave();
                });
              },
              onMotivationDelayChanged: (val) {
                if (val == null) return;
                setState(() {
                  motivationDelaySeconds = val;
                  _lsSave();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerSetupTab() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            TimerPanel(
              timerValue: timerValue,
              sliderValue: sliderValue,
              voicesCount: voices.length,
              timerNoiseOn: timerNoiseOn,
              timerSpeakOn: timerSpeakOn,
              timerAnnounceEvery: timerAnnounceEvery,
              muteSpeechAfterMidnight: muteSpeechAfterMidnight,
              nightMuteMode: nightMuteMode,
              timerAnnounceOptions: timerAnnounceOptions,
              chainModeOn: chainModeOn,
              chainPresetKey: chainPresetKey,
              chainPresets: chainPresets,
              chainIndex: chainIndex,
              startTimer: startTimer,
              stopTimer: stopTimer,
              resetTimer: resetTimer,
              onSliderChanged: (val) {
                setState(() {
                  sliderValue = val.toInt();
                });
              },
              onTimerNoiseOnChanged: (val) {
                setState(() {
                  timerNoiseOn = val ?? true;
                  audioPlaying = timerInterval != null && timerNoiseOn;
                  _lsSave();
                });
                _applyAudioSettings();
              },
              onTimerSpeakOnChanged: (val) {
                setState(() {
                  timerSpeakOn = val!;
                  _lsSave();
                });
                unawaited(_publishWidgetStateToPrefs());
              },
              onTimerAnnounceEveryChanged: (val) {
                setState(() {
                  timerAnnounceEvery = val!;
                  _lsSave();
                });
              },
              onMuteSpeechAfterMidnightChanged: (val) {
                setState(() {
                  muteSpeechAfterMidnight = val ?? false;
                  if (!muteSpeechAfterMidnight) {
                    autoNightMuteActive = false;
                    _cancelNightIdleTimer();
                    nightResumeSpeechTimer?.cancel();
                  } else if (nightMuteMode == 'automatic') {
                    _startNightIdleTimerIfNeeded();
                  }
                  if (_isSpeechMutedForSleep()) {
                    speechQueue.clear();
                  }
                  _lsSave();
                });
                unawaited(_publishWidgetStateToPrefs());
              },
              onNightMuteModeChanged: (val) {
                if (val == null) return;
                setState(() {
                  nightMuteMode = val;
                  if (nightMuteMode == 'manual') {
                    autoNightMuteActive = false;
                    _cancelNightIdleTimer();
                    nightResumeSpeechTimer?.cancel();
                  } else if (muteSpeechAfterMidnight) {
                    autoNightMuteActive = false;
                    _startNightIdleTimerIfNeeded();
                  }
                  if (_isSpeechMutedForSleep()) {
                    speechQueue.clear();
                  }
                  _lsSave();
                });
                unawaited(_publishWidgetStateToPrefs());
              },
              onChainModeChanged: (val) {
                setState(() {
                  chainModeOn = val ?? false;
                  chainIndex = 0;
                });
              },
              onChainPresetChanged: (val) {
                if (val == null) return;
                setState(() {
                  chainPresetKey = val;
                  chainIndex = 0;
                });
              },
            ),
            const SizedBox(height: 8),
            PresetsPanel(
              presetValues: presetValues,
              choosePreset: choosePreset,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTab() {
    final settingsVoices = _availableVoicesForSettings();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            SettingsPanel(
              soundChosen: soundChosen,
              noiseVolume: noiseVolume,
              speakVolume: speakVolume,
              fullscreenDarkTheme: fullscreenDarkTheme,
              fullscreenDimBrightness: fullscreenDimBrightness,
              fullscreenStartLandscape: fullscreenStartLandscape,
              appDarkTheme: appDarkTheme,
              muteSpeechAfterMidnight: muteSpeechAfterMidnight,
              nightMuteMode: nightMuteMode,
              sleepStartLabel: _formatMinutesAs12Hour(sleepStartMinutes),
              sleepEndLabel: _formatMinutesAs12Hour(sleepEndMinutes),
              soundList: soundList,
              volumeLists: volumeLists,
              isSpeechActive: isSpeechActive,
              speechQueueLength: speechQueue.length,
              voiceListMode: voiceListMode,
              voices: settingsVoices,
              favoriteVoiceName: favoriteVoiceName,
              favoriteVoiceLocale: favoriteVoiceLocale,
              onSoundChanged: (val) {
                setState(() {
                  soundChosen = val!;
                  _lsSave();
                  _applyAudioSettings();
                });
              },
              onNoiseVolumeChanged: (val) {
                setState(() {
                  noiseVolume = val!;
                  _lsSave();
                  _applyAudioSettings();
                });
              },
              onSpeakVolumeChanged: (val) {
                setState(() {
                  speakVolume = val!;
                  _lsSave();
                });
              },
              onFullscreenDarkThemeChanged: (val) {
                setState(() {
                  fullscreenDarkTheme = val ?? true;
                  _lsSave();
                });
              },
              onAppDarkThemeChanged: (val) {
                setState(() {
                  appDarkTheme = val ?? false;
                  _lsSave();
                });
                setAppThemeMode(appDarkTheme);
              },
              onFullscreenDimBrightnessChanged: (val) {
                setState(() {
                  fullscreenDimBrightness = val ?? false;
                  _lsSave();
                });
              },
              onFullscreenStartLandscapeChanged: (val) {
                setState(() {
                  fullscreenStartLandscape = val ?? false;
                  _lsSave();
                });
              },
              onMuteSpeechAfterMidnightChanged: (val) {
                setState(() {
                  muteSpeechAfterMidnight = val ?? false;
                  if (!muteSpeechAfterMidnight) {
                    autoNightMuteActive = false;
                    _cancelNightIdleTimer();
                    nightResumeSpeechTimer?.cancel();
                  } else if (nightMuteMode == 'automatic') {
                    _startNightIdleTimerIfNeeded();
                  }
                  if (_isSpeechMutedForSleep()) {
                    speechQueue.clear();
                  }
                  _lsSave();
                });
                unawaited(_publishWidgetStateToPrefs());
              },
              onNightMuteModeChanged: (val) {
                if (val == null) return;
                setState(() {
                  nightMuteMode = val;
                  if (nightMuteMode == 'manual') {
                    autoNightMuteActive = false;
                    _cancelNightIdleTimer();
                    nightResumeSpeechTimer?.cancel();
                  } else if (muteSpeechAfterMidnight) {
                    autoNightMuteActive = false;
                    _startNightIdleTimerIfNeeded();
                  }
                  if (_isSpeechMutedForSleep()) {
                    speechQueue.clear();
                  }
                  _lsSave();
                });
                unawaited(_publishWidgetStateToPrefs());
              },
              onPickSleepStart: () {
                unawaited(_pickSleepStartTime());
              },
              onPickSleepEnd: () {
                unawaited(_pickSleepEndTime());
              },
              onVoiceListModeChanged: (val) {
                if (val == null) return;
                setState(() {
                  voiceListMode = val;
                  _lsSave();
                });
              },
              onFavoriteVoiceChanged: (val) {
                setState(() {
                  if (val == null || val == '__auto__') {
                    favoriteVoiceName = null;
                    favoriteVoiceLocale = null;
                  } else {
                    final parts = val.split('|');
                    if (parts.length == 2) {
                      favoriteVoiceName = parts[0];
                      favoriteVoiceLocale = parts[1];
                    }
                  }
                  _lsSave();
                });
              },
              onOpenHelp: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => _buildHelpTab()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpTab() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: palette.bg,
        elevation: 0,
        iconTheme: IconThemeData(color: palette.primary),
        title: Text(
          'Help / Working',
          style: TextStyle(
            color: palette.primary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              HelpPanel(
                muteSpeechAfterMidnight: muteSpeechAfterMidnight,
                nightMuteMode: nightMuteMode,
                sleepStartLabel: _formatMinutesAs12Hour(sleepStartMinutes),
                sleepEndLabel: _formatMinutesAs12Hour(sleepEndMinutes),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    nightIdleTimer?.cancel();
    nightResumeSpeechTimer?.cancel();
    speechStateSyncTimer?.cancel();
    stopClock();
    stopTimer();
    displayTick?.cancel();
    unawaited(_audioService.dispose());
    // Remove callback to avoid memory leaks
    FlutterForegroundTask.removeTaskDataCallback(_onReceiveTaskData);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 48,
        backgroundColor: palette.bg,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Lifer',
              style: TextStyle(
                color: palette.primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => unawaited(_exitAppFully()),
            tooltip: 'Exit App',
            icon: Icon(Icons.power_settings_new, color: palette.primary),
          ),
          IconButton(
            onPressed: _openFullscreenFocus,
            tooltip: 'Fullscreen Focus',
            icon: Icon(Icons.fullscreen, color: palette.primary),
          ),
        ],
        centerTitle: true,
      ),
      body: currentTabIndex == 0
          ? _buildSpeakClockTab()
          : (currentTabIndex == 1
                ? _buildTimerSetupTab()
                : _buildSettingsTab()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentTabIndex,
        onTap: (index) {
          setState(() {
            currentTabIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time_outlined),
            activeIcon: Icon(Icons.access_time),
            label: 'SpeakClock',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tune_outlined),
            activeIcon: Icon(Icons.tune),
            label: 'Timer Setup',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
