import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class ForegroundNotificationState {
  final bool isTimerRunning;
  final bool isStopwatchRunning;
  final String timerValue;
  final String stopwatchValue;
  final String currentTimeDisplay;
  final bool clockSpeechOn;

  const ForegroundNotificationState({
    required this.isTimerRunning,
    required this.isStopwatchRunning,
    required this.timerValue,
    required this.stopwatchValue,
    required this.currentTimeDisplay,
    required this.clockSpeechOn,
  });

  String get title {
    if (isTimerRunning) return 'lifer (Timer Running)';
    if (isStopwatchRunning) return 'lifer (Stopwatch Running)';
    return 'lifer (Clock Mode)';
  }

  String get text {
    if (isTimerRunning) {
      return 'Time remaining: $timerValue';
    }
    if (isStopwatchRunning) {
      return 'Elapsed: $stopwatchValue';
    }
    return 'Current time: $currentTimeDisplay';
  }

  List<NotificationButton> get buttons {
    if (isTimerRunning) {
      return [
        const NotificationButton(id: 'btn_timer_toggle', text: 'Stop Timer'),
        const NotificationButton(id: 'btn_stopwatch_toggle', text: 'Start SW'),
        NotificationButton(
          id: 'btn_clock_speech',
          text: clockSpeechOn ? 'Clock Speech ON' : 'Clock Speech OFF',
        ),
        const NotificationButton(id: 'btn_exit', text: 'Exit'),
      ];
    }

    if (isStopwatchRunning) {
      return [
        const NotificationButton(id: 'btn_stopwatch_toggle', text: 'Stop SW'),
        const NotificationButton(id: 'btn_timer_toggle', text: 'Start Timer'),
        NotificationButton(
          id: 'btn_clock_speech',
          text: clockSpeechOn ? 'Clock Speech ON' : 'Clock Speech OFF',
        ),
        const NotificationButton(id: 'btn_exit', text: 'Exit'),
      ];
    }

    return [
      const NotificationButton(id: 'btn_stopwatch_toggle', text: 'Start SW'),
      NotificationButton(
        id: 'btn_clock_speech',
        text: clockSpeechOn ? 'Clock Speech ON' : 'Clock Speech OFF',
      ),
      const NotificationButton(id: 'btn_exit', text: 'Exit'),
    ];
  }
}
