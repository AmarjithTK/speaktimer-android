import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter/services.dart';

import '../models/foreground_notification_state.dart';

class ForegroundNotificationService {
  final String notificationIconMetaDataName;

  const ForegroundNotificationService({
    required this.notificationIconMetaDataName,
  });

  bool get _supportsForegroundTask {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  Future<bool> _isServiceRunningSafe() async {
    if (!_supportsForegroundTask) return false;
    try {
      return await FlutterForegroundTask.isRunningService;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  Future<void> _updateServiceSafe(ForegroundNotificationState state) async {
    try {
      await FlutterForegroundTask.updateService(
        notificationTitle: state.title,
        notificationText: state.text,
        notificationButtons: state.buttons,
      );
    } on MissingPluginException {
      // Plugin is unavailable on this runtime; ignore foreground update.
    } on PlatformException {
      // Platform rejected the update; ignore and keep app functional.
    }
  }

  Future<int> sync({
    required ForegroundNotificationState state,
    required int lastSyncMs,
    bool force = false,
    int minIntervalMs = 100,
  }) async {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    if (!force && nowMs - lastSyncMs < minIntervalMs) {
      return lastSyncMs;
    }

    if (await _isServiceRunningSafe()) {
      await _updateServiceSafe(state);
      return nowMs;
    }

    return lastSyncMs;
  }

  Future<void> ensureRunning({
    required ForegroundNotificationState state,
    required Function callback,
  }) async {
    if (!await _isServiceRunningSafe()) {
      if (!_supportsForegroundTask) return;
      try {
        await FlutterForegroundTask.startService(
          notificationTitle: state.title,
          notificationText: state.text,
          notificationIcon: NotificationIcon(
            metaDataName: notificationIconMetaDataName,
          ),
          notificationButtons: state.buttons,
          callback: callback,
        );
      } on MissingPluginException {
        return;
      } on PlatformException {
        return;
      }
      return;
    }

    await _updateServiceSafe(state);
  }
}