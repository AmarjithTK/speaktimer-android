// ============================================================================
// TimerService - Timer countdown logic and time formatting
// ============================================================================
//
// Responsibilities:
// - Format current time in 12-hour and 24-hour displays
// - Convert time to spoken words (e.g., "3 o'clock PM")
// - Calculate countdown remaining from seconds
// - Determine announcement points based on frequency settings
// - Track completion and achievement thresholds
//
// This service is stateless: it receives timer state and returns formatted
// results. No timers are managed here; that's done in the UI layer.

import '../models/timer_tick_result.dart';

class TimerService {
  /// Format current time with milliseconds for detailed display
  /// Returns: "HH:MM:SS.mmm AM/PM" (e.g., "03:45:30.125 PM")
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

  /// Convert time to natural spoken English (for TTS announcements)
  /// Examples:
  ///   - 3:00 AM → "3 o'clock AM"
  ///   - 3:05 PM → "3 oh 5 PM"
  ///   - 3:45 PM → "3 45 PM"
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

  int remainingSeconds({required DateTime endAt, required DateTime now}) {
    final deltaMs = endAt.millisecondsSinceEpoch - now.millisecondsSinceEpoch;
    if (deltaMs <= 0) return 0;
    return (deltaMs + 999) ~/ 1000;
  }

  List<int> crossedAnnouncementMinutes({
    required int previousSeconds,
    required int currentSeconds,
    required int announceEveryMinutes,
  }) {
    if (currentSeconds >= previousSeconds || previousSeconds <= 0) {
      return const [];
    }
    final frequency = announceEveryMinutes.clamp(1, 720);
    final crossed = <int>[];
    final highestMinute = previousSeconds ~/ 60;
    final lowestMinute = (currentSeconds / 60).ceil();
    for (var minute = highestMinute; minute >= lowestMinute; minute--) {
      final boundary = minute * 60;
      if (minute > 0 &&
          minute % frequency == 0 &&
          previousSeconds >= boundary &&
          currentSeconds < boundary) {
        crossed.add(minute);
      }
    }
    return crossed;
  }

  TimerTickResult tick({
    required int seconds,
    required bool timerSpeakOn,
    required int timerAnnounceEvery,
  }) {
    final safeSeconds = seconds.clamp(0, 720 * 60);
    final mins = safeSeconds ~/ 60;
    final secs = safeSeconds % 60;
    final nextSeconds = safeSeconds > 0 ? safeSeconds - 1 : 0;
    final frequency = timerAnnounceEvery.clamp(1, 720);

    final mStr = mins.toString().padLeft(2, '0');
    final sStr = secs.toString().padLeft(2, '0');
    final timerValue = '$mStr:$sStr';

    final shouldAnnounceRemaining =
        secs == 0 &&
        nextSeconds != 0 &&
        timerSpeakOn &&
        mins > 0 &&
        mins % frequency == 0;

    return TimerTickResult(
      nextSeconds: nextSeconds,
      timerValue: timerValue,
      shouldAnnounceRemaining: shouldAnnounceRemaining,
      announceMinutes: mins,
      isFinished: safeSeconds > 0 && nextSeconds == 0,
    );
  }
}
