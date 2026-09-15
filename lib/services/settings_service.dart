import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/pref_keys.dart';
import '../models/app_settings.dart';

/// Stores one validated, versioned settings document.
///
/// Legacy keys are read only for the one-time migration. All writes are
/// serialized and replace one JSON value, so a crash cannot leave a mixture of
/// two settings revisions.
class SettingsService {
  static const int currentSchemaVersion = 9;
  static const String snapshotKey = 'SettingsSnapshotV9';
  static const String speechMasterOverrideKey = 'SpeechMasterTaskOverride';

  static Future<void> _writeTail = Future<void>.value();

  Future<AppSettings> load({required String defaultSound}) async {
    await flush();
    final prefs = await SharedPreferences.getInstance();
    await _runLegacyMigrations(prefs);

    AppSettings settings;
    final encoded = prefs.getString(snapshotKey);
    if (encoded != null) {
      try {
        final decoded = jsonDecode(encoded);
        settings = decoded is Map<String, dynamic>
            ? AppSettings.fromJson(decoded)
            : AppSettings.defaults(defaultSound: defaultSound);
      } catch (error) {
        debugPrint('Ignoring corrupt settings snapshot: $error');
        settings = _loadLegacy(prefs, defaultSound: defaultSound);
      }
    } else {
      settings = _loadLegacy(prefs, defaultSound: defaultSound);
    }

    final taskOverride = prefs.getBool(speechMasterOverrideKey);
    if (taskOverride != null) {
      settings = settings.copyWith(speechMasterOn: taskOverride).normalized();
      await prefs.remove(speechMasterOverrideKey);
    }

    await save(settings);
    return settings;
  }

  Future<void> save(AppSettings settings) {
    final stable = AppSettings.fromJson(settings.normalized().toJson());
    final encoded = jsonEncode(stable.toJson());
    _writeTail = _writeTail
        .catchError((Object error, StackTrace stackTrace) {
          debugPrint('Previous settings write failed: $error');
        })
        .then((_) async {
          final prefs = await SharedPreferences.getInstance();
          final written = await prefs.setString(snapshotKey, encoded);
          if (!written) {
            throw StateError(
              'SharedPreferences rejected settings snapshot write',
            );
          }
          final versionWritten = await prefs.setInt(
            PrefKeys.settingsSchemaVersion,
            currentSchemaVersion,
          );
          if (!versionWritten) {
            throw StateError(
              'SharedPreferences rejected settings schema write',
            );
          }
          await prefs.remove(speechMasterOverrideKey);
        });
    return _writeTail;
  }

  Future<void> flush() => _writeTail;

