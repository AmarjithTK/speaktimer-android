import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/palette.dart' show AppColorAccess;
import 'primary_button.dart';
import 'secondary_button.dart';
import 'settings_row.dart';
import 'section_header.dart';

/// Redesigned Stopwatch panel — clean, minimal, time-first.
class StopwatchPanel extends StatelessWidget {
  final VoidCallback onFullscreenPressed;
  final VoidCallback onFullscreenImmersivePressed;
  final String elapsedValue;
  final bool isRunning;
  final VoidCallback startStopwatch;
  final VoidCallback stopStopwatch;
  final VoidCallback resetStopwatch;
  final VoidCallback? onLap;
  final int lapCount;
  final List<String> lapTimes;
  final VoidCallback onExitApp;

  final bool stopwatchSpeakOn;
  final bool stopwatchShowMilliseconds;
  final int stopwatchSpeakDelaySeconds;
  final List<int> stopwatchSpeakDelayOptions;
  final ValueChanged<bool?> onStopwatchSpeakOnChanged;
  final ValueChanged<bool?> onStopwatchShowMillisecondsChanged;
  final ValueChanged<int?> onStopwatchSpeakDelayChanged;

  const StopwatchPanel({
    super.key,
    required this.onFullscreenPressed,
    required this.onFullscreenImmersivePressed,
    required this.elapsedValue,
    required this.isRunning,
    required this.startStopwatch,
    required this.stopStopwatch,
    required this.resetStopwatch,
    this.onLap,
    this.lapCount = 0,
    this.lapTimes = const [],
    required this.onExitApp,
    required this.stopwatchSpeakOn,
    required this.stopwatchShowMilliseconds,
    required this.stopwatchSpeakDelaySeconds,
    required this.stopwatchSpeakDelayOptions,
    required this.onStopwatchSpeakOnChanged,
    required this.onStopwatchShowMillisecondsChanged,
    required this.onStopwatchSpeakDelayChanged,
  });

  String _formatElapsed(String value) {
    if (value.contains('.') && !stopwatchShowMilliseconds) {
      return value.split('.').first;
    }
    return value;
  }

  String _delayLabel(int seconds) {
    if (seconds < 60) return '$seconds sec';
    if (seconds % 60 == 0) return '${seconds ~/ 60} min';
    return '$seconds sec';
  }

  String _lapDelta(int index) {
    if (lapTimes.length < 2 || index >= lapTimes.length) return '';
    final current = _parseSeconds(lapTimes[index]);
    final previous = _parseSeconds(lapTimes[index - 1]);
    if (current == null || previous == null) return '';
    final diff = current - previous;
    if (diff >= 0) return '+${_formatDelta(diff)}';
    return '-${_formatDelta(diff.abs())}';
  }

  int? _parseSeconds(String time) {
    try {
      final parts = time.split(':');
      if (parts.length == 2) {
        return int.parse(parts[0]) * 60 + int.parse(parts[1]);
      }
      if (parts.length == 3) {
        return int.parse(parts[0]) * 3600 +
            int.parse(parts[1]) * 60 +
            int.parse(parts[2]);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  String _formatDelta(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final display = _formatElapsed(elapsedValue);

    return SafeArea(
      child: ColoredBox(
        color: c.background,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            const SizedBox(height: 16),

            // ── Hero elapsed display ─────────────────────────────
            GestureDetector(
              onTap: onFullscreenPressed,
              onDoubleTap: onFullscreenImmersivePressed,
              child: Center(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: c.surfaceBorder),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'ELAPSED',
                        style: GoogleFonts.inter(
                          color: c.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          display,
                          style: GoogleFonts.inter(
                            color: c.textPrimary,
                            fontSize: 64,
                            height: 0.85,
                            fontWeight: FontWeight.w800,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                      if (lapCount > 0) ...[
                        const SizedBox(height: 8),
                        Text(
                          '$lapCount laps',
                          style: GoogleFonts.inter(
                            color: c.textMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Action buttons ───────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: isRunning ? 'Pause' : 'Start',
                    icon: isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    onPressed: isRunning ? stopStopwatch : startStopwatch,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SecondaryButton(
                    label: 'Lap',
                    icon: Icons.flag_rounded,
                    onPressed: isRunning ? onLap : null,
                    compact: true,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 48,
                  width: 48,
                  child: OutlinedButton(
                    onPressed: resetStopwatch,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Icon(Icons.refresh_rounded, size: 20, color: c.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── Lap list ─────────────────────────────────────────
            if (lapTimes.isNotEmpty) ...[
              const SectionHeader(label: 'Lap times'),
              const SizedBox(height: 4),
              ...List.generate(math.min(lapTimes.length, 20), (index) {
                final i = lapTimes.length - 1 - index;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: i > 0 ? c.divider : Colors.transparent,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: c.surfaceSubtle,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${i + 1}',
                          style: GoogleFonts.inter(
                            color: c.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          lapTimes[i],
                          style: GoogleFonts.inter(
                            color: c.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                      if (i > 0)
                        Text(
                          _lapDelta(i),
                          style: GoogleFonts.inter(
                            color: c.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 20),
            ],

            // ── Settings rows ────────────────────────────────────
            SettingsRow(
              icon: Icons.record_voice_over_rounded,
              label: 'Speech',
              value: stopwatchSpeakOn ? 'On' : 'Off',
              onTap: () => onStopwatchSpeakOnChanged(!stopwatchSpeakOn),
            ),
            SettingsRow(
              icon: Icons.speed_rounded,
              label: 'Show milliseconds',
              value: stopwatchShowMilliseconds ? 'On' : 'Off',
              onTap: () => onStopwatchShowMillisecondsChanged(!stopwatchShowMilliseconds),
            ),
            SettingsRow(
              icon: Icons.timer_outlined,
              label: 'Speak delay',
              value: _delayLabel(stopwatchSpeakDelaySeconds),
              onTap: () => _showDelaySheet(context),
              showDivider: false,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDelaySheet(BuildContext context) async {
    final c = context.appColors;
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Speak elapsed every',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              ...stopwatchSpeakDelayOptions.map((value) {
                final selected = value == stopwatchSpeakDelaySeconds;
                return ListTile(
                  selected: selected,
                  selectedTileColor: c.accentLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: Icon(
                    selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: selected ? c.accent : c.textMuted,
                  ),
                  title: Text(
                    _delayLabel(value),
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: c.textPrimary,
                    ),
                  ),
                  onTap: () {
                    onStopwatchSpeakDelayChanged(value);
                    Navigator.of(context).pop();
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
