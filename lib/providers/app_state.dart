import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_settings.dart';

// ═══════════════════════════════════════════════════════════════════════════
// SETTINGS STATE — All user preferences in one reactive container
// ═══════════════════════════════════════════════════════════════════════════

class SettingsState {
  final String soundChosen;
  final double noiseVolume;
  final double speakVolume;
  final bool maximumSpeechVolume;
  final bool clockOn;
  final int clockIntervalMins;
  final bool clockShowMilliseconds;
  final bool clockShowSeconds;
  final bool clockSpeakTime;
  final int clockSpeakRepeatCount;
  final bool clockNoiseOn;
  final bool motivationOn;
  final String motivationCategory;
  final int motivationDelaySeconds;
  final bool timerSpeakOn;
  final int timerAnnounceEvery;
  final bool timerShowMilliseconds;
  final bool timerNoiseOn;
  final bool goalReminderOn;
  final int goalReminderIntervalMins;
  final List<String> goalReminderItems;
  final int goalReminderNextIndex;
  final bool stopwatchShowMilliseconds;
  final int stopwatchSpeakDelaySeconds;
  final bool muteSpeechAfterMidnight;
  final String nightMuteMode;
  final int sleepStartMinutes;
  final int sleepEndMinutes;
  final bool appDarkTheme;
  final bool fullscreenDarkTheme;
  final bool fullscreenDimBrightness;
  final bool fullscreenStartLandscape;
  final String voiceListMode;
  final String speechEngineMode;
  final String? favoriteVoiceName;
  final String? favoriteVoiceLocale;
  final bool speechMasterOn;
  final double appFontSizeMultiplier;

  const SettingsState({
    required this.soundChosen,
    required this.noiseVolume,
    required this.speakVolume,
    required this.maximumSpeechVolume,
    required this.clockOn,
    required this.clockIntervalMins,
    required this.clockShowMilliseconds,
    required this.clockShowSeconds,
    required this.clockSpeakTime,
    required this.clockSpeakRepeatCount,
    required this.clockNoiseOn,
    required this.motivationOn,
    required this.motivationCategory,
    required this.motivationDelaySeconds,
    required this.timerSpeakOn,
    required this.timerAnnounceEvery,
    required this.timerShowMilliseconds,
    required this.timerNoiseOn,
    required this.goalReminderOn,
    required this.goalReminderIntervalMins,
    required this.goalReminderItems,
    required this.goalReminderNextIndex,
    required this.stopwatchShowMilliseconds,
    required this.stopwatchSpeakDelaySeconds,
    required this.muteSpeechAfterMidnight,
    required this.nightMuteMode,
    required this.sleepStartMinutes,
    required this.sleepEndMinutes,
    required this.appDarkTheme,
    required this.fullscreenDarkTheme,
    required this.fullscreenDimBrightness,
    required this.fullscreenStartLandscape,
    required this.voiceListMode,
    required this.speechEngineMode,
    this.favoriteVoiceName,
    this.favoriteVoiceLocale,
    required this.speechMasterOn,
    required this.appFontSizeMultiplier,
  });

  factory SettingsState.defaults() => const SettingsState(
    soundChosen: 'rain.mp3',
    noiseVolume: 1.0,
    speakVolume: 1.0,
    maximumSpeechVolume: false,
    clockOn: false,
    clockIntervalMins: 30,
    clockShowMilliseconds: true,
    clockShowSeconds: true,
    clockSpeakTime: true,
    clockSpeakRepeatCount: 1,
    clockNoiseOn: false,
    motivationOn: true,
    motivationCategory: 'General',
    motivationDelaySeconds: 10,
    timerSpeakOn: true,
    timerAnnounceEvery: 1,
    timerShowMilliseconds: false,
    timerNoiseOn: true,
    goalReminderOn: false,
    goalReminderIntervalMins: 60,
    goalReminderItems: [],
    goalReminderNextIndex: 0,
    stopwatchShowMilliseconds: false,
    stopwatchSpeakDelaySeconds: 60,
    muteSpeechAfterMidnight: false,
    nightMuteMode: 'manual',
    sleepStartMinutes: 0,
    sleepEndMinutes: 360,
    appDarkTheme: false,
    fullscreenDarkTheme: true,
    fullscreenDimBrightness: false,
    fullscreenStartLandscape: false,
    voiceListMode: 'auto',
    speechEngineMode: 'auto',
    speechMasterOn: true,
    appFontSizeMultiplier: 1.0,
  );

