class AppSettings {
  final String soundChosen;
  final double noiseVolume;
  final double speakVolume;
  final bool clockOn;
  final int clockIntervalMins;
  final bool motivationOn;
  final bool timerSpeakOn;
  final int timerAnnounceEvery;
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
    required this.timerSpeakOn,
    required this.timerAnnounceEvery,
    required this.voiceListMode,
    required this.favoriteVoiceName,
    required this.favoriteVoiceLocale,
  });
}