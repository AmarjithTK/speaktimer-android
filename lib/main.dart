import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const SpeakTimerApp());
}

class Palette {
  final Color primary;
  final Color accent;
  final Color bg;
  const Palette(this.primary, this.accent, this.bg);
}

const List<Palette> palettes = [
  Palette(Color(0xFF1A051D), Color(0xFFE5D4F5), Color(0xFFF4EFFF)),
  Palette(Color(0xFF0A1824), Color(0xFFCDE8F5), Color(0xFFEAF6FF)),
  Palette(Color(0xFF201004), Color(0xFFFCEFD4), Color(0xFFFFF8EA)),
  Palette(Color(0xFF0D1E16), Color(0xFFC8F0DA), Color(0xFFEEFAF3)),
  Palette(Color(0xFF2A0B0B), Color(0xFFF5DCD4), Color(0xFFFFF0EB)),
  Palette(Color(0xFF0D0D2A), Color(0xFFD8DBF5), Color(0xFFF1F2FF)),
  Palette(Color(0xFF210D2C), Color(0xFFEEDDF7), Color(0xFFF8F0FF)),
  Palette(Color(0xFF051A1A), Color(0xFFC4EEEC), Color(0xFFEFFFFD)),
  Palette(Color(0xFF2A1C00), Color(0xFFFAEFD4), Color(0xFFFFFBEA)),
  Palette(Color(0xFF14051D), Color(0xFFE5D4F5), Color(0xFFF6EEFF)),
  Palette(Color(0xFF200D00), Color(0xFFFFE8C8), Color(0xFFFFF4EA)),
  Palette(Color(0xFF001E1E), Color(0xFFC0F5EE), Color(0xFFEAFFFC)),
  Palette(Color(0xFF000000), Color(0xFFE0E0E0), Color(0xFFFFFFFF)),
  Palette(Color(0xFF1C0017), Color(0xFFFAD4F2), Color(0xFFFFF0FA)),
  Palette(Color(0xFF001C0C), Color(0xFFD4FAE0), Color(0xFFEEFFF3)),
  Palette(Color(0xFF0B141C), Color(0xFFD4E0F5), Color(0xFFF0F5FF)),
  Palette(Color(0xFF1A1A00), Color(0xFFF5F0C8), Color(0xFFFEFFEA)),
  Palette(Color(0xFF25000F), Color(0xFFFAD4DC), Color(0xFFFFF0F4)),
  Palette(Color(0xFF000B1C), Color(0xFFD4E4FA), Color(0xFFF0F6FF)),
  Palette(Color(0xFF0B1C00), Color(0xFFDFF5C4), Color(0xFFF4FFEA)),
];

final Palette palette = palettes[Random().nextInt(palettes.length)];

class SpeakTimerApp extends StatelessWidget {
  const SpeakTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
    );
  }
}

class SpeechItem {
  final String text;
  final bool isQuote;
  final int delayMs;
  SpeechItem(this.text, {this.isQuote = false, this.delayMs = 0});
}

class SoundOption {
  final String link;
  final String title;
  SoundOption(this.link, this.title);
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
  String soundChosen = "https://www.soundjay.com/nature/sounds/rain-04.mp3";
  double noiseVolume = 0.2;
  double speakVolume = 0.8;
  bool clockOn = false;
  int clockIntervalMins = 30;
  bool motivationOn = true;
  bool timerSpeakOn = true;
  int timerAnnounceEvery = 1;