  AppSettings _loadLegacy(
    SharedPreferences prefs, {
    required String defaultSound,
  }) {
    String sound = prefs.getString(PrefKeys.soundChosen) ?? defaultSound;
    if (sound.startsWith('assets/')) {
      sound = sound.replaceFirst('assets/', '');
    }
    final defaults = AppSettings.defaults(defaultSound: defaultSound);
    return AppSettings(
      soundChosen: sound,
      noiseVolume:
          prefs.getDouble(PrefKeys.noiseVolume) ?? defaults.noiseVolume,
      speakVolume:
          prefs.getDouble(PrefKeys.speakVolume) ?? defaults.speakVolume,
      maximumSpeechVolume:
          prefs.getBool(PrefKeys.maximumSpeechVolume) ??
          defaults.maximumSpeechVolume,
      clockOn: prefs.getBool(PrefKeys.clockOn) ?? defaults.clockOn,
      clockIntervalMins:
          prefs.getInt(PrefKeys.clockIntervalMins) ??
          defaults.clockIntervalMins,
      clockShowMilliseconds:
          prefs.getBool(PrefKeys.clockShowMilliseconds) ??
          defaults.clockShowMilliseconds,
      clockShowSeconds:
          prefs.getBool(PrefKeys.clockShowSeconds) ?? defaults.clockShowSeconds,
      clockSpeakTime:
          prefs.getBool(PrefKeys.clockSpeakTime) ?? defaults.clockSpeakTime,
      clockSpeakRepeatCount:
          prefs.getInt(PrefKeys.clockSpeakRepeatCount) ??
          defaults.clockSpeakRepeatCount,
      clockNoiseOn:
          prefs.getBool(PrefKeys.clockNoiseOn) ?? defaults.clockNoiseOn,
      motivationOn:
          prefs.getBool(PrefKeys.motivationOn) ?? defaults.motivationOn,
      motivationCategory:
          prefs.getString(PrefKeys.motivationCategory) ??
          defaults.motivationCategory,
      motivationDelaySeconds:
          prefs.getInt(PrefKeys.motivationDelaySeconds) ??
          defaults.motivationDelaySeconds,
      timerSpeakOn:
          prefs.getBool(PrefKeys.timerSpeakOn) ?? defaults.timerSpeakOn,
      timerAnnounceEvery:
          prefs.getInt(PrefKeys.timerAnnounceEvery) ??
          defaults.timerAnnounceEvery,
      timerShowMilliseconds:
          prefs.getBool(PrefKeys.timerShowMilliseconds) ??
          defaults.timerShowMilliseconds,
      timerNoiseOn:
          prefs.getBool(PrefKeys.timerNoiseOn) ?? defaults.timerNoiseOn,
      goalReminderOn:
          prefs.getBool(PrefKeys.goalReminderOn) ?? defaults.goalReminderOn,
      goalReminderIntervalMins:
          prefs.getInt(PrefKeys.goalReminderIntervalMins) ??
          defaults.goalReminderIntervalMins,
      goalReminderItems:
          prefs.getStringList(PrefKeys.goalReminderItems) ?? const [],
      goalReminderNextIndex:
          prefs.getInt(PrefKeys.goalReminderNextIndex) ??
          defaults.goalReminderNextIndex,
      stopwatchSpeakOn:
          prefs.getBool(PrefKeys.stopwatchSpeakOn) ?? defaults.stopwatchSpeakOn,
      stopwatchShowMilliseconds:
          prefs.getBool(PrefKeys.stopwatchShowMilliseconds) ??
          defaults.stopwatchShowMilliseconds,
      stopwatchSpeakDelaySeconds:
          prefs.getInt(PrefKeys.stopwatchSpeakDelaySeconds) ??
          defaults.stopwatchSpeakDelaySeconds,
      muteSpeechAfterMidnight:
          prefs.getBool(PrefKeys.muteSpeechAfterMidnight) ??
          defaults.muteSpeechAfterMidnight,
      nightMuteMode:
          prefs.getString(PrefKeys.nightMuteMode) ?? defaults.nightMuteMode,
      sleepStartMinutes:
          prefs.getInt(PrefKeys.sleepStartMinutes) ??
          defaults.sleepStartMinutes,
      sleepEndMinutes:
          prefs.getInt(PrefKeys.sleepEndMinutes) ?? defaults.sleepEndMinutes,
      appDarkTheme:
          prefs.getBool(PrefKeys.appDarkTheme) ?? defaults.appDarkTheme,
      fullscreenDarkTheme:
          prefs.getBool(PrefKeys.fullscreenDarkTheme) ??
          defaults.fullscreenDarkTheme,
      fullscreenDimBrightness:
          prefs.getBool(PrefKeys.fullscreenDimBrightness) ??
          defaults.fullscreenDimBrightness,
      fullscreenStartLandscape:
          prefs.getBool(PrefKeys.fullscreenStartLandscape) ??
          defaults.fullscreenStartLandscape,
      fullscreenShowClock:
          prefs.getBool(PrefKeys.fullscreenShowClock) ??
          defaults.fullscreenShowClock,
      fullscreenClockScale:
          prefs.getDouble(PrefKeys.fullscreenClockScale) ??
          defaults.fullscreenClockScale,
      voiceListMode:
          prefs.getString(PrefKeys.voiceListMode) ?? defaults.voiceListMode,
      speechEngineMode:
          prefs.getString(PrefKeys.speechEngineMode) ??
          defaults.speechEngineMode,
      favoriteVoiceName: prefs.getString(PrefKeys.favoriteVoiceName),
      favoriteVoiceLocale: prefs.getString(PrefKeys.favoriteVoiceLocale),
      speechMasterOn:
          prefs.getBool(PrefKeys.speechMasterOn) ?? defaults.speechMasterOn,
      appFontSizeMultiplier:
          prefs.getDouble(PrefKeys.appFontSizeMultiplier) ??
          defaults.appFontSizeMultiplier,
      backgroundPersistenceOn:
          prefs.getBool(PrefKeys.backgroundPersistenceOn) ??
          defaults.backgroundPersistenceOn,
      fullscreenDimBrightnessLevel:
          prefs.getDouble(PrefKeys.fullscreenDimBrightnessLevel) ??
          defaults.fullscreenDimBrightnessLevel,
      taggingOn: prefs.getBool(PrefKeys.taggingOn) ?? defaults.taggingOn,
      sessionTag: prefs.getString(PrefKeys.sessionTag) ?? defaults.sessionTag,
    ).normalized();
  }

  Future<void> _runLegacyMigrations(SharedPreferences prefs) async {
    final sound = prefs.getString(PrefKeys.soundChosen);
    if (sound != null && sound.startsWith('assets/')) {
      await prefs.setString(
        PrefKeys.soundChosen,
        sound.replaceFirst('assets/', ''),
      );
    }
    if (!prefs.containsKey(PrefKeys.maximumSpeechVolume)) {
      final oldBoost = prefs.getBool('TtsVolumeBoostEnabled') ?? false;
      final oldLock = prefs.getBool('TtsMaxVolumeLockEnabled') ?? false;
      await prefs.setBool(PrefKeys.maximumSpeechVolume, oldBoost || oldLock);
    }
  }

  Future<String> exportToJson({required String defaultSound}) async {
    await flush();
    final settings = await load(defaultSound: defaultSound);
    return const JsonEncoder.withIndent('  ').convert(settings.toJson());
  }

  AppSettings? importFromJson(String jsonString) {
    try {
      final decoded = const JsonDecoder().convert(jsonString);
      if (decoded is! Map<String, dynamic>) return null;
      return AppSettings.fromJson(decoded);
    } catch (error) {
      debugPrint('Settings import failed: $error');
      return null;
    }
  }

  Future<String?> exportToUserFolder({required String defaultSound}) async {
    try {
      final directory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Choose backup folder',
      );
      if (directory == null) return null;
      final contents = await exportToJson(defaultSound: defaultSound);
      final now = DateTime.now();
      final date =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final time =
          '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
      final file = File('$directory/SolasFlow_Settings_${date}_$time.json');
      await file.writeAsString(contents, flush: true);
      return file.path;
    } catch (error) {
      debugPrint('Settings export failed: $error');
      return null;
    }
  }

  Future<AppSettings?> importFromFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );
    if (result == null || result.files.isEmpty) return null;
    final path = result.files.single.path;
    if (path == null) return null;
    try {
      return importFromJson(await File(path).readAsString());
    } catch (error) {
      debugPrint('Settings import failed: $error');
      return null;
    }
  }
}
