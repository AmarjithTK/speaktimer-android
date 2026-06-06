// ============================================================================
// SOLASFLOW - A Productivity Timer & Meditation App
// ============================================================================
//
// **Version:** 1.0.0
// **Platform:** Android, iOS, Web, macOS, Linux, Windows
// **Target:** Dart ^3.11.3, Flutter stable
//
// ## Architecture Overview
//
// This is a feature-modular, service-oriented app for managing focused work
// sessions, clock displays, and motivational quotes. Clean architecture:
//
// - **UI Layer:** Screens & Widgets (main tabs: Timer, Clock, Settings, Presets)
// - **Service Layer:** Business logic (TimerService, SettingsService, etc.)
// - **Features:** Domain-specific modules (motivation/ feature)
// - **Models:** Data classes representing app state
// - **Theme:** Centralized Material 3 styling via palette.dart
//
// ## Key Features
//
// 1. Timer Management: Countdown with customizable presets & chain mode
// 2. Speech: TTS announcements with Malayalam support
// 3. Background Audio: Ambient sounds (rain, waterfall, fire, stream)
// 4. Foreground Service: Persistent notifications during long sessions
// 5. Motivational Quotes: Category-based rotating quotes for focus
// 6. Night Mode: Auto-mute speech after midnight with configurable window
// 7. Localization: Multi-language support (English, Malayalam)
// 8. Theme System: Light/dark mode toggle with Material 3 theming
// 9. Health Checks: Periodic service recovery to prevent OS kills
// 10. Settable Presets: Pomodoro, Sprint, and Quick session types
//
// ## Service Initialization Pattern
//
// Services are initialized as class members in _MainScreenState:
// - SettingsService: Persists user preferences via SharedPreferences
// - TimerService: Manages countdown logic and announcements
// - SpeechService: Queues TTS/ringtone playback with concurrency control
// - AudioService: Plays ambient background sounds
// - ForegroundNotificationService: Android foreground service & notification
// - QuoteRotationService: Cycling logic for motivational quotes
// - MalayalamTtsService: Language-specific TTS selection
//
// ## Performance Optimizations
//
// - Display Ticker: 250ms frequency (up from 30ms) for reduced GPU pressure
// - Conditional setState(): Only rebuild if display actually changed
// - Idle Notification Throttle: 4:1 reduction in idle notification syncs
// - Lazy TTS initialization: Voices loaded only when needed
// - Health Check Interval: 30s periodic service recovery
//
// ## Future Roadmap
//
// - [ ] Custom preset creation UI
// - [ ] Session history & analytics
// - [ ] Haptic feedback on timer complete
// - [ ] Circular progress indicator widget
// - [ ] Cloud sync of settings & session history
// - [ ] Wear OS companion app
// - [ ] Export session data to Google Fit

import 'dart:async';
import 'dart:math';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:google_fonts/google_fonts.dart';

import 'l10n/app_localizations.dart';
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
import 'features/motivation/motivation_content.dart';
import 'features/motivation/services/quote_rotation_service.dart';
import 'widgets/clock_panel.dart';
import 'widgets/fullscreen_focus_view.dart';
import 'widgets/timer_panel.dart';
import 'widgets/stopwatch_panel.dart';
import 'widgets/settings_panel.dart';
import 'widgets/help_panel.dart';
import 'services/voice_session_manager.dart';

final ValueNotifier<ThemeMode> appThemeModeNotifier = ValueNotifier(
  ThemeMode.light,
);

final ValueNotifier<double> appFontSizeNotifier = ValueNotifier(1.0);

void setAppThemeMode(bool isDark) {
  appThemeModeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
}

void setAppFontSizeMultiplier(double multiplier) {
  appFontSizeNotifier.value = multiplier;
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
  runApp(const SolasFlowApp());
}

