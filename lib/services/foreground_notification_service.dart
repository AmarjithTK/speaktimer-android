import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../models/foreground_notification_state.dart';

class ForegroundNotificationService {
  final String notificationIconMetaDataName;

  const ForegroundNotificationService({
    required this.notificationIconMetaDataName,
  });

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

    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.updateService(
        notificationTitle: state.title,
        notificationText: state.text,
        notificationButtons: state.buttons,
      );
      return nowMs;
    }

    return lastSyncMs;
  }

  Future<void> ensureRunning({
    required ForegroundNotificationState state,
    required Function callback,
  }) async {
    if (!await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.startService(
        notificationTitle: state.title,
        notificationText: state.text,
        notificationIcon: NotificationIcon(
          metaDataName: notificationIconMetaDataName,
        ),
        notificationButtons: state.buttons,
        callback: callback,
      );
      return;
    }

    await FlutterForegroundTask.updateService(
      notificationTitle: state.title,
      notificationText: state.text,
      notificationButtons: state.buttons,
    );
  }
}