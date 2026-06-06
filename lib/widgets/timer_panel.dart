import 'package:flutter/material.dart';
import '../theme/palette.dart' show TintedSurfaces;

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

  String _endLabel() {
    if (remainingSeconds <= 0) return '';
    final end = DateTime.now().add(Duration(seconds: remainingSeconds));
    final hour = end.hour % 12 == 0 ? 12 : end.hour % 12;
    final minute = end.minute.toString().padLeft(2, '0');
    final suffix = end.hour >= 12 ? 'PM' : 'AM';
    return 'Ends at $hour:$minute $suffix';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final timerParts = _splitTimer(timerValue);
    final minutes = timerParts.$1;
    final seconds = timerParts.$2;
    final millis = timerParts.$3;

    return SafeArea(
      child: ColoredBox(
        color: cs.surface,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            // ── Hero timer display (like clock, no ring) ────────────
            GestureDetector(
              onTap: onFullscreenPressed,
              onDoubleTap: onFullscreenImmersivePressed,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = constraints.maxWidth * 0.9;
                  return Center(
                    child: Container(
                      width: maxWidth,
                      padding: const EdgeInsets.symmetric(
                        vertical: 32,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: context.tintedSurface,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: cs.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Remaining',
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              millis != null ? '$minutes:$seconds.$millis' : '$minutes:$seconds',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: cs.onSurface,
                                fontSize: 72,
                                height: 0.85,
                                fontWeight: FontWeight.w900,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          // Ends at badge + chain progress
                          if (isRunning && _endLabel().isNotEmpty)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: cs.primaryContainer,
                                    borderRadius:
                                        BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.schedule_rounded,
                                          size: 14,
                                          color: cs.onPrimaryContainer),
                                      const SizedBox(width: 4),
                                      Text(
                                        _endLabel(),
                                        style: TextStyle(
                                          color: cs.onPrimaryContainer,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (chainModeOn)
                                  const SizedBox(width: 8),
                                if (chainModeOn)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: cs.tertiaryContainer,
                                      borderRadius:
                                          BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.link_rounded,
                                            size: 14,
                                            color: cs.onTertiaryContainer),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Step ${chainIndex + 1}',
                                          style: TextStyle(
                                            color: cs.onTertiaryContainer,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // ── Action buttons (no fullscreen icon) ─────────────────
            Row(
              children: [
                // Play / Pause
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: isRunning ? stopTimer : startTimer,
                      icon: Icon(
                        isRunning
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 20,
                      ),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(isRunning ? 'Pause' : 'Start'),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Reset
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: resetTimer,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: const Text('Reset'),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: cs.onSurface,
                        backgroundColor: cs.surfaceContainerHighest,
                        side: BorderSide(color: cs.outline, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Quick-toggle chips ────────────────────────────
            Row(
              children: [
                _quickToggle(
                  context,
                  icon: Icons.record_voice_over_rounded,
                  label: 'Speech',
                  active: timerSpeakOn,
                  activeColor: cs.secondaryContainer,
                  onToggle: () => onTimerSpeakOnChanged(!timerSpeakOn),
                ),
                const SizedBox(width: 8),
                _quickToggle(
                  context,
                  icon: Icons.music_note_rounded,
                  label: 'Noise',
                  active: timerNoiseOn,
                  activeColor: cs.tertiaryContainer,
                  onToggle: () => onTimerNoiseOnChanged(!timerNoiseOn),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Quick presets (4 per row) ───────────────────────────
            sectionLabel(cs, 'Quick presets'),
            const SizedBox(height: 8),
            _buildPresetGrid(context, cs),
            const SizedBox(height: 8),
            // Custom time
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: () => _showCustomTimeDialog(context),
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: const Text('Custom time'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: cs.onSurface,
                  backgroundColor: cs.surfaceContainerHighest,
                  side: BorderSide(color: cs.outline, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Collapsible options ──────────────────────────────────
            _buildOptionsSection(context, cs),
          ],
        ),
      ),
    );
  }

  Widget _quickToggle(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool active,
    required Color activeColor,
    required VoidCallback onToggle,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? activeColor : context.tintedSurfaceLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: active ? cs.onSurface : cs.onSurfaceVariant,
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: active ? cs.onSurface : cs.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresetGrid(BuildContext context, ColorScheme cs) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: presetValues.map((p) {
        final selected = p == sliderValue;
        final label = p >= 60 ? '${p ~/ 60}h' : '${p}m';
        return Semantics(
          button: true,
          label: '$p minutes',
          child: SizedBox(
            width: (MediaQuery.of(context).size.width - 16 * 2 - 8 * 4) / 5,
            child: Material(
              color: selected
                  ? cs.primaryContainer
                  : context.tintedSurfaceLow,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => choosePreset(p),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    style: TextStyle(
                      color: selected
                          ? cs.onPrimaryContainer
                          : cs.onSurface,
                      fontWeight: selected
                          ? FontWeight.w800
                          : FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget sectionLabel(ColorScheme cs, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(
        text,
        style: TextStyle(
          color: cs.onSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildOptionsSection(BuildContext context, ColorScheme cs) {
    return Container(
      decoration: BoxDecoration(
        color: context.tintedSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(Icons.tune_rounded, size: 18, color: cs.primary),
            const SizedBox(width: 8),
            Text(
              'Timer Options',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
        initiallyExpanded: false,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          ListTile(
            leading: Icon(Icons.timer_outlined,
                color: cs.primary, size: 22),
            title: Text('Announce every',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: cs.onSurface)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$timerAnnounceEvery min',
                    style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded,
                    color: cs.onSurfaceVariant, size: 20),
              ],
            ),
            onTap: () => _showAnnounceSheet(context),
          ),
          if (chainModeOn)
            const Divider(height: 1, indent: 16, endIndent: 16),
          if (chainModeOn)
            ListTile(
              leading: Icon(Icons.list_alt_rounded,
                  color: cs.primary, size: 22),
              title: Text('Preset sequence',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: cs.onSurface)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(chainPresetKey,
                      style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded,
                      color: cs.onSurfaceVariant, size: 20),
                ],
              ),
              onTap: () => _showChainSheet(context),
            ),
        ],
      ),
    );
  }

  Future<void> _showAnnounceSheet(BuildContext context) async {
    final cs = Theme.of(context).colorScheme;
    await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      backgroundColor: cs.surfaceContainerLow,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Announcement interval',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              ...timerAnnounceOptions.map((mins) {
                final selected = mins == timerAnnounceEvery;
                return ListTile(
                  selected: selected,
                  selectedTileColor:
                      cs.primaryContainer.withAlpha(80),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  leading: Icon(
                    selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: selected
                        ? cs.primary
                        : cs.onSurfaceVariant,
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
  }

  Future<void> _showChainSheet(BuildContext context) async {
    final cs = Theme.of(context).colorScheme;
    await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      backgroundColor: cs.surfaceContainerLow,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Chain preset',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              ...chainPresets.entries.map((entry) {
                final selected = entry.key == chainPresetKey;
                return ListTile(
                  selected: selected,
                  selectedTileColor:
                      cs.primaryContainer.withAlpha(80),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  leading: Icon(
                    selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: selected
                        ? cs.primary
                        : cs.onSurfaceVariant,
                  ),
                  title: Text(entry.key),
                  subtitle: Text(
                      '${entry.value.join(' / ')} min'),
                  onTap: () {
                    onChainPresetChanged(entry.key);
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

  Future<void> _showCustomTimeDialog(BuildContext context) async {
    final controller = TextEditingController(text: '25');
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Custom timer'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Minutes',
            hintText: 'Enter minutes (1-720)',
            suffixText: 'min',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final parsed = int.tryParse(controller.text.trim());
              if (parsed != null && parsed >= 1 && parsed <= 720) {
                Navigator.of(ctx).pop(parsed);
              }
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result != null) {
      choosePreset(result);
    }
  }
}
