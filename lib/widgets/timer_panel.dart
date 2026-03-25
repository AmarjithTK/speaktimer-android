import 'package:flutter/material.dart';
import '../theme/palette.dart';
import 'ui_helpers.dart';

class TimerPanel extends StatelessWidget {
  final String timerValue;
  final int sliderValue;
  final int voicesCount;
  final VoidCallback startTimer;
  final VoidCallback stopTimer;
  final VoidCallback resetTimer;
  final ValueChanged<double> onSliderChanged;

  // Advanced controls
  final bool timerNoiseOn;
  final bool timerSpeakOn;
  final bool timerShowMilliseconds;
  final int timerAnnounceEvery;
  final bool chainModeOn;
  final String chainPresetKey;
  final Map<String, List<int>> chainPresets;
  final int chainIndex;
  final List<int> timerAnnounceOptions;
  final ValueChanged<bool?> onTimerNoiseOnChanged;
  final ValueChanged<bool?> onTimerSpeakOnChanged;
  final ValueChanged<bool?> onTimerShowMillisecondsChanged;
  final ValueChanged<int?> onTimerAnnounceEveryChanged;
  final ValueChanged<bool?> onChainModeChanged;
  final ValueChanged<String?> onChainPresetChanged;

  const TimerPanel({
    super.key,
    required this.timerValue,
    required this.sliderValue,
    required this.voicesCount,
    required this.startTimer,
    required this.stopTimer,
    required this.resetTimer,
    required this.onSliderChanged,
    required this.timerNoiseOn,
    required this.timerSpeakOn,
    required this.timerShowMilliseconds,
    required this.timerAnnounceEvery,
    required this.chainModeOn,
    required this.chainPresetKey,
    required this.chainPresets,
    required this.chainIndex,
    required this.timerAnnounceOptions,
    required this.onTimerNoiseOnChanged,
    required this.onTimerSpeakOnChanged,
    required this.onTimerShowMillisecondsChanged,
    required this.onTimerAnnounceEveryChanged,
    required this.onChainModeChanged,
    required this.onChainPresetChanged,
  });

  (String, String, String?) _splitTimer(String value) {
    final dotParts = value.split('.');
    final base = dotParts.first;
    final millis = dotParts.length > 1 ? dotParts[1] : null;
    final parts = base.split(':');
    if (parts.length == 2) {
      return (parts[0], parts[1], millis);
    }
    return ('00', '00', null);
  }

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
          headerTitle("Timer", "B", icon: Icons.timer_outlined),
          const SizedBox(height: 8),
          Builder(
            builder: (_) {
              final timerParts = _splitTimer(timerValue);
              final minutes = timerParts.$1;
              final seconds = timerParts.$2;
              final millis = timerParts.$3;

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: palette.accent,
                  border: Border.all(color: palette.primary, width: 2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  children: [
                    Text(
                      'REMAINING',
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
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              color: palette.primary,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                            children: [
                              TextSpan(
                                text: minutes,
                                style: const TextStyle(
                                  fontSize: 46,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              TextSpan(
                                text: ':',
                                style: TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w700,
                                  color: palette.primary.withAlpha(180),
                                ),
                              ),
                              TextSpan(
                                text: seconds,
                                style: const TextStyle(
                                  fontSize: 46,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (millis != null)
                                TextSpan(
                                  text: '.$millis',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: palette.primary.withAlpha(170),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                sectionLabel("$sliderValue min"),
                Text(
                  "$voicesCount voice${voicesCount != 1 ? 's' : ''} loaded",
                  style: TextStyle(
                    fontSize: 10,
                    color: palette.primary.withAlpha(140),
                  ),
                ),
              ],
            ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: palette.accent,
              inactiveTrackColor: palette.accent,
              thumbColor: palette.accent,
              trackHeight: 8,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: sliderValue.toDouble(),
              min: 1,
              max: 120,
              onChanged: onSliderChanged,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: actionBtn('Start', startTimer, icon: Icons.play_arrow),
              ),
              const SizedBox(width: 4),
              Expanded(child: actionBtn('Stop', stopTimer, icon: Icons.pause)),
              const SizedBox(width: 4),
              Expanded(
                child: actionBtn('Reset', resetTimer, icon: Icons.refresh),
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
                        value: timerNoiseOn,
                        activeColor: palette.primary,
                        checkColor: palette.accent,
                        onChanged: onTimerNoiseOnChanged,
                      ),
                      Expanded(child: sectionLabel('Background noise during timer')),
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: timerSpeakOn,
                        activeColor: palette.primary,
                        checkColor: palette.accent,
                        onChanged: onTimerSpeakOnChanged,
                      ),
                      Expanded(child: sectionLabel('Speak remaining time')),
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: timerShowMilliseconds,
                        activeColor: palette.primary,
                        checkColor: palette.accent,
                        onChanged: onTimerShowMillisecondsChanged,
                      ),
                      Expanded(child: sectionLabel('Show milliseconds')),
                    ],
                  ),
                  if (timerSpeakOn) ...[
                    const SizedBox(height: 4),
                    dropdownContainer(
                      DropdownButton<int>(
                        value: timerAnnounceEvery,
                        isExpanded: true,
                        underline: const SizedBox(),
                        iconEnabledColor: palette.primary,
                        dropdownColor: palette.accent,
                        items: timerAnnounceOptions
                            .map(
                              (mins) => DropdownMenuItem(
                                value: mins,
                                child: Text(
                                  'Speak every $mins min',
                                  style: TextStyle(
                                    color: palette.primary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: onTimerAnnounceEveryChanged,
                      ),
                    ),
                  ],
                  Row(
                    children: [
                      Checkbox(
                        value: chainModeOn,
                        activeColor: palette.primary,
                        checkColor: palette.accent,
                        onChanged: onChainModeChanged,
                      ),
                      Expanded(child: sectionLabel('Enable chain timers')),
                    ],
                  ),
                  if (chainModeOn) ...[
                    dropdownContainer(
                      DropdownButton<String>(
                        value: chainPresetKey,
                        isExpanded: true,
                        underline: const SizedBox(),
                        iconEnabledColor: palette.primary,
                        dropdownColor: palette.accent,
                        items: chainPresets.keys
                            .map(
                              (key) => DropdownMenuItem(
                                value: key,
                                child: Text(
                                  key,
                                  style: TextStyle(
                                    color: palette.primary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: onChainPresetChanged,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Chain step ${chainIndex + 1}/${chainPresets[chainPresetKey]?.length ?? 1}',
                        style: TextStyle(
                          color: palette.primary.withAlpha(170),
                          fontSize: 11,
                        ),
                      ),
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
