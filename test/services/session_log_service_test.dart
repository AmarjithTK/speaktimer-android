import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solasflow/models/session_log.dart';
import 'package:solasflow/services/session_log_service.dart';

void main() {
  group('SessionLog', () {
    test('JSON round-trip', () {
      final now = DateTime.now();
      final session = SessionLog(
        startTime: now,
        endTime: now.add(const Duration(hours: 2)),
        durationSeconds: 7200,
        tag: 'study',
      );

      final json = session.toJson();
      final restored = SessionLog.fromJson(json);

      expect(restored.startTime, now);
      expect(restored.durationSeconds, 7200);
      expect(restored.tag, 'study');
      expect(restored.isStudy, true);
      expect(restored.isNonStudy, false);
    });

    test('formattedDuration shows hours and minutes', () {
      final session = SessionLog(
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        durationSeconds: 5400, // 1h 30m
        tag: 'study',
      );
      expect(session.formattedDuration, '1h 30m');
    });

    test('formattedDuration shows minutes and seconds', () {
      final session = SessionLog(
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        durationSeconds: 90, // 1m 30s
        tag: 'non-study',
      );
      expect(session.formattedDuration, '1m 30s');
    });

    test('summarize groups study and non-study', () {
      final now = DateTime.now();
      final sessions = [
        SessionLog(startTime: now, endTime: now, durationSeconds: 3600, tag: 'study'),
        SessionLog(startTime: now, endTime: now, durationSeconds: 1800, tag: 'non-study'),
        SessionLog(startTime: now, endTime: now, durationSeconds: 900, tag: 'study'),
      ];
      final summary = SessionLog.summarize(sessions);
      expect(summary.studySeconds, 4500); // 1h 15m
      expect(summary.nonStudySeconds, 1800); // 30m
      expect(summary.totalSeconds, 6300);
    });

    test('DailySummary formatted', () {
      const summary = DailySummary(studySeconds: 7200, nonStudySeconds: 3600);
      expect(summary.studyFormatted, '2h 0m');
      expect(summary.nonStudyFormatted, '1h 0m');
      expect(summary.totalFormatted, '3h 0m');
    });
  });

  group('SessionLogService', () {
    late SessionLogService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      service = SessionLogService();
    });

    test('logSession persists and loads', () async {
      final now = DateTime(2026, 7, 28, 10, 0);
      final session = SessionLog(
        startTime: now,
        endTime: now.add(const Duration(hours: 1)),
        durationSeconds: 3600,
        tag: 'study',
      );

      await service.logSession(session);
      final sessions = await service.getSessionsForDate(DateTime(2026, 7, 28));

      expect(sessions.length, 1);
      expect(sessions.first.tag, 'study');
      expect(sessions.first.durationSeconds, 3600);
    });

    test('getDailySummary aggregates correctly', () async {
      final base = DateTime(2026, 7, 28, 10, 0);
      await service.logSession(SessionLog(
        startTime: base,
        endTime: base.add(const Duration(hours: 2)),
        durationSeconds: 7200,
        tag: 'study',
      ));
      await service.logSession(SessionLog(
        startTime: base.add(const Duration(hours: 3)),
        endTime: base.add(const Duration(hours: 4)),
        durationSeconds: 3600,
        tag: 'non-study',
      ));

      final summary = await service.getDailySummary(DateTime(2026, 7, 28));
      expect(summary.studySeconds, 7200);
      expect(summary.nonStudySeconds, 3600);
    });

    test('getSessionsForDate filters by day', () async {
      final day1 = DateTime(2026, 7, 28, 10, 0);
      final day2 = DateTime(2026, 7, 29, 10, 0);

      await service.logSession(SessionLog(
        startTime: day1,
        endTime: day1.add(const Duration(hours: 1)),
        durationSeconds: 3600,
        tag: 'study',
      ));
      await service.logSession(SessionLog(
        startTime: day2,
        endTime: day2.add(const Duration(hours: 1)),
        durationSeconds: 3600,
        tag: 'non-study',
      ));

      final day1Sessions = await service.getSessionsForDate(DateTime(2026, 7, 28));
      final day2Sessions = await service.getSessionsForDate(DateTime(2026, 7, 29));

      expect(day1Sessions.length, 1);
      expect(day1Sessions.first.tag, 'study');
      expect(day2Sessions.length, 1);
      expect(day2Sessions.first.tag, 'non-study');
    });

    test('getRecentSummaries returns only days with sessions', () async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 10, 0);
      final twoDaysAgo = DateTime(now.year, now.month, now.day - 2, 10, 0);

      await service.logSession(SessionLog(
        startTime: today,
        endTime: today.add(const Duration(hours: 1)),
        durationSeconds: 3600,
        tag: 'study',
      ));
      // No session on yesterday (day - 1)
      await service.logSession(SessionLog(
        startTime: twoDaysAgo,
        endTime: twoDaysAgo.add(const Duration(hours: 1)),
        durationSeconds: 3600,
        tag: 'non-study',
      ));

      final summaries = await service.getRecentSummaries(days: 7);
      // Should have 2 entries (today and 2 days ago), not yesterday
      expect(summaries.length, 2);
    });

    test('prune removes old entries', () async {
      final old = DateTime.now().subtract(const Duration(days: 100));
      await service.logSession(SessionLog(
        startTime: old,
        endTime: old.add(const Duration(hours: 1)),
        durationSeconds: 3600,
        tag: 'study',
      ));
      await service.logSession(SessionLog(
        startTime: DateTime.now().subtract(const Duration(days: 1)),
        endTime: DateTime.now(),
        durationSeconds: 3600,
        tag: 'non-study',
      ));

      await service.prune();
      final all = await service.getSessionsForDate(
        DateTime.now().subtract(const Duration(days: 100)),
      );
      expect(all.length, 0);

      final recent = await service.getSessionsForDate(DateTime.now());
      expect(recent.length, 1);
    });

    test('handles corrupt entries gracefully', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('SessionLogs', ['not valid json']);

      final sessions = await service.getSessionsForDate(DateTime.now());
      expect(sessions, isEmpty);
    });
  });
}
