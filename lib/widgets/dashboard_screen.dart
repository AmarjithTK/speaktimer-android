import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/session_log.dart';
import '../services/session_log_service.dart';
import 'day_summary_card.dart';

/// Scrollable dashboard showing daily study/non-study time utilization.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _service = SessionLogService();
  List<(DateTime date, DailySummary summary)> _summaries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _service.getRecentSummaries(days: 90);
    if (!mounted) return;
    setState(() {
      _summaries = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Time Utilization',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _summaries.isEmpty
              ? Center(
                  child: Text(
                    'No sessions logged yet.\nEnable tagging and complete a timer to see data.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: cs.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  itemCount: _summaries.length,
                  itemBuilder: (context, index) {
                    final (date, summary) = _summaries[index];
                    return DaySummaryCard(date: date, summary: summary);
                  },
                ),
    );
  }
}
