import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/session_log.dart';

/// Persists and queries timer session logs stored as JSON in SharedPreferences.
///
/// Each session records start/end times, duration, and a study/non-study tag.
/// Old entries are auto-pruned beyond [retentionDays] (default 90).
class SessionLogService {
  static const String _prefsKey = 'SessionLogs';
  static const int retentionDays = 90;

  /// Append a completed session log to persistent storage.
  Future<void> logSession(SessionLog session) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey) ?? [];
    raw.add(jsonEncode(session.toJson()));

    // Prune old entries in the same write to avoid unbounded growth.
    final cutoff = DateTime.now().subtract(const Duration(days: retentionDays));
    final pruned = raw.where((line) {
      try {
        final json = jsonDecode(line) as Map<String, dynamic>;
        final end = DateTime.parse(json['endTime'] as String);
        return end.isAfter(cutoff);
      } catch (_) {
        return false; // drop corrupt entries
      }
    }).toList();

    await prefs.setStringList(_prefsKey, pruned);
  }

  /// Return all sessions that overlap with the given calendar date (local time).
  Future<List<SessionLog>> getSessionsForDate(DateTime date) async {
    final all = await _loadAll();
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    return all.where((s) {
      // Session overlaps the day if it starts before dayEnd and ends after dayStart.
      return s.startTime.isBefore(dayEnd) && s.endTime.isAfter(dayStart);
    }).toList();
  }

  /// Return a [DailySummary] for the given calendar date.
  Future<DailySummary> getDailySummary(DateTime date) async {
    final sessions = await getSessionsForDate(date);
    return SessionLog.summarize(sessions);
  }

  /// Return daily summaries for the last [days] days, most recent first.
  Future<List<(DateTime date, DailySummary summary)>> getRecentSummaries({
    int days = 30,
  }) async {
    final all = await _loadAll();
    final now = DateTime.now();
    final results = <(DateTime, DailySummary)>[];

    for (int i = 0; i < days; i++) {
      final date = DateTime(now.year, now.month, now.day - i);
      final dayStart = date;
      final dayEnd = date.add(const Duration(days: 1));
      final daySessions = all.where((s) {
        return s.startTime.isBefore(dayEnd) && s.endTime.isAfter(dayStart);
      }).toList();
      // Skip days with no sessions.
      if (daySessions.isEmpty) continue;
      results.add((date, SessionLog.summarize(daySessions)));
    }

    return results;
  }

  /// Remove entries older than [retentionDays].
  Future<void> prune() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey) ?? [];
    final cutoff = DateTime.now().subtract(const Duration(days: retentionDays));
    final pruned = raw.where((line) {
      try {
        final json = jsonDecode(line) as Map<String, dynamic>;
        final end = DateTime.parse(json['endTime'] as String);
        return end.isAfter(cutoff);
      } catch (_) {
        return false;
      }
    }).toList();
    await prefs.setStringList(_prefsKey, pruned);
  }

  Future<List<SessionLog>> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey) ?? [];
    return raw.map((line) {
      try {
        final json = jsonDecode(line) as Map<String, dynamic>;
        return SessionLog.fromJson(json);
      } catch (_) {
        return null;
      }
    }).whereType<SessionLog>().toList();
  }
}
