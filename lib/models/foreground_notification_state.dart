import 'package:flutter_foreground_task/flutter_foreground_task.dart';

/// Minimal foreground notification state.
///
/// Shows dynamic status text and only two buttons:
/// - Master Audio Toggle (Speech ON / OFF)
/// - Exit (stop foreground service)
class ForegroundNotificationState {
  final bool isTimerRunning;
  final bool isStopwatchRunning;
  final String timerValue;
  final String stopwatchValue;
  final String currentTimeDisplay;
  final bool speechMasterOn;

  const ForegroundNotificationState({
    required this.isTimerRunning,
    required this.isStopwatchRunning,
    required this.timerValue,
    required this.stopwatchValue,
    required this.currentTimeDisplay,
    required this.speechMasterOn,
  });

  String get title {
    if (isTimerRunning) return 'SolasFlow - Timer Running';
    if (isStopwatchRunning) return 'SolasFlow - Stopwatch Running';
    return 'SolasFlow';
  }

  String get text {
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
    return [
      NotificationButton(
        id: 'btn_speech_master',
        text: speechMasterOn ? 'Audio ON' : 'Audio OFF',
      ),
      const NotificationButton(id: 'btn_exit', text: 'Exit'),
    ];
  }
}
