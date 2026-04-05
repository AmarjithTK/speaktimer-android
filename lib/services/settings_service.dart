// ============================================================================
// SettingsService - Persistent user preferences management
// ============================================================================
//
// Responsibilities:
// - Load all user preferences from SharedPreferences at startup
// - Apply data migrations for backward compatibility across app versions
// - Save updated preferences back to persistent storage
// - Handle defaults for missing or corrupted preference values
//
// Architecture Pattern:
// - Uses AppSettings data class for type-safe preference snapshots
// - Migrations run automatically on load() before reading preferences
// - Schema versioning enables safe evolution of preference structure
// - All preference keys centralized in lib/core/pref_keys.dart
//
// Migration Example:
// If app v2.x stored sound paths as "assets/rain.mp3" but v3.x expects
// "rain.mp3", load() automatically fixes this via _runMigrations().

import 'package:shared_preferences/shared_preferences.dart';

import '../core/pref_keys.dart';
import '../models/app_settings.dart';

class SettingsService {
  /// Current schema version: increment when preference structure changes
  /// Used to detect and run migrations for old stored data
  static const int _currentSchemaVersion = 7;

  String _normalizeVoiceLanguageMode(String? mode) {
    final normalized = mode?.trim().toLowerCase() ?? '';
    switch (normalized) {
      case 'auto':
      case 'english':
      case 'malayalam':
        return normalized;
      case 'pleasant':
      case 'all':
        return 'english';
      default:
        return 'auto';
    }
  }

  String _normalizeSpeechEngineMode(String? mode) {
    final normalized = mode?.trim().toLowerCase() ?? '';
    switch (normalized) {
      case 'auto':
      case 'system_only':
      case 'sherpa_only':
        return normalized;
      default:
        return 'auto';
    }
  }

  /// Load all settings from persistent storage
  /// Automatically runs migrations if stored version differs from current
  /// Returns AppSettings with all user preferences and defaults
  Future<AppSettings> load({required String defaultSound}) async {
    final prefs = await SharedPreferences.getInstance();
    await _runMigrations(prefs);

    String sound = prefs.getString(PrefKeys.soundChosen) ?? defaultSound;
    if (sound.startsWith('assets/')) {
      sound = sound.replaceFirst('assets/', '');
    }

    return AppSettings(
      soundChosen: sound,
      noiseVolume: prefs.getDouble(PrefKeys.noiseVolume) ?? 1.0,
      speakVolume: prefs.getDouble(PrefKeys.speakVolume) ?? 1.0,
      ttsMaxVolumeLockEnabled:
          prefs.getBool(PrefKeys.ttsMaxVolumeLockEnabled) ?? false,
      ttsVolumeBoostEnabled:
          prefs.getBool(PrefKeys.ttsVolumeBoostEnabled) ?? false,
      clockOn: prefs.getBool(PrefKeys.clockOn) ?? false,
      clockIntervalMins: prefs.getInt(PrefKeys.clockIntervalMins) ?? 30,
      clockShowMilliseconds:
          prefs.getBool(PrefKeys.clockShowMilliseconds) ?? true,
      clockSpeakTime: prefs.getBool(PrefKeys.clockSpeakTime) ?? true,
        clockSpeakRepeatCount:
          (prefs.getInt(PrefKeys.clockSpeakRepeatCount) ?? 1).clamp(1, 3),
      clockNoiseOn: prefs.getBool(PrefKeys.clockNoiseOn) ?? false,
      motivationOn: prefs.getBool(PrefKeys.motivationOn) ?? true,
      motivationCategory:
          prefs.getString(PrefKeys.motivationCategory) ?? 'General',
      motivationDelaySeconds:
          prefs.getInt(PrefKeys.motivationDelaySeconds) ?? 10,
      timerSpeakOn: prefs.getBool(PrefKeys.timerSpeakOn) ?? true,
      timerAnnounceEvery: prefs.getInt(PrefKeys.timerAnnounceEvery) ?? 1,
      timerShowMilliseconds:
          prefs.getBool(PrefKeys.timerShowMilliseconds) ?? false,
      timerNoiseOn: prefs.getBool(PrefKeys.timerNoiseOn) ?? true,
      goalReminderOn: prefs.getBool(PrefKeys.goalReminderOn) ?? false,
      goalReminderIntervalMins:
          prefs.getInt(PrefKeys.goalReminderIntervalMins) ?? 60,
      goalReminderItems:
          (prefs.getStringList(PrefKeys.goalReminderItems) ?? const [])
              .map((item) => item.trim())
              .where((item) => item.isNotEmpty)
              .toList(),
      goalReminderNextIndex: prefs.getInt(PrefKeys.goalReminderNextIndex) ?? 0,
      stopwatchShowMilliseconds:
          prefs.getBool(PrefKeys.stopwatchShowMilliseconds) ?? false,
      stopwatchSpeakDelaySeconds:
          prefs.getInt(PrefKeys.stopwatchSpeakDelaySeconds) ?? 60,
      muteSpeechAfterMidnight:
          prefs.getBool(PrefKeys.muteSpeechAfterMidnight) ?? false,
      nightMuteMode: prefs.getString(PrefKeys.nightMuteMode) ?? 'manual',
      sleepStartMinutes: prefs.getInt(PrefKeys.sleepStartMinutes) ?? 0,
      sleepEndMinutes: prefs.getInt(PrefKeys.sleepEndMinutes) ?? 360,
      appDarkTheme: prefs.getBool(PrefKeys.appDarkTheme) ?? false,
      fullscreenDarkTheme: prefs.getBool(PrefKeys.fullscreenDarkTheme) ?? true,
      fullscreenDimBrightness:
          prefs.getBool(PrefKeys.fullscreenDimBrightness) ?? false,
      fullscreenStartLandscape:
          prefs.getBool(PrefKeys.fullscreenStartLandscape) ?? false,
      voiceListMode: _normalizeVoiceLanguageMode(
        prefs.getString(PrefKeys.voiceListMode),
      ),
      speechEngineMode: _normalizeSpeechEngineMode(
        prefs.getString(PrefKeys.speechEngineMode),
      ),
      favoriteVoiceName: prefs.getString(PrefKeys.favoriteVoiceName),
      favoriteVoiceLocale: prefs.getString(PrefKeys.favoriteVoiceLocale),
      appFontSizeMultiplier: prefs.getDouble(PrefKeys.appFontSizeMultiplier) ?? 1.0,
    );
  }

