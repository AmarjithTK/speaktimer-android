import 'package:flutter/material.dart';
import '../theme/palette.dart';
import 'ui_helpers.dart';

class TimerPanel extends StatelessWidget {
  final String timerValue;
  final int sliderValue;
  final int voicesCount;
  final bool timerNoiseOn;
  final bool timerSpeakOn;
  final int timerAnnounceEvery;
  final List<int> timerAnnounceOptions;
  final bool chainModeOn;
  final String chainPresetKey;
  final Map<String, List<int>> chainPresets;
  final int chainIndex;
  final VoidCallback startTimer;
  final VoidCallback stopTimer;
  final VoidCallback resetTimer;
  final ValueChanged<double> onSliderChanged;
  final ValueChanged<bool?> onTimerNoiseOnChanged;
  final ValueChanged<bool?> onTimerSpeakOnChanged;
  final ValueChanged<int?> onTimerAnnounceEveryChanged;
  final ValueChanged<bool?> onChainModeChanged;
  final ValueChanged<String?> onChainPresetChanged;

  const TimerPanel({
    super.key,
    required this.timerValue,
    required this.sliderValue,
    required this.voicesCount,
    required this.timerNoiseOn,
    required this.timerSpeakOn,
    required this.timerAnnounceEvery,
    required this.timerAnnounceOptions,
    required this.chainModeOn,
    required this.chainPresetKey,
    required this.chainPresets,
    required this.chainIndex,
    required this.startTimer,
    required this.stopTimer,
    required this.resetTimer,
    required this.onSliderChanged,
    required this.onTimerNoiseOnChanged,
    required this.onTimerSpeakOnChanged,
    required this.onTimerAnnounceEveryChanged,
    required this.onChainModeChanged,
    required this.onChainPresetChanged,
  });

  (String, String) _splitTimer(String value) {
    final parts = value.split(':');
    if (parts.length == 2) {
      return (parts[0], parts[1]);
    }
    return ('00', '00');
  }

  @override
  Widget build(BuildContext context) {
    return panelContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headerTitle("⏱ Timer", "B"),
          const SizedBox(height: 8),
          Builder(
            builder: (_) {
              final timerParts = _splitTimer(timerValue);
              final minutes = timerParts.$1;
              final seconds = timerParts.$2;

              return Container(
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
                              fontFeatures: const [FontFeature.tabularFigures()],
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
                Text("$voicesCount voice${voicesCount != 1 ? 's' : ''} loaded", style: TextStyle(fontSize: 10, color: palette.primary.withAlpha(140))),
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
              Expanded(child: actionBtn("▶ Start", startTimer)),
              const SizedBox(width: 4),
              Expanded(child: actionBtn("⏸ Stop", stopTimer)),
              const SizedBox(width: 4),
              Expanded(child: actionBtn("↺ Reset", resetTimer)),
            ],
          ),
          Row(
            children: [
              Checkbox(
                value: timerNoiseOn,
                activeColor: palette.primary,
                checkColor: palette.accent,
                onChanged: onTimerNoiseOnChanged,
              ),
              Expanded(child: sectionLabel("Play background noise during timer")),
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
              Expanded(child: sectionLabel("Speak remaining — every")),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            decoration: BoxDecoration(
              color: palette.accent,
              border: Border.all(color: palette.primary, width: 2),
              borderRadius: BorderRadius.circular(5),
            ),
            child: DropdownButton<int>(
              value: timerAnnounceEvery,
              isExpanded: true,
              underline: const SizedBox(),
              iconEnabledColor: palette.primary,
              dropdownColor: palette.accent,
              items: timerAnnounceOptions.map((e) => DropdownMenuItem(
                value: e,
                child: Text("$e min", style: TextStyle(color: palette.primary, fontWeight: FontWeight.w500, fontSize: 12)),
              )).toList(),
              onChanged: timerSpeakOn ? onTimerAnnounceEveryChanged : null,
            ),
          ),
          const SizedBox(height: 8),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            decoration: BoxDecoration(
              color: palette.accent,
              border: Border.all(color: palette.primary, width: 2),
              borderRadius: BorderRadius.circular(5),
            ),
            child: DropdownButton<String>(
              value: chainPresetKey,
              isExpanded: true,
              underline: const SizedBox(),
              iconEnabledColor: palette.primary,
              dropdownColor: palette.accent,
              items: chainPresets.keys.map((key) => DropdownMenuItem(
                value: key,
                child: Text(
                  key,
                  style: TextStyle(color: palette.primary, fontWeight: FontWeight.w500, fontSize: 12),
                ),
              )).toList(),
              onChanged: chainModeOn ? onChainPresetChanged : null,
            ),
          ),
          if (chainModeOn)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Chain step ${chainIndex + 1}/${chainPresets[chainPresetKey]?.length ?? 1}',
                style: TextStyle(color: palette.primary.withAlpha(170), fontSize: 11),
              ),
            ),
        ],
      )
    );
  }
}
