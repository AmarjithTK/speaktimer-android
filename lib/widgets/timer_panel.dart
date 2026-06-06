
import 'package:flutter/material.dart';

class TimerPanel extends StatelessWidget {
  final String timerValue;
  final int sliderValue;
  final int remainingSeconds;
  final int voicesCount;
  final bool isRunning;
  final List<int> presetValues;
  final VoidCallback startTimer;
  final VoidCallback stopTimer;
  final VoidCallback resetTimer;
  final ValueChanged<double> onSliderChanged;
  final ValueChanged<int> choosePreset;

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
  final VoidCallback onFullscreenPressed;
  final VoidCallback onFullscreenImmersivePressed;
  final VoidCallback onExitApp;

  const TimerPanel({
    super.key,
    required this.timerValue,
    required this.sliderValue,
    required this.remainingSeconds,
    required this.voicesCount,
    required this.isRunning,
    required this.presetValues,
    required this.startTimer,
    required this.stopTimer,
    required this.resetTimer,
    required this.onSliderChanged,
    required this.choosePreset,
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
    required this.onFullscreenPressed,
    required this.onFullscreenImmersivePressed,
    required this.onExitApp,
  });

  (String, String, String?) _splitTimer(String value) {
    final dotParts = value.split('.');
    final base = dotParts.first;
    final millis = dotParts.length > 1 ? dotParts[1] : null;
    final parts = base.split(':');
    if (parts.length == 2) return (parts[0], parts[1], millis);
    return ('00', '00', null);
  }

  String _endLabel(BuildContext context) {
    if (remainingSeconds <= 0) return 'Tap timer for fullscreen';
    final end = DateTime.now().add(Duration(seconds: remainingSeconds));
    final hour = end.hour % 12 == 0 ? 12 : end.hour % 12;
    final minute = end.minute.toString().padLeft(2, '0');
    final suffix = end.hour >= 12 ? 'PM' : 'AM';
    return 'Timer will end at $hour:$minute $suffix';
  }

