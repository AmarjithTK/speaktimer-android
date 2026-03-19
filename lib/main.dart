import 'dart:async';
import 'dart:math';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'theme/palette.dart';
import 'models/speech_item.dart';
import 'models/sound_option.dart';
import 'widgets/clock_panel.dart';
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
  // SharedPreferences
  SharedPreferences? prefs;

  // TTS & Speech Queue
  FlutterTts flutterTts = FlutterTts();
  List<SpeechItem> speechQueue = [];
  bool isSpeechActive = false;
  List<Map<dynamic, dynamic>> voices = [];
  int voiceIndex = 0;

  // Audio Players
  AudioPlayer bgPlayer = AudioPlayer();
  AudioPlayer notifyPlayer = AudioPlayer();
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

  void _onReceiveTaskData(Object data) {
    if (data is String) {
      switch (data) {
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
          break;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _initForegroundTask();
    _initPrefs();
  _initAudio();
    _initTts();

    // Add callback to handle notification button presses
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);

    displayTick = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      final now = DateTime.now();
      final h = now.hour;
      final m = now.minute.toString().padLeft(2, '0');
      final s = now.second.toString().padLeft(2, '0');
      final ms = now.millisecond.toString().padLeft(3, '0');
      final ampm = h >= 12 ? 'PM' : 'AM';
      final h12 = h % 12 == 0 ? 12 : h % 12;
      final hStr = h12.toString().padLeft(2, '0');
      if (mounted) {
        setState(() {
          currentTimeDisplay = "$hStr:$m:$s.$ms $ampm";
        });
      }
    });
  }

  Future<void> _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      String savedSound = prefs?.getString("SoundChosen") ?? soundList.first.link;
      // Normalize path: remove 'assets/' prefix if present from old saves
      if (savedSound.startsWith('assets/')) {
        savedSound = savedSound.replaceFirst('assets/', '');
      }
      soundChosen = savedSound;
      noiseVolume = prefs?.getDouble("NoiseVolume") ?? 0.6;
      speakVolume = prefs?.getDouble("SpeakVolume") ?? 0.8;
      clockOn = prefs?.getBool("ClockOn") ?? false;
      clockIntervalMins = prefs?.getInt("ClockIntervalMins") ?? 30;
      motivationOn = prefs?.getBool("MotivationOn") ?? true;
      timerSpeakOn = prefs?.getBool("TimerSpeakOn") ?? true;
      timerAnnounceEvery = prefs?.getInt("TimerAnnounceEvery") ?? 1;
    });

    _applyAudioSettings();
    if (clockOn) {
      Future.delayed(const Duration(milliseconds: 200), startClock);
    }
  }

  void _lsSave() {
    if (prefs == null) return;
    prefs!.setString("SoundChosen", soundChosen);
    prefs!.setDouble("NoiseVolume", noiseVolume);
    prefs!.setDouble("SpeakVolume", speakVolume);
    prefs!.setBool("ClockOn", clockOn);
    prefs!.setInt("ClockIntervalMins", clockIntervalMins);
    prefs!.setBool("MotivationOn", motivationOn);
    prefs!.setBool("TimerSpeakOn", timerSpeakOn);
    prefs!.setInt("TimerAnnounceEvery", timerAnnounceEvery);
  }

  void _initAudio() {
    bgPlayer.setReleaseMode(ReleaseMode.loop);
  }

  void _applyAudioSettings() {
    if (audioPlaying) {
      try {
        bgPlayer.play(AssetSource(soundChosen));
        bgPlayer.setVolume(noiseVolume);
      } catch (e) {
        debugPrint('Audio play error: $e');
      }
    }
  }

  Future<void> _initTts() async {
    final v = await flutterTts.getVoices;
    if (v != null) {
      voices = List<Map<dynamic, dynamic>>.from(v)
          .where((v) => v["locale"]?.toString().startsWith("en") ?? false)
          .toList();
    }
    await flutterTts.awaitSpeakCompletion(true);
  }

  Map<dynamic, dynamic>? getPleasantVoice() {
    if (voices.isEmpty) return null;

    // Try to find a high-quality Indian English voice
    // "network" voices on Android sound the most human. "veena" and "rishi" are great on iOS.
    const pleasantNames = [
      "en-in-x-ahp-network", "en-in-x-cxx-network", "en-in-x-ene-network",
      "veena", "rishi", "en-in-x-ahp-local", "en-in",
      // Fallbacks just in case
      "en-us-x-sfg-network", "samantha", "en-us",
    ];

    for (var name in pleasantNames) {
      try {
        var v = voices.firstWhere(
          (v) =>
              v['name'].toString().toLowerCase().contains(name) ||
              v['locale'].toString().toLowerCase() == name,
        );
        return v;
      } catch (e) {
        // Not found, continue loop
      }
    }
    // Return first english voice if no specific matches
    return voices.first;
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

    // Always use a pleasant voice, don't cycle through random/bad voices
    final pv = getPleasantVoice();
    if (pv != null) {
      await flutterTts.setVoice({"name": pv["name"], "locale": pv["locale"]});
    }

    if (item.isQuote) {
      await flutterTts.setPitch(1.0); // 1.0 is natural pitch
      await flutterTts.setSpeechRate(0.45); // slightly slower for quotes
    } else {
      await flutterTts.setPitch(
        1.0,
      ); // 1.0 is natural pitch (0.75 sounds robotic/distorted)
      await flutterTts.setSpeechRate(0.5); // standard speed
    }

    await flutterTts.setVolume(speakVolume);
    await flutterTts.speak(item.text);

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
    final now = DateTime.now();
    final h = now.hour;
    final m = now.minute;
    var s = h == 0 ? "12" : (h > 12 ? (h - 12).toString() : h.toString());
    if (m == 0) {
      s += " o'clock";
    } else if (m < 10) {
      s += " oh $m";
    } else {
      s += " $m";
    }
    s += h < 12 ? " AM" : " PM";
    return s;
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
      final mins = seconds ~/ 60;
      final secs = seconds % 60;
      seconds--;
      final mStr = mins.toString().padLeft(2, '0');
      final sStr = secs.toString().padLeft(2, '0');
      timerValue = "$mStr:$sStr";

      FlutterForegroundTask.updateService(
        notificationTitle: "Speaktimer (Speech ${timerSpeakOn ? 'ON' : 'OFF'})",
        notificationText: "Time remaining: $timerValue",
      );

      if (secs == 0 &&
          seconds != 0 &&
          timerSpeakOn &&
          mins > 0 &&
          mins % timerAnnounceEvery == 0) {
        speakTimerMessage("$mins minute${mins != 1 ? 's' : ''} remaining");
      }

      if (seconds == 0) {
        resetTimer();
        if (timerSpeakOn) speakTimerMessage("Timer finished");

        if (Platform.isAndroid) {
          FlutterRingtonePlayer().playAlarm(looping: true);
          Future.delayed(const Duration(seconds: 10), () {
            FlutterRingtonePlayer().stop();
          });
        } else {
          notifyPlayer.play(AssetSource(notifySound));
          Future.delayed(const Duration(seconds: 10), () {
            notifyPlayer.pause();
            notifyPlayer.seek(Duration.zero);
          });
        }
      }
    });
  }

  void startTimer() async {
    _lsSave();
    if (seconds == 0) seconds = sliderValue * 60;
    if (timerInterval != null) return;

    try {
      if (!await FlutterForegroundTask.isRunningService) {
        await FlutterForegroundTask.startService(
          notificationTitle: "Speaktimer (Speech \${timerSpeakOn ? 'ON' : 'OFF'})",
          notificationText: "Time remaining: \$timerValue",
          notificationIcon: const NotificationIcon(
            metaDataName: 'com.example.speakertimer.service.NOTIFICATION_ICON',
          ),
          notificationButtons: [
            const NotificationButton(id: 'btn_clock_speech', text: 'Clock Speech'),
          ],
          callback: startCallback,
        );
      }
    } catch (e) {
      debugPrint("FOREGROUND TASK ERROR: \$e");
    }

    setState(() {
      timerInterval = Timer.periodic(const Duration(seconds: 1), tick);
      audioPlaying = true;
    });
    _applyAudioSettings();
  }

  void stopTimer() {
    timerInterval?.cancel();
    timerInterval = null;
    setState(() {
      audioPlaying = false;
    });
    bgPlayer.pause();
  }

  void resetTimer() {
    stopTimer();
    setState(() {
      seconds = 0;
      timerValue = "00:00";
    });
  }

  void choosePreset(int val) {
    setState(() {
      sliderValue = val;
    });
    resetTimer();
    startTimer();
  }

  @override
  void dispose() {
    stopClock();
    stopTimer();
    displayTick?.cancel();
    bgPlayer.dispose();
    notifyPlayer.dispose();
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
          centerTitle: true,
        ),
        body: SafeArea(
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
                const SizedBox(height: 8),
                TimerPanel(
                  timerValue: timerValue,
                  sliderValue: sliderValue,
                  voicesCount: voices.length,
                  timerSpeakOn: timerSpeakOn,
                  timerAnnounceEvery: timerAnnounceEvery,
                  timerAnnounceOptions: timerAnnounceOptions,
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
                ),
                const SizedBox(height: 8),
                PresetsPanel(
                  presetValues: presetValues,
                  choosePreset: choosePreset,
                ),
                const SizedBox(height: 8),
                SettingsPanel(
                  soundChosen: soundChosen,
                  noiseVolume: noiseVolume,
                  speakVolume: speakVolume,
                  soundList: soundList,
                  volumeLists: volumeLists,
                  isSpeechActive: isSpeechActive,
                  speechQueueLength: speechQueue.length,
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
                ),
              ],
            ),
          ),
        ),
    );
  }
}
