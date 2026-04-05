class AppSettings {
  final String soundChosen;
  final double noiseVolume;
  final double speakVolume;
  final bool ttsMaxVolumeLockEnabled;
  final bool ttsVolumeBoostEnabled;
  final bool clockOn;
  final int clockIntervalMins;
  final bool clockShowMilliseconds;
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
  final double appFontSizeMultiplier;

  const AppSettings({
    required this.soundChosen,
    required this.noiseVolume,
    required this.speakVolume,
    required this.ttsMaxVolumeLockEnabled,
    required this.ttsVolumeBoostEnabled,
    required this.clockOn,
    required this.clockIntervalMins,
    required this.clockShowMilliseconds,
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
    required this.favoriteVoiceName,
    required this.favoriteVoiceLocale,
    required this.appFontSizeMultiplier,
  });
}
