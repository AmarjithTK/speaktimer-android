import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solasflow/models/app_settings.dart';
import 'package:solasflow/providers/app_state.dart';

void main() {
  test('settings commands update the same snapshot watched by consumers', () {
    SettingsNotifier.bootstrap(
      AppSettings.defaults().copyWith(speechMasterOn: true),
    );
    final container = ProviderContainer();
    addTearDown(() {
      container.dispose();
      SettingsNotifier.bootstrap(AppSettings.defaults());
    });

    container
        .read(settingsProvider.notifier)
        .update((settings) => settings.copyWith(speechMasterOn: false));

    expect(container.read(settingsProvider).speechMasterOn, isFalse);
  });
}
