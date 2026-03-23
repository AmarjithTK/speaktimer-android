import 'package:flutter_test/flutter_test.dart';
import 'package:lifer/services/timer_service.dart';

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
  });
}
