import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../theme/palette.dart' show TintedSurfaces;

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

  String _delayLabel(int seconds) {
    if (seconds < 60) return '$seconds sec';
    if (seconds % 60 == 0) return '${seconds ~/ 60} min';
    return '$seconds sec';
  }

  String _formatElapsed(String value) {
    // Remove trailing milliseconds for a cleaner hero display
    if (value.contains('.') && !stopwatchShowMilliseconds) {
      return value.split('.').first;
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final display = _formatElapsed(elapsedValue);

    return SafeArea(
      child: ColoredBox(
        color: cs.surface,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const SizedBox(height: 8),

            // ── Hero elapsed display ─────────────────────────────
            GestureDetector(
              onTap: onFullscreenPressed,
              onDoubleTap: onFullscreenImmersivePressed,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = constraints.maxWidth * 0.9;
                  return Center(
                    child: Container(
                      width: maxWidth,
                      padding: const EdgeInsets.symmetric(
                        vertical: 32,
                      ),
                      decoration: BoxDecoration(
                        color: context.tintedSurface,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: cs.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'ELAPSED',
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              display,
                              style: TextStyle(
                                color: cs.onSurface,
                                fontSize: 72,
                                height: 0.85,
                                fontWeight: FontWeight.w900,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ),
                          if (lapCount > 0) ...[
                            const SizedBox(height: 8),
                            Text(
                              '$lapCount laps',
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // ── Action buttons ───────────────────────────────────
            Row(
              children: [
                // Start / Pause
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: FilledButton.icon(
                      onPressed:
                          isRunning ? stopStopwatch : startStopwatch,
                      icon: Icon(
                        isRunning
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 22,
                      ),
                      label: Text(isRunning ? 'Pause' : 'Start'),
                      style: FilledButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Lap
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: isRunning ? onLap : null,
                      icon: const Icon(Icons.flag_rounded, size: 20),
                      label: const Text('Lap'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            isRunning ? cs.onSurface : cs.onSurfaceVariant,
                        backgroundColor: context.tintedSurfaceLow,
                        side: BorderSide(color: cs.outline, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Reset
                SizedBox(
                  height: 52,
                  width: 52,
                  child: IconButton(
                    onPressed: resetStopwatch,
                    tooltip: 'Reset',
                    icon: const Icon(Icons.refresh_rounded),
                    style: IconButton.styleFrom(
                      foregroundColor: cs.onSurfaceVariant,
                      backgroundColor: context.tintedSurfaceLow,
                      side: BorderSide(color: cs.outline, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // ── Quick-toggle chips (like clock & timer) ──────────
            Row(
              children: [
                _quickToggle(
                  context,
                  icon: Icons.record_voice_over_rounded,
                  label: 'Speech',
                  active: stopwatchSpeakOn,
                  activeColor: cs.secondaryContainer,
                  onToggle: () => onStopwatchSpeakOnChanged(!stopwatchSpeakOn),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Lap list ─────────────────────────────────────────
            if (lapTimes.isNotEmpty) ...[
              sectionLabel(cs, 'Lap times'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: context.tintedSurface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: math.min(lapTimes.length, 20),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  separatorBuilder: (_, _) =>
                      Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (context, index) {
                    final i = lapTimes.length - 1 - index;
                    return ListTile(
                      dense: true,
                      leading: Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: context.tintedSurfaceLow,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      title: Text(
                        lapTimes[i],
                        style: TextStyle(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          fontFeatures: const [
                            FontFeature.tabularFigures(),
                          ],
                        ),
                      ),
                      trailing: i > 0
                          ? Text(
                              _lapDelta(i),
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : null,
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── Collapsible options ──────────────────────────────
            _buildOptionsSection(context, cs),
          ],
        ),
      ),
    );
  }

  Widget _quickToggle(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool active,
    required Color activeColor,
    required VoidCallback onToggle,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? activeColor : context.tintedSurfaceLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: active ? cs.onSurface : cs.onSurfaceVariant,
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: active ? cs.onSurface : cs.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

  Widget sectionLabel(ColorScheme cs, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(
        text,
        style: TextStyle(
          color: cs.onSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildOptionsSection(BuildContext context, ColorScheme cs) {
    return Container(
      decoration: BoxDecoration(
        color: context.tintedSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(Icons.tune_rounded, size: 18, color: cs.primary),
            const SizedBox(width: 8),
            Text(
              'Stopwatch Options',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
        initiallyExpanded: false,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          SwitchListTile(
            value: stopwatchSpeakOn,
            onChanged: (val) => onStopwatchSpeakOnChanged(val),
            activeThumbColor: cs.onSecondary,
            activeTrackColor: cs.secondary,
            secondary: Icon(Icons.record_voice_over_rounded,
                color: cs.secondary, size: 22),
            title: Text('Speech',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: cs.onSurface)),
            subtitle: Text('Announce elapsed time',
                style:
                    TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
          ),
          if (stopwatchSpeakOn)
            ListTile(
              leading: Icon(Icons.timer_outlined,
                  color: cs.primary, size: 22),
              title: Text('Speak every',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: cs.onSurface)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_delayLabel(stopwatchSpeakDelaySeconds),
                      style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded,
                      color: cs.onSurfaceVariant, size: 20),
                ],
              ),
              onTap: () => _showDelaySheet(context),
            ),
        ],
      ),
    );
  }

  Future<void> _showDelaySheet(BuildContext context) async {
    final cs = Theme.of(context).colorScheme;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: cs.surfaceContainerLow,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Speak elapsed every',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              ...stopwatchSpeakDelayOptions.map((value) {
                final selected = value == stopwatchSpeakDelaySeconds;
                return ListTile(
                  selected: selected,
                  selectedTileColor: cs.primaryContainer.withAlpha(80),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  leading: Icon(
                    selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color:
                        selected ? cs.primary : cs.onSurfaceVariant,
                  ),
                  title: Text(_delayLabel(value)),
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
