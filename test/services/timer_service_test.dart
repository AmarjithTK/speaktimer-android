import 'package:flutter_test/flutter_test.dart';
import 'package:solasflow/services/timer_service.dart';

void main() {
  group('TimerService.tick', () {
    final service = TimerService();

    test('returns finished when countdown reaches zero', () {
      final result = service.tick(
        seconds: 1,
        timerSpeakOn: true,
        timerAnnounceEvery: 1,
      );

      expect(result.nextSeconds, 0);
      expect(result.isFinished, true);
      expect(result.timerValue, '00:01');
    });

    test('announces only on minute boundaries with interval', () {
      final result = service.tick(
        seconds: 5 * 60,
        timerSpeakOn: true,
        timerAnnounceEvery: 5,
      );

      expect(result.shouldAnnounceRemaining, true);
      expect(result.announceMinutes, 5);
      expect(result.isFinished, false);
    });

    test('does not announce when speech is disabled', () {
      final result = service.tick(
        seconds: 5 * 60,
        timerSpeakOn: false,
        timerAnnounceEvery: 1,
      );

      expect(result.shouldAnnounceRemaining, false);
    });

    test('reports every announcement boundary crossed by a delayed tick', () {
      final crossed = service.crossedAnnouncementMinutes(
        previousSeconds: 5 * 60 + 10,
        currentSeconds: 2 * 60 + 50,
        announceEveryMinutes: 1,
      );

      expect(crossed, [5, 4, 3]);
    });

    test(
      'clamps invalid announcement intervals instead of dividing by zero',
      () {
        final result = service.tick(
          seconds: 60,
          timerSpeakOn: true,
          timerAnnounceEvery: 0,
        );

        expect(result.shouldAnnounceRemaining, isTrue);
        expect(
          service.crossedAnnouncementMinutes(
            previousSeconds: 61,
            currentSeconds: 59,
            announceEveryMinutes: 0,
          ),
          [1],
        );
      },
    );
  });
}
