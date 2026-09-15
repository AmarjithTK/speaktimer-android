import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/session_log.dart';

class SessionLogService {
  static const String _prefsKey = 'SessionLogs';
  static const int retentionDays = 90;
  static Future<void> _writeTail = Future<void>.value();

  Future<void> logSession(SessionLog session) {
    _writeTail = _writeTail
        .catchError((Object error, StackTrace stackTrace) {
          debugPrint('Previous session write failed: $error');
        })
        .then((_) async {
          final prefs = await SharedPreferences.getInstance();
          final sessions = _decode(prefs.getStringList(_prefsKey) ?? const []);
          sessions.add(session);
          await _writeSessions(prefs, sessions);
        });
    return _writeTail;
  }

  Future<List<SessionLog>> getSessionsForDate(DateTime date) async {
    final all = await _loadAll();
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    return all
        .where(
          (session) =>
              session.startTime.isBefore(dayEnd) &&
              session.endTime.isAfter(dayStart),
        )
        .toList(growable: false);
  }

  Future<DailySummary> getDailySummary(DateTime date) async {
    final sessions = await getSessionsForDate(date);
    return SessionLog.summarizeForDay(sessions, date);
  }

  Future<List<(DateTime date, DailySummary summary)>> getRecentSummaries({
    int days = 30,
  }) async {
    final all = await _loadAll();
    final now = DateTime.now();
    final results = <(DateTime, DailySummary)>[];
    for (var offset = 0; offset < days; offset++) {
      final date = DateTime(now.year, now.month, now.day - offset);
      final summary = SessionLog.summarizeForDay(all, date);
      if (summary.totalSeconds > 0) results.add((date, summary));
    }
    return results;
  }

  Future<void> prune() {
    _writeTail = _writeTail
        .catchError((Object error, StackTrace stackTrace) {
          debugPrint('Previous session write failed: $error');
        })
        .then((_) async {
          final prefs = await SharedPreferences.getInstance();
          await _writeSessions(
            prefs,
            _decode(prefs.getStringList(_prefsKey) ?? const []),
          );
        });
    return _writeTail;
  }

  Future<List<SessionLog>> _loadAll() async {
    await _writeTail;
    final prefs = await SharedPreferences.getInstance();
    return _decode(prefs.getStringList(_prefsKey) ?? const []);
  }

  List<SessionLog> _decode(List<String> raw) => raw
      .map((line) {
        try {
          final decoded = jsonDecode(line);
          return decoded is Map<String, dynamic>
              ? SessionLog.fromJson(decoded)
              : null;
        } catch (_) {
          return null;
        }
      })
      .whereType<SessionLog>()
      .toList();

  Future<void> _writeSessions(
    SharedPreferences prefs,
    List<SessionLog> sessions,
  ) async {
    final cutoff = DateTime.now().subtract(const Duration(days: retentionDays));
    final encoded = sessions
        .where((session) => session.endTime.isAfter(cutoff))
        .map((session) => jsonEncode(session.toJson()))
        .toList(growable: false);
    final written = await prefs.setStringList(_prefsKey, encoded);
    if (!written) throw StateError('SharedPreferences rejected session log');
  }
}
