import 'package:flutter/material.dart';
import '../theme/palette.dart';
import 'ui_helpers.dart';

class StopwatchPanel extends StatelessWidget {
  final String elapsedValue;
  final bool isRunning;
  final VoidCallback startStopwatch;
  final VoidCallback stopStopwatch;
  final VoidCallback resetStopwatch;

  const StopwatchPanel({
    super.key,
    required this.elapsedValue,
    required this.isRunning,
    required this.startStopwatch,
    required this.stopStopwatch,
    required this.resetStopwatch,
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
        ],
      ),
    );
  }
}
