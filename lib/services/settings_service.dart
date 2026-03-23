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
  static const int _currentSchemaVersion = 1;

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
      noiseVolume: prefs.getDouble(PrefKeys.noiseVolume) ?? 0.6,
      speakVolume: prefs.getDouble(PrefKeys.speakVolume) ?? 0.8,
      clockOn: prefs.getBool(PrefKeys.clockOn) ?? false,
      clockIntervalMins: prefs.getInt(PrefKeys.clockIntervalMins) ?? 30,
      motivationOn: prefs.getBool(PrefKeys.motivationOn) ?? true,
      motivationCategory:
          prefs.getString(PrefKeys.motivationCategory) ?? 'General',
      motivationDelaySeconds:
          prefs.getInt(PrefKeys.motivationDelaySeconds) ?? 10,
      timerSpeakOn: prefs.getBool(PrefKeys.timerSpeakOn) ?? true,
      timerAnnounceEvery: prefs.getInt(PrefKeys.timerAnnounceEvery) ?? 1,
      timerNoiseOn: prefs.getBool(PrefKeys.timerNoiseOn) ?? true,
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
      voiceListMode: prefs.getString(PrefKeys.voiceListMode) ?? 'pleasant',
      favoriteVoiceName: prefs.getString(PrefKeys.favoriteVoiceName),
      favoriteVoiceLocale: prefs.getString(PrefKeys.favoriteVoiceLocale),
    );
  }

  Future<void> save(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(PrefKeys.soundChosen, settings.soundChosen);
    await prefs.setDouble(PrefKeys.noiseVolume, settings.noiseVolume);
    await prefs.setDouble(PrefKeys.speakVolume, settings.speakVolume);
    await prefs.setBool(PrefKeys.clockOn, settings.clockOn);
    await prefs.setInt(PrefKeys.clockIntervalMins, settings.clockIntervalMins);
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
    await prefs.setBool(PrefKeys.timerNoiseOn, settings.timerNoiseOn);
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

    await prefs.setInt(PrefKeys.settingsSchemaVersion, _currentSchemaVersion);
  }
}