  factory SettingsState.fromAppSettings(AppSettings s) => SettingsState(
    soundChosen: s.soundChosen,
    noiseVolume: s.noiseVolume,
    speakVolume: s.speakVolume,
    maximumSpeechVolume: s.maximumSpeechVolume,
    clockOn: s.clockOn,
    clockIntervalMins: s.clockIntervalMins,
    clockShowMilliseconds: s.clockShowMilliseconds,
    clockShowSeconds: s.clockShowSeconds,
    clockSpeakTime: s.clockSpeakTime,
    clockSpeakRepeatCount: s.clockSpeakRepeatCount,
    clockNoiseOn: s.clockNoiseOn,
    motivationOn: s.motivationOn,
    motivationCategory: s.motivationCategory,
    motivationDelaySeconds: s.motivationDelaySeconds,
    timerSpeakOn: s.timerSpeakOn,
    timerAnnounceEvery: s.timerAnnounceEvery,
    timerShowMilliseconds: s.timerShowMilliseconds,
    timerNoiseOn: s.timerNoiseOn,
    goalReminderOn: s.goalReminderOn,
    goalReminderIntervalMins: s.goalReminderIntervalMins,
    goalReminderItems: s.goalReminderItems,
    goalReminderNextIndex: s.goalReminderNextIndex,
    stopwatchShowMilliseconds: s.stopwatchShowMilliseconds,
    stopwatchSpeakDelaySeconds: s.stopwatchSpeakDelaySeconds,
    muteSpeechAfterMidnight: s.muteSpeechAfterMidnight,
    nightMuteMode: s.nightMuteMode,
    sleepStartMinutes: s.sleepStartMinutes,
    sleepEndMinutes: s.sleepEndMinutes,
    appDarkTheme: s.appDarkTheme,
    fullscreenDarkTheme: s.fullscreenDarkTheme,
    fullscreenDimBrightness: s.fullscreenDimBrightness,
    fullscreenStartLandscape: s.fullscreenStartLandscape,
    voiceListMode: s.voiceListMode,
    speechEngineMode: s.speechEngineMode,
    favoriteVoiceName: s.favoriteVoiceName,
    favoriteVoiceLocale: s.favoriteVoiceLocale,
    speechMasterOn: s.speechMasterOn,
    appFontSizeMultiplier: s.appFontSizeMultiplier,
  );

