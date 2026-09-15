import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_settings.dart';

/// The immutable, complete settings snapshot used by every UI surface.
typedef SettingsState = AppSettings;

/// Owns the only in-memory copy of user settings.
///
/// [bootstrap] is called before `runApp`, so consumers never render temporary
/// defaults and external actions cannot race a later preferences load.
class SettingsNotifier extends Notifier<AppSettings> {
  static AppSettings _bootSettings = AppSettings.defaults();

  static void bootstrap(AppSettings settings) {
    _bootSettings = settings.normalized();
  }

  @override
  AppSettings build() => _bootSettings;

  void replace(AppSettings settings) {
    state = settings.normalized();
  }

  void update(AppSettings Function(AppSettings current) transform) {
    state = transform(state).normalized();
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
