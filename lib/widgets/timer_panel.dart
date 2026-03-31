import 'package:flutter/material.dart';
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
          headerTitle(context, 'Timer', icon: Icons.timer_outlined),
          const SizedBox(height: 12),
          Builder(
            builder: (_) {
              final timerParts = _splitTimer(timerValue);
              final minutes = timerParts.$1;
              final seconds = timerParts.$2;
              final millis = timerParts.$3;

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'REMAINING',
                      style: tt.labelSmall?.copyWith(
                        color: cs.onPrimaryContainer.withAlpha(180),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: double.infinity,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              color: cs.onPrimaryContainer,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                            children: [
                              TextSpan(
                                text: minutes,
                                style: const TextStyle(
                                  fontSize: 52,
                                  fontWeight: FontWeight.w300,
                                  height: 1,
                                ),
                              ),
                              TextSpan(
                                text: ':',
                                style: TextStyle(
                                  fontSize: 44,
                                  fontWeight: FontWeight.w300,
                                  color: cs.onPrimaryContainer.withAlpha(180),
                                  height: 1,
                                ),
                              ),
                              TextSpan(
                                text: seconds,
                                style: const TextStyle(
                                  fontSize: 52,
                                  fontWeight: FontWeight.w300,
                                  height: 1,
                                ),
                              ),
                              if (millis != null)
                                TextSpan(
                                  text: '.$millis',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w400,
                                    color: cs.onPrimaryContainer.withAlpha(170),
                                    height: 1,
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
                Text(
                  '$sliderValue minutes',
                  style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                Text(
                  '$voicesCount voice${voicesCount != 1 ? 's' : ''} loaded',
                  style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
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
                child: actionBtn(context, 'Start', startTimer,
                    icon: Icons.play_arrow),
              ),
              const SizedBox(width: 6),
              Expanded(
                  child:
                      actionBtn(context, 'Stop', stopTimer, icon: Icons.pause)),
              const SizedBox(width: 6),
              Expanded(
                child: actionBtn(context, 'Reset', resetTimer,
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
                    value: timerNoiseOn,
                    onChanged: onTimerNoiseOnChanged,
                    title: Text(
                      'Background noise during timer',
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                  CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    value: timerSpeakOn,
                    onChanged: onTimerSpeakOnChanged,
                    title: Text(
                      'Speak remaining time',
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                  CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    value: timerShowMilliseconds,
                    onChanged: onTimerShowMillisecondsChanged,
                    title: Text(
                      'Show milliseconds',
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (timerSpeakOn) ...[
                    const SizedBox(height: 4),
                    dropdownField<int>(
                      value: timerAnnounceEvery,
                      items: timerAnnounceOptions
                          .map(
                            (mins) => DropdownMenuItem(
                              value: mins,
                              child: Text(
                                'Speak every $mins min',
                                style: tt.bodyMedium?.copyWith(
                                  color: cs.onSurface,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: onTimerAnnounceEveryChanged,
                    ),
                  ],
                  CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    value: chainModeOn,
                    onChanged: onChainModeChanged,
                    title: Text(
                      'Enable chain timers',
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (chainModeOn) ...[
                    dropdownField<String>(
                      value: chainPresetKey,
                      items: chainPresets.keys
                          .map(
                            (key) => DropdownMenuItem(
                              value: key,
                              child: Text(
                                key,
                                style: tt.bodyMedium?.copyWith(
                                  color: cs.onSurface,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: onChainPresetChanged,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Chain step ${chainIndex + 1}/${chainPresets[chainPresetKey]?.length ?? 1}',
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
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
