import 'package:flutter/material.dart';

const _surface = Color(0xFFFEFBFF);
const _onSurface = Color(0xFF1C1B1F);
const _onSurfaceVariant = Color(0xFF49454F);
const _outline = Color(0xFFE6E0EA);
const _primary = Color(0xFF3F55F6);
const _softBlue = Color(0xFFEFF2FF);

class StopwatchPanel extends StatelessWidget {
  final VoidCallback onFullscreenPressed;
  final VoidCallback onFullscreenImmersivePressed;
  final String elapsedValue;
  final bool isRunning;
  final VoidCallback startStopwatch;
  final VoidCallback stopStopwatch;
  final VoidCallback resetStopwatch;
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
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: _surface,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Speak elapsed every',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: _onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              ...stopwatchSpeakDelayOptions.map((value) {
                final selected = value == stopwatchSpeakDelaySeconds;
                return ListTile(
                  selected: selected,
                  selectedTileColor: _softBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  leading: Icon(
                    selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: selected ? _primary : _onSurfaceVariant,
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
    required ValueChanged<bool?> onChanged,
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
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: _onSurfaceVariant, fontSize: 12),
      ),
    );
  }

  Widget _optionRow({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: _primary, size: 20),
      title: Text(
        title,
        style: const TextStyle(
          color: _onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: _onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: _onSurfaceVariant,
          ),
        ],
      ),
      onTap: onTap,
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

  Widget _elapsedCard(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onFullscreenPressed,
      onDoubleTap: onFullscreenImmersivePressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF9FF),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _outline),
        ),
        child: Column(
          children: [
            const Text(
              'ELAPSED TIME',
              style: TextStyle(
                color: _onSurfaceVariant,
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
                style: const TextStyle(
                  color: _onSurface,
                  fontSize: 42,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _TimeUnitLabel('hr'),
                SizedBox(width: 30),
                _TimeUnitLabel('min'),
                SizedBox(width: 30),
                _TimeUnitLabel('sec'),
                SizedBox(width: 30),
                _TimeUnitLabel('ms'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyLapCard() {
    return Container(
      width: double.infinity,
      height: 190,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _outline),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(child: _LapHeader('Lap')),
                Expanded(child: _LapHeader('Time')),
                Expanded(child: _LapHeader('Total')),
              ],
            ),
          ),
          const Spacer(),
          Icon(
            Icons.timer_outlined,
            color: _onSurfaceVariant.withValues(alpha: 0.8),
            size: 48,
          ),
          const SizedBox(height: 8),
          const Text(
            'No laps yet',
            style: TextStyle(
              color: _onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Start the stopwatch to track elapsed time.',
            style: TextStyle(color: _onSurfaceVariant, fontSize: 12),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _actions() {
    return Column(
      children: [
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
              backgroundColor: _primary,
              foregroundColor: Colors.white,
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
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 42,
                child: OutlinedButton.icon(
                  onPressed: stopStopwatch,
                  icon: const Icon(Icons.stop_rounded, size: 16),
                  label: const Text('Stop'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _onSurface,
                    side: const BorderSide(color: _outline),
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
                    foregroundColor: _onSurface,
                    side: const BorderSide(color: _outline),
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
        _sectionTitle('Options'),
        const SizedBox(height: 8),
        _settingsCard(
          children: [
            _switchRow(
              icon: Icons.record_voice_over_rounded,
              title: 'Speak elapsed time',
              subtitle: 'Announce elapsed time automatically',
              value: stopwatchSpeakOn,
              onChanged: onStopwatchSpeakOnChanged,
            ),
            _switchRow(
              icon: Icons.timer_rounded,
              title: 'Show milliseconds',
              subtitle: 'Use a precise stopwatch display',
              value: stopwatchShowMilliseconds,
              onChanged: onStopwatchShowMillisecondsChanged,
            ),
            if (stopwatchSpeakOn)
              _optionRow(
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 430,
                maxHeight: constraints.maxHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Stopwatch',
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
                        _topAction(
                          icon: Icons.fullscreen_rounded,
                          tooltip: 'Fullscreen',
                          onPressed: onFullscreenPressed,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _elapsedCard(context),
                    const SizedBox(height: 14),
                    _emptyLapCard(),
                    const SizedBox(height: 14),
                    _actions(),
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
  }
}

class _TimeUnitLabel extends StatelessWidget {
  final String label;

  const _TimeUnitLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: _onSurfaceVariant,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _LapHeader extends StatelessWidget {
  final String label;

  const _LapHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: _onSurfaceVariant,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