  SettingsState copyWith({
    String? soundChosen,
    double? noiseVolume,
    double? speakVolume,
    bool? maximumSpeechVolume,
    bool? clockOn,
    int? clockIntervalMins,
    bool? clockShowMilliseconds,
    bool? clockShowSeconds,
    bool? clockSpeakTime,
    int? clockSpeakRepeatCount,
    bool? clockNoiseOn,
    bool? motivationOn,
    String? motivationCategory,
    int? motivationDelaySeconds,
    bool? timerSpeakOn,
    int? timerAnnounceEvery,
    bool? timerShowMilliseconds,
    bool? timerNoiseOn,
    bool? goalReminderOn,
    int? goalReminderIntervalMins,
    List<String>? goalReminderItems,
    int? goalReminderNextIndex,
    bool? stopwatchShowMilliseconds,
    int? stopwatchSpeakDelaySeconds,
    bool? muteSpeechAfterMidnight,
    String? nightMuteMode,
    int? sleepStartMinutes,
    int? sleepEndMinutes,
    bool? appDarkTheme,
    bool? fullscreenDarkTheme,
    bool? fullscreenDimBrightness,
    bool? fullscreenStartLandscape,
    String? voiceListMode,
    String? speechEngineMode,
    String? Function()? favoriteVoiceName,
    String? Function()? favoriteVoiceLocale,
    bool? speechMasterOn,
    double? appFontSizeMultiplier,
  }) {
    return SettingsState(
      soundChosen: soundChosen ?? this.soundChosen,
      noiseVolume: noiseVolume ?? this.noiseVolume,
      speakVolume: speakVolume ?? this.speakVolume,
      maximumSpeechVolume: maximumSpeechVolume ?? this.maximumSpeechVolume,
      clockOn: clockOn ?? this.clockOn,
      clockIntervalMins: clockIntervalMins ?? this.clockIntervalMins,
      clockShowMilliseconds: clockShowMilliseconds ?? this.clockShowMilliseconds,
      clockShowSeconds: clockShowSeconds ?? this.clockShowSeconds,
      clockSpeakTime: clockSpeakTime ?? this.clockSpeakTime,
      clockSpeakRepeatCount: clockSpeakRepeatCount ?? this.clockSpeakRepeatCount,
      clockNoiseOn: clockNoiseOn ?? this.clockNoiseOn,
      motivationOn: motivationOn ?? this.motivationOn,
      motivationCategory: motivationCategory ?? this.motivationCategory,
      motivationDelaySeconds: motivationDelaySeconds ?? this.motivationDelaySeconds,
      timerSpeakOn: timerSpeakOn ?? this.timerSpeakOn,
      timerAnnounceEvery: timerAnnounceEvery ?? this.timerAnnounceEvery,
      timerShowMilliseconds: timerShowMilliseconds ?? this.timerShowMilliseconds,
      timerNoiseOn: timerNoiseOn ?? this.timerNoiseOn,
      goalReminderOn: goalReminderOn ?? this.goalReminderOn,
      goalReminderIntervalMins: goalReminderIntervalMins ?? this.goalReminderIntervalMins,
      goalReminderItems: goalReminderItems ?? this.goalReminderItems,
      goalReminderNextIndex: goalReminderNextIndex ?? this.goalReminderNextIndex,
      stopwatchShowMilliseconds: stopwatchShowMilliseconds ?? this.stopwatchShowMilliseconds,
      stopwatchSpeakDelaySeconds: stopwatchSpeakDelaySeconds ?? this.stopwatchSpeakDelaySeconds,
      muteSpeechAfterMidnight: muteSpeechAfterMidnight ?? this.muteSpeechAfterMidnight,
      nightMuteMode: nightMuteMode ?? this.nightMuteMode,
      sleepStartMinutes: sleepStartMinutes ?? this.sleepStartMinutes,
      sleepEndMinutes: sleepEndMinutes ?? this.sleepEndMinutes,
      appDarkTheme: appDarkTheme ?? this.appDarkTheme,
      fullscreenDarkTheme: fullscreenDarkTheme ?? this.fullscreenDarkTheme,
      fullscreenDimBrightness: fullscreenDimBrightness ?? this.fullscreenDimBrightness,
      fullscreenStartLandscape: fullscreenStartLandscape ?? this.fullscreenStartLandscape,
      voiceListMode: voiceListMode ?? this.voiceListMode,
      speechEngineMode: speechEngineMode ?? this.speechEngineMode,
      favoriteVoiceName: favoriteVoiceName != null ? favoriteVoiceName() : this.favoriteVoiceName,
      favoriteVoiceLocale: favoriteVoiceLocale != null ? favoriteVoiceLocale() : this.favoriteVoiceLocale,
      speechMasterOn: speechMasterOn ?? this.speechMasterOn,
      appFontSizeMultiplier: appFontSizeMultiplier ?? this.appFontSizeMultiplier,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SETTINGS NOTIFIER (Riverpod 3.x Notifier)
// ═══════════════════════════════════════════════════════════════════════════

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() => SettingsState.defaults();

  void loadFromSettings(AppSettings settings) {
    state = SettingsState.fromAppSettings(settings);
  }

  void updateSound(String value) => state = state.copyWith(soundChosen: value);
  void updateNoiseVolume(double value) => state = state.copyWith(noiseVolume: value);
  void updateSpeakVolume(double value) => state = state.copyWith(speakVolume: value);
  void updateMaximumSpeechVolume(bool value) => state = state.copyWith(maximumSpeechVolume: value);
  void updateSpeechMasterOn(bool value) => state = state.copyWith(speechMasterOn: value);
  void updateClockOn(bool value) => state = state.copyWith(clockOn: value);
  void updateClockIntervalMins(int value) => state = state.copyWith(clockIntervalMins: value);
  void updateClockShowMilliseconds(bool value) => state = state.copyWith(clockShowMilliseconds: value);
  void updateClockShowSeconds(bool value) => state = state.copyWith(clockShowSeconds: value);
  void updateClockSpeakTime(bool value) => state = state.copyWith(clockSpeakTime: value);
  void updateClockSpeakRepeatCount(int value) => state = state.copyWith(clockSpeakRepeatCount: value);
  void updateClockNoiseOn(bool value) => state = state.copyWith(clockNoiseOn: value);
  void updateMotivationOn(bool value) => state = state.copyWith(motivationOn: value);
  void updateMotivationCategory(String value) => state = state.copyWith(motivationCategory: value);
  void updateMotivationDelaySeconds(int value) => state = state.copyWith(motivationDelaySeconds: value);
  void updateTimerSpeakOn(bool value) => state = state.copyWith(timerSpeakOn: value);
  void updateTimerAnnounceEvery(int value) => state = state.copyWith(timerAnnounceEvery: value);
  void updateTimerShowMilliseconds(bool value) => state = state.copyWith(timerShowMilliseconds: value);
  void updateTimerNoiseOn(bool value) => state = state.copyWith(timerNoiseOn: value);
  void updateMuteSpeechAfterMidnight(bool value) => state = state.copyWith(muteSpeechAfterMidnight: value);
  void updateNightMuteMode(String value) => state = state.copyWith(nightMuteMode: value);
  void updateSleepStartMinutes(int value) => state = state.copyWith(sleepStartMinutes: value);
  void updateSleepEndMinutes(int value) => state = state.copyWith(sleepEndMinutes: value);
  void updateAppDarkTheme(bool value) => state = state.copyWith(appDarkTheme: value);
  void updateFullscreenDarkTheme(bool value) => state = state.copyWith(fullscreenDarkTheme: value);
  void updateFullscreenDimBrightness(bool value) => state = state.copyWith(fullscreenDimBrightness: value);
  void updateFullscreenStartLandscape(bool value) => state = state.copyWith(fullscreenStartLandscape: value);
  void updateVoiceListMode(String value) => state = state.copyWith(voiceListMode: value);
  void updateSpeechEngineMode(String value) => state = state.copyWith(speechEngineMode: value);
  void updateFavoriteVoice(String? name, String? locale) {
    state = state.copyWith(
      favoriteVoiceName: () => name,
      favoriteVoiceLocale: () => locale,
    );
  }
  void updateAppFontSizeMultiplier(double value) => state = state.copyWith(appFontSizeMultiplier: value);
  void updateStopwatchShowMilliseconds(bool value) => state = state.copyWith(stopwatchShowMilliseconds: value);
  void updateStopwatchSpeakDelaySeconds(int value) => state = state.copyWith(stopwatchSpeakDelaySeconds: value);
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);

// ═══════════════════════════════════════════════════════════════════════════
// UI STATE — Current tab, accessibility, etc.
// ═══════════════════════════════════════════════════════════════════════════

class UiState {
  final int currentTabIndex;
  final bool isTimerFinished;

  const UiState({
    required this.currentTabIndex,
    required this.isTimerFinished,
  });

  factory UiState.defaults() => const UiState(
    currentTabIndex: 0,
    isTimerFinished: false,
  );

  UiState copyWith({int? currentTabIndex, bool? isTimerFinished}) {
    return UiState(
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      isTimerFinished: isTimerFinished ?? this.isTimerFinished,
    );
  }
}

class UiNotifier extends Notifier<UiState> {
  @override
  UiState build() => UiState.defaults();

  void setTab(int index) => state = state.copyWith(currentTabIndex: index);
  void setTimerFinished(bool value) => state = state.copyWith(isTimerFinished: value);
}

final uiProvider = NotifierProvider<UiNotifier, UiState>(
  UiNotifier.new,
);

// ═══════════════════════════════════════════════════════════════════════════
// RUNTIME STATE — Timer, Clock, Stopwatch display values
// ═══════════════════════════════════════════════════════════════════════════

class RuntimeState {
  final String timerDisplayValue;
  final int timerSliderValue;
  final int timerRemainingSeconds;
  final bool timerIsRunning;
  final int? timerArmedPresetValue;
  final bool timerChainModeOn;
  final String timerChainPresetKey;
  final int timerChainIndex;

  final String clockDisplayValue;
  final bool clockIsRunning;

  final String stopwatchDisplayValue;
  final bool stopwatchIsRunning;
  final int stopwatchLapCount;
  final List<String> stopwatchLapTimes;

  const RuntimeState({
    this.timerDisplayValue = '00:00',
    this.timerSliderValue = 25,
    this.timerRemainingSeconds = 0,
    this.timerIsRunning = false,
    this.timerArmedPresetValue,
    this.timerChainModeOn = false,
    this.timerChainPresetKey = 'Pomodoro',
    this.timerChainIndex = 0,
    this.clockDisplayValue = '',
    this.clockIsRunning = false,
    this.stopwatchDisplayValue = '00:00',
    this.stopwatchIsRunning = false,
    this.stopwatchLapCount = 0,
    this.stopwatchLapTimes = const [],
  });

  RuntimeState copyWith({
    String? timerDisplayValue,
    int? timerSliderValue,
    int? timerRemainingSeconds,
    bool? timerIsRunning,
    int? Function()? timerArmedPresetValue,
    bool? timerChainModeOn,
    String? timerChainPresetKey,
    int? timerChainIndex,
    String? clockDisplayValue,
    bool? clockIsRunning,
    String? stopwatchDisplayValue,
    bool? stopwatchIsRunning,
    int? stopwatchLapCount,
    List<String>? stopwatchLapTimes,
  }) {
    return RuntimeState(
      timerDisplayValue: timerDisplayValue ?? this.timerDisplayValue,
      timerSliderValue: timerSliderValue ?? this.timerSliderValue,
      timerRemainingSeconds: timerRemainingSeconds ?? this.timerRemainingSeconds,
      timerIsRunning: timerIsRunning ?? this.timerIsRunning,
      timerArmedPresetValue: timerArmedPresetValue != null ? timerArmedPresetValue() : this.timerArmedPresetValue,
      timerChainModeOn: timerChainModeOn ?? this.timerChainModeOn,
      timerChainPresetKey: timerChainPresetKey ?? this.timerChainPresetKey,
      timerChainIndex: timerChainIndex ?? this.timerChainIndex,
      clockDisplayValue: clockDisplayValue ?? this.clockDisplayValue,
      clockIsRunning: clockIsRunning ?? this.clockIsRunning,
      stopwatchDisplayValue: stopwatchDisplayValue ?? this.stopwatchDisplayValue,
      stopwatchIsRunning: stopwatchIsRunning ?? this.stopwatchIsRunning,
      stopwatchLapCount: stopwatchLapCount ?? this.stopwatchLapCount,
      stopwatchLapTimes: stopwatchLapTimes ?? this.stopwatchLapTimes,
    );
  }
}

class RuntimeNotifier extends Notifier<RuntimeState> {
  @override
  RuntimeState build() => const RuntimeState();

  // Timer
  void updateTimerDisplay(String value) => state = state.copyWith(timerDisplayValue: value);
  void updateTimerSlider(int value) => state = state.copyWith(timerSliderValue: value);
  void updateTimerRemaining(int value) => state = state.copyWith(timerRemainingSeconds: value);
  void updateTimerRunning(bool value) => state = state.copyWith(timerIsRunning: value);
  void updateTimerArmedPreset(int? value) => state = state.copyWith(timerArmedPresetValue: () => value);
  void updateTimerChainMode(bool value) => state = state.copyWith(timerChainModeOn: value);
  void updateTimerChainPresetKey(String value) => state = state.copyWith(timerChainPresetKey: value);
  void updateTimerChainIndex(int value) => state = state.copyWith(timerChainIndex: value);

  // Clock
  void updateClockDisplay(String value) => state = state.copyWith(clockDisplayValue: value);
  void updateClockRunning(bool value) => state = state.copyWith(clockIsRunning: value);

  // Stopwatch
  void updateStopwatchDisplay(String value) => state = state.copyWith(stopwatchDisplayValue: value);
  void updateStopwatchRunning(bool value) => state = state.copyWith(stopwatchIsRunning: value);
  void updateStopwatchLaps(int count, List<String> times) => state = state.copyWith(stopwatchLapCount: count, stopwatchLapTimes: times);
}

final runtimeProvider = NotifierProvider<RuntimeNotifier, RuntimeState>(
  RuntimeNotifier.new,
);
