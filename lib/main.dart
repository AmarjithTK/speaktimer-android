import 'dart:async';
import 'dart:math';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'theme/palette.dart';
import 'models/app_settings.dart';
import 'models/foreground_notification_state.dart';
import 'models/speech_item.dart';
import 'models/sound_option.dart';
import 'services/audio_service.dart';
import 'services/foreground_notification_service.dart';
import 'services/settings_service.dart';
import 'services/speech_service.dart';
import 'services/timer_service.dart';
import 'widgets/clock_panel.dart';
import 'widgets/fullscreen_focus_view.dart';
import 'widgets/timer_panel.dart';
import 'widgets/presets_panel.dart';
import 'widgets/settings_panel.dart';

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
  runApp(const SpeakTimerApp());
}

class SpeakTimerApp extends StatelessWidget {
  const SpeakTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return WithForegroundTask(
      child: MaterialApp(
      title: 'Speaktimer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: palette.bg,
        primaryColor: palette.primary,
        colorScheme: ColorScheme.light(
          primary: palette.primary,
          secondary: palette.accent,
          surface: palette.bg,
        ),
        fontFamily: 'Rubik', // Standard fallback is fine if not imported
        useMaterial3: true,
      ),
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final AudioService _audioService = AudioService();
  final SettingsService _settingsService = SettingsService();
  final SpeechService _speechService = SpeechService();
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

  final List<String> quotes = [
    "Use this moment well — it won't come back.",
    "Small steps every hour build the life you want.",
    "Your attention is your most valuable currency.",
    "Time is the only resource you cannot earn back.",
    "What you do right now shapes who you become.",
    "Every minute of focus is an investment in your future.",
    "Be present. This hour is a gift.",
    "Clarity comes to those who use their time with intention.",
    "Progress, not perfection, is what time rewards.",
    "An hour of deep work is worth a day of distraction.",
    "Don't count the hours; make the hours count.",
    "Your future self will thank you for the work you do now.",
    "One focused hour can change a whole day.",
    "Time flies — but you are the pilot.",
    "Do something today that your future self will be proud of.",
    "Momentum is built one intentional moment at a time.",
    "The best time to start was yesterday. The second best is now.",
    "Each hour is a fresh canvas. Paint it well.",
    "Discipline is choosing what you want most over what you want now.",
    "Greatness is built minute by minute.",
    "A year from now you'll wish you had started today.",
    "Your work right now is compounding silently.",
    "Focused effort now creates freedom later.",
    "Every hour of rest is fuel. Every hour of work is progress.",
    "Time is the great equaliser — what matters is what you do with it.",
    "Stay the course. The results are coming.",
    "Consistency over time is unstoppable.",
    "You have enough time for what truly matters.",
    "Let this hour be better than the last.",
    "Breathe, focus, and make this moment count.",
  ];
  int quoteIndex = 0;

  Future<void> _requestPermissions() async {
    if (await FlutterForegroundTask.isIgnoringBatteryOptimizations == false) {
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }
    final NotificationPermission status = await FlutterForegroundTask.checkNotificationPermission();
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
      iosNotificationOptions: const IOSNotificationOptions(showNotification: true, playSound: false),
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

  Future<void> _openFullscreenFocus() async {
    final startInTimer = timerInterval != null || currentTabIndex == 1;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullscreenFocusView(
          startInTimerMode: startInTimer,
          clockTextBuilder: () => currentTimeDisplay,
          timerTextBuilder: () => timerValue,
          isTimerRunningBuilder: () => timerInterval != null,
        ),
      ),
    );
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
          stopTimer();
          FlutterForegroundTask.stopService();
          break;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initForegroundTask();
    _initPrefs();
    _initAudio();
    _initTts();
    _initializeForegroundNotification();

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
    final settings = await _settingsService.load(defaultSound: soundList.first.link);
    setState(() {
      soundChosen = settings.soundChosen;
      noiseVolume = settings.noiseVolume;
      speakVolume = settings.speakVolume;
      clockOn = settings.clockOn;
      clockIntervalMins = settings.clockIntervalMins;
      motivationOn = settings.motivationOn;
      timerSpeakOn = settings.timerSpeakOn;
      timerAnnounceEvery = settings.timerAnnounceEvery;
      voiceListMode = settings.voiceListMode;
      favoriteVoiceName = settings.favoriteVoiceName;
      favoriteVoiceLocale = settings.favoriteVoiceLocale;
    });

    _applyAudioSettings();
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
      timerSpeakOn: timerSpeakOn,
      timerAnnounceEvery: timerAnnounceEvery,
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
    if (audioPlaying) {
      unawaited(
        _audioService.applyBackground(
          shouldPlay: true,
          assetPath: soundChosen,
          volume: noiseVolume,
        ),
      );
    }
  }

