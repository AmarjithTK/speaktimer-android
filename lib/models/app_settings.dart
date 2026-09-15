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
  final bool stopwatchSpeakOn;
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
  final double fullscreenClockScale;
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
    this.stopwatchSpeakOn = true,
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
    this.fullscreenClockScale = 1.0,
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

  factory AppSettings.defaults({String defaultSound = 'audio/rain.mp3'}) =>
      AppSettings(
        soundChosen: defaultSound,
        noiseVolume: 1,
        speakVolume: 1,
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
        goalReminderItems: const [],
        goalReminderNextIndex: 0,
        stopwatchSpeakOn: true,
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
        fullscreenShowClock: false,
        fullscreenClockScale: 1,
        voiceListMode: 'auto',
        speechEngineMode: 'auto',
        favoriteVoiceName: null,
        favoriteVoiceLocale: null,
        speechMasterOn: true,
        appFontSizeMultiplier: 1,
        backgroundPersistenceOn: false,
        fullscreenDimBrightnessLevel: 0.08,
        taggingOn: false,
        sessionTag: 'study',
      );

  AppSettings normalized() {
    final items = goalReminderItems
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList(growable: false);
    final nextIndex = items.isEmpty ? 0 : goalReminderNextIndex % items.length;
    final voiceMode = switch (voiceListMode.trim().toLowerCase()) {
      'english' => 'english',
      'malayalam' => 'malayalam',
      _ => 'auto',
    };
    final rawEngine = speechEngineMode.trim();
    final knownEngine = rawEngine.toLowerCase();
    final engineMode = switch (knownEngine) {
      'system_only' => 'system_only',
      'sherpa_only' => 'sherpa_only',
      'auto' => 'auto',
      _ when rawEngine.contains('.') => rawEngine,
      _ => 'auto',
    };
    final normalizedNightMode = switch (nightMuteMode.trim().toLowerCase()) {
      'automatic' || 'auto' => 'automatic',
      _ => 'manual',
    };
    final normalizedTag = sessionTag == 'non-study' ? 'non-study' : 'study';

    return copyWith(
      soundChosen: soundChosen.trim().isEmpty ? 'audio/rain.mp3' : soundChosen,
      noiseVolume: noiseVolume.clamp(0, 1).toDouble(),
      speakVolume: speakVolume.clamp(0, 1).toDouble(),
      clockIntervalMins: clockIntervalMins.clamp(1, 1440),
      clockSpeakRepeatCount: clockSpeakRepeatCount.clamp(1, 3),
      motivationCategory: motivationCategory.trim().isEmpty
          ? 'General'
          : motivationCategory,
      motivationDelaySeconds: motivationDelaySeconds.clamp(1, 3600),
      timerAnnounceEvery: timerAnnounceEvery.clamp(1, 720),
      goalReminderIntervalMins: goalReminderIntervalMins.clamp(1, 1440),
      goalReminderItems: items,
      goalReminderNextIndex: nextIndex,
      stopwatchSpeakDelaySeconds: stopwatchSpeakDelaySeconds.clamp(1, 86400),
      nightMuteMode: normalizedNightMode,
      sleepStartMinutes: sleepStartMinutes.clamp(0, 1439),
      sleepEndMinutes: sleepEndMinutes.clamp(0, 1439),
      fullscreenClockScale: fullscreenClockScale.clamp(0.8, 2).toDouble(),
      voiceListMode: voiceMode,
      speechEngineMode: engineMode,
      favoriteVoiceName: () => _cleanNullable(favoriteVoiceName),
      favoriteVoiceLocale: () => _cleanNullable(favoriteVoiceLocale),
      appFontSizeMultiplier: appFontSizeMultiplier.clamp(0.8, 1.5).toDouble(),
      fullscreenDimBrightnessLevel: fullscreenDimBrightnessLevel
          .clamp(0.01, 1)
          .toDouble(),
      sessionTag: normalizedTag,
    );
  }

  static String? _cleanNullable(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  AppSettings copyWith({
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
    bool? stopwatchSpeakOn,
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
    bool? fullscreenShowClock,
    double? fullscreenClockScale,
    String? voiceListMode,
    String? speechEngineMode,
    String? Function()? favoriteVoiceName,
    String? Function()? favoriteVoiceLocale,
    bool? speechMasterOn,
    double? appFontSizeMultiplier,
    bool? backgroundPersistenceOn,
    double? fullscreenDimBrightnessLevel,
    bool? taggingOn,
    String? sessionTag,
  }) => AppSettings(
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
    motivationDelaySeconds:
        motivationDelaySeconds ?? this.motivationDelaySeconds,
    timerSpeakOn: timerSpeakOn ?? this.timerSpeakOn,
    timerAnnounceEvery: timerAnnounceEvery ?? this.timerAnnounceEvery,
    timerShowMilliseconds: timerShowMilliseconds ?? this.timerShowMilliseconds,
    timerNoiseOn: timerNoiseOn ?? this.timerNoiseOn,
    goalReminderOn: goalReminderOn ?? this.goalReminderOn,
    goalReminderIntervalMins:
        goalReminderIntervalMins ?? this.goalReminderIntervalMins,
    goalReminderItems: List<String>.unmodifiable(
      goalReminderItems ?? this.goalReminderItems,
    ),
    goalReminderNextIndex: goalReminderNextIndex ?? this.goalReminderNextIndex,
    stopwatchSpeakOn: stopwatchSpeakOn ?? this.stopwatchSpeakOn,
    stopwatchShowMilliseconds:
        stopwatchShowMilliseconds ?? this.stopwatchShowMilliseconds,
    stopwatchSpeakDelaySeconds:
        stopwatchSpeakDelaySeconds ?? this.stopwatchSpeakDelaySeconds,
    muteSpeechAfterMidnight:
        muteSpeechAfterMidnight ?? this.muteSpeechAfterMidnight,
    nightMuteMode: nightMuteMode ?? this.nightMuteMode,
    sleepStartMinutes: sleepStartMinutes ?? this.sleepStartMinutes,
    sleepEndMinutes: sleepEndMinutes ?? this.sleepEndMinutes,
    appDarkTheme: appDarkTheme ?? this.appDarkTheme,
    fullscreenDarkTheme: fullscreenDarkTheme ?? this.fullscreenDarkTheme,
    fullscreenDimBrightness:
        fullscreenDimBrightness ?? this.fullscreenDimBrightness,
    fullscreenStartLandscape:
        fullscreenStartLandscape ?? this.fullscreenStartLandscape,
    fullscreenShowClock: fullscreenShowClock ?? this.fullscreenShowClock,
    fullscreenClockScale: fullscreenClockScale ?? this.fullscreenClockScale,
    voiceListMode: voiceListMode ?? this.voiceListMode,
    speechEngineMode: speechEngineMode ?? this.speechEngineMode,
    favoriteVoiceName: favoriteVoiceName == null
        ? this.favoriteVoiceName
        : favoriteVoiceName(),
    favoriteVoiceLocale: favoriteVoiceLocale == null
        ? this.favoriteVoiceLocale
        : favoriteVoiceLocale(),
    speechMasterOn: speechMasterOn ?? this.speechMasterOn,
    appFontSizeMultiplier: appFontSizeMultiplier ?? this.appFontSizeMultiplier,
    backgroundPersistenceOn:
        backgroundPersistenceOn ?? this.backgroundPersistenceOn,
    fullscreenDimBrightnessLevel:
        fullscreenDimBrightnessLevel ?? this.fullscreenDimBrightnessLevel,
    taggingOn: taggingOn ?? this.taggingOn,
    sessionTag: sessionTag ?? this.sessionTag,
  );

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
    'goalReminderItems': List<String>.from(goalReminderItems),
    'goalReminderNextIndex': goalReminderNextIndex,
    'stopwatchSpeakOn': stopwatchSpeakOn,
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
    'fullscreenClockScale': fullscreenClockScale,
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

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final defaults = AppSettings.defaults();
    return AppSettings(
      soundChosen: _string(json, 'soundChosen', defaults.soundChosen),
      noiseVolume: _double(json, 'noiseVolume', defaults.noiseVolume),
      speakVolume: _double(json, 'speakVolume', defaults.speakVolume),
      maximumSpeechVolume: _bool(
        json,
        'maximumSpeechVolume',
        defaults.maximumSpeechVolume,
      ),
      clockOn: _bool(json, 'clockOn', defaults.clockOn),
      clockIntervalMins: _int(
        json,
        'clockIntervalMins',
        defaults.clockIntervalMins,
      ),
      clockShowMilliseconds: _bool(
        json,
        'clockShowMilliseconds',
        defaults.clockShowMilliseconds,
      ),
      clockShowSeconds: _bool(
        json,
        'clockShowSeconds',
        defaults.clockShowSeconds,
      ),
      clockSpeakTime: _bool(json, 'clockSpeakTime', defaults.clockSpeakTime),
      clockSpeakRepeatCount: _int(
        json,
        'clockSpeakRepeatCount',
        defaults.clockSpeakRepeatCount,
      ),
      clockNoiseOn: _bool(json, 'clockNoiseOn', defaults.clockNoiseOn),
      motivationOn: _bool(json, 'motivationOn', defaults.motivationOn),
      motivationCategory: _string(
        json,
        'motivationCategory',
        defaults.motivationCategory,
      ),
      motivationDelaySeconds: _int(
        json,
        'motivationDelaySeconds',
        defaults.motivationDelaySeconds,
      ),
      timerSpeakOn: _bool(json, 'timerSpeakOn', defaults.timerSpeakOn),
      timerAnnounceEvery: _int(
        json,
        'timerAnnounceEvery',
        defaults.timerAnnounceEvery,
      ),
      timerShowMilliseconds: _bool(
        json,
        'timerShowMilliseconds',
        defaults.timerShowMilliseconds,
      ),
      timerNoiseOn: _bool(json, 'timerNoiseOn', defaults.timerNoiseOn),
      goalReminderOn: _bool(json, 'goalReminderOn', defaults.goalReminderOn),
      goalReminderIntervalMins: _int(
        json,
        'goalReminderIntervalMins',
        defaults.goalReminderIntervalMins,
      ),
      goalReminderItems: json['goalReminderItems'] is List
          ? (json['goalReminderItems'] as List)
                .map((item) => item.toString())
                .toList(growable: false)
          : defaults.goalReminderItems,
      goalReminderNextIndex: _int(
        json,
        'goalReminderNextIndex',
        defaults.goalReminderNextIndex,
      ),
      stopwatchSpeakOn: _bool(
        json,
        'stopwatchSpeakOn',
        defaults.stopwatchSpeakOn,
      ),
      stopwatchShowMilliseconds: _bool(
        json,
        'stopwatchShowMilliseconds',
        defaults.stopwatchShowMilliseconds,
      ),
      stopwatchSpeakDelaySeconds: _int(
        json,
        'stopwatchSpeakDelaySeconds',
        defaults.stopwatchSpeakDelaySeconds,
      ),
      muteSpeechAfterMidnight: _bool(
        json,
        'muteSpeechAfterMidnight',
        defaults.muteSpeechAfterMidnight,
      ),
      nightMuteMode: _string(json, 'nightMuteMode', defaults.nightMuteMode),
      sleepStartMinutes: _int(
        json,
        'sleepStartMinutes',
        defaults.sleepStartMinutes,
      ),
      sleepEndMinutes: _int(json, 'sleepEndMinutes', defaults.sleepEndMinutes),
      appDarkTheme: _bool(json, 'appDarkTheme', defaults.appDarkTheme),
      fullscreenDarkTheme: _bool(
        json,
        'fullscreenDarkTheme',
        defaults.fullscreenDarkTheme,
      ),
      fullscreenDimBrightness: _bool(
        json,
        'fullscreenDimBrightness',
        defaults.fullscreenDimBrightness,
      ),
      fullscreenStartLandscape: _bool(
        json,
        'fullscreenStartLandscape',
        defaults.fullscreenStartLandscape,
      ),
      fullscreenShowClock: _bool(
        json,
        'fullscreenShowClock',
        defaults.fullscreenShowClock,
      ),
      fullscreenClockScale: _double(
        json,
        'fullscreenClockScale',
        defaults.fullscreenClockScale,
      ),
      voiceListMode: _string(json, 'voiceListMode', defaults.voiceListMode),
      speechEngineMode: _string(
        json,
        'speechEngineMode',
        defaults.speechEngineMode,
      ),
      favoriteVoiceName: json['favoriteVoiceName']?.toString(),
      favoriteVoiceLocale: json['favoriteVoiceLocale']?.toString(),
      speechMasterOn: _bool(json, 'speechMasterOn', defaults.speechMasterOn),
      appFontSizeMultiplier: _double(
        json,
        'appFontSizeMultiplier',
        defaults.appFontSizeMultiplier,
      ),
      backgroundPersistenceOn: _bool(
        json,
        'backgroundPersistenceOn',
        defaults.backgroundPersistenceOn,
      ),
      fullscreenDimBrightnessLevel: _double(
        json,
        'fullscreenDimBrightnessLevel',
        defaults.fullscreenDimBrightnessLevel,
      ),
      taggingOn: _bool(json, 'taggingOn', defaults.taggingOn),
      sessionTag: _string(json, 'sessionTag', defaults.sessionTag),
    ).normalized();
  }

  static String _string(
    Map<String, dynamic> json,
    String key,
    String fallback,
  ) => json[key] is String ? json[key] as String : fallback;

  static bool _bool(Map<String, dynamic> json, String key, bool fallback) =>
      json[key] is bool ? json[key] as bool : fallback;

  static int _int(Map<String, dynamic> json, String key, int fallback) {
    final value = json[key];
    return value is num ? value.toInt() : fallback;
  }

  static double _double(
    Map<String, dynamic> json,
    String key,
    double fallback,
  ) {
    final value = json[key];
    return value is num ? value.toDouble() : fallback;
  }
}