  Future<void> save(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(PrefKeys.soundChosen, settings.soundChosen);
    await prefs.setDouble(PrefKeys.noiseVolume, settings.noiseVolume);
    await prefs.setDouble(PrefKeys.speakVolume, settings.speakVolume);
    await prefs.setBool(
      PrefKeys.ttsMaxVolumeLockEnabled,
      settings.ttsMaxVolumeLockEnabled,
    );
    await prefs.setBool(
      PrefKeys.ttsVolumeBoostEnabled,
      settings.ttsVolumeBoostEnabled,
    );
    await prefs.setBool(PrefKeys.clockOn, settings.clockOn);
    await prefs.setInt(PrefKeys.clockIntervalMins, settings.clockIntervalMins);
    await prefs.setBool(
      PrefKeys.clockShowMilliseconds,
      settings.clockShowMilliseconds,
    );
    await prefs.setBool(PrefKeys.clockSpeakTime, settings.clockSpeakTime);
    await prefs.setInt(
      PrefKeys.clockSpeakRepeatCount,
      settings.clockSpeakRepeatCount,
    );
    await prefs.setBool(PrefKeys.clockNoiseOn, settings.clockNoiseOn);
    await prefs.setBool(PrefKeys.motivationOn, settings.motivationOn);
    await prefs.setString(
      PrefKeys.motivationCategory,
      settings.motivationCategory,
    );
    await prefs.setInt(
      PrefKeys.motivationDelaySeconds,
      settings.motivationDelaySeconds,
    );
    await prefs.setBool(PrefKeys.timerSpeakOn, settings.timerSpeakOn);
    await prefs.setInt(
      PrefKeys.timerAnnounceEvery,
      settings.timerAnnounceEvery,
    );
    await prefs.setBool(
      PrefKeys.timerShowMilliseconds,
      settings.timerShowMilliseconds,
    );
    await prefs.setBool(PrefKeys.timerNoiseOn, settings.timerNoiseOn);
    await prefs.setBool(
      PrefKeys.stopwatchShowMilliseconds,
      settings.stopwatchShowMilliseconds,
    );
    await prefs.setInt(
      PrefKeys.stopwatchSpeakDelaySeconds,
      settings.stopwatchSpeakDelaySeconds,
    );
    await prefs.setBool(
      PrefKeys.muteSpeechAfterMidnight,
      settings.muteSpeechAfterMidnight,
    );
    await prefs.setString(PrefKeys.nightMuteMode, settings.nightMuteMode);
    await prefs.setInt(PrefKeys.sleepStartMinutes, settings.sleepStartMinutes);
    await prefs.setInt(PrefKeys.sleepEndMinutes, settings.sleepEndMinutes);
    await prefs.setBool(PrefKeys.appDarkTheme, settings.appDarkTheme);
    await prefs.setBool(
      PrefKeys.fullscreenDarkTheme,
      settings.fullscreenDarkTheme,
    );
    await prefs.setBool(
      PrefKeys.fullscreenDimBrightness,
      settings.fullscreenDimBrightness,
    );
    await prefs.setBool(
      PrefKeys.fullscreenStartLandscape,
      settings.fullscreenStartLandscape,
    );
    await prefs.setString(PrefKeys.voiceListMode, settings.voiceListMode);
    await prefs.setString(PrefKeys.speechEngineMode, settings.speechEngineMode);
    await prefs.setBool(PrefKeys.goalReminderOn, settings.goalReminderOn);
    await prefs.setInt(
      PrefKeys.goalReminderIntervalMins,
      settings.goalReminderIntervalMins,
    );
    await prefs.setStringList(
      PrefKeys.goalReminderItems,
      settings.goalReminderItems,
    );
    await prefs.setInt(
      PrefKeys.goalReminderNextIndex,
      settings.goalReminderNextIndex,
    );

    if (settings.favoriteVoiceName != null) {
      await prefs.setString(
        PrefKeys.favoriteVoiceName,
        settings.favoriteVoiceName!,
      );
    } else {
      await prefs.remove(PrefKeys.favoriteVoiceName);
    }

    if (settings.favoriteVoiceLocale != null) {
      await prefs.setString(
        PrefKeys.favoriteVoiceLocale,
        settings.favoriteVoiceLocale!,
      );
    } else {
      await prefs.remove(PrefKeys.favoriteVoiceLocale);
    }

    await prefs.setDouble(PrefKeys.appFontSizeMultiplier, settings.appFontSizeMultiplier);
  }

