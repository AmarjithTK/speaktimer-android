import 'package:flutter_test/flutter_test.dart';
import 'package:solasflow/core/pref_keys.dart';
import 'package:solasflow/models/app_settings.dart';
import 'package:solasflow/providers/app_state.dart';
import 'package:solasflow/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Fullscreen Clock Scale', () {
    test('AppSettings defaults fullscreenClockScale to 1.0', () {
      final json = <String, dynamic>{};
      final settings = AppSettings.fromJson(json);
      expect(settings.fullscreenClockScale, 1.0);
    });

    test('AppSettings serializes and deserializes fullscreenClockScale', () {
      final json = <String, dynamic>{
        'fullscreenClockScale': 1.5,
      };
      final settings = AppSettings.fromJson(json);
      expect(settings.fullscreenClockScale, 1.5);

      final outJson = settings.toJson();
      expect(outJson['fullscreenClockScale'], 1.5);
    });

    test('SettingsState defaults and copyWith handles fullscreenClockScale', () {
      final state = SettingsState.defaults();
      expect(state.fullscreenClockScale, 1.0);

      final updated = state.copyWith(fullscreenClockScale: 2.0);
      expect(updated.fullscreenClockScale, 2.0);
    });

    test('SettingsService saves and loads fullscreenClockScale', () async {
      SharedPreferences.setMockInitialValues({
        PrefKeys.fullscreenClockScale: 1.25,
      });

      final service = SettingsService();
      final loaded = await service.load(defaultSound: 'audio/rain.mp3');
      expect(loaded.fullscreenClockScale, 1.25);
    });
  });
}
