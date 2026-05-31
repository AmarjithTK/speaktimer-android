import 'dart:math' as math;

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
                    fontWeight: FontWeight.w800,
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
                      fontWeight: FontWeight.w800,
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
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
      ),
    );
  }

  Widget _timerCircle(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final timerParts = _splitTimer(timerValue);
    final minutes = timerParts.$1;
    final seconds = timerParts.$2;
    final millis = timerParts.$3;
    final totalSeconds = math.max(sliderValue * 60, 1);
    final progress = (remainingSeconds / totalSeconds).clamp(0.0, 1.0);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onFullscreenPressed,
      onDoubleTap: onFullscreenImmersivePressed,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final diameter = math.min(constraints.maxWidth * 0.86, 260.0);
          final scale = (diameter / 260.0).clamp(0.78, 1.0);
          return Center(
            child: SizedBox.square(
              dimension: diameter,
              child: CustomPaint(
                painter: _TimerRingPainter(
                  progress: progress,
                  primary: cs.primary,
                  trackColor: cs.primaryContainer.withAlpha(100),
                ),
                child: Padding(
                  padding: EdgeInsets.all(diameter * 0.16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 42 * scale,
                        height: 42 * scale,
                        decoration: BoxDecoration(
                          color: cs.primaryContainer.withAlpha(120),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.hourglass_empty_rounded,
                          color: cs.primary,
                          size: 24 * scale,
                        ),
                      ),
                      SizedBox(height: 20 * scale),
                      Text(
                        'Remaining time',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 18 * scale),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                color: cs.onSurface,
                                fontFeatures: [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                              children: [
                                TextSpan(
                                  text: minutes,
                                  style: TextStyle(
                                    fontSize: 48 * scale,
                                    height: 0.95,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                TextSpan(
                                  text: ':',
                                  style: TextStyle(
                                    fontSize: 46 * scale,
                                    height: 0.95,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                TextSpan(
                                  text: seconds,
                                  style: TextStyle(
                                    fontSize: 48 * scale,
                                    height: 0.95,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                if (millis != null)
                                  TextSpan(
                                    text: '.$millis',
                                    style: TextStyle(
                                      color: cs.onSurfaceVariant,
                                      fontSize: 20 * scale,
                                      height: 0.95,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 14 * scale),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_rounded,
                            color: cs.onSurfaceVariant,
                            size: 14 * scale,
                          ),
                          SizedBox(width: 6 * scale),
                          Flexible(
                            child: Text(
                              _endLabel(context),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontSize: 11 * scale,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
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
          child: FilledButton.icon(
            onPressed: isRunning ? stopTimer : startTimer,
            icon: Icon(primaryIcon, size: 18),
            label: Text(primaryLabel),
            style: FilledButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
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
                      fontWeight: FontWeight.w700,
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
                      fontWeight: FontWeight.w700,
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
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'min',
                  style: TextStyle(
                    color: selected ? cs.onPrimary : cs.onSurfaceVariant,
                    fontSize: 8,
                    height: 1,
                    fontWeight: FontWeight.w600,
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
            fontWeight: FontWeight.w700,
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
        fontWeight: FontWeight.w800,
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
          fontWeight: FontWeight.w800,
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
              fontWeight: FontWeight.w600,
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
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$sliderValue min',
                    style: TextStyle(
                      color: cs.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
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
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
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
                    fontWeight: FontWeight.w800,
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
                                  fontWeight: FontWeight.w800,
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
                        _timerCircle(context),
                        const SizedBox(height: 14),
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

class _TimerRingPainter extends CustomPainter {
  final double progress;
  final Color primary;
  final Color trackColor;

  const _TimerRingPainter({
    required this.progress,
    required this.primary,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = math.max(size.width * 0.028, 7.0);
    final halfStroke = strokeWidth / 2;
    final rect = Rect.fromLTWH(
      halfStroke,
      halfStroke,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    // Outer shadow ring
    final shadowPaint = Paint()
      ..color = primary.withAlpha(25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 4;
    canvas.drawArc(rect, 0, math.pi * 2, false, shadowPaint);

    // Track ring
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, trackPaint);

    if (progress > 0) {
      // Progress arc with gradient effect
      final sweep = math.pi * 2 * progress;
      final progressPaint = Paint()
        ..shader = SweepGradient(
          center: Alignment.center,
          startAngle: -math.pi / 2,
          endAngle: -math.pi / 2 + sweep,
          colors: [
            primary.withAlpha(180),
            primary,
            primary.withAlpha(230),
          ],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, -math.pi / 2, sweep, false, progressPaint);

      // Knob glow
      final angle = -math.pi / 2 + sweep;
      final radius = rect.width / 2;
      final center = rect.center;
      final knobPos = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      final glowPaint = Paint()
        ..color = primary.withAlpha(40)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(knobPos, strokeWidth * 1.5, glowPaint);

      // Knob
      canvas.drawCircle(knobPos, strokeWidth * 0.9, Paint()..color = primary);

      // Knob highlight
      final highlightPaint = Paint()
        ..color = Colors.white.withAlpha(100);
      canvas.drawCircle(
        Offset(knobPos.dx - strokeWidth * 0.2, knobPos.dy - strokeWidth * 0.2),
        strokeWidth * 0.3,
        highlightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.primary != primary;
  }
}
