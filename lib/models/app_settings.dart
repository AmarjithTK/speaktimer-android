class AppSettings {
  final String soundChosen;
  final double noiseVolume;
  final double speakVolume;
  final bool clockOn;
  final int clockIntervalMins;
  final bool motivationOn;
  final String motivationCategory;
  final int motivationDelaySeconds;
  final bool timerSpeakOn;
  final int timerAnnounceEvery;
  final bool timerNoiseOn;
  final bool muteSpeechAfterMidnight;
  final String nightMuteMode;
  final int sleepStartMinutes;
  final int sleepEndMinutes;
  final bool appDarkTheme;
  final bool fullscreenDarkTheme;
  final bool fullscreenDimBrightness;
  final bool fullscreenStartLandscape;
  final String voiceListMode;
  final String? favoriteVoiceName;
  final String? favoriteVoiceLocale;

  const AppSettings({
    required this.soundChosen,
    required this.noiseVolume,
    required this.speakVolume,
    required this.clockOn,
    required this.clockIntervalMins,
    required this.motivationOn,
    required this.motivationCategory,
    required this.motivationDelaySeconds,
    required this.timerSpeakOn,
    required this.timerAnnounceEvery,
    required this.timerNoiseOn,
    required this.muteSpeechAfterMidnight,
    required this.nightMuteMode,
    required this.sleepStartMinutes,
    required this.sleepEndMinutes,
    required this.appDarkTheme,
    required this.fullscreenDarkTheme,
    required this.fullscreenDimBrightness,
    required this.fullscreenStartLandscape,
    required this.voiceListMode,
    required this.favoriteVoiceName,
    required this.favoriteVoiceLocale,
  });
}
