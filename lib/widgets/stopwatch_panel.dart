import 'package:flutter/material.dart';

class StopwatchPanel extends StatelessWidget {
  final VoidCallback onFullscreenPressed;
  final VoidCallback onFullscreenImmersivePressed;
  final String elapsedValue;
  final bool isRunning;
  final VoidCallback startStopwatch;
  final VoidCallback stopStopwatch;
  final VoidCallback resetStopwatch;
  final VoidCallback? onLap;
  final int lapCount;
  final List<String> lapTimes;
  final VoidCallback onExitApp;

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
    this.onLap,
    this.lapCount = 0,
    this.lapTimes = const [],
    required this.onExitApp,
    required this.stopwatchSpeakOn,
    required this.stopwatchShowMilliseconds,
    required this.stopwatchSpeakDelaySeconds,
    required this.stopwatchSpeakDelayOptions,
    required this.onStopwatchSpeakOnChanged,
    required this.onStopwatchShowMillisecondsChanged,
    required this.onStopwatchSpeakDelayChanged,
  });

  String _delayLabel(int seconds) {
    if (seconds < 60) return '$seconds sec';
    if (seconds % 60 == 0) return '${seconds ~/ 60} min';
    return '$seconds sec';
  }

  Future<void> _showDelaySheet(BuildContext context) async {
    final cs = Theme.of(context).colorScheme;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: cs.surfaceContainerLow,
      builder: (sheetContext) => SafeArea(
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
                  'Speak elapsed every',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                ...stopwatchSpeakDelayOptions.map((value) {
                  final selected = value == stopwatchSpeakDelaySeconds;
                  return ListTile(
                    selected: selected,
                    selectedTileColor: cs.primaryContainer.withAlpha(80),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    leading: Icon(
                      selected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: selected ? cs.primary : cs.onSurfaceVariant,
                    ),
                    title: Text(_delayLabel(value)),
                    onTap: () {
                      onStopwatchSpeakDelayChanged(value);
                      Navigator.of(context).pop();
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
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
    required ValueChanged<bool?> onChanged,
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

  Widget _optionRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: cs.primary, size: 20),
      title: Text(
        title,
        style: TextStyle(
          color: cs.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: cs.onSurfaceVariant,
          ),
        ],
      ),
      onTap: onTap,
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

  Widget _elapsedCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onFullscreenPressed,
      onDoubleTap: onFullscreenImmersivePressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          children: [
            Text(
              'ELAPSED TIME',
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 14),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                elapsedValue,
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 42,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _TimeUnitLabel(cs.onSurfaceVariant, 'hr'),
                const SizedBox(width: 30),
                _TimeUnitLabel(cs.onSurfaceVariant, 'min'),
                const SizedBox(width: 30),
                _TimeUnitLabel(cs.onSurfaceVariant, 'sec'),
                const SizedBox(width: 30),
                _TimeUnitLabel(cs.onSurfaceVariant, 'ms'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _lapCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (lapTimes.isEmpty) {
      return Container(
        width: double.infinity,
        height: 190,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Expanded(child: _LapHeader(cs.onSurfaceVariant, 'Lap')),
                  Expanded(child: _LapHeader(cs.onSurfaceVariant, 'Time')),
                ],
              ),
            ),
            const Spacer(),
            Icon(
              Icons.timer_outlined,
              color: cs.onSurfaceVariant.withValues(alpha: 0.8),
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              'No laps yet',
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap Lap while running to record.',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
            ),
            const Spacer(),
          ],
        ),
      );
    }
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 260),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Expanded(child: _LapHeader(cs.onSurfaceVariant, 'Lap')),
                Expanded(child: _LapHeader(cs.onSurfaceVariant, 'Time')),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: lapTimes.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    entry,
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actions(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        // Start/Pause button
        SizedBox(
          width: double.infinity,
          height: 46,
          child: FilledButton.icon(
            onPressed: isRunning ? stopStopwatch : startStopwatch,
            icon: Icon(
              isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 18,
            ),
            label: Text(isRunning ? 'Pause' : 'Start'),
            style: FilledButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Lap / Stop / Reset row
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 42,
                child: OutlinedButton.icon(
                  onPressed: isRunning ? onLap : null,
                  icon: const Icon(Icons.flag_rounded, size: 16),
                  label: Text(lapCount > 0 ? 'Lap $lapCount' : 'Lap'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.onSurface,
                    side: BorderSide(color: cs.outlineVariant),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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
                  onPressed: stopStopwatch,
                  icon: const Icon(Icons.stop_rounded, size: 16),
                  label: const Text('Stop'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.onSurface,
                    side: BorderSide(color: cs.outlineVariant),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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
                  onPressed: resetStopwatch,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Reset'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.onSurface,
                    side: BorderSide(color: cs.outlineVariant),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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

  Widget _optionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(context, 'Options'),
        const SizedBox(height: 8),
        _settingsCard(
          context,
          children: [
            _switchRow(
              context,
              icon: Icons.record_voice_over_rounded,
              title: 'Speak elapsed time',
              subtitle: 'Announce elapsed time automatically',
              value: stopwatchSpeakOn,
              onChanged: onStopwatchSpeakOnChanged,
            ),
            _switchRow(
              context,
              icon: Icons.timer_rounded,
              title: 'Show milliseconds',
              subtitle: 'Use a precise stopwatch display',
              value: stopwatchShowMilliseconds,
              onChanged: onStopwatchShowMillisecondsChanged,
            ),
            if (stopwatchSpeakOn)
              _optionRow(
                context,
                icon: Icons.schedule_rounded,
                title: 'Speak every',
                value: _delayLabel(stopwatchSpeakDelaySeconds),
                onTap: () => _showDelaySheet(context),
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
                                'Stopwatch',
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
                            _topAction(
                              context,
                              icon: Icons.fullscreen_rounded,
                              tooltip: 'Fullscreen',
                              onPressed: onFullscreenPressed,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _elapsedCard(context),
                        const SizedBox(height: 14),
                        _lapCard(context),
                        const SizedBox(height: 14),
                        _actions(context),
                        const SizedBox(height: 12),
                        _optionsSection(context),
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

class _TimeUnitLabel extends StatelessWidget {
  final Color color;
  final String label;

  const _TimeUnitLabel(this.color, this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: color,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _LapHeader extends StatelessWidget {
  final Color color;
  final String label;

  const _LapHeader(this.color, this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: color,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
