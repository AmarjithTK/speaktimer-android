import 'package:flutter/material.dart';
import '../theme/palette.dart';
import 'ui_helpers.dart';

class StopwatchPanel extends StatelessWidget {
  final String elapsedValue;
  final bool isRunning;
  final bool stopwatchSpeakOn;
  final bool stopwatchShowMilliseconds;
  final int stopwatchSpeakDelaySeconds;
  final List<int> stopwatchSpeakDelayOptions;
  final VoidCallback startStopwatch;
  final VoidCallback stopStopwatch;
  final VoidCallback resetStopwatch;
  final VoidCallback openFullscreen;
  final VoidCallback speakElapsedNow;
  final ValueChanged<bool?> onStopwatchSpeakOnChanged;
  final ValueChanged<bool?> onStopwatchShowMillisecondsChanged;
  final ValueChanged<int?> onStopwatchSpeakDelayChanged;

  const StopwatchPanel({
    super.key,
    required this.elapsedValue,
    required this.isRunning,
    required this.stopwatchSpeakOn,
    required this.stopwatchShowMilliseconds,
    required this.stopwatchSpeakDelaySeconds,
    required this.stopwatchSpeakDelayOptions,
    required this.startStopwatch,
    required this.stopStopwatch,
    required this.resetStopwatch,
    required this.openFullscreen,
    required this.speakElapsedNow,
    required this.onStopwatchSpeakOnChanged,
    required this.onStopwatchShowMillisecondsChanged,
    required this.onStopwatchSpeakDelayChanged,
  });

  @override
  Widget build(BuildContext context) {
    return panelContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headerTitle('Stopwatch', 'C', icon: Icons.av_timer_outlined),
          const SizedBox(height: 8),
          Container(
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
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: actionBtn(
                  'Fullscreen',
                  openFullscreen,
                  icon: Icons.fullscreen,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: actionBtn(
                  'Speak Elapsed',
                  speakElapsedNow,
                  icon: Icons.record_voice_over,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Checkbox(
                value: stopwatchSpeakOn,
                activeColor: palette.primary,
                checkColor: palette.accent,
                onChanged: onStopwatchSpeakOnChanged,
              ),
              Expanded(child: sectionLabel('Speak elapsed time automatically')),
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
              Expanded(child: sectionLabel('Show milliseconds in Stopwatch')),
            ],
          ),
          sectionLabel('Speak elapsed delay'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            decoration: BoxDecoration(
              color: palette.accent,
              border: Border.all(color: palette.primary, width: 2),
              borderRadius: BorderRadius.circular(5),
            ),
            child: DropdownButton<int>(
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
              onChanged: stopwatchSpeakOn ? onStopwatchSpeakDelayChanged : null,
            ),
          ),
        ],
      ),
    );
  }
}