  final String notifySound = "https://www.soundjay.com/clock/sounds/alarm-clock-01.mp3";
  final List<SoundOption> soundList = [
    SoundOption("https://www.soundjay.com/nature/sounds/rain-04.mp3", "Rain"),
    SoundOption("https://www.soundjay.com/nature/sounds/waterfall-1.mp3", "Waterfall"),
    SoundOption("https://www.soundjay.com/nature/sounds/fire-1.mp3", "Fire"),
    SoundOption("https://www.soundjay.com/nature/sounds/stream-3.mp3", "Stream"),
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

  @override
  void initState() {
    super.initState();
    _initPrefs();
    _initAudio();
    _initTts();

    displayTick = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      final now = DateTime.now();
      final h = now.hour;
      final m = now.minute.toString().padLeft(2, '0');
      final s = now.second.toString().padLeft(2, '0');
      final ms = now.millisecond.toString().padLeft(3, '0');
      final ampm = h >= 12 ? 'PM' : 'AM';
      final h12 = h % 12 == 0 ? 12 : h % 12;
      final hStr = h12.toString().padLeft(2, '0');
      setState(() {
        currentTimeDisplay = "$hStr:$m:$s.$ms $ampm";
      });
    });
  }

  Future<void> _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      soundChosen = prefs?.getString("SoundChosen") ?? soundList.first.link;
      noiseVolume = prefs?.getDouble("NoiseVolume") ?? 0.2;
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
    bgPlayer.setSourceUrl(soundChosen);
    bgPlayer.setVolume(noiseVolume);
    if (audioPlaying) {
      bgPlayer.resume();
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
    const pleasantNames = [
      "google", "samantha", "karen", "victoria", "moira", "fiona",
      "veena", "tessa", "allison", "ava", "susan", "zira",
    ];
    for (var name in pleasantNames) {
      try {
        var v = voices.firstWhere((v) => v['name'].toString().toLowerCase().contains(name));
        return v;
      } catch (e) {
        // Not found, continue loop
      }
    }
    return voices.first;
  }

  Future<void> drainQueue() async {
    if (isSpeechActive || speechQueue.isEmpty) return;
    setState(() { isSpeechActive = true; });

    final item = speechQueue.removeAt(0);

    if (item.delayMs > 0) {
      await Future.delayed(Duration(milliseconds: item.delayMs));
    }

    if (item.isQuote) {
      final pv = getPleasantVoice();
      if (pv != null) {
        await flutterTts.setVoice({"name": pv["name"], "locale": pv["locale"]});
      }
      await flutterTts.setPitch(1.05);
      await flutterTts.setSpeechRate(0.5); // 0.5 is normally 1.0x in Flutter TTS
    } else {
      if (voices.isNotEmpty) {
        final v = voices[voiceIndex % voices.length];
        voiceIndex++;
        await flutterTts.setVoice({"name": v["name"], "locale": v["locale"]});
      }
      await flutterTts.setPitch(0.75);
      await flutterTts.setSpeechRate(0.5); 
    }

    await flutterTts.setVolume(speakVolume);
    await flutterTts.speak(item.text);
    
    // Done speaking
    setState(() { isSpeechActive = false; });
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
    final waitMs = max(0, gap - (DateTime.now().millisecondsSinceEpoch - lastTimerSpoke));
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
    final waitMs = max(0, gap - (DateTime.now().millisecondsSinceEpoch - lastClockSpoke));
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

      if (secs == 0 && seconds != 0 && timerSpeakOn && mins > 0 && mins % timerAnnounceEvery == 0) {
        speakTimerMessage("$mins minute${mins != 1 ? 's' : ''} remaining");
      }

      if (seconds == 0) {
        resetTimer();
        if (timerSpeakOn) speakTimerMessage("Timer finished");
        
        notifyPlayer.setSourceUrl(notifySound);
        notifyPlayer.resume();
        Future.delayed(const Duration(seconds: 10), () {
          notifyPlayer.pause();
          notifyPlayer.seek(Duration.zero);
        });
      }
    });
  }

  void startTimer() {
    _lsSave();
    if (seconds == 0) seconds = sliderValue * 60;
    if (timerInterval != null) return;
    
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
    super.dispose();
  }

  Widget _panelContainer({required Widget child, bool active = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: palette.bg,
        border: Border.all(
          color: palette.primary,
          width: active ? 3 : 2,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: child,
    );
  }

  Widget _header(String title, String tag) {
    return Row(
      children: [
        Text(title, style: TextStyle(color: palette.primary, fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(color: palette.primary, borderRadius: BorderRadius.circular(3)),
          child: Text(tag, style: TextStyle(color: palette.accent, fontWeight: FontWeight.bold, fontSize: 9)),
        )
      ],
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(text, style: TextStyle(color: palette.primary.withAlpha(140), fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 540;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (isMobile) {
                return ListView(
                  children: [
                    _buildClockPanel(),
                    const SizedBox(height: 8),
                    _buildTimerPanel(),
                    const SizedBox(height: 8),
                    _buildPresetsPanel(),
                    const SizedBox(height: 8),
                    _buildSettingsPanel(),
                  ],
                );
              } else {
                return GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: (constraints.maxWidth / 2) / (constraints.maxHeight / 2),
                  children: [
                    _buildClockPanel(),
                    _buildTimerPanel(),
                    _buildPresetsPanel(),
                    _buildSettingsPanel(),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildClockPanel() {
    return _panelContainer(
      active: clockOn,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header("🕐 Speaking Clock", "A"),
          const SizedBox(height: 8),
          Text(
            currentTimeDisplay,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: palette.primary,
              letterSpacing: 1.2,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          _label("Announce every"),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            decoration: BoxDecoration(
              color: palette.accent,
              border: Border.all(color: palette.primary, width: 2),
              borderRadius: BorderRadius.circular(5),
            ),
            child: DropdownButton<int>(
              value: clockIntervalMins,
              isExpanded: true,
              underline: const SizedBox(),
              iconEnabledColor: palette.primary,
              dropdownColor: palette.accent,
              items: clockIntervalOptions.map((e) => DropdownMenuItem(
                value: e,
                child: Text("$e min", style: TextStyle(color: palette.primary, fontWeight: FontWeight.w500, fontSize: 12)),
              )).toList(),
              onChanged: (val) {
                setState(() { clockIntervalMins = val!; _lsSave(); });
                if (clockOn) startClock();
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Checkbox(
                value: motivationOn,
                activeColor: palette.primary,
                checkColor: palette.accent,
                onChanged: (val) {
                  setState(() { motivationOn = val!; _lsSave(); });
                },
              ),
              Expanded(child: _label("Speak motivational quote after time")),
            ],
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: toggleClock,
            style: ElevatedButton.styleFrom(
              backgroundColor: clockOn ? palette.primary : palette.accent,
              foregroundColor: clockOn ? palette.accent : palette.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              side: BorderSide(color: palette.primary, width: 2),
            ),
            child: Text(clockOn ? "🔔 ON" : "🔕 OFF", style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      )
    );
  }

  Widget _buildTimerPanel() {
    return _panelContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header("⏱ Timer", "B"),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: palette.accent,
              border: Border.all(color: palette.primary, width: 2),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              timerValue,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: palette.primary,
                letterSpacing: 2,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _label("$sliderValue min"),
                Text("${voices.length} voice${voices.length != 1 ? 's' : ''} loaded", style: TextStyle(fontSize: 10, color: palette.primary.withAlpha(140))),
              ],
            ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: palette.accent,
              inactiveTrackColor: palette.accent,
              thumbColor: palette.accent,
              trackHeight: 8,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: sliderValue.toDouble(),
              min: 1,
              max: 120,
              onChanged: (val) {
                setState(() { sliderValue = val.toInt(); });
              },
            ),
          ),
          Row(
            children: [
              Expanded(child: _btn("▶ Start", startTimer)),
              const SizedBox(width: 4),
              Expanded(child: _btn("⏸ Stop", stopTimer)),
              const SizedBox(width: 4),
              Expanded(child: _btn("↺ Reset", resetTimer)),
            ],
          ),
          Row(
            children: [
              Checkbox(
                value: timerSpeakOn,
                activeColor: palette.primary,
                checkColor: palette.accent,
                onChanged: (val) { setState(() { timerSpeakOn = val!; _lsSave(); }); },
              ),
              Expanded(child: _label("Speak remaining — every")),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            decoration: BoxDecoration(
              color: palette.accent,
              border: Border.all(color: palette.primary, width: 2),
              borderRadius: BorderRadius.circular(5),
            ),
            child: DropdownButton<int>(
              value: timerAnnounceEvery,
              isExpanded: true,
              underline: const SizedBox(),
              iconEnabledColor: palette.primary,
              dropdownColor: palette.accent,
              items: timerAnnounceOptions.map((e) => DropdownMenuItem(
                value: e,
                child: Text("$e min", style: TextStyle(color: palette.primary, fontWeight: FontWeight.w500, fontSize: 12)),
              )).toList(),
              onChanged: timerSpeakOn ? (val) {
                setState(() { timerAnnounceEvery = val!; _lsSave(); });
              } : null,
            ),
          ),
        ],
      )
    );
  }

  Widget _btn(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: palette.accent,
        foregroundColor: palette.primary,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        side: BorderSide(color: palette.primary, width: 2),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildPresetsPanel() {
    return _panelContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header("⚡ Presets", ""),
          _label("Tap to start instantly"),
          Expanded(
            child: GridView.count(
              crossAxisCount: 5,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 1.8,
              children: presetValues.map((p) {
                return InkWell(
                  onTap: () => choosePreset(p),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: palette.bg,
                      border: Border.all(color: palette.primary, width: p == 25 ? 2 : 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      p.toString(),
                      style: TextStyle(
                        color: palette.primary,
                        fontWeight: p >= 90 ? FontWeight.bold : FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text("🍅 25 = Pomodoro  ·  bold = deep work", style: TextStyle(fontSize: 10, color: palette.primary.withAlpha(140))),
          )
        ],
      )
    );
  }

  Widget _buildSettingsPanel() {
    return _panelContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header("⚙ Settings", ""),
          _label("Background sound"),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            decoration: BoxDecoration(
              color: palette.accent,
              border: Border.all(color: palette.primary, width: 2),
              borderRadius: BorderRadius.circular(5),
            ),
            child: DropdownButton<String>(
              value: soundList.any((e) => e.link == soundChosen) ? soundChosen : soundList.first.link,
              isExpanded: true,
              underline: const SizedBox(),
              iconEnabledColor: palette.primary,
              dropdownColor: palette.accent,
              items: soundList.map((e) => DropdownMenuItem(
                value: e.link,
                child: Text(e.title, style: TextStyle(color: palette.primary, fontWeight: FontWeight.w500, fontSize: 12)),
              )).toList(),
              onChanged: (val) {
                setState(() { soundChosen = val!; _lsSave(); _applyAudioSettings(); });
              },
            ),
          ),
          _label("Noise volume"),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            decoration: BoxDecoration(
              color: palette.accent,
              border: Border.all(color: palette.primary, width: 2),
              borderRadius: BorderRadius.circular(5),
            ),
            child: DropdownButton<double>(
              value: noiseVolume,
              isExpanded: true,
              underline: const SizedBox(),
              iconEnabledColor: palette.primary,
              dropdownColor: palette.accent,
              items: volumeLists.map((e) => DropdownMenuItem(
                value: e,
                child: Text(_getVolTitle(e), style: TextStyle(color: palette.primary, fontWeight: FontWeight.w500, fontSize: 12)),
              )).toList(),
              onChanged: (val) {
                setState(() { noiseVolume = val!; _lsSave(); _applyAudioSettings(); });
              },
            ),
          ),
          _label("Speech volume"),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            decoration: BoxDecoration(
              color: palette.accent,
              border: Border.all(color: palette.primary, width: 2),
              borderRadius: BorderRadius.circular(5),
            ),
            child: DropdownButton<double>(
              value: speakVolume,
              isExpanded: true,
              underline: const SizedBox(),
              iconEnabledColor: palette.primary,
              dropdownColor: palette.accent,
              items: volumeLists.map((e) => DropdownMenuItem(
                value: e,
                child: Text(_getVolTitle(e), style: TextStyle(color: palette.primary, fontWeight: FontWeight.w500, fontSize: 12)),
              )).toList(),
              onChanged: (val) {
                setState(() { speakVolume = val!; _lsSave(); });
              },
            ),
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: palette.primary, width: 1, style: BorderStyle.none))),
            child: Text(
              "${isSpeechActive ? '🔉 Speaking…' : (speechQueue.isNotEmpty ? '⏳ ${speechQueue.length} queued' : '✔ Ready')}  ·  A↔B gap: 10 s",
              style: TextStyle(fontSize: 10, color: palette.primary.withAlpha(140)),
            ),
          )
        ],
      )
    );
  }

  String _getVolTitle(double v) {
    if (v == 0.1) return "Very Low";
    if (v == 0.2) return "Low";
    if (v == 0.6) return "Medium";
    if (v == 0.8) return "High";
    return "Very High";
  }
}