  Future<void> _initTts() async {
    final v = await flutterTts.getVoices;
    if (v != null) {
      final loadedVoices = _speechService.parseEnglishVoices(v);
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

  Future<void> drainQueue() async {
    if (isSpeechActive || speechQueue.isEmpty) return;
    setState(() {
      isSpeechActive = true;
    });

    final item = speechQueue.removeAt(0);

    if (item.delayMs > 0) {
      await Future.delayed(Duration(milliseconds: item.delayMs));
    }

    final pv = getPreferredVoice();
    await _speechService.speakItem(
      flutterTts: flutterTts,
      item: item,
      speakVolume: speakVolume,
      preferredVoice: pv,
    );

    // Done speaking
    setState(() {
      isSpeechActive = false;
    });
    drainQueue();
  }

  void speak(String text) {
    speechQueue.add(SpeechItem(text));
    drainQueue();
  }

  String timeToWords() {
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
    const gap = 10000;
    final waitMs = max(
      0,
      gap - (DateTime.now().millisecondsSinceEpoch - lastTimerSpoke),
    );
    Future.delayed(Duration(milliseconds: waitMs), () {
      lastClockSpoke = DateTime.now().millisecondsSinceEpoch;
      speak(text);

      if (motivationOn) {
        final quoteText = quotes[quoteIndex % quotes.length];
        quoteIndex++;
        speechQueue.add(SpeechItem(quoteText, isQuote: true, delayMs: 5000));
      }
      drainQueue();
    });
  }

  void speakTimerMessage(String text) {
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
        speakTimerMessage("$mins minute${mins != 1 ? 's' : ''} remaining");
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
              speakTimerMessage(
                'Starting next timer: $nextMinutes minute${nextMinutes != 1 ? 's' : ''}',
              );
            }
            _syncForegroundNotification(force: true);
            return;
          }
          chainIndex = 0;
        }

        resetTimer();
        if (timerSpeakOn) speakTimerMessage("Timer finished");

        if (Platform.isAndroid) {
          FlutterRingtonePlayer().playAlarm(looping: true);
          Future.delayed(const Duration(seconds: 10), () {
            FlutterRingtonePlayer().stop();
          });
        } else {
          unawaited(
            _audioService.playNotification(assetPath: notifySound),
          );
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
      audioPlaying = true;
    });
    _applyAudioSettings();
    _syncForegroundNotification(force: true);
  }

  void stopTimer() {
    timerInterval?.cancel();
    timerInterval = null;
    setState(() {
      audioPlaying = false;
    });
    unawaited(_audioService.stopBackground());
    _syncForegroundNotification(force: true);
  }

  void resetTimer() {
    stopTimer();
    setState(() {
      seconds = 0;
      timerValue = "00:00";
      chainIndex = 0;
    });
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
              clockIntervalOptions: clockIntervalOptions,
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
              timerSpeakOn: timerSpeakOn,
              timerAnnounceEvery: timerAnnounceEvery,
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
              onTimerSpeakOnChanged: (val) {
                setState(() {
                  timerSpeakOn = val!;
                  _lsSave();
                });
              },
              onTimerAnnounceEveryChanged: (val) {
                setState(() {
                  timerAnnounceEvery = val!;
                  _lsSave();
                });
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
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
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
                'lifer',
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
              onPressed: _openFullscreenFocus,
              tooltip: 'Fullscreen Focus',
              icon: Icon(Icons.fullscreen, color: palette.primary),
            ),
          ],
          centerTitle: true,
        ),
        body: currentTabIndex == 0
            ? _buildSpeakClockTab()
            : (currentTabIndex == 1 ? _buildTimerSetupTab() : _buildSettingsTab()),
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