  Future<void> _runMigrations(SharedPreferences prefs) async {
    final currentVersion = prefs.getInt(PrefKeys.settingsSchemaVersion) ?? 0;
    if (currentVersion >= _currentSchemaVersion) return;

    if (currentVersion < 1) {
      final sound = prefs.getString(PrefKeys.soundChosen);
      if (sound != null && sound.startsWith('assets/')) {
        await prefs.setString(
          PrefKeys.soundChosen,
          sound.replaceFirst('assets/', ''),
        );
      }
    }

    if (currentVersion < 2) {
      final goalItems = prefs.getStringList(PrefKeys.goalReminderItems);
      if (goalItems != null) {
        await prefs.setStringList(
          PrefKeys.goalReminderItems,
          goalItems
              .map((item) => item.trim())
              .where((item) => item.isNotEmpty)
              .toList(),
        );
      }
    }

    if (currentVersion < 3) {
      await prefs.setString(
        PrefKeys.voiceListMode,
        _normalizeVoiceLanguageMode(prefs.getString(PrefKeys.voiceListMode)),
      );
    }

    if (currentVersion < 4) {
      await prefs.setString(
        PrefKeys.speechEngineMode,
        _normalizeSpeechEngineMode(prefs.getString(PrefKeys.speechEngineMode)),
      );
    }

    if (currentVersion < 6) {
      if (!prefs.containsKey(PrefKeys.ttsMaxVolumeLockEnabled)) {
        await prefs.setBool(PrefKeys.ttsMaxVolumeLockEnabled, false);
      }
    }

    if (currentVersion < 7) {
      if (!prefs.containsKey(PrefKeys.clockSpeakRepeatCount)) {
        await prefs.setInt(PrefKeys.clockSpeakRepeatCount, 1);
      }
    }

    await prefs.setInt(PrefKeys.settingsSchemaVersion, _currentSchemaVersion);
  }
}
