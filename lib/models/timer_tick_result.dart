class TimerTickResult {
  final int nextSeconds;
  final String timerValue;
  final bool shouldAnnounceRemaining;
  final int announceMinutes;
  final bool isFinished;

  const TimerTickResult({
    required this.nextSeconds,
    required this.timerValue,
    required this.shouldAnnounceRemaining,
    required this.announceMinutes,
    required this.isFinished,
  });
}