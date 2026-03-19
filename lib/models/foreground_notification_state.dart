import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class ForegroundNotificationState {
  final bool isTimerRunning;
  final String timerValue;
  final String currentTimeDisplay;
  final bool clockSpeechOn;

  const ForegroundNotificationState({
    required this.isTimerRunning,
    required this.timerValue,
    required this.currentTimeDisplay,
    required this.clockSpeechOn,
  });

  String get title =>
      isTimerRunning ? 'lifer (Timer Running)' : 'lifer (Clock Mode)';

  String get text {
    if (isTimerRunning) {
      return 'Time remaining: $timerValue';
    }
    return 'Current time: $currentTimeDisplay';
  }

  List<NotificationButton> get buttons {
    if (isTimerRunning) {
      return [
        const NotificationButton(id: 'btn_timer_toggle', text: 'Stop Timer'),
        NotificationButton(
          id: 'btn_clock_speech',
          text: clockSpeechOn ? 'Clock Speech ON' : 'Clock Speech OFF',
        ),
        const NotificationButton(id: 'btn_exit', text: 'Exit'),
      ];
    }

    return [
      NotificationButton(
        id: 'btn_clock_speech',
        text: clockSpeechOn ? 'Clock Speech ON' : 'Clock Speech OFF',
      ),
      const NotificationButton(id: 'btn_exit', text: 'Exit'),
    ];
  }
}