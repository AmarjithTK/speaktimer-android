enum TimerRuntimeStatus { idle, running, paused, finished }

class TimerRuntime {
  final String runId;
  final TimerRuntimeStatus status;
  final int durationSeconds;
  final int remainingSeconds;
  final int? endAtEpochMs;
  final bool chainModeOn;
  final String chainPresetKey;
  final int chainIndex;
  final int revision;

  const TimerRuntime({
    required this.runId,
    required this.status,
    required this.durationSeconds,
    required this.remainingSeconds,
    required this.endAtEpochMs,
    required this.chainModeOn,
    required this.chainPresetKey,
    required this.chainIndex,
    required this.revision,
  });

  factory TimerRuntime.idle() => const TimerRuntime(
    runId: '',
    status: TimerRuntimeStatus.idle,
    durationSeconds: 0,
    remainingSeconds: 0,
    endAtEpochMs: null,
    chainModeOn: false,
    chainPresetKey: 'Pomodoro 25-5x4',
    chainIndex: 0,
    revision: 0,
  );

  factory TimerRuntime.running({
    required int durationSeconds,
    required int remainingSeconds,
    required DateTime now,
    required bool chainModeOn,
    required String chainPresetKey,
    required int chainIndex,
    String? runId,
    int revision = 1,
  }) {
    final safeRemaining = remainingSeconds.clamp(1, 720 * 60);
    return TimerRuntime(
      runId: runId ?? '${now.microsecondsSinceEpoch}',
      status: TimerRuntimeStatus.running,
      durationSeconds: durationSeconds.clamp(1, 720 * 60),
      remainingSeconds: safeRemaining,
      endAtEpochMs: now
          .add(Duration(seconds: safeRemaining))
          .millisecondsSinceEpoch,
      chainModeOn: chainModeOn,
      chainPresetKey: chainPresetKey,
      chainIndex: chainIndex,
      revision: revision,
    );
  }

  int remainingAt(DateTime now) {
    if (status != TimerRuntimeStatus.running || endAtEpochMs == null) {
      return remainingSeconds.clamp(0, 720 * 60);
    }
    final deltaMs = endAtEpochMs! - now.millisecondsSinceEpoch;
    if (deltaMs <= 0) return 0;
    return ((deltaMs + 999) ~/ 1000).clamp(0, 720 * 60);
  }

  TimerRuntime copyWith({
    String? runId,
    TimerRuntimeStatus? status,
    int? durationSeconds,
    int? remainingSeconds,
    int? Function()? endAtEpochMs,
    bool? chainModeOn,
    String? chainPresetKey,
    int? chainIndex,
    int? revision,
  }) => TimerRuntime(
    runId: runId ?? this.runId,
    status: status ?? this.status,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    endAtEpochMs: endAtEpochMs == null ? this.endAtEpochMs : endAtEpochMs(),
    chainModeOn: chainModeOn ?? this.chainModeOn,
    chainPresetKey: chainPresetKey ?? this.chainPresetKey,
    chainIndex: chainIndex ?? this.chainIndex,
    revision: revision ?? this.revision,
  );

  Map<String, dynamic> toJson() => {
    'runId': runId,
    'status': status.name,
    'durationSeconds': durationSeconds,
    'remainingSeconds': remainingSeconds,
    'endAtEpochMs': endAtEpochMs,
    'chainModeOn': chainModeOn,
    'chainPresetKey': chainPresetKey,
    'chainIndex': chainIndex,
    'revision': revision,
  };

  factory TimerRuntime.fromJson(Map<String, dynamic> json) {
    final statusName = json['status']?.toString();
    final status = TimerRuntimeStatus.values.firstWhere(
      (value) => value.name == statusName,
      orElse: () => TimerRuntimeStatus.idle,
    );
    int readInt(String key, [int fallback = 0]) {
      final value = json[key];
      return value is num ? value.toInt() : fallback;
    }

    return TimerRuntime(
      runId: json['runId']?.toString() ?? '',
      status: status,
      durationSeconds: readInt('durationSeconds').clamp(0, 720 * 60),
      remainingSeconds: readInt('remainingSeconds').clamp(0, 720 * 60),
      endAtEpochMs: json['endAtEpochMs'] is num
          ? readInt('endAtEpochMs')
          : null,
      chainModeOn: json['chainModeOn'] == true,
      chainPresetKey: json['chainPresetKey']?.toString() ?? 'Pomodoro 25-5x4',
      chainIndex: readInt('chainIndex').clamp(0, 1000),
      revision: readInt('revision').clamp(0, 1 << 30),
    );
  }
}

class StopwatchRuntime {
  final bool isRunning;
  final int accumulatedMs;
  final int? startedAtEpochMs;
  final int revision;

  const StopwatchRuntime({
    required this.isRunning,
    required this.accumulatedMs,
    required this.startedAtEpochMs,
    required this.revision,
  });

  factory StopwatchRuntime.idle() => const StopwatchRuntime(
    isRunning: false,
    accumulatedMs: 0,
    startedAtEpochMs: null,
    revision: 0,
  );

  int elapsedMsAt(DateTime now) {
    if (!isRunning || startedAtEpochMs == null) return accumulatedMs;
    return accumulatedMs +
        (now.millisecondsSinceEpoch - startedAtEpochMs!).clamp(0, 1 << 52);
  }

  StopwatchRuntime copyWith({
    bool? isRunning,
    int? accumulatedMs,
    int? Function()? startedAtEpochMs,
    int? revision,
  }) => StopwatchRuntime(
    isRunning: isRunning ?? this.isRunning,
    accumulatedMs: accumulatedMs ?? this.accumulatedMs,
    startedAtEpochMs: startedAtEpochMs == null
        ? this.startedAtEpochMs
        : startedAtEpochMs(),
    revision: revision ?? this.revision,
  );

  Map<String, dynamic> toJson() => {
    'isRunning': isRunning,
    'accumulatedMs': accumulatedMs,
    'startedAtEpochMs': startedAtEpochMs,
    'revision': revision,
  };

  factory StopwatchRuntime.fromJson(Map<String, dynamic> json) {
    int readInt(String key, [int fallback = 0]) {
      final value = json[key];
      return value is num ? value.toInt() : fallback;
    }

    return StopwatchRuntime(
      isRunning: json['isRunning'] == true,
      accumulatedMs: readInt('accumulatedMs').clamp(0, 1 << 52),
      startedAtEpochMs: json['startedAtEpochMs'] is num
          ? readInt('startedAtEpochMs')
          : null,
      revision: readInt('revision').clamp(0, 1 << 30),
    );
  }
}
