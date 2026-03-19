import 'package:shared_preferences/shared_preferences.dart';

import '../core/pref_keys.dart';
import '../models/app_settings.dart';

class SettingsService {
  Future<AppSettings> load({required String defaultSound}) async {
    final prefs = await SharedPreferences.getInstance();

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
      motivationCategory: prefs.getString(PrefKeys.motivationCategory) ?? 'General',
      motivationDelaySeconds: prefs.getInt(PrefKeys.motivationDelaySeconds) ?? 10,
      timerSpeakOn: prefs.getBool(PrefKeys.timerSpeakOn) ?? true,
      timerAnnounceEvery: prefs.getInt(PrefKeys.timerAnnounceEvery) ?? 1,
      timerNoiseOn: prefs.getBool(PrefKeys.timerNoiseOn) ?? true,
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
    await prefs.setString(PrefKeys.motivationCategory, settings.motivationCategory);
    await prefs.setInt(PrefKeys.motivationDelaySeconds, settings.motivationDelaySeconds);
    await prefs.setBool(PrefKeys.timerSpeakOn, settings.timerSpeakOn);
    await prefs.setInt(PrefKeys.timerAnnounceEvery, settings.timerAnnounceEvery);
    await prefs.setBool(PrefKeys.timerNoiseOn, settings.timerNoiseOn);
    await prefs.setString(PrefKeys.voiceListMode, settings.voiceListMode);

    if (settings.favoriteVoiceName != null) {
      await prefs.setString(PrefKeys.favoriteVoiceName, settings.favoriteVoiceName!);
    } else {
      await prefs.remove(PrefKeys.favoriteVoiceName);
    }

    if (settings.favoriteVoiceLocale != null) {
      await prefs.setString(PrefKeys.favoriteVoiceLocale, settings.favoriteVoiceLocale!);
    } else {
      await prefs.remove(PrefKeys.favoriteVoiceLocale);
    }
  }
}