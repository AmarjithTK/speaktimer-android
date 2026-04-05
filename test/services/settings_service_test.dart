import 'package:flutter_test/flutter_test.dart';
import 'package:lifer/core/pref_keys.dart';
import 'package:lifer/models/app_settings.dart';
import 'package:lifer/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SettingsService migrations', () {
    test('migrates legacy assets/ sound path and schema version', () async {
      SharedPreferences.setMockInitialValues({
        PrefKeys.soundChosen: 'assets/audio/rain.mp3',
        PrefKeys.settingsSchemaVersion: 0,
      });

      final service = SettingsService();
      final loaded = await service.load(defaultSound: 'audio/fire.mp3');
      final prefs = await SharedPreferences.getInstance();

      expect(loaded.soundChosen, 'audio/rain.mp3');
      expect(prefs.getString(PrefKeys.soundChosen), 'audio/rain.mp3');
      expect(prefs.getInt(PrefKeys.settingsSchemaVersion), 7);
    });
  });

  group('SettingsService save/load', () {
    test('round-trips key values', () async {
      SharedPreferences.setMockInitialValues({});

      final service = SettingsService();
      const input = AppSettings(
        soundChosen: 'audio/stream.mp3',
        noiseVolume: 0.2,
        speakVolume: 0.9,
        ttsMaxVolumeLockEnabled: false,
        ttsVolumeBoostEnabled: false,
        clockOn: true,
        clockSpeakTime: true,
        clockSpeakRepeatCount: 2,
        clockNoiseOn: false,
        appFontSizeMultiplier: 1.0,
        clockIntervalMins: 15,
        clockShowMilliseconds: true,
        motivationOn: true,
        motivationCategory: 'Focus',
        motivationDelaySeconds: 20,
        timerSpeakOn: false,
        timerAnnounceEvery: 5,
        timerShowMilliseconds: false,
        timerNoiseOn: true,
        goalReminderOn: true,
        goalReminderIntervalMins: 60,
        goalReminderItems: ['Deep work', 'Ship release'],
        goalReminderNextIndex: 1,
        stopwatchShowMilliseconds: true,
        stopwatchSpeakDelaySeconds: 120,
        muteSpeechAfterMidnight: true,
        nightMuteMode: 'automatic',
        sleepStartMinutes: 1320,
        sleepEndMinutes: 360,
        appDarkTheme: true,
        fullscreenDarkTheme: true,
        fullscreenDimBrightness: true,
        fullscreenStartLandscape: false,
        voiceListMode: 'english',
        speechEngineMode: 'auto',
        favoriteVoiceName: 'Voice 1',
        favoriteVoiceLocale: 'en-US',
      );

      await service.save(input);
      final loaded = await service.load(defaultSound: 'audio/rain.mp3');

      expect(loaded.soundChosen, input.soundChosen);
      expect(loaded.clockIntervalMins, input.clockIntervalMins);
      expect(loaded.timerAnnounceEvery, input.timerAnnounceEvery);
      expect(loaded.nightMuteMode, input.nightMuteMode);
      expect(loaded.favoriteVoiceName, input.favoriteVoiceName);
      expect(loaded.favoriteVoiceLocale, input.favoriteVoiceLocale);
    });
  });
}
