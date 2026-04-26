import 'dart:math' as math;

import 'package:flutter/material.dart';

const _surface = Color(0xFFFEFBFF);
const _onSurface = Color(0xFF1C1B1F);
const _onSurfaceVariant = Color(0xFF49454F);
const _outline = Color(0xFFE6E0EA);
const _primary = Color(0xFF3F55F6);
const _primarySoft = Color(0xFFE7E9FF);

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
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: _surface,
      builder: (context) {
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
                    color: _onSurface,
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
                    selectedTileColor: _primarySoft,
                    leading: Icon(
                      selected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: selected ? _primary : _onSurfaceVariant,
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

  Widget _settingsCard({required List<Widget> children}) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _outline),
      ),
      child: Column(children: children),
    );
  }

  Widget _switchRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeThumbColor: Colors.white,
      activeTrackColor: _primary,
      secondary: Icon(icon, color: _primary, size: 20),
      title: Text(
        title,
        style: const TextStyle(
          color: _onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: _onSurfaceVariant, fontSize: 12),
      ),
    );
  }

  Widget _timerCircle(BuildContext context) {
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
          return Center(
            child: SizedBox.square(
              dimension: diameter,
              child: CustomPaint(
                painter: _TimerRingPainter(progress: progress),
                child: Padding(
                  padding: EdgeInsets.all(diameter * 0.16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1EFFF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.hourglass_empty_rounded,
                          color: _primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Remaining time',
                        style: TextStyle(
                          color: _onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 18),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(
                              color: _onSurface,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                            children: [
                              TextSpan(
                                text: minutes,
                                style: const TextStyle(
                                  fontSize: 48,
                                  height: 0.95,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const TextSpan(
                                text: ':',
                                style: TextStyle(
                                  fontSize: 46,
                                  height: 0.95,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              TextSpan(
                                text: seconds,
                                style: const TextStyle(
                                  fontSize: 48,
                                  height: 0.95,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (millis != null)
                                TextSpan(
                                  text: '.$millis',
                                  style: const TextStyle(
                                    color: _onSurfaceVariant,
                                    fontSize: 20,
                                    height: 0.95,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.search_rounded,
                            color: _onSurfaceVariant,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _endLabel(context),
                            style: const TextStyle(
                              color: _onSurfaceVariant,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
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

  Widget _actions() {
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
              backgroundColor: _primary,
              foregroundColor: Colors.white,
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
                    foregroundColor: _onSurface,
                    side: const BorderSide(color: _outline),
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
                    foregroundColor: _onSurface,
                    side: const BorderSide(color: _outline),
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

  Widget _presetChip(int preset) {
    final selected = preset == sliderValue;
    return SizedBox(
      width: 40,
      height: 46,
      child: Material(
        color: selected ? _primary : _surface,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => choosePreset(preset),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: selected ? null : Border.all(color: _outline),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$preset',
                  style: TextStyle(
                    color: selected ? Colors.white : _onSurface,
                    fontSize: 13,
                    height: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'min',
                  style: TextStyle(
                    color: selected ? Colors.white : _onSurfaceVariant,
                    fontSize: 10,
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

  Widget _quickPresets() {
    final visiblePresets = presetValues
        .where((value) => const {5, 10, 15, 25, 45, 90, 120}.contains(value))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick presets',
          style: TextStyle(
            color: _onSurface,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              for (final preset in visiblePresets) ...[
                _presetChip(preset),
                const SizedBox(width: 6),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: _onSurface,
        fontSize: 13,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _intervalChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: timerAnnounceOptions.map((mins) {
          return FilterChip(
            selected: mins == timerAnnounceEvery,
            label: Text('$mins min'),
            onSelected: timerSpeakOn
                ? (_) => onTimerAnnounceEveryChanged(mins)
                : null,
            selectedColor: _primarySoft,
            checkmarkColor: _primary,
            labelStyle: TextStyle(
              color: mins == timerAnnounceEvery ? _primary : _onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            side: const BorderSide(color: _outline),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _advancedOptions(BuildContext context) {
    final stepCount = chainPresets[chainPresetKey]?.length ?? 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Advanced'),
        const SizedBox(height: 8),
        _settingsCard(
          children: [
            _switchRow(
              icon: Icons.graphic_eq_rounded,
              title: 'Background noise',
              subtitle: 'Play ambient sound during timer',
              value: timerNoiseOn,
              onChanged: (value) => onTimerNoiseOnChanged(value),
            ),
            _switchRow(
              icon: Icons.record_voice_over_rounded,
              title: 'Speak remaining time',
              subtitle: 'Announce progress while focusing',
              value: timerSpeakOn,
              onChanged: (value) => onTimerSpeakOnChanged(value),
            ),
            _switchRow(
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
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Text(
                'Announcement interval',
                style: TextStyle(
                  color: _onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            _intervalChips(),
          ],
        ),
        const SizedBox(height: 10),
        _settingsCard(
          children: [
            _switchRow(
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
                leading: const Icon(
                  Icons.low_priority_rounded,
                  color: _primary,
                  size: 20,
                ),
                title: const Text(
                  'Chain preset',
                  style: TextStyle(
                    color: _onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                subtitle: Text(
                  chainPresetKey,
                  style: const TextStyle(
                    color: _onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showChainPresetSheet(context),
              ),
          ],
        ),
        const SizedBox(height: 10),
        _settingsCard(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Row(
                children: [
                  const Text(
                    'Duration',
                    style: TextStyle(
                      color: _onSurface,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$sliderValue min',
                    style: const TextStyle(
                      color: _primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Slider(
              value: sliderValue.toDouble(),
              min: 1,
              max: 120,
              divisions: 119,
              label: '$sliderValue min',
              onChanged: onSliderChanged,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Text(
                '$voicesCount voice${voicesCount == 1 ? '' : 's'} loaded',
                style: const TextStyle(color: _onSurfaceVariant, fontSize: 11),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _topAction({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, color: _onSurface, size: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _surface,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Timer',
                        style: TextStyle(
                          color: _onSurface,
                          fontSize: 18,
                          height: 1,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    _topAction(
                      icon: Icons.power_settings_new_rounded,
                      tooltip: 'Shutdown app',
                      onPressed: onExitApp,
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Fullscreen',
                      onPressed: onFullscreenPressed,
                      icon: const Icon(
                        Icons.fullscreen_rounded,
                        color: _onSurface,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _timerCircle(context),
                const SizedBox(height: 14),
                _actions(),
                const SizedBox(height: 16),
                _quickPresets(),
                const SizedBox(height: 14),
                _advancedOptions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TimerRingPainter extends CustomPainter {
  final double progress;

  const _TimerRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = math.max(size.width * 0.024, 6.0);
    final rect =
        Offset(strokeWidth / 2, strokeWidth / 2) &
        Size(size.width - strokeWidth, size.height - strokeWidth);
    final trackPaint = Paint()
      ..color = const Color(0xFFDAD7F8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final progressPaint = Paint()
      ..color = _primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, math.pi * 2, false, trackPaint);
    if (progress > 0) {
      final sweep = math.pi * 2 * progress;
      canvas.drawArc(rect, -math.pi / 2, sweep, false, progressPaint);
      final angle = -math.pi / 2 + sweep;
      final radius = rect.width / 2;
      final center = rect.center;
      final knob = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      canvas.drawCircle(knob, strokeWidth * 0.9, Paint()..color = _primary);
    }
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
