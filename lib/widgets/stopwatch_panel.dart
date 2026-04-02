import 'package:flutter/material.dart';
import '../theme/palette.dart';
import 'ui_helpers.dart';

class StopwatchPanel extends StatelessWidget {
  final VoidCallback onFullscreenPressed;
  final VoidCallback onFullscreenImmersivePressed;
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
    required this.onFullscreenPressed,
    required this.onFullscreenImmersivePressed,
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
    Widget dropdownContainer(Widget child) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: palette.accent,
        border: Border.all(color: palette.primary, width: 2),
        borderRadius: BorderRadius.circular(5),
      ),
      child: child,
    );

    return panelContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headerTitle('Stopwatch', 'C', icon: Icons.av_timer_outlined),
          const SizedBox(height: 8),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onFullscreenPressed,
            onDoubleTap: onFullscreenImmersivePressed,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: palette.accent,
                border: Border.all(color: palette.primary, width: 2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                children: [
                  Text(
                    'ELAPSED',
                    style: TextStyle(
                      color: palette.primary.withAlpha(150),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    'Tap fullscreen • Double tap clean fullscreen',
                    style: TextStyle(
                      color: palette.primary.withAlpha(130),
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  SizedBox(
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        elapsedValue,
                        style: TextStyle(
                          color: palette.primary,
                          fontSize: 46,
                          fontWeight: FontWeight.w800,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: actionBtn(
                  isRunning ? 'Running' : 'Start',
                  startStopwatch,
                  icon: Icons.play_arrow,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: actionBtn('Stop', stopStopwatch, icon: Icons.pause),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: actionBtn('Reset', resetStopwatch, icon: Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ── Advanced Controls (collapsed by default) ──────────────────
          Container(
            decoration: BoxDecoration(
              color: palette.accent,
              border: Border.all(color: palette.primary, width: 2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 10),
                childrenPadding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                iconColor: palette.primary,
                collapsedIconColor: palette.primary,
                textColor: palette.primary,
                collapsedTextColor: palette.primary,
                expansionAnimationStyle: AnimationStyle(
                  curve: Curves.easeOutCubic,
                  reverseCurve: Curves.easeInCubic,
                  duration: const Duration(milliseconds: 250),
                  reverseDuration: const Duration(milliseconds: 200),
                ),
                title: Row(
                  children: [
                    Icon(Icons.tune_outlined, color: palette.primary, size: 15),
                    const SizedBox(width: 6),
                    Text(
                      'Advanced',
                      style: TextStyle(
                        color: palette.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: stopwatchSpeakOn,
                        activeColor: palette.primary,
                        checkColor: palette.accent,
                        onChanged: onStopwatchSpeakOnChanged,
                      ),
                      Expanded(
                        child: sectionLabel('Speak elapsed time automatically'),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: stopwatchShowMilliseconds,
                        activeColor: palette.primary,
                        checkColor: palette.accent,
                        onChanged: onStopwatchShowMillisecondsChanged,
                      ),
                      Expanded(child: sectionLabel('Show milliseconds')),
                    ],
                  ),
                  if (stopwatchSpeakOn)
                    dropdownContainer(
                      DropdownButton<int>(
                        value: stopwatchSpeakDelaySeconds,
                        isExpanded: true,
                        underline: const SizedBox(),
                        iconEnabledColor: palette.primary,
                        dropdownColor: palette.accent,
                        items: stopwatchSpeakDelayOptions
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e >= 60
                                      ? (e % 60 == 0 ? '${e ~/ 60} min' : '${e}s')
                                      : '$e sec',
                                  style: TextStyle(
                                    color: palette.primary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: onStopwatchSpeakDelayChanged,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