  Future<void> _showChainPresetSheet(BuildContext context) async {
    final cs = Theme.of(context).colorScheme;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: cs.surfaceContainerLow,
      builder: (sheetContext) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chain preset',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                ...chainPresets.entries.map((entry) {
                  final selected = entry.key == chainPresetKey;
                  return ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    selected: selected,
                    selectedTileColor: cs.primaryContainer.withAlpha(80),
                    leading: Icon(
                      selected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: selected ? cs.primary : cs.onSurfaceVariant,
                    ),
                    title: Text(entry.key),
                    subtitle: Text('${entry.value.join(' / ')} min'),
                    onTap: () {
                      onChainPresetChanged(entry.key);
                      Navigator.of(context).pop();
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showTimerAnnounceSheet(BuildContext context) async {
    final cs = Theme.of(context).colorScheme;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: cs.surfaceContainerLow,
      builder: (sheetContext) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.65,
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    'Announcement interval',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...timerAnnounceOptions.map((mins) {
                    final selected = mins == timerAnnounceEvery;
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      selected: selected,
                      selectedTileColor: cs.primaryContainer.withAlpha(80),
                      leading: Icon(
                        selected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: selected ? cs.primary : cs.onSurfaceVariant,
                      ),
                      title: Text('Announce every $mins min'),
                      onTap: () {
                        onTimerAnnounceEveryChanged(mins);
                        Navigator.of(context).pop();
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _settingsCard(BuildContext context, {required List<Widget> children}) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Column(children: children),
    );
  }

  Widget _switchRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final cs = Theme.of(context).colorScheme;
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeThumbColor: cs.onPrimary,
      activeTrackColor: cs.primary,
      secondary: Icon(icon, color: cs.primary, size: 20),
      title: Text(
        title,
        style: TextStyle(
          color: cs.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
      ),
    );
  }

  Widget _timeCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final timerParts = _splitTimer(timerValue);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onFullscreenPressed,
      onDoubleTap: onFullscreenImmersivePressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cs.primary, cs.primary.withAlpha(200)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Text(
              'REMAINING TIME',
              style: TextStyle(
                color: cs.onPrimary.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 14),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    timerParts.$1,
                    style: TextStyle(
                      color: cs.onPrimary,
                      fontSize: 48,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    ':',
                    style: TextStyle(
                      color: cs.onPrimary,
                      fontSize: 46,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    timerParts.$2,
                    style: TextStyle(
                      color: cs.onPrimary,
                      fontSize: 48,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  if (timerParts.$3 != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '.${timerParts.$3}',
                        style: TextStyle(
                          color: cs.onPrimary.withValues(alpha: 0.7),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              _endLabel(context),
              style: TextStyle(
                color: cs.onPrimary.withValues(alpha: 0.82),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actions(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final primaryIcon = isRunning
        ? Icons.pause_rounded
        : Icons.play_arrow_rounded;
    final primaryLabel = isRunning ? 'Pause' : 'Start';

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton.icon(
            onPressed: isRunning ? stopTimer : startTimer,
            icon: Icon(primaryIcon, size: 18),
            label: Text(primaryLabel),
            style: OutlinedButton.styleFrom(
              foregroundColor: cs.primary,
              side: BorderSide(color: cs.primary, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 42,
                child: OutlinedButton.icon(
                  onPressed: stopTimer,
                  icon: const Icon(Icons.stop_rounded, size: 16),
                  label: const Text('Stop'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.onSurface,
                    side: BorderSide(color: cs.outlineVariant),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 42,
                child: OutlinedButton.icon(
                  onPressed: resetTimer,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Reset'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.onSurface,
                    side: BorderSide(color: cs.outlineVariant),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _presetChip(BuildContext context, int preset) {
    final cs = Theme.of(context).colorScheme;
    final selected = preset == sliderValue;
    return AspectRatio(
      aspectRatio: 1.0,
      child: Material(
        color: selected ? cs.primary : cs.surface,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => choosePreset(preset),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: selected ? null : Border.all(color: cs.outlineVariant, width: 0.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$preset',
                  style: TextStyle(
                    color: selected ? cs.onPrimary : cs.onSurface,
                    fontSize: 12,
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'min',
                  style: TextStyle(
                    color: selected ? cs.onPrimary : cs.onSurfaceVariant,
                    fontSize: 8,
                    height: 1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _quickPresets(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick presets',
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        GridView.count(
          crossAxisCount: 5,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          childAspectRatio: 1.0,
          children: presetValues.map((p) => _presetChip(context, p)).toList(),
        ),
      ],
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      title,
      style: TextStyle(
        color: cs.onSurface,
        fontSize: 13,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _optionRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback? onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      enabled: onTap != null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(icon, color: cs.primary, size: 20),
      title: Text(
        title,
        style: TextStyle(
          color: cs.onSurface,
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: onTap == null
                  ? cs.onSurfaceVariant.withValues(alpha: 0.55)
                  : cs.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: onTap == null
                ? cs.onSurfaceVariant.withValues(alpha: 0.55)
                : cs.onSurfaceVariant,
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _durationSection(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final durationChips = [1, 3, 5, 10, 15, 25, 30, 45, 60, 90, 120];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(context, 'Duration'),
        const SizedBox(height: 8),
        _settingsCard(
          context,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Row(
                children: [
                  Icon(Icons.timer_outlined, color: cs.primary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Custom duration',
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$sliderValue min',
                    style: TextStyle(
                      color: cs.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            // Chip row for quick duration selection
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: durationChips.map((mins) {
                  final selected = mins == sliderValue;
                  return ChoiceChip(
                    label: Text('$mins'),
                    selected: selected,
                    onSelected: (_) => onSliderChanged(mins.toDouble()),
                    selectedColor: cs.primaryContainer,
                    labelStyle: TextStyle(
                      color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                      fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide(
                      color: selected ? cs.primary : cs.outlineVariant,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            // Removed the old Slider, keeping voice count
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Text(
                '$voicesCount voice${voicesCount == 1 ? '' : 's'} loaded',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _advancedOptions(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final stepCount = chainPresets[chainPresetKey]?.length ?? 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(context, 'Advanced'),
        const SizedBox(height: 8),
        _settingsCard(
          context,
          children: [
            _switchRow(
              context,
              icon: Icons.graphic_eq_rounded,
              title: 'Background noise',
              subtitle: 'Play ambient sound during timer',
              value: timerNoiseOn,
              onChanged: (value) => onTimerNoiseOnChanged(value),
            ),
            _switchRow(
              context,
              icon: Icons.record_voice_over_rounded,
              title: 'Speak remaining time',
              subtitle: 'Announce progress while focusing',
              value: timerSpeakOn,
              onChanged: (value) => onTimerSpeakOnChanged(value),
            ),
            _switchRow(
              context,
              icon: Icons.timer_rounded,
              title: 'Show milliseconds',
              subtitle: 'Use a precise timer display',
              value: timerShowMilliseconds,
              onChanged: (value) => onTimerShowMillisecondsChanged(value),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _settingsCard(
          context,
          children: [
            _optionRow(
              context,
              icon: Icons.schedule_rounded,
              title: 'Announcement interval',
              value: '$timerAnnounceEvery min',
              // Always allow opening regardless of timerSpeakOn state
              onTap: () => _showTimerAnnounceSheet(context),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _settingsCard(
          context,
          children: [
            _switchRow(
              context,
              icon: Icons.repeat_rounded,
              title: 'Chain timers',
              subtitle: chainModeOn
                  ? '$chainPresetKey - step ${chainIndex + 1}/$stepCount'
                  : 'Run focus and break sequences',
              value: chainModeOn,
              onChanged: (value) => onChainModeChanged(value),
            ),
            if (chainModeOn)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: Icon(
                  Icons.low_priority_rounded,
                  color: cs.primary,
                  size: 20,
                ),
                title: Text(
                  'Chain preset',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                subtitle: Text(
                  chainPresetKey,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showChainPresetSheet(context),
              ),
          ],
        ),
      ],
    );
  }

  Widget _topAction(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    final cs = Theme.of(context).colorScheme;
    return IconButton(
      visualDensity: VisualDensity.compact,
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, color: cs.onSurface, size: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;
        return ColoredBox(
          color: cs.surface,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isLandscape ? double.infinity : 430,
                    maxHeight: constraints.maxHeight,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Timer',
                                style: TextStyle(
                                  color: cs.onSurface,
                                  fontSize: 18,
                                  height: 1,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            _topAction(
                              context,
                              icon: Icons.power_settings_new_rounded,
                              tooltip: 'Shutdown app',
                              onPressed: onExitApp,
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              tooltip: 'Fullscreen',
                              onPressed: onFullscreenPressed,
                              icon: Icon(
                                Icons.fullscreen_rounded,
                                color: cs.onSurface,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _timeCard(context),
                        const SizedBox(height: 22),
                        _actions(context),
                        const SizedBox(height: 16),
                        _quickPresets(context),
                        const SizedBox(height: 14),
                        _durationSection(context),
                        const SizedBox(height: 14),
                        _advancedOptions(context),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

