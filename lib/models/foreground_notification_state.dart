import 'package:flutter_foreground_task/flutter_foreground_task.dart';

/// Foreground notification state.
///
/// Shows dynamic status text and contextual action buttons.
/// When the timer finishes, the notification switches to a
/// "Timer finished!" state with action buttons so the user
/// can respond even from another app.
class ForegroundNotificationState {
  final bool isTimerRunning;
  final bool isStopwatchRunning;
  final String timerValue;
  final String stopwatchValue;
  final String currentTimeDisplay;
  final bool speechMasterOn;
  final bool isTimerFinished;

  const ForegroundNotificationState({
    required this.isTimerRunning,
    required this.isStopwatchRunning,
    required this.timerValue,
    required this.stopwatchValue,
    required this.currentTimeDisplay,
    required this.speechMasterOn,
    this.isTimerFinished = false,
  });

  String get title {
    if (isTimerFinished) return 'SolasFlow - Timer Finished';
    if (isTimerRunning) return 'SolasFlow - Timer Running';
    if (isStopwatchRunning) return 'SolasFlow - Stopwatch Running';
    return 'SolasFlow';
  }

  String get text {
    if (isTimerFinished) {
      return 'Timer finished! Tap to set next timer.';
    }
    final audioStatus = speechMasterOn ? 'Audio ON' : 'Audio OFF';
    if (isTimerRunning) {
      return '$audioStatus  |  Time remaining: $timerValue';
    }
    if (isStopwatchRunning) {
      return '$audioStatus  |  Elapsed: $stopwatchValue';
    }
    final timeStr = currentTimeDisplay.isNotEmpty ? currentTimeDisplay : '';
    return timeStr.isNotEmpty ? '$audioStatus  |  $timeStr' : audioStatus;
  }

  List<NotificationButton> get buttons {
    if (isTimerFinished) {
      return [
        const NotificationButton(id: 'btn_timer_repeat', text: 'Repeat'),
        const NotificationButton(id: 'btn_timer_dismiss', text: 'Dismiss'),
        NotificationButton(
          id: 'btn_speech_master',
          text: speechMasterOn ? 'Audio ON' : 'Audio OFF',
        ),
      ];
    }
    return [
      NotificationButton(
        id: 'btn_speech_master',
        text: speechMasterOn ? 'Audio ON' : 'Audio OFF',
      ),
      const NotificationButton(id: 'btn_exit', text: 'Exit'),
    ];
  }
}
