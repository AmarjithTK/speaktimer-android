import 'package:flutter_test/flutter_test.dart';
import 'package:solasflow/models/foreground_notification_state.dart';

void main() {
  test(
    'master audio notification actions encode the requested final state',
    () {
      const enabled = ForegroundNotificationState(
        isTimerRunning: false,
        isStopwatchRunning: false,
        timerValue: '00:00',
        stopwatchValue: '00:00',
        currentTimeDisplay: '10:00',
        speechMasterOn: true,
        isTimerFinished: false,
      );
      const disabled = ForegroundNotificationState(
        isTimerRunning: false,
        isStopwatchRunning: false,
        timerValue: '00:00',
        stopwatchValue: '00:00',
        currentTimeDisplay: '10:00',
        speechMasterOn: false,
        isTimerFinished: false,
      );

      expect(
        enabled.buttons.map((button) => button.id),
        containsAll(['audio:set:off', 'open_app']),
      );
      expect(
        disabled.buttons.map((button) => button.id),
        containsAll(['audio:set:on', 'open_app']),
      );
    },
  );

  test('finished timer exposes repeat and dismiss actions', () {
    const state = ForegroundNotificationState(
      isTimerRunning: false,
      isStopwatchRunning: false,
      timerValue: '00:00',
      stopwatchValue: '00:00',
      currentTimeDisplay: '10:00',
      speechMasterOn: true,
      isTimerFinished: true,
    );

    expect(
      state.buttons.map((button) => button.id),
      containsAll(['btn_timer_repeat', 'btn_timer_dismiss', 'open_app']),
    );
  });
}
