/// A single timer session record with study/non-study tag.
///
/// Stored as JSON in SharedPreferences. Each completed or partial timer
/// session is logged with its start/end times, duration, and tag.
class SessionLog {
  final DateTime startTime;
  final DateTime endTime;
  final int durationSeconds;
  final String tag; // "study" | "non-study"

  const SessionLog({
    required this.startTime,
    required this.endTime,
    required this.durationSeconds,
    required this.tag,
  });

  bool get isStudy => tag == 'study';
  bool get isNonStudy => tag == 'non-study';

  String get formattedDuration {
    final h = durationSeconds ~/ 3600;
    final m = (durationSeconds % 3600) ~/ 60;
    final s = durationSeconds % 60;
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  Map<String, dynamic> toJson() => {
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'durationSeconds': durationSeconds,
        'tag': tag,
      };

  factory SessionLog.fromJson(Map<String, dynamic> json) => SessionLog(
        startTime: DateTime.parse(json['startTime'] as String),
        endTime: DateTime.parse(json['endTime'] as String),
        durationSeconds: json['durationSeconds'] as int,
        tag: json['tag'] as String,
      );

  /// Daily summary for a group of sessions.
  static DailySummary summarize(List<SessionLog> sessions) {
    int studySeconds = 0;
    int nonStudySeconds = 0;
    for (final s in sessions) {
      if (s.isStudy) {
        studySeconds += s.durationSeconds;
      } else {
        nonStudySeconds += s.durationSeconds;
      }
    }
    return DailySummary(studySeconds: studySeconds, nonStudySeconds: nonStudySeconds);
  }
}

/// Aggregated study/non-study totals for a single day.
class DailySummary {
  final int studySeconds;
  final int nonStudySeconds;

  const DailySummary({required this.studySeconds, required this.nonStudySeconds});

  int get totalSeconds => studySeconds + nonStudySeconds;

  String get studyFormatted => _format(studySeconds);
  String get nonStudyFormatted => _format(nonStudySeconds);
  String get totalFormatted => _format(totalSeconds);

  static String _format(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }
}