class SolasFlowApp extends StatelessWidget {
  const SolasFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return WithForegroundTask(
      child: DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
          return ValueListenableBuilder<ThemeMode>(
            valueListenable: appThemeModeNotifier,
            builder: (context, themeMode, _) {
              return ValueListenableBuilder<double>(
                valueListenable: appFontSizeNotifier,
                builder: (context, fontSizeMultiplier, _) {
                  final l10n = AppLocalizations.of(context);
                  return MaterialApp(
                    title: l10n?.appTitle ?? 'SolasFlow',
                    debugShowCheckedModeBanner: false,
                    localizationsDelegates:
                        AppLocalizations.localizationsDelegates,
                    supportedLocales: AppLocalizations.supportedLocales,
                    themeMode: themeMode,
                    builder: (context, child) {
                      return MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                          textScaler:
                              TextScaler.linear(fontSizeMultiplier),
                        ),
                        child: child!,
                      );
                    },
                    theme: _buildSolasFlowTheme(
                      _darkenColors(lightDynamic ??
                          ColorScheme.fromSeed(
                            seedColor: const Color(0xFF6256D9),
                            brightness: Brightness.light,
                          )),
                      Brightness.light,
                    ),
                    darkTheme: _buildSolasFlowTheme(
                      _darkenColors(darkDynamic ??
                          ColorScheme.fromSeed(
                            seedColor: const Color(0xFF6256D9),
                            brightness: Brightness.dark,
                          )),
                      Brightness.dark,
                    ),
                    home: const MainScreen(),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

ColorScheme _darkenColors(ColorScheme scheme) {
  Color darken(Color c) => Color.lerp(c, Colors.black, 0.2) ?? c;
  return scheme.copyWith(
    primary: darken(scheme.primary),
    onPrimary: darken(scheme.onPrimary),
    primaryContainer: darken(scheme.primaryContainer),
    secondary: darken(scheme.secondary),
    secondaryContainer: darken(scheme.secondaryContainer),
    tertiary: darken(scheme.tertiary),
    tertiaryContainer: darken(scheme.tertiaryContainer),
    surface: darken(scheme.surface),
    surfaceContainer: darken(scheme.surfaceContainer),
    surfaceContainerHigh: darken(scheme.surfaceContainerHigh),
    surfaceContainerHighest: darken(scheme.surfaceContainerHighest),
    surfaceContainerLow: darken(scheme.surfaceContainerLow),
    surfaceContainerLowest: darken(scheme.surfaceContainerLowest),
    error: darken(scheme.error),
    errorContainer: darken(scheme.errorContainer),
  );
}

ThemeData _buildSolasFlowTheme(ColorScheme scheme, Brightness brightness) {
  final base = ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    brightness: brightness,
    fontFamily: GoogleFonts.poppins().fontFamily,
    fontFamilyFallback: const ['Arial'],
  );
  final textTheme = GoogleFonts.poppinsTextTheme(base.textTheme).apply(
    bodyColor: scheme.onSurface,
    displayColor: scheme.onSurface,
  );

  return base.copyWith(
    scaffoldBackgroundColor: scheme.surface,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: const StadiumBorder(),
        textStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shape: const StadiumBorder(),
        textStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      labelStyle: textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      selectedColor: scheme.primaryContainer,
      secondarySelectedColor: scheme.primaryContainer,
      showCheckmark: false,
    ),
    sliderTheme: base.sliderTheme.copyWith(
      trackHeight: 8,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 11),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 22),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return scheme.onPrimary;
        }
        return scheme.outline;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return scheme.primary;
        }
        return scheme.surfaceContainerHighest;
      }),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 78,
      elevation: 3,
      shadowColor: scheme.shadow,
      surfaceTintColor: scheme.surfaceTint,
      backgroundColor: scheme.surface,
      indicatorColor: scheme.secondaryContainer,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return textTheme.labelMedium?.copyWith(
          color:
              selected ? scheme.primary : scheme.onSurfaceVariant,
          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color:
              selected ? scheme.primary : scheme.onSurfaceVariant,
          size: selected ? 26 : 24,
        );
      }),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      surfaceTintColor: scheme.surfaceTint,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    cardTheme: CardThemeData(
      color: scheme.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: scheme.surfaceTint,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
    expansionTileTheme: ExpansionTileThemeData(
      shape: const RoundedRectangleBorder(side: BorderSide.none),
      collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
      tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      iconColor: scheme.primary,
      collapsedIconColor: scheme.onSurfaceVariant,
    ),
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: scheme.surfaceTint,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(28),
          right: Radius.zero,
        ),
      ),
    ),
  );
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  bool get _supportsForegroundTask {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  bool get _supportsQuickActions {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  /// ============================================================================
  /// SERVICE LAYER - Dependency injection for business logic
  /// ============================================================================
  /// Each service is a singleton responsible for specific domain logic.
  /// Services handle persistence, calculations, and external system integration.

  /// Manages quick actions (home screen shortcuts) for rapid timer start
  final QuickActions _quickActions = const QuickActions();

  /// MethodChannel for receiving widget button actions from native Android
  static const MethodChannel _widgetChannel = MethodChannel(
    'com.atherpulse.solasflow/widget',
  );

  /// MethodChannel for checking system permissions
  static const MethodChannel _permissionsChannel = MethodChannel(
    'com.atherpulse.solasflow/permissions',
  );

  /// Check if accessibility service is enabled for auto-start on reboot
  Future<bool> checkAccessibilityEnabled() async {
    try {
      return await _permissionsChannel.invokeMethod('isAccessibilityEnabled') ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> openAccessibilitySettings() async {
    try {
      await _permissionsChannel.invokeMethod('openAccessibilitySettings');
    } catch (_) {}
  }

  /// Plays ambient background sounds (rain, waterfall, fire, stream)
  /// Handles volume and audio session management
  final AudioService _audioService = AudioService();

  /// Loads/saves AppSettings from SharedPreferences with versioned migrations
  /// Ensures data compatibility across app versions
  final SettingsService _settingsService = SettingsService();

  /// Queues TTS (text-to-speech) and ringtone announcements
  /// Ensures speech items play sequentially (no overlaps)
  final SpeechService _speechService = SpeechService();

  /// Handles Malayalam-specific TTS voice selection and synthesis
  /// Provides fallback to English if Malayalam unavailable
  final MalayalamTtsService _malayalamTtsService = MalayalamTtsService();

  /// Singleton voice session manager for consistent language selection
  final VoiceSessionManager _voiceSessionManager = VoiceSessionManager();

  /// Manages timer countdown logic: starts, pauses, resumes, calculates display
  /// Handles announcement timings based on user preferences
  final TimerService _timerService = TimerService();

  /// Cycles through motivational quotes by category
  /// Encapsulates quote rotation state and list management
  final QuoteRotationService _quoteRotationService = QuoteRotationService();

  /// Manages Android foreground service & persistent notifications
  /// Keeps app alive during long timer sessions
  final ForegroundNotificationService _foregroundNotificationService =
      const ForegroundNotificationService(
        notificationIconMetaDataName:
            'com.atherpulse.solasflow.service.NOTIFICATION_ICON',
      );

  /// ============================================================================
  /// TTS & SPEECH STATE - Text-to-speech management
  /// ============================================================================
  /// Manages voice synthesis, queue management, and concurrent speech exclusion

  /// Flutter TTS instance for speech synthesis
  FlutterTts flutterTts = FlutterTts();

  /// True when TTS engine is initialized and callable.
  bool _ttsReady = false;

  /// Single-flight guard to prevent concurrent init races.
  Future<void>? _ttsInitInFlight;

  /// Backoff gate for repeated initialization failures.
  DateTime _nextTtsInitAllowedAt = DateTime.fromMillisecondsSinceEpoch(0);

  /// Queue of pending speech items (announcements, quotes, affirmations)
  List<SpeechItem> speechQueue = [];

  /// Flag to prevent concurrent speech playback (TTS can't overlap)
  bool isSpeechActive = false;

  /// List of available TTS voices fetched from system
  List<Map<dynamic, dynamic>> voices = [];

  /// Current voice index in the voices list
  int voiceIndex = 0;

  /// Voice language mode: auto / english / malayalam
  String voiceListMode = 'auto';

  /// Speech engine mode: auto / system_only / sherpa_only
  String speechEngineMode = 'auto';

  /// User's preferred voice name (cached from settings)
  String? favoriteVoiceName;

  /// Locale of the user's preferred voice (e.g., 'en-US', 'ml-IN')
  String? favoriteVoiceLocale;

  /// Flag indicating if background audio is currently playing
  bool audioPlaying = false;

  /// ============================================================================
  /// TIMER STATE - Timer display & countdown management
  /// ============================================================================
  /// Tracks timer value, intervals, and completion status

  /// Slider input value (0-120 minutes) from timer UI
  int sliderValue = 25;

  /// Current countdown seconds remaining
  int seconds = 0;

  /// Active countdown interval timer (null when stopped)
  Timer? timerInterval;

  /// Formatted display string (MM:SS)
  String timerValue = "00:00";

  /// Timer text used by UI (supports optional centiseconds)
  String timerDisplayValue = "00:00";

  /// ============================================================================
  /// CLOCK STATE - Clock display & periodic announcements
  /// ============================================================================
  /// Manages clock time display and interval-based time announcements

  /// Periodic timer for clock time updates
  Timer? clockTimer;

  /// Display ticker: updates UI at 250ms intervals (reduced from 30ms for performance)
  Timer? displayTick;

  /// Current time formatted for display (HH:MM or HH:MM:SS)
  String currentTimeDisplay = "";

  /// 30-second health check timer for foreground service recovery
  /// Detects if OS killed the service and restarts it
  Timer? foregroundHealthTimer;

  /// Counter for idle notification ticks (used with 4:1 throttle ratio)
  int _idleNotificationTicks = 0;

  /// Timestamp of last notification sync to prevent excessive updates
  int lastNotificationSyncMs = 0;

  /// Currently active tab index (0=SpeakClock, 1=Timer Setup, 2=Stopwatch, 3=Goals, 4=Settings)
  int currentTabIndex = 1;

  /// ============================================================================
  /// ANNOUNCEMENT TIMING - 10-second gap enforcement between speech segments
  /// ============================================================================
  /// Prevents rapid repeated announcements from overlapping

  /// Timestamp of last clock announcement (prevents <10s re-announcements)
  int lastClockSpoke = 0;

  /// Timestamp of last timer announcement (prevents <10s re-announcements)
  int lastTimerSpoke = 0;

  /// Timestamp of last stopwatch announcement (prevents <10s re-announcements)
  int lastStopwatchSpoke = 0;

  /// Timestamp of last goal reminder announcement
  int lastGoalReminderSpoke = 0;

  /// Stopwatch ticker interval
  Timer? stopwatchInterval;

  /// Internal high-precision stopwatch engine
  final Stopwatch _stopwatchEngine = Stopwatch();

  /// Elapsed stopwatch seconds
  int stopwatchElapsedSeconds = 0;

  /// Formatted elapsed stopwatch display (MM:SS or HH:MM:SS)
  String stopwatchElapsedValue = '00:00';

  /// Enable/disable periodic stopwatch announcements
  bool stopwatchSpeakOn = true;

  /// Show centiseconds in timer display
  bool timerShowMilliseconds = false;

  /// Show centiseconds in stopwatch display
  bool stopwatchShowMilliseconds = false;

  /// Speak stopwatch elapsed announcement every N seconds
  int stopwatchSpeakDelaySeconds = 60;

  /// Guard to avoid repeated auto-announcements within the same elapsed second
  int _lastStopwatchAutoAnnouncedSecond = -1;

  /// ============================================================================
  /// PREFERENCES STATE - User-configurable settings (loaded from storage)
  /// ============================================================================
  /// All preference variables mirror keys in lib/core/pref_keys.dart

  /// Currently selected background sound file path
  String soundChosen = "audio/rain.mp3";

  /// Volume level for background ambient audio (0.0-1.0)
  double noiseVolume = 1.0;

  /// Volume level for speech/TTS output (0.0-1.0)
  double speakVolume = 1.0;

  /// Combine boost + max device volume in one toggle
  bool maximumSpeechVolume = false;

  /// Global speech on/off — when OFF, suppresses ALL speech
  bool speechMasterOn = true;

  /// Enable/disable clock announcements
  bool clockOn = false;

  /// Clock announcement interval in minutes
  int clockIntervalMins = 30;

  /// Show milliseconds in speaking clock display
  bool clockShowMilliseconds = true;
  /// Show seconds in speaking clock display (when false, only hours:minutes shown)
  bool clockShowSeconds = true;

  /// Enable/disable announcing the time (speech) during clock
  bool clockSpeakTime = true;

  /// Number of times each clock time announcement should be repeated
  int clockSpeakRepeatCount = 1;

  /// Enable/disable background noise during clock
  bool clockNoiseOn = false;

  /// Enable/disable motivational quote announcements
  bool motivationOn = true;

  /// Category of quotes to use (General, Malayalam, Focus, etc.)
  String motivationCategory = 'General';

  /// Delay between quote announcements in seconds
  int motivationDelaySeconds = 10;

  /// Enable/disable background noise during timer
  bool timerNoiseOn = true;

  /// Enable/disable periodic goal reminders
  bool goalReminderOn = false;

  /// Accessibility service enabled for auto-start after reboot
  bool _accessibilityEnabled = false;

  /// Goal reminder interval in minutes
  int goalReminderIntervalMins = 60;

  /// Round-robin list of user goals
  List<String> goalReminderItems = [];

  /// Next goal index for reminders
  int goalReminderNextIndex = 0;

  /// Use dark theme for app UI
  bool appDarkTheme = false;

  /// Automatically mute speech after midnight threshold
  bool muteSpeechAfterMidnight = false;

  /// Night mute mode: 'manual' or 'auto' (with sleep window)
  String nightMuteMode = 'manual';

  /// Start of auto-mute window in minutes since midnight (e.g., 2400 = 12 AM + 400 min)
  int sleepStartMinutes = 0;

  /// End of auto-mute window in minutes since midnight
  int sleepEndMinutes = 360;

  /// Flag: auto-mute is currently active in the sleep window
  bool autoNightMuteActive = false;

  /// Timer for managing idle auto-mute countdown
  Timer? nightIdleTimer;

  /// Timer for resuming speech after auto-mute duration expires
  Timer? nightResumeSpeechTimer;

  /// Periodic timer for goal reminders
  Timer? goalReminderTimer;

  /// Use dark theme in fullscreen focus mode
  bool fullscreenDarkTheme = true;

  /// Dim screen brightness in fullscreen focus mode
  bool fullscreenDimBrightness = false;

  /// Start fullscreen focus mode in landscape orientation
  bool fullscreenStartLandscape = false;

  /// Enable/disable timer completion announcements
  bool timerSpeakOn = true;

  /// Announce timer every N minutes during countdown
  int timerAnnounceEvery = 1;

  /// Enable/disable chain mode (consecutive presets)
  bool chainModeOn = false;

  /// Name of current preset being used in chain mode
  String chainPresetKey = 'Pomodoro 25-5x4';

  /// Index of current preset in chain sequence
  int chainIndex = 0;

  /// Currently running timer duration in seconds (used by "Repeat same timer")
  int _activeTimerDurationSeconds = 0;

  /// Last completed timer duration in seconds
  int _lastFinishedTimerDurationSeconds = 25 * 60;

  /// Guards against stacking multiple completion dialogs.
  bool _timerFinishedDialogOpen = false;

  /// True while the focus fullscreen route is on top.
  bool _fullscreenFocusOpen = false;

  /// Presets shown in the timer-finished popup.
  final List<int> _timerFinishedPresetMinutes = [
    1,
    2,
    3,
    5,
    10,
    15,
    20,
    25,
    30,
    35,
    40,
    45,
    50,
    60,
    75,
    90,
    120,
  ];

  /// ============================================================================
  /// PRESET CONFIGURATIONS - Predefined timer sequences & options
  /// ============================================================================
  /// These define user-selectable options for different timer modes

  /// Named chains of timer durations (in minutes) to run consecutively
  /// Useful for Pomodoro technique: work 25min, break 5min (4 cycles), long break 15min
  final Map<String, List<int>> chainPresets = {
    'Pomodoro 25-5x4': [25, 5, 25, 5, 25, 5, 25, 15], // Classic Pomodoro
    'Sprint 50-10x2': [50, 10, 50, 10], // Long focus + short breaks
    'Quick 15-3x3': [15, 3, 15, 3, 15, 3], // Fast-paced cycles
  };

  /// Sound file path for timer completion notification
  final String notifySound = "audio/notify.mp3";

  /// Available ambient background sounds with user-friendly names
  final List<SoundOption> soundList = [
    SoundOption("audio/rain.mp3", "Rain"),
    SoundOption("audio/waterfall.mp3", "Waterfall"),
    SoundOption("audio/fire.mp3", "Fire"),
    SoundOption("audio/stream.mp3", "Stream"),
  ];

  /// Available volume levels (0.0-1.0) for numerical selection
  final List<double> volumeLists = [0.1, 0.2, 0.6, 0.8, 1.0];

  /// Quick preset timer values (in minutes) for rapid timer setup
  final List<int> presetValues = [
    1, 2, 5, 10, 15,
    20, 25, 30, 45, 60,
    3, 7, 12, 35, 90,
  ];

  /// Available clock announcement intervals (in minutes)
  final List<int> clockIntervalOptions = [1, 2, 5, 10, 15, 20, 30, 60];

  /// Allowed repetitions for each clock speech announcement
  final List<int> clockSpeakRepeatOptions = [1, 2, 3];

  /// Timer announcement frequency options (announce every N minutes)
  final List<int> timerAnnounceOptions = [1, 2, 5, 10, 15, 20, 30];

  /// Stopwatch speech delay options (in seconds)
  final List<int> stopwatchSpeakDelayOptions = [
    15,
    30,
    45,
    60,
    120,
    300,
    600,
    900,
    1800,
  ];

  /// Delay options between motivational quote announcements (in seconds)
  final List<int> motivationDelayOptions = [5, 10, 20, 30, 40, 60];

  /// Goal reminder interval options in minutes
  final List<int> goalReminderIntervalOptions = [30, 60, 120, 180, 240];

  /// SharedPreferences key for last timer seconds via quick action
  static const String _lastTimerSecondsKey = 'QuickActionLastSeconds';

  // Flag to avoid asking for battery optimization multiple times
  static const String _batteryOptimizationAskedKey = 'BatteryOptAsked';

  Future<void> _requestPermissions() async {
    if (!_supportsForegroundTask) return;
    final prefs = await SharedPreferences.getInstance();
    final bool hasAskedBattery =
        prefs.getBool(_batteryOptimizationAskedKey) ?? false;

    if (!hasAskedBattery &&
        await FlutterForegroundTask.isIgnoringBatteryOptimizations == false) {
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      await prefs.setBool(_batteryOptimizationAskedKey, true);
    }
    final NotificationPermission status =
        await FlutterForegroundTask.checkNotificationPermission();
    if (status != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
  }

  void _initForegroundTask() {
    if (!_supportsForegroundTask) return;
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'solasflow_fg',
        channelName: 'SolasFlow',
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
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: true,
        allowAutoRestart: true,
        stopWithTask: false,
      ),
    );
  }

  String _formatCurrentTime(DateTime now) {
    final withMs = _timerService.formatCurrentTime(now);
    final parts = withMs.split(' ');
    final timePartWithFraction = parts.first; // e.g. 03:45:30.125
    final suffix = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    final timeWithoutFraction = timePartWithFraction.split('.').first; // 03:45:30
    final hmParts = timeWithoutFraction.split(':');
    final hm = hmParts.length >= 2
        ? '${hmParts[0]}:${hmParts[1]}'
        : timeWithoutFraction;

    if (!clockShowSeconds) {
      return suffix.isEmpty ? hm : '$hm $suffix';
    }

    if (clockShowMilliseconds) {
      return withMs;
    }

    return suffix.isEmpty
        ? timeWithoutFraction
        : '$timeWithoutFraction $suffix';
  }

  ForegroundNotificationState _foregroundState() {
    final idleTime = currentTimeDisplay.isNotEmpty
        ? currentTimeDisplay
        : _formatCurrentTime(DateTime.now());

    return ForegroundNotificationState(
      isTimerRunning: timerInterval != null,
      isStopwatchRunning: stopwatchInterval != null,
      timerValue: timerDisplayValue,
      stopwatchValue: stopwatchElapsedValue,
      currentTimeDisplay: idleTime,
      clockSpeechOn: clockOn,
      speechMasterOn: speechMasterOn,
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
    if (!_supportsForegroundTask) return;
    await _requestPermissions();
    await _ensureForegroundServiceRunning();
  }

  void _startForegroundHealthCheck() {
    foregroundHealthTimer?.cancel();
    foregroundHealthTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      if (timerInterval == null && stopwatchInterval == null && !clockOn) {
        return;
      }
      unawaited(_ensureForegroundServiceRunning());
      unawaited(_syncForegroundNotification(force: true));
    });
  }

  Future<void> _saveLastTimerSeconds(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastTimerSecondsKey, value);
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
      case 'toggle_speech_master':
        setState(() {
          speechMasterOn = !speechMasterOn;
          if (!speechMasterOn) {
            speechQueue.clear();
            unawaited(flutterTts.stop());
          }
          _lsSave();
        });
        _syncForegroundNotification(force: true);
        break;
    }
  }

  void _initQuickActions() {
    if (!_supportsQuickActions) {
      _startForegroundHealthCheck();
      return;
    }

    try {
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
    } on MissingPluginException {
      debugPrint('QuickActions plugin unavailable on this platform/runtime.');
    } on PlatformException catch (e) {
      debugPrint('QuickActions failed: $e');
    }

    _startForegroundHealthCheck();
  }

  void _openSettings() {
    final settingsVoices = _availableVoicesForSettings();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SettingsPanel(
          soundChosen: soundChosen,
          noiseVolume: noiseVolume,
          speakVolume: speakVolume,
          maximumSpeechVolume: maximumSpeechVolume,
          speechMasterOn: speechMasterOn,
          appFontSizeMultiplier: appFontSizeNotifier.value,
          onAppFontSizeMultiplierChanged: (val) {
            if (val != null) {
              setState(() {
                setAppFontSizeMultiplier(val);
                _lsSave();
              });
            }
          },
          fullscreenDarkTheme: fullscreenDarkTheme,
          fullscreenDimBrightness: fullscreenDimBrightness,
          fullscreenStartLandscape: fullscreenStartLandscape,
          muteSpeechAfterMidnight: muteSpeechAfterMidnight,
          nightMuteMode: nightMuteMode,
          sleepStartLabel: _formatMinutesAs12Hour(sleepStartMinutes),
          sleepEndLabel: _formatMinutesAs12Hour(sleepEndMinutes),
          soundList: soundList,
          volumeLists: volumeLists,
          isSpeechActive: isSpeechActive,
          speechQueueLength: speechQueue.length,
          voiceListMode: voiceListMode,
          speechEngineMode: speechEngineMode,
          speechEngineRuntime: _speechService.lastEngineUsed,
          speechEngineRuntimeDetail: _speechService.lastEngineDetail,
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
          onMaximumSpeechVolumeChanged: (val) {
            setState(() {
              maximumSpeechVolume = val ?? false;
              _lsSave();
            });
          },
          onSpeechMasterOnChanged: (val) {
            setState(() {
              speechMasterOn = val ?? true;
              if (!speechMasterOn) {
                speechQueue.clear();
                unawaited(flutterTts.stop());
              }
              _lsSave();
            });
          },
          onFullscreenDarkThemeChanged: (val) {
            setState(() {
              fullscreenDarkTheme = val ?? true;
              _lsSave();
            });
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
              if (_isSpeechMutedForSleep()) speechQueue.clear();
              _lsSave();
            });
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
              if (_isSpeechMutedForSleep()) speechQueue.clear();
              _lsSave();
            });
          },
          onPickSleepStart: () => unawaited(_pickSleepStartTime()),
          onPickSleepEnd: () => unawaited(_pickSleepEndTime()),
          onVoiceListModeChanged: (val) {
            if (val == null) return;
            _voiceSessionManager.resetSession();
            speechQueue.clear();
            unawaited(flutterTts.stop());
            setState(() {
              voiceListMode = _speechService.normalizeVoiceLanguageMode(val);
              final available = _availableVoicesForSettings();
              final hasFavorite = available.any(
                (voice) =>
                    voice['name']?.toString() == favoriteVoiceName &&
                    voice['locale']?.toString() == favoriteVoiceLocale,
              );
              if (!hasFavorite) {
                favoriteVoiceName = null;
                favoriteVoiceLocale = null;
              }
              _lsSave();
            });
          },
          onSpeechEngineModeChanged: (val) {
            if (val == null) return;
            setState(() {
              speechEngineMode = _speechService.normalizeSpeechEngineMode(val);
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
          accessibilityEnabled: _accessibilityEnabled,
          onOpenAccessibility: () async {
            final enabled = await checkAccessibilityEnabled();
            if (enabled) {
              if (mounted) setState(() => _accessibilityEnabled = true);
              return;
            }
            await openAccessibilitySettings();
          },
          onOpenHelp: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => _buildHelpTab()),
            );
          },
        ),
      ),
    );
  }

  Future<void> _openFullscreenFocus({
    FullscreenFocusMode? specificMode,
    bool forceHorizontal = false,
    bool startImmersive = false,
  }) async {
    final initialMode =
        specificMode ??
        (currentTabIndex == 2
            ? FullscreenFocusMode.moduleC
            : (timerInterval != null || currentTabIndex == 1
                  ? FullscreenFocusMode.timer
                  : FullscreenFocusMode.clock));
    _fullscreenFocusOpen = true;
    await Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => FullscreenFocusView(
              initialMode: initialMode,
              initialDarkTheme: fullscreenDarkTheme,
              initialDimBrightness: fullscreenDimBrightness,
              initialForceLandscape: forceHorizontal
                  ? true
                  : fullscreenStartLandscape,
              startImmersive: startImmersive,
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
              timerTextBuilder: () => timerDisplayValue,
              isTimerRunningBuilder: () => timerInterval != null,
              stopwatchTextBuilder: () => stopwatchElapsedValue,
              isStopwatchRunningBuilder: () => stopwatchInterval != null,
              onTimerStart: startTimer,
              onTimerStop: stopTimer,
              onTimerReset: resetTimer,
              onStopwatchStart: startStopwatch,
              onStopwatchStop: stopStopwatch,
              onStopwatchReset: resetStopwatch,
            ),
          ),
        )
        .whenComplete(() {
          _fullscreenFocusOpen = false;
        });
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
        case 'btn_speech_master':
          setState(() {
            speechMasterOn = !speechMasterOn;
            if (!speechMasterOn) {
              speechQueue.clear();
              unawaited(flutterTts.stop());
            }
            _lsSave();
          });
          _syncForegroundNotification(force: true);
          break;
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
          _applyAudioSettings();
          _syncForegroundNotification(force: true);
          break;
        case 'btn_stopwatch_toggle':
          if (stopwatchInterval != null) {
            stopStopwatch();
          } else {
            startStopwatch();
          }
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
    _initWidgetChannel();
    // Add callback to handle notification button presses
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);

    displayTick = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (!mounted) return;

      final display = _formatCurrentTime(DateTime.now());
      final timerDisplay = _formatTimerDisplayValue(seconds);
      final stopwatchDisplay = _formatStopwatchElapsed(
        stopwatchElapsedSeconds,
        showMilliseconds: stopwatchShowMilliseconds,
      );
      if (display != currentTimeDisplay) {
        setState(() {
          currentTimeDisplay = display;
          timerDisplayValue = timerDisplay;
          stopwatchElapsedValue = stopwatchDisplay;
        });
      } else if (timerDisplay != timerDisplayValue ||
          stopwatchDisplay != stopwatchElapsedValue) {
        setState(() {
          timerDisplayValue = timerDisplay;
          stopwatchElapsedValue = stopwatchDisplay;
        });
      }

      if (timerInterval == null) {
        _idleNotificationTicks = (_idleNotificationTicks + 1) % 4;
        if (_idleNotificationTicks == 0) {
          _syncForegroundNotification();
        }
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
      maximumSpeechVolume = settings.maximumSpeechVolume;
      clockOn = settings.clockOn;
      clockIntervalMins = settings.clockIntervalMins;
      clockShowMilliseconds = settings.clockShowMilliseconds;
      clockShowSeconds = settings.clockShowSeconds;
      clockSpeakTime = settings.clockSpeakTime;
      clockSpeakRepeatCount = settings.clockSpeakRepeatCount.clamp(1, 3);
      clockNoiseOn = settings.clockNoiseOn;
      motivationOn = settings.motivationOn;
      motivationCategory = settings.motivationCategory;
      motivationDelaySeconds = settings.motivationDelaySeconds;
      timerSpeakOn = settings.timerSpeakOn;
      timerAnnounceEvery = settings.timerAnnounceEvery;
      timerShowMilliseconds = settings.timerShowMilliseconds;
      timerNoiseOn = settings.timerNoiseOn;
      goalReminderOn = settings.goalReminderOn;
      goalReminderIntervalMins = settings.goalReminderIntervalMins;
      goalReminderItems = List<String>.from(settings.goalReminderItems);
      goalReminderNextIndex = settings.goalReminderNextIndex;
      stopwatchShowMilliseconds = settings.stopwatchShowMilliseconds;
      stopwatchSpeakDelaySeconds = settings.stopwatchSpeakDelaySeconds;
      appDarkTheme = settings.appDarkTheme;
      muteSpeechAfterMidnight = settings.muteSpeechAfterMidnight;
      nightMuteMode = settings.nightMuteMode;
      sleepStartMinutes = settings.sleepStartMinutes;
      sleepEndMinutes = settings.sleepEndMinutes;
      fullscreenDarkTheme = settings.fullscreenDarkTheme;
      fullscreenDimBrightness = settings.fullscreenDimBrightness;
      fullscreenStartLandscape = settings.fullscreenStartLandscape;
      voiceListMode = _speechService.normalizeVoiceLanguageMode(
        settings.voiceListMode,
      );
      speechEngineMode = _speechService.normalizeSpeechEngineMode(
        settings.speechEngineMode,
      );
      favoriteVoiceName = settings.favoriteVoiceName;
      favoriteVoiceLocale = settings.favoriteVoiceLocale;
      speechMasterOn = settings.speechMasterOn;
      setAppFontSizeMultiplier(settings.appFontSizeMultiplier);

      if (!motivationCategories.contains(motivationCategory)) {
        motivationCategory = 'General';
      }
      if (!motivationDelayOptions.contains(motivationDelaySeconds)) {
        motivationDelaySeconds = 10;
      }
      if (!stopwatchSpeakDelayOptions.contains(stopwatchSpeakDelaySeconds)) {
        stopwatchSpeakDelaySeconds = 60;
      }
      if (!goalReminderIntervalOptions.contains(goalReminderIntervalMins)) {
        goalReminderIntervalMins = 60;
      }
      goalReminderItems = goalReminderItems
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
      if (goalReminderItems.isEmpty) {
        goalReminderNextIndex = 0;
      } else {
        goalReminderNextIndex =
            goalReminderNextIndex % goalReminderItems.length;
      }
      if (nightMuteMode != 'manual' && nightMuteMode != 'automatic') {
        nightMuteMode = 'manual';
      }
      speechEngineMode = _speechService.normalizeSpeechEngineMode(
        speechEngineMode,
      );
      sleepStartMinutes = sleepStartMinutes.clamp(0, 1439);
      sleepEndMinutes = sleepEndMinutes.clamp(0, 1439);
      timerDisplayValue = _formatTimerDisplayValue(seconds);
      stopwatchElapsedValue = _formatStopwatchElapsed(
        stopwatchElapsedSeconds,
        showMilliseconds: stopwatchShowMilliseconds,
      );
    });

    _applyAudioSettings();
    setAppThemeMode(appDarkTheme);
    _restartGoalReminderTimer();
    unawaited(_writeWidgetState());
    if (clockOn) {
      Future.delayed(const Duration(milliseconds: 200), startClock);
    }
    // Check accessibility status
    unawaited(_refreshAccessibilityStatus());
  }

  Future<void> _refreshAccessibilityStatus() async {
    debugPrint('[A11y-DEBUG] _refreshAccessibilityStatus() called');
    final enabled = await checkAccessibilityEnabled();
    debugPrint('[A11y-DEBUG] _refreshAccessibilityStatus() result: $enabled (was: $_accessibilityEnabled)');
    if (mounted) {
      setState(() => _accessibilityEnabled = enabled);
    }
  }

  AppSettings _currentSettingsSnapshot() {
    return AppSettings(
      soundChosen: soundChosen,
      noiseVolume: noiseVolume,
      speakVolume: speakVolume,
      maximumSpeechVolume: maximumSpeechVolume,
      clockOn: clockOn,
      clockIntervalMins: clockIntervalMins,
      clockShowMilliseconds: clockShowMilliseconds,
      clockShowSeconds: clockShowSeconds,
      clockSpeakTime: clockSpeakTime,
      clockSpeakRepeatCount: clockSpeakRepeatCount,
      clockNoiseOn: clockNoiseOn,
      motivationOn: motivationOn,
      motivationCategory: motivationCategory,
      motivationDelaySeconds: motivationDelaySeconds,
      timerSpeakOn: timerSpeakOn,
      timerAnnounceEvery: timerAnnounceEvery,
      timerShowMilliseconds: timerShowMilliseconds,
      timerNoiseOn: timerNoiseOn,
      goalReminderOn: goalReminderOn,
      goalReminderIntervalMins: goalReminderIntervalMins,
      goalReminderItems: goalReminderItems,
      goalReminderNextIndex: goalReminderNextIndex,
      stopwatchShowMilliseconds: stopwatchShowMilliseconds,
      stopwatchSpeakDelaySeconds: stopwatchSpeakDelaySeconds,
      appDarkTheme: appDarkTheme,
      muteSpeechAfterMidnight: muteSpeechAfterMidnight,
      nightMuteMode: nightMuteMode,
      sleepStartMinutes: sleepStartMinutes,
      sleepEndMinutes: sleepEndMinutes,
      fullscreenDarkTheme: fullscreenDarkTheme,
      fullscreenDimBrightness: fullscreenDimBrightness,
      fullscreenStartLandscape: fullscreenStartLandscape,
      voiceListMode: voiceListMode,
      speechEngineMode: speechEngineMode,
      favoriteVoiceName: favoriteVoiceName,
      favoriteVoiceLocale: favoriteVoiceLocale,
      speechMasterOn: speechMasterOn,
      appFontSizeMultiplier: appFontSizeNotifier.value,
    );
  }

  void _lsSave() {
    unawaited(_settingsService.save(_currentSettingsSnapshot()));
    unawaited(_writeWidgetState());
  }

  /// Writes current toggle states + timer display to Android SharedPreferences
  /// so home screen widgets can display correct on/off labels without the app open.
  Future<void> _writeWidgetState() async {
    if (!Platform.isAndroid) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('widget_clock_on', clockOn);
      await prefs.setBool('widget_timer_speak', timerSpeakOn);
      await prefs.setBool('widget_stopwatch_speak', stopwatchSpeakOn);
      await prefs.setBool('widget_goals_on', goalReminderOn);
      await prefs.setBool('widget_speech_master', speechMasterOn);
      await prefs.setString('widget_timer_display', timerDisplayValue);
      // Ask native to refresh widget UI
      await _widgetChannel.invokeMethod('refreshWidgets');
    } catch (_) {}
  }

  /// Sets up the MethodChannel listener for widget button actions sent from MainActivity.
  void _initWidgetChannel() {
    _widgetChannel.setMethodCallHandler((call) async {
      if (call.method == 'widgetAction') {
        final action = call.arguments as String?;
        if (action != null) unawaited(_handleWidgetAction(action));
      }
    });
  }

  /// Handles actions arriving from home screen widget button taps.
  Future<void> _handleWidgetAction(String type) async {
    if (!mounted) return;
    // Map preset durations
    const presetMap = {
      'start_5m': 5,
      'start_10m': 10,
      'start_15m': 15,
      'start_20m': 20,
      'start_25m': 25,
      'start_30m': 30,
      'start_45m': 45,
      'start_60m': 60,
      'start_90m': 90,
      'start_120m': 120,
    };

    if (presetMap.containsKey(type)) {
      final mins = presetMap[type]!;
      setState(() {
        currentTabIndex = 1;
        chainModeOn = false;
        seconds = mins * 60;
        final m = mins.toString().padLeft(2, '0');
        timerValue = '$m:00';
      });
      startTimer();
      _openFullscreenFocus(
        specificMode: FullscreenFocusMode.timer,
        forceHorizontal: true,
        startImmersive: true,
      );
      return;
    }

    switch (type) {
      case 'resume_last':
        await _handleQuickAction('resume_last');
        break;
      case 'open_fullscreen_clock':
        setState(() {
          currentTabIndex = 0;
        });
        _openFullscreenFocus(
          specificMode: FullscreenFocusMode.clock,
          forceHorizontal: true,
          startImmersive: true,
        );
        break;
      case 'start_timer_fullscreen':
        setState(() {
          currentTabIndex = 1;
        });
        startTimer();
        _openFullscreenFocus(
          specificMode: FullscreenFocusMode.timer,
          forceHorizontal: true,
          startImmersive: true,
        );
        break;
      case 'start_stopwatch_fullscreen':
        setState(() {
          currentTabIndex = 2;
        });
        startStopwatch();
        _openFullscreenFocus(
          specificMode: FullscreenFocusMode.moduleC,
          forceHorizontal: true,
          startImmersive: true,
        );
        break;
      case 'toggle_clock_speech':
        setState(() {
          clockOn = !clockOn;
          _lsSave();
          if (clockOn) {
            startClock();
          } else {
            stopClock();
          }
        });
        _applyAudioSettings();
        unawaited(_syncForegroundNotification(force: true));
        break;
      case 'toggle_timer_speech':
        setState(() {
          timerSpeakOn = !timerSpeakOn;
          _lsSave();
        });
        break;
      case 'toggle_stopwatch_speech':
        setState(() {
          stopwatchSpeakOn = !stopwatchSpeakOn;
          _lsSave();
        });
        break;
      case 'toggle_speech_master':
        setState(() {
          speechMasterOn = !speechMasterOn;
          if (!speechMasterOn) {
            speechQueue.clear();
            unawaited(flutterTts.stop());
          }
          _lsSave();
        });
        _syncForegroundNotification(force: true);
        break;
      case 'toggle_goals_speech':
        setState(() {
          goalReminderOn = !goalReminderOn;
          _lsSave();
          _restartGoalReminderTimer();
        });
        break;
    }
  }

  void _initAudio() {
    unawaited(_audioService.init());
  }

  void _applyAudioSettings() {
    final bool shouldTimerPlay = timerInterval != null && timerNoiseOn;
    final bool shouldClockPlay = clockOn && clockNoiseOn;
    final bool shouldPlay = shouldTimerPlay || shouldClockPlay;

    if (audioPlaying != shouldPlay) {
      if (mounted) {
        setState(() {
          audioPlaying = shouldPlay;
        });
      } else {
        audioPlaying = shouldPlay;
      }
    }

    if (shouldPlay) {
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

  void _restartGoalReminderTimer() {
    goalReminderTimer?.cancel();
    goalReminderTimer = null;

    if (!goalReminderOn || goalReminderItems.isEmpty) {
      return;
    }

    goalReminderTimer = Timer.periodic(
      Duration(minutes: goalReminderIntervalMins),
      (_) {
        if (!mounted) return;
        _announceNextGoalReminder();
      },
    );
  }

  Future<void> _showGoalInputDialog({int? editIndex}) async {
    final isEdit = editIndex != null;
    final initialText = isEdit ? goalReminderItems[editIndex] : '';
    final controller = TextEditingController(text: initialText);

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'Edit goal' : 'Add goal'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Write one important goal',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == null) return;
    final trimmed = result.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      if (isEdit) {
        goalReminderItems[editIndex] = trimmed;
      } else {
        goalReminderItems.add(trimmed);
      }

      if (goalReminderItems.isEmpty) {
        goalReminderNextIndex = 0;
      } else {
        goalReminderNextIndex =
            goalReminderNextIndex % goalReminderItems.length;
      }
      _lsSave();
    });
    _restartGoalReminderTimer();
  }

  Future<void> _showBulkGoalInputDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Bulk add goals'),
          content: TextField(
            controller: controller,
            autofocus: true,
            minLines: 6,
            maxLines: 12,
            decoration: const InputDecoration(hintText: 'One goal per line'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Add lines'),
            ),
          ],
        );
      },
    );

    if (result == null) return;
    final lines = result
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    if (lines.isEmpty) return;

    setState(() {
      goalReminderItems.addAll(lines);
      if (goalReminderItems.isEmpty) {
        goalReminderNextIndex = 0;
      } else {
        goalReminderNextIndex =
            goalReminderNextIndex % goalReminderItems.length;
      }
      _lsSave();
    });
    _restartGoalReminderTimer();
  }

  void _removeGoalAt(int index) {
    if (index < 0 || index >= goalReminderItems.length) return;

    setState(() {
      goalReminderItems.removeAt(index);
      if (goalReminderItems.isEmpty) {
        goalReminderNextIndex = 0;
      } else {
        goalReminderNextIndex =
            goalReminderNextIndex % goalReminderItems.length;
      }
      _lsSave();
    });
    _restartGoalReminderTimer();
  }

  void _speakGoalReminderMessage(String text) {
    if (_isSpeechMutedForSleep()) {
      speechQueue.clear();
      return;
    }
    _speakAfterGap(
      text: text,
      getLatestOtherSpoke: () => max(
        max(lastClockSpoke, lastTimerSpoke),
        lastStopwatchSpoke,
      ),
      markSpoke: () => lastGoalReminderSpoke = DateTime.now().millisecondsSinceEpoch,
      onFire: () => speak(text),
    );
  }

  void _announceNextGoalReminder({bool force = false}) {
    if ((!goalReminderOn && !force) || goalReminderItems.isEmpty) return;

    final index = goalReminderNextIndex % goalReminderItems.length;
    final goal = goalReminderItems[index];

    setState(() {
      goalReminderNextIndex = (index + 1) % goalReminderItems.length;
      _lsSave();
    });

    _speakGoalReminderMessage('Goal reminder: $goal');
  }

  Future<bool> _initTts({bool forceRebind = false}) async {
    if (forceRebind) {
      _ttsReady = false;
      _nextTtsInitAllowedAt = DateTime.fromMillisecondsSinceEpoch(0);
      flutterTts = FlutterTts();
    }

    if (!_ttsReady && DateTime.now().isBefore(_nextTtsInitAllowedAt)) {
      return false;
    }

    if (_ttsInitInFlight != null) {
      await _ttsInitInFlight;
      return _ttsReady;
    }

    final completer = Completer<void>();
    _ttsInitInFlight = completer.future;

    try {
      _ttsReady = false;

      flutterTts.setErrorHandler((message) {
        _ttsReady = false;
        debugPrint('TTS error: $message');
      });

      try {
        await flutterTts.awaitSpeakCompletion(true);
      } on MissingPluginException {
        _nextTtsInitAllowedAt = DateTime.now().add(const Duration(seconds: 20));
        debugPrint('flutter_tts plugin unavailable on this platform/runtime.');
        return false;
      } on PlatformException catch (e) {
        _nextTtsInitAllowedAt = DateTime.now().add(const Duration(seconds: 20));
        debugPrint('flutter_tts init failed: $e');
        return false;
      }

      dynamic fetchedVoices;
      const maxAttempts = 4;
      for (var attempt = 1; attempt <= maxAttempts; attempt++) {
        try {
          fetchedVoices = await flutterTts.getVoices;
          final loadedVoices = _speechService.parseSupportedVoices(
            fetchedVoices,
          );
          if (loadedVoices.isNotEmpty) {
            if (mounted) {
              setState(() {
                voices = loadedVoices;
              });
            } else {
              voices = loadedVoices;
            }
            _ttsReady = true;
            break;
          }
        } catch (e) {
          debugPrint('TTS getVoices attempt $attempt failed: $e');
        }
        await Future.delayed(Duration(milliseconds: 250 * attempt));
      }

      if (!_ttsReady) {
        // Avoid hammering the TTS engine if it is unavailable on device.
        _nextTtsInitAllowedAt = DateTime.now().add(const Duration(seconds: 12));
        debugPrint('TTS init unavailable; next retry after cooldown.');
      }
    } finally {
      completer.complete();
      _ttsInitInFlight = null;
    }

    return _ttsReady;
  }

  Future<bool> _ensureTtsReady({bool forceRebind = false}) async {
    if (_ttsReady && !forceRebind) return true;
    return _initTts(forceRebind: forceRebind);
  }

  List<Map<dynamic, dynamic>> _availableVoicesForSettings() {
    return _speechService.availableVoicesForSettings(
      voices: voices,
      voiceListMode: voiceListMode,
    );
  }

  Map<dynamic, dynamic>? getPreferredVoice() {
    return _voiceSessionManager.getPreferredVoice(
      voiceResolver: () => _speechService.preferredVoice(
        voices: voices,
        voiceListMode: voiceListMode,
        favoriteVoiceName: favoriteVoiceName,
        favoriteVoiceLocale: favoriteVoiceLocale,
      ),
      voiceListMode: voiceListMode,
      favoriteVoiceName: favoriteVoiceName,
      favoriteVoiceLocale: favoriteVoiceLocale,
    );
  }

  bool _isMalayalamActive(Map<dynamic, dynamic>? preferredVoice) {
    return _voiceSessionManager.isMalayalamActive(
      isMalayalamResolver: (voice) => _malayalamTtsService.isMalayalamMode(
        voiceListMode: voiceListMode,
        preferredVoice: voice,
      ),
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

    final normalizedEngineMode = _speechService.normalizeSpeechEngineMode(
      speechEngineMode,
    );
    final desktopPlatform = Platform.isLinux || Platform.isWindows;
    final desktopSherpaOnly =
        desktopPlatform && normalizedEngineMode == 'sherpa_only';

    // On desktop, speech service can still use Sherpa/espeak without flutter_tts plugin.
    if (!desktopSherpaOnly && !desktopPlatform) {
      final ready = await _ensureTtsReady();
      if (!ready) {
        if (mounted) {
          setState(() {
            isSpeechActive = false;
          });
        }
        // Drop pending items when engine is unavailable to prevent retry loops.
        speechQueue.clear();
        return;
      }
    }

    final pv = getPreferredVoice();
    final useMalayalam = _isMalayalamActive(pv);
    try {
      await _speechService.speakItem(
        flutterTts: flutterTts,
        item: item,
        speakVolume: speakVolume,
        maximumSpeechVolume: maximumSpeechVolume,
        preferredVoice: pv,
        useMalayalamNuance: useMalayalam,
        speechEngineMode: speechEngineMode,
      );
    } catch (e) {
      debugPrint('TTS speak failed, retrying after rebind: $e');
      try {
        final rebound = await _ensureTtsReady(forceRebind: true);
        if (!rebound) {
          throw Exception('TTS rebind unavailable');
        }
        final retryVoice = getPreferredVoice();
        await _speechService.speakItem(
          flutterTts: flutterTts,
          item: item,
          speakVolume: speakVolume,
          maximumSpeechVolume: maximumSpeechVolume,
          preferredVoice: retryVoice,
          useMalayalamNuance: _isMalayalamActive(retryVoice),
          speechEngineMode: speechEngineMode,
        );
      } catch (retryError) {
        debugPrint('TTS retry failed: $retryError');
      }
    }

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
    final pv = getPreferredVoice();
    final useMalayalam = _isMalayalamActive(pv);
    final language = useMalayalam ? 'ml' : 'en';
    speechQueue.add(SpeechItem(text, language: language));
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
    debugPrint('[A11y-DEBUG] didChangeAppLifecycleState: $state, _accessibilityEnabled=$_accessibilityEnabled');
    _handleNightUsageStateChange(state);
    if (state == AppLifecycleState.resumed) {
      debugPrint('[A11y-DEBUG] App resumed — refreshing accessibility status');
      unawaited(_refreshAccessibilityStatus());
    }
  }

  bool _isSpeechMutedForSleep() {
    // Global speech master toggle — when OFF, suppress everything
    if (!speechMasterOn) return true;

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

  /// Centralized speech gap enforcement: ensures 10-second gap between different
  /// announcement types (clock, timer, stopwatch, goal reminders) to prevent
  /// overlapping speech. Replaces 4 duplicated implementations.
  void _speakAfterGap({
    required String text,
    required int Function() getLatestOtherSpoke,
    required void Function() markSpoke,
    required VoidCallback onFire,
  }) {
    const gap = 10000;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final latestOther = getLatestOtherSpoke();
    final waitMs = max(0, gap - (nowMs - latestOther));
    Future.delayed(Duration(milliseconds: waitMs), () {
      markSpoke();
      onFire();
    });
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
    if (clockSpeakTime) {
      speakClock(timeToWords());
    }
    clockTimer = Timer.periodic(Duration(minutes: clockIntervalMins), (timer) {
      if (clockSpeakTime) {
        speakClock(timeToWords());
      }
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
    _applyAudioSettings();
  }

  void speakClock(String text) {
    if (_isSpeechMutedForSleep()) {
      speechQueue.clear();
      return;
    }
    _speakAfterGap(
      text: text,
      getLatestOtherSpoke: () => max(
        max(lastTimerSpoke, lastStopwatchSpoke),
        lastGoalReminderSpoke,
      ),
      markSpoke: () => lastClockSpoke = DateTime.now().millisecondsSinceEpoch,
      onFire: () {
        final repeatCount = clockSpeakRepeatCount.clamp(1, 3);
        for (var i = 0; i < repeatCount; i++) {
          speechQueue.add(SpeechItem(text, delayMs: i == 0 ? 0 : 350));
        }
        if (motivationOn) {
          final quoteText = _nextQuoteForCategory(motivationCategory);
          speechQueue.add(
            SpeechItem(quoteText, isQuote: true, delayMs: motivationDelaySeconds * 1000),
          );
        }
        drainQueue();
      },
    );
  }

  String _nextQuoteForCategory(String category) {
    final preferredVoice = getPreferredVoice();
    final useMalayalam = _isMalayalamActive(preferredVoice);

    if (useMalayalam) {
      final categoryQuotes = _malayalamTtsService.quotesForCategory(category);
      return _quoteRotationService.nextQuoteForList(
        key: category,
        quotes: categoryQuotes,
        fallbackQuote: _malayalamTtsService.defaultQuote(),
      );
    }

    return _quoteRotationService.nextQuoteFromMap(
      category: category,
      quotesByCategory: quotesByCategory,
      fallbackCategory: 'General',
      fallbackQuote: 'Stay steady and use this moment well.',
    );
  }

  void speakTimerMessage(String text) {
    if (_isSpeechMutedForSleep()) {
      speechQueue.clear();
      return;
    }
    _speakAfterGap(
      text: text,
      getLatestOtherSpoke: () => max(
        max(lastClockSpoke, lastStopwatchSpoke),
        lastGoalReminderSpoke,
      ),
      markSpoke: () => lastTimerSpoke = DateTime.now().millisecondsSinceEpoch,
      onFire: () => speak(text),
    );
  }

  String _formatTimerDisplayValue(int totalSeconds) {
    final mins = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  String _formatStopwatchElapsed(
    int totalSeconds, {
    bool showMilliseconds = false,
  }) {
    final elapsedMs = _stopwatchEngine.elapsedMilliseconds;
    final totalForView = stopwatchInterval != null
        ? (elapsedMs ~/ 1000)
        : totalSeconds;
    final hours = totalForView ~/ 3600;
    final minutes = (totalForView % 3600) ~/ 60;
    final secs = totalForView % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _stopwatchElapsedSpeechText() {
    final hours = stopwatchElapsedSeconds ~/ 3600;
    final minutes = (stopwatchElapsedSeconds % 3600) ~/ 60;
    final secs = stopwatchElapsedSeconds % 60;

    final parts = <String>[];
    if (hours > 0) {
      parts.add('$hours hour${hours == 1 ? '' : 's'}');
    }
    if (minutes > 0) {
      parts.add('$minutes minute${minutes == 1 ? '' : 's'}');
    }
    if (secs > 0 || parts.isEmpty) {
      parts.add('$secs second${secs == 1 ? '' : 's'}');
    }

    return 'Elapsed ${parts.join(', ')}';
  }

  void _speakStopwatchMessage(String text) {
    if (_isSpeechMutedForSleep()) {
      speechQueue.clear();
      return;
    }
    _speakAfterGap(
      text: text,
      getLatestOtherSpoke: () => max(
        max(lastClockSpoke, lastTimerSpoke),
        lastGoalReminderSpoke,
      ),
      markSpoke: () => lastStopwatchSpoke = DateTime.now().millisecondsSinceEpoch,
      onFire: () => speak(text),
    );
  }

  void _tickStopwatch(Timer timer) {
    setState(() {
      stopwatchElapsedSeconds = _stopwatchEngine.elapsed.inSeconds;
      stopwatchElapsedValue = _formatStopwatchElapsed(
        stopwatchElapsedSeconds,
        showMilliseconds: stopwatchShowMilliseconds,
      );

      _syncForegroundNotification(force: true);

      if (stopwatchSpeakOn &&
          stopwatchElapsedSeconds > 0 &&
          stopwatchElapsedSeconds % stopwatchSpeakDelaySeconds == 0 &&
          stopwatchElapsedSeconds != _lastStopwatchAutoAnnouncedSecond) {
        _lastStopwatchAutoAnnouncedSecond = stopwatchElapsedSeconds;
        _speakStopwatchMessage(_stopwatchElapsedSpeechText());
      }
    });
  }

  void startStopwatch() {
    if (stopwatchInterval != null) return;
    _stopwatchEngine.start();
    setState(() {
      stopwatchInterval = Timer.periodic(
        const Duration(milliseconds: 50),
        _tickStopwatch,
      );
    });
  }

  void stopStopwatch() {
    _stopwatchEngine.stop();
    stopwatchInterval?.cancel();
    stopwatchInterval = null;
  }

  void resetStopwatch() {
    stopStopwatch();
    _stopwatchEngine.reset();
    setState(() {
      stopwatchElapsedSeconds = 0;
      _lastStopwatchAutoAnnouncedSecond = -1;
      stopwatchElapsedValue = _formatStopwatchElapsed(
        0,
        showMilliseconds: stopwatchShowMilliseconds,
      );
    });
  }

  void speakStopwatchElapsedNow() {
    _speakStopwatchMessage(_stopwatchElapsedSpeechText());
  }

  void tick(Timer timer) {
    bool showTimerFinishedDialog = false;
    setState(() {
      final tickResult = _timerService.tick(
        seconds: seconds,
        timerSpeakOn: timerSpeakOn,
        timerAnnounceEvery: timerAnnounceEvery,
      );

      seconds = tickResult.nextSeconds;
      timerValue = tickResult.timerValue;
      timerDisplayValue = _formatTimerDisplayValue(seconds);

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
            _activeTimerDurationSeconds = seconds;
            timerValue = '${nextMinutes.toString().padLeft(2, '0')}:00';
            timerDisplayValue = _formatTimerDisplayValue(seconds);
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

        _lastFinishedTimerDurationSeconds =
            _activeTimerDurationSeconds > 0
            ? _activeTimerDurationSeconds
            : sliderValue * 60;

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
          Future.delayed(const Duration(seconds: 5), () {
            FlutterRingtonePlayer().stop();
          });
        } else {
          unawaited(
            _audioService.playNotification(
              assetPath: notifySound,
              stopAfter: const Duration(seconds: 5),
            ),
          );
        }

        showTimerFinishedDialog = true;
      }
    });

    if (showTimerFinishedDialog) {
      unawaited(_showTimerFinishedDialog());
    }
  }

  void _startTimerFromMinutes(int minutes) {
    final safeMinutes = minutes.clamp(1, 720).toInt();
    FlutterRingtonePlayer().stop();
    stopTimer();
    setState(() {
      chainModeOn = false;
      chainIndex = 0;
      sliderValue = safeMinutes;
      seconds = safeMinutes * 60;
      timerValue = '${safeMinutes.toString().padLeft(2, '0')}:00';
      timerDisplayValue = _formatTimerDisplayValue(seconds);
      _activeTimerDurationSeconds = seconds;
    });
    startTimer();
  }

  Future<void> _showTimerFinishedDialog() async {
    if (!mounted || _timerFinishedDialogOpen) return;

    _timerFinishedDialogOpen = true;
    final selectedMinutes = _fullscreenFocusOpen
        ? await _showFullscreenTimerFinishedDialog()
        : await _showNormalTimerFinishedDialog();
    FlutterRingtonePlayer().stop();
    _timerFinishedDialogOpen = false;

    if (!mounted) return;
    if (selectedMinutes == null) {
      if (_fullscreenFocusOpen) {
        await Navigator.of(context, rootNavigator: true).maybePop();
      }
      return;
    }
    _startTimerFromMinutes(selectedMinutes);
  }

  Future<int?> _showNormalTimerFinishedDialog() async {
    final customController = TextEditingController();
    String? inputError;

    final selectedMinutes = await showDialog<int>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Timer finished'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        final repeatMinutes =
                            (_lastFinishedTimerDurationSeconds ~/ 60)
                                .clamp(1, 720)
                                .toInt();
                        Navigator.of(dialogContext).pop(repeatMinutes);
                      },
                      icon: const Icon(Icons.replay_rounded),
                      label: const Text('Repeat Same Timer'),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Start New Preset Timer',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _timerFinishedPresetMinutes.map((mins) {
                        return ActionChip(
                          label: Text('$mins min'),
                          onPressed: () {
                            Navigator.of(dialogContext).pop(mins);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: customController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Custom duration (minutes)',
                        errorText: inputError,
                      ),
                      onSubmitted: (_) {
                        final minutes = int.tryParse(
                          customController.text.trim(),
                        );
                        if (minutes == null || minutes < 1 || minutes > 720) {
                          setDialogState(() {
                            inputError = 'Enter a value between 1 and 720';
                          });
                          return;
                        }
                        Navigator.of(dialogContext).pop(minutes);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Exit / Close Timer'),
            ),
            FilledButton(
              onPressed: () {
                final minutes = int.tryParse(customController.text.trim());
                if (minutes == null || minutes < 1 || minutes > 720) {
                  return;
                }
                Navigator.of(dialogContext).pop(minutes);
              },
              child: const Text('Start custom'),
            ),
          ],
        );
      },
    );

    customController.dispose();
    return selectedMinutes;
  }

  Future<int?> _showFullscreenTimerFinishedDialog() {

    return showDialog<int>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      builder: (dialogContext) {
        final cs = Theme.of(dialogContext).colorScheme;
        final fg = cs.onSurface;
        final bg = cs.surface;
        final surface = cs.surfaceContainerLow;
        final variant = cs.onSurfaceVariant;
        final outline = cs.outlineVariant;
        final primary = cs.primary;
        final selectedBg = cs.primaryContainer;

        Widget presetButton(int mins) {
          return Material(
            color: surface,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.of(dialogContext).pop(mins),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: outline),
                ),
                child: Center(
                  child: Text(
                    '$mins min',
                    style: TextStyle(
                      color: fg,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return Dialog.fullscreen(
          backgroundColor: bg,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton.filledTonal(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: IconButton.styleFrom(
                          backgroundColor: selectedBg,
                          foregroundColor: fg,
                        ),
                        icon: const Icon(Icons.close_rounded),
                      ),
                      const Spacer(),
                      Text(
                        'Timer finished',
                        style: TextStyle(
                          color: fg,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: FilledButton.icon(
                      onPressed: () {
                        final repeatMinutes =
                            (_lastFinishedTimerDurationSeconds ~/ 60).clamp(
                              1,
                              720,
                            ).toInt();
                        Navigator.of(dialogContext).pop(repeatMinutes);
                      },
                      icon: const Icon(Icons.replay_rounded),
                      label: const Text('Repeat Same Timer'),
                      style: FilledButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: cs.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Start New Preset Timer',
                      style: TextStyle(
                        color: variant,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: GridView.builder(
                      itemCount: _timerFinishedPresetMinutes.length,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 150,
                            mainAxisExtent: 64,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                          ),
                      itemBuilder: (context, index) =>
                          presetButton(_timerFinishedPresetMinutes[index]),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Exit / Close Timer'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: fg,
                        side: BorderSide(color: outline),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
      _activeTimerDurationSeconds = seconds;
    } else if (_activeTimerDurationSeconds <= 0) {
      _activeTimerDurationSeconds = seconds;
    }
    timerValue = _formatTimerDisplayValue(seconds).split('.').first;
    timerDisplayValue = _formatTimerDisplayValue(seconds);
    if (timerInterval != null) return;

    try {
      await _ensureForegroundServiceRunning();
    } catch (e) {
      debugPrint('FOREGROUND TASK ERROR: $e');
    }

    setState(() {
      timerInterval = Timer.periodic(const Duration(seconds: 1), tick);
    });
    unawaited(_saveLastTimerSeconds(seconds > 0 ? seconds : sliderValue * 60));
    _applyAudioSettings();
    _syncForegroundNotification(force: true);
  }

  void stopTimer() {
    if (seconds > 0) {
      unawaited(_saveLastTimerSeconds(seconds));
    }
    timerInterval?.cancel();
    timerInterval = null;
    _applyAudioSettings();
    _syncForegroundNotification(force: true);
  }

  void resetTimer() {
    stopTimer();
    setState(() {
      seconds = 0;
      timerValue = "00:00";
      timerDisplayValue = _formatTimerDisplayValue(0);
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
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: ColoredBox(
        color: cs.surface,
        child: ClockPanel(
          onExitApp: () => unawaited(_exitAppFully()),
          onFullscreenPressed: () => _openFullscreenFocus(
            specificMode: FullscreenFocusMode.clock,
            forceHorizontal: true,
          ),
          onFullscreenImmersivePressed: () => _openFullscreenFocus(
            specificMode: FullscreenFocusMode.clock,
            forceHorizontal: true,
            startImmersive: true,
          ),
          currentTimeDisplay: currentTimeDisplay,
          clockIntervalMins: clockIntervalMins,
          clockShowMilliseconds: clockShowMilliseconds,
          clockSpeakTime: clockSpeakTime,
          clockSpeakRepeatCount: clockSpeakRepeatCount,
          clockNoiseOn: clockNoiseOn,
          motivationOn: motivationOn,
          motivationCategory: motivationCategory,
          motivationDelaySeconds: motivationDelaySeconds,
          clockIntervalOptions: clockIntervalOptions,
          clockSpeakRepeatOptions: clockSpeakRepeatOptions,
          motivationCategories: motivationCategories,
          motivationDelayOptions: motivationDelayOptions,
          clockShowSeconds: clockShowSeconds,
          onClockIntervalChanged: (val) {
            if (val == null) return;
            setState(() {
              clockIntervalMins = val;
              _lsSave();
            });
            if (clockOn) startClock();
          },
          onClockShowMillisecondsChanged: (val) {
            setState(() {
              clockShowMilliseconds = val ?? true;
              currentTimeDisplay = _formatCurrentTime(DateTime.now());
              _lsSave();
            });
          },
          onClockShowSecondsChanged: (val) {
            setState(() {
              clockShowSeconds = val ?? true;
              currentTimeDisplay = _formatCurrentTime(DateTime.now());
              _lsSave();
            });
          },
          onClockSpeakTimeChanged: (val) {
            final nowOn = val ?? true;
            final needsStart = nowOn && !clockOn;
            setState(() {
              clockSpeakTime = nowOn;
              if (needsStart) clockOn = true;
              _lsSave();
            });
            if (needsStart) startClock();
            if (nowOn) speakClock(timeToWords());
          },
          onClockSpeakRepeatCountChanged: (val) {
            if (val == null) return;
            setState(() {
              clockSpeakRepeatCount = val.clamp(1, 3);
              _lsSave();
            });
          },
          onClockNoiseOnChanged: (val) {
            final nowOn = val ?? false;
            final needsStart = nowOn && !clockOn;
            setState(() {
              clockNoiseOn = nowOn;
              if (needsStart) clockOn = true;
              _lsSave();
            });
            if (needsStart) startClock();
            _applyAudioSettings();
          },
          onMotivationChanged: (val) {
            final nowOn = val ?? true;
            final needsStart = nowOn && !clockOn;
            setState(() {
              motivationOn = nowOn;
              if (needsStart) clockOn = true;
              _lsSave();
            });
            if (needsStart) startClock();
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
      ),
    );
  }

  Widget _buildTimerSetupTab() {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: ColoredBox(
        color: cs.surface,
        child: TimerPanel(
          onExitApp: () => unawaited(_exitAppFully()),
          onFullscreenPressed: () => _openFullscreenFocus(
            specificMode: FullscreenFocusMode.timer,
            forceHorizontal: true,
          ),
          onFullscreenImmersivePressed: () => _openFullscreenFocus(
            specificMode: FullscreenFocusMode.timer,
            forceHorizontal: true,
            startImmersive: true,
          ),
          timerValue: timerDisplayValue,
          sliderValue: sliderValue,
          remainingSeconds: seconds,
          voicesCount: voices.length,
          isRunning: timerInterval != null,
          presetValues: presetValues,
          startTimer: startTimer,
          stopTimer: stopTimer,
          resetTimer: resetTimer,
          choosePreset: choosePreset,
          onSliderChanged: (val) {
            setState(() {
              sliderValue = val.toInt();
            });
          },
          timerNoiseOn: timerNoiseOn,
          timerSpeakOn: timerSpeakOn,
          timerShowMilliseconds: timerShowMilliseconds,
          timerAnnounceEvery: timerAnnounceEvery,
          chainModeOn: chainModeOn,
          chainPresetKey: chainPresetKey,
          chainPresets: chainPresets,
          chainIndex: chainIndex,
          timerAnnounceOptions: timerAnnounceOptions,
          onTimerNoiseOnChanged: (val) {
            setState(() {
              timerNoiseOn = val ?? true;
              _lsSave();
            });
            _applyAudioSettings();
          },
          onTimerSpeakOnChanged: (val) {
            setState(() {
              timerSpeakOn = val ?? true;
              _lsSave();
            });
          },
          onTimerShowMillisecondsChanged: (val) {
            setState(() {
              timerShowMilliseconds = val ?? false;
              timerDisplayValue = _formatTimerDisplayValue(seconds);
              _lsSave();
            });
          },
          onTimerAnnounceEveryChanged: (val) {
            if (val == null) return;
            setState(() {
              timerAnnounceEvery = val;
              _lsSave();
            });
          },
          onChainModeChanged: (val) {
            setState(() {
              chainModeOn = val ?? false;
              chainIndex = 0;
              _lsSave();
            });
          },
          onChainPresetChanged: (val) {
            if (val == null) return;
            setState(() {
              chainPresetKey = val;
              chainIndex = 0;
              _lsSave();
            });
          },
        ),
      ),
    );
  }

  int _lapCount = 0;
  List<String> _lapTimes = [];

  void _recordLap() {
    setState(() {
      _lapCount++;
      _lapTimes.insert(0, 'Lap $_lapCount  $stopwatchElapsedValue');
    });
  }

  Widget _buildStopwatchTab() {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: ColoredBox(
        color: cs.surface,
        child: StopwatchPanel(
          onExitApp: () => unawaited(_exitAppFully()),
          onFullscreenPressed: () => _openFullscreenFocus(
            specificMode: FullscreenFocusMode.moduleC,
            forceHorizontal: true,
          ),
          onFullscreenImmersivePressed: () => _openFullscreenFocus(
            specificMode: FullscreenFocusMode.moduleC,
            forceHorizontal: true,
            startImmersive: true,
          ),
          elapsedValue: stopwatchElapsedValue,
          isRunning: stopwatchInterval != null,
          startStopwatch: startStopwatch,
          stopStopwatch: stopStopwatch,
          resetStopwatch: () {
            resetStopwatch();
            setState(() {
              _lapCount = 0;
              _lapTimes = [];
            });
          },
          onLap: _recordLap,
          lapCount: _lapCount,
          lapTimes: _lapTimes,
          stopwatchSpeakOn: stopwatchSpeakOn,
          stopwatchShowMilliseconds: stopwatchShowMilliseconds,
          stopwatchSpeakDelaySeconds: stopwatchSpeakDelaySeconds,
          stopwatchSpeakDelayOptions: stopwatchSpeakDelayOptions,
          onStopwatchSpeakOnChanged: (val) {
            setState(() {
              stopwatchSpeakOn = val ?? true;
              _lsSave();
            });
          },
          onStopwatchShowMillisecondsChanged: (val) {
            setState(() {
              stopwatchShowMilliseconds = val ?? false;
              stopwatchElapsedValue = _formatStopwatchElapsed(
                stopwatchElapsedSeconds,
                showMilliseconds: stopwatchShowMilliseconds,
              );
              _lsSave();
            });
          },
          onStopwatchSpeakDelayChanged: (val) {
            if (val == null) return;
            setState(() {
              stopwatchSpeakDelaySeconds = val;
              _lastStopwatchAutoAnnouncedSecond = -1;
              _lsSave();
            });
          },
        ),
      ),
    );
  }

  Widget _buildHelpTab() {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: cs.primary),
        title: Text(
          AppLocalizations.of(context)?.helpTitle ?? 'Help / Working',
          style: TextStyle(
            color: cs.primary,
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
    foregroundHealthTimer?.cancel();
    nightIdleTimer?.cancel();
    nightResumeSpeechTimer?.cancel();
    goalReminderTimer?.cancel();
    stopClock();
    stopTimer();
    stopStopwatch();
    displayTick?.cancel();
    unawaited(_audioService.dispose());
    // Remove callback to avoid memory leaks
    FlutterForegroundTask.removeTaskDataCallback(_onReceiveTaskData);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tabLabels = ['Clock', 'Timer', 'Stopwatch'];
    final appTitle = currentTabIndex == 0
        ? 'Clock'
        : currentTabIndex == 1
            ? 'Timer'
            : 'Stopwatch';

    return OrientationBuilder(
      builder: (context, orientation) {
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 56,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: scheme.surface,
            foregroundColor: scheme.onSurface,
            title: Text(
              appTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.tune_rounded),
              tooltip: 'Settings',
              onPressed: _openSettings,
            ),
            actions: [
              IconButton(
                onPressed: _openFullscreenFocus,
                tooltip: 'Focus mode',
                icon: const Icon(Icons.fullscreen_rounded),
              ),
              IconButton(
                onPressed: () => unawaited(_exitAppFully()),
                tooltip: 'Shutdown',
                icon: const Icon(Icons.power_settings_new_rounded),
                style: IconButton.styleFrom(
                  foregroundColor: scheme.error,
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final offsetAnim =
                  Tween<Offset>(
                    begin: const Offset(0, 0.03),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  );
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: offsetAnim,
                  child: child,
                ),
              );
            },
            child: KeyedSubtree(
              key: ValueKey<int>(currentTabIndex),
              child: currentTabIndex == 0
                  ? _buildSpeakClockTab()
                  : (currentTabIndex == 1
                        ? _buildTimerSetupTab()
                        : _buildStopwatchTab()),
            ),
          ),
          bottomNavigationBar: orientation == Orientation.portrait
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    NavigationBar(
                      selectedIndex: currentTabIndex,
                      labelBehavior:
                          NavigationDestinationLabelBehavior.alwaysShow,
                      onDestinationSelected: (index) {
                        setState(() {
                          currentTabIndex = index;
                        });
                      },
                      destinations: [
                        NavigationDestination(
                          icon: Icon(Icons.access_time_outlined),
                          selectedIcon: Icon(Icons.access_time_rounded),
                          label: tabLabels[0],
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.hourglass_empty_rounded),
                          selectedIcon: Icon(Icons.hourglass_full_rounded),
                          label: tabLabels[1],
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.av_timer_outlined),
                          selectedIcon: Icon(Icons.av_timer_rounded),
                          label: tabLabels[2],
                        ),
                      ],
                    ),
                  ],
                )
              : null,
        );
      },
    );
  }
}
