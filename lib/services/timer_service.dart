import '../models/timer_tick_result.dart';

class TimerService {
  String formatCurrentTime(DateTime now) {
    final h = now.hour;
    final m = now.minute.toString().padLeft(2, '0');
    final s = now.second.toString().padLeft(2, '0');
    final ms = now.millisecond.toString().padLeft(3, '0');
    final ampm = h >= 12 ? 'PM' : 'AM';
    final h12 = h % 12 == 0 ? 12 : h % 12;
    final hStr = h12.toString().padLeft(2, '0');
    return '$hStr:$m:$s.$ms $ampm';
  }

  String timeToWords(DateTime now) {
    final h = now.hour;
    final m = now.minute;
    var s = h == 0 ? '12' : (h > 12 ? (h - 12).toString() : h.toString());
    if (m == 0) {
      s += " o'clock";
    } else if (m < 10) {
      s += ' oh $m';
    } else {
      s += ' $m';
    }
    s += h < 12 ? ' AM' : ' PM';
    return s;
  }

  TimerTickResult tick({
    required int seconds,
    required bool timerSpeakOn,
    required int timerAnnounceEvery,
  }) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    final nextSeconds = seconds - 1;

    final mStr = mins.toString().padLeft(2, '0');
    final sStr = secs.toString().padLeft(2, '0');
    final timerValue = '$mStr:$sStr';

    final shouldAnnounceRemaining =
        secs == 0 &&
        nextSeconds != 0 &&
        timerSpeakOn &&
        mins > 0 &&
        mins % timerAnnounceEvery == 0;

    final isFinished = nextSeconds == 0;

    return TimerTickResult(
      nextSeconds: nextSeconds,
      timerValue: timerValue,
      shouldAnnounceRemaining: shouldAnnounceRemaining,
      announceMinutes: mins,
      isFinished: isFinished,
    );
  }
}