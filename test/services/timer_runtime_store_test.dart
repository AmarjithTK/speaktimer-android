import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solasflow/models/timer_runtime.dart';
import 'package:solasflow/services/timer_runtime_store.dart';

void main() {
  group('TimerRuntime', () {
    test('derives remaining time from the persisted deadline', () {
      final startedAt = DateTime(2026, 7, 28, 10);
      final runtime = TimerRuntime.running(
        durationSeconds: 300,
        remainingSeconds: 300,
        now: startedAt,
        chainModeOn: false,
        chainPresetKey: 'Pomodoro 25-5x4',
        chainIndex: 0,
      );

      expect(
        runtime.remainingAt(startedAt.add(const Duration(seconds: 123))),
        177,
      );
      expect(runtime.remainingAt(startedAt.add(const Duration(minutes: 6))), 0);
    });

    test('restores a running stopwatch from wall-clock time', () {
      final startedAt = DateTime(2026, 7, 28, 10);
      final runtime = StopwatchRuntime(
        isRunning: true,
        accumulatedMs: 2500,
        startedAtEpochMs: startedAt.millisecondsSinceEpoch,
        revision: 1,
      );

      expect(
        runtime.elapsedMsAt(startedAt.add(const Duration(seconds: 10))),
        12500,
      );
    });
  });

  group('TimerRuntimeStore', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test(
      'persists the last serialized timer and stopwatch revisions',
      () async {
        final store = TimerRuntimeStore();
        final now = DateTime(2026, 7, 28, 10);
        final first = TimerRuntime.running(
          durationSeconds: 60,
          remainingSeconds: 60,
          now: now,
          chainModeOn: false,
          chainPresetKey: 'Pomodoro 25-5x4',
          chainIndex: 0,
          revision: 1,
        );
        final second = first.copyWith(
          status: TimerRuntimeStatus.paused,
          remainingSeconds: 42,
          endAtEpochMs: () => null,
          revision: 2,
        );
        final stopwatch = StopwatchRuntime(
          isRunning: false,
          accumulatedMs: 12345,
          startedAtEpochMs: null,
          revision: 3,
        );

        await Future.wait([store.save(first), store.save(second)]);
        await store.saveStopwatch(stopwatch);

        final restoredTimer = await store.load();
        final restoredStopwatch = await store.loadStopwatch();
        expect(restoredTimer.status, TimerRuntimeStatus.paused);
        expect(restoredTimer.remainingSeconds, 42);
        expect(restoredTimer.revision, 2);
        expect(restoredStopwatch.accumulatedMs, 12345);
        expect(restoredStopwatch.revision, 3);
      },
    );
  });
}
