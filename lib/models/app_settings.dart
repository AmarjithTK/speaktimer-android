class AppSettings {
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
  final bool fullscreenShowClock;
  final String voiceListMode;
  final String speechEngineMode;
  final String? favoriteVoiceName;
  final String? favoriteVoiceLocale;
  final bool speechMasterOn;
  final double appFontSizeMultiplier;
  final bool backgroundPersistenceOn;
  final double fullscreenDimBrightnessLevel;
  final bool taggingOn;
  final String sessionTag;

  const AppSettings({
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
    required this.fullscreenShowClock,
    required this.voiceListMode,
    required this.speechEngineMode,
    required this.favoriteVoiceName,
    required this.favoriteVoiceLocale,
    required this.speechMasterOn,
    required this.appFontSizeMultiplier,
    required this.backgroundPersistenceOn,
    required this.fullscreenDimBrightnessLevel,
    required this.taggingOn,
    required this.sessionTag,
  });

  // ── JSON serialization for backup/restore ──────────────────
  Map<String, dynamic> toJson() => {
    'soundChosen': soundChosen,
    'noiseVolume': noiseVolume,
    'speakVolume': speakVolume,
    'maximumSpeechVolume': maximumSpeechVolume,
    'clockOn': clockOn,
    'clockIntervalMins': clockIntervalMins,
    'clockShowMilliseconds': clockShowMilliseconds,
    'clockShowSeconds': clockShowSeconds,
    'clockSpeakTime': clockSpeakTime,
    'clockSpeakRepeatCount': clockSpeakRepeatCount,
    'clockNoiseOn': clockNoiseOn,
    'motivationOn': motivationOn,
    'motivationCategory': motivationCategory,
    'motivationDelaySeconds': motivationDelaySeconds,
    'timerSpeakOn': timerSpeakOn,
    'timerAnnounceEvery': timerAnnounceEvery,
    'timerShowMilliseconds': timerShowMilliseconds,
    'timerNoiseOn': timerNoiseOn,
    'goalReminderOn': goalReminderOn,
    'goalReminderIntervalMins': goalReminderIntervalMins,
    'goalReminderItems': goalReminderItems,
    'goalReminderNextIndex': goalReminderNextIndex,
    'stopwatchShowMilliseconds': stopwatchShowMilliseconds,
    'stopwatchSpeakDelaySeconds': stopwatchSpeakDelaySeconds,
    'muteSpeechAfterMidnight': muteSpeechAfterMidnight,
    'nightMuteMode': nightMuteMode,
    'sleepStartMinutes': sleepStartMinutes,
    'sleepEndMinutes': sleepEndMinutes,
    'appDarkTheme': appDarkTheme,
    'fullscreenDarkTheme': fullscreenDarkTheme,
    'fullscreenDimBrightness': fullscreenDimBrightness,
    'fullscreenStartLandscape': fullscreenStartLandscape,
    'fullscreenShowClock': fullscreenShowClock,
    'voiceListMode': voiceListMode,
    'speechEngineMode': speechEngineMode,
    'favoriteVoiceName': favoriteVoiceName,
    'favoriteVoiceLocale': favoriteVoiceLocale,
    'speechMasterOn': speechMasterOn,
    'appFontSizeMultiplier': appFontSizeMultiplier,
    'backgroundPersistenceOn': backgroundPersistenceOn,
    'fullscreenDimBrightnessLevel': fullscreenDimBrightnessLevel,
    'taggingOn': taggingOn,
    'sessionTag': sessionTag,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    soundChosen: json['soundChosen'] as String? ?? 'audio/rain.mp3',
    noiseVolume: (json['noiseVolume'] as num?)?.toDouble() ?? 1.0,
    speakVolume: (json['speakVolume'] as num?)?.toDouble() ?? 1.0,
    maximumSpeechVolume: json['maximumSpeechVolume'] as bool? ?? false,
    clockOn: json['clockOn'] as bool? ?? false,
    clockIntervalMins: json['clockIntervalMins'] as int? ?? 30,
    clockShowMilliseconds: json['clockShowMilliseconds'] as bool? ?? true,
    clockShowSeconds: json['clockShowSeconds'] as bool? ?? true,
    clockSpeakTime: json['clockSpeakTime'] as bool? ?? true,
    clockSpeakRepeatCount: (json['clockSpeakRepeatCount'] as int? ?? 1).clamp(1, 3),
    clockNoiseOn: json['clockNoiseOn'] as bool? ?? false,
    motivationOn: json['motivationOn'] as bool? ?? true,
    motivationCategory: json['motivationCategory'] as String? ?? 'General',
    motivationDelaySeconds: json['motivationDelaySeconds'] as int? ?? 10,
    timerSpeakOn: json['timerSpeakOn'] as bool? ?? true,
    timerAnnounceEvery: json['timerAnnounceEvery'] as int? ?? 1,
    timerShowMilliseconds: json['timerShowMilliseconds'] as bool? ?? false,
    timerNoiseOn: json['timerNoiseOn'] as bool? ?? true,
    goalReminderOn: json['goalReminderOn'] as bool? ?? false,
    goalReminderIntervalMins: json['goalReminderIntervalMins'] as int? ?? 60,
    goalReminderItems: (json['goalReminderItems'] as List<dynamic>?)
        ?.map((e) => e.toString().trim())
        .where((s) => s.isNotEmpty)
        .toList() ?? const [],
    goalReminderNextIndex: json['goalReminderNextIndex'] as int? ?? 0,
    stopwatchShowMilliseconds: json['stopwatchShowMilliseconds'] as bool? ?? false,
    stopwatchSpeakDelaySeconds: json['stopwatchSpeakDelaySeconds'] as int? ?? 60,
    muteSpeechAfterMidnight: json['muteSpeechAfterMidnight'] as bool? ?? false,
    nightMuteMode: json['nightMuteMode'] as String? ?? 'manual',
    sleepStartMinutes: json['sleepStartMinutes'] as int? ?? 0,
    sleepEndMinutes: json['sleepEndMinutes'] as int? ?? 360,
    appDarkTheme: json['appDarkTheme'] as bool? ?? false,
    fullscreenDarkTheme: json['fullscreenDarkTheme'] as bool? ?? true,
    fullscreenDimBrightness: json['fullscreenDimBrightness'] as bool? ?? false,
    fullscreenStartLandscape: json['fullscreenStartLandscape'] as bool? ?? false,
    fullscreenShowClock: json['fullscreenShowClock'] as bool? ?? false,
    voiceListMode: json['voiceListMode'] as String? ?? 'auto',
    speechEngineMode: json['speechEngineMode'] as String? ?? 'auto',
    favoriteVoiceName: json['favoriteVoiceName'] as String?,
    favoriteVoiceLocale: json['favoriteVoiceLocale'] as String?,
    speechMasterOn: json['speechMasterOn'] as bool? ?? true,
    appFontSizeMultiplier: (json['appFontSizeMultiplier'] as num?)?.toDouble() ?? 1.0,
    backgroundPersistenceOn: json['backgroundPersistenceOn'] as bool? ?? false,
    fullscreenDimBrightnessLevel: (json['fullscreenDimBrightnessLevel'] as num?)?.toDouble() ?? 0.08,
    taggingOn: json['taggingOn'] as bool? ?? false,
    sessionTag: json['sessionTag'] as String? ?? 'study',
  );
}
