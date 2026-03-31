import 'package:flutter/material.dart';
import 'ui_helpers.dart';

class StopwatchPanel extends StatelessWidget {
  final String elapsedValue;
  final bool isRunning;
  final VoidCallback startStopwatch;
  final VoidCallback stopStopwatch;
  final VoidCallback resetStopwatch;

  // Advanced controls
  final bool stopwatchSpeakOn;
  final bool stopwatchShowMilliseconds;
  final int stopwatchSpeakDelaySeconds;
  final List<int> stopwatchSpeakDelayOptions;
  final ValueChanged<bool?> onStopwatchSpeakOnChanged;
  final ValueChanged<bool?> onStopwatchShowMillisecondsChanged;
  final ValueChanged<int?> onStopwatchSpeakDelayChanged;

  const StopwatchPanel({
    super.key,
    required this.elapsedValue,
    required this.isRunning,
    required this.startStopwatch,
    required this.stopStopwatch,
    required this.resetStopwatch,
    required this.stopwatchSpeakOn,
    required this.stopwatchShowMilliseconds,
    required this.stopwatchSpeakDelaySeconds,
    required this.stopwatchSpeakDelayOptions,
    required this.onStopwatchSpeakOnChanged,
    required this.onStopwatchShowMillisecondsChanged,
    required this.onStopwatchSpeakDelayChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    Widget dropdownField<T>({
      required T value,
      required List<DropdownMenuItem<T>> items,
      required ValueChanged<T?> onChanged,
    }) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          underline: const SizedBox(),
          iconEnabledColor: cs.onSurfaceVariant,
          dropdownColor: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          items: items,
          onChanged: onChanged,
        ),
      );
    }

    return panelContainer(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headerTitle(context, 'Stopwatch', icon: Icons.av_timer_outlined),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: cs.tertiaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'ELAPSED',
                  style: tt.labelSmall?.copyWith(
                    color: cs.onTertiaryContainer.withAlpha(180),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      elapsedValue,
                      style: TextStyle(
                        color: cs.onTertiaryContainer,
                        fontSize: 52,
                        fontWeight: FontWeight.w300,
                        height: 1,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: actionBtn(
                  context,
                  isRunning ? 'Running' : 'Start',
                  startStopwatch,
                  icon: Icons.play_arrow,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: actionBtn(context, 'Stop', stopStopwatch,
                    icon: Icons.pause),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: actionBtn(context, 'Reset', resetStopwatch,
                    icon: Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Advanced Controls ──────────────────────────────────────────
          Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            color: cs.surfaceContainerHigh,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                iconColor: cs.onSurfaceVariant,
                collapsedIconColor: cs.onSurfaceVariant,
                expansionAnimationStyle: AnimationStyle(
                  curve: Curves.easeOutCubic,
                  reverseCurve: Curves.easeInCubic,
                  duration: const Duration(milliseconds: 250),
                  reverseDuration: const Duration(milliseconds: 200),
                ),
                title: Row(
                  children: [
                    Icon(
                      Icons.tune_outlined,
                      color: cs.onSurfaceVariant,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Advanced',
                      style: tt.titleSmall?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                children: [
                  CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    value: stopwatchSpeakOn,
                    onChanged: onStopwatchSpeakOnChanged,
                    title: Text(
                      'Speak elapsed time automatically',
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                  CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    value: stopwatchShowMilliseconds,
                    onChanged: onStopwatchShowMillisecondsChanged,
                    title: Text(
                      'Show milliseconds',
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (stopwatchSpeakOn) ...[
                    const SizedBox(height: 4),
                    dropdownField<int>(
                      value: stopwatchSpeakDelaySeconds,
                      items: stopwatchSpeakDelayOptions
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(
                                e >= 60
                                    ? (e % 60 == 0
                                        ? '${e ~/ 60} min'
                                        : '${e}s')
                                    : '$e sec',
                                style: tt.bodyMedium?.copyWith(
                                  color: cs.onSurface,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: onStopwatchSpeakDelayChanged,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
