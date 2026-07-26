import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/palette.dart' show AppColorAccess;
import 'primary_button.dart';
import 'secondary_button.dart';
import 'preset_grid.dart';
import 'settings_row.dart';
import 'timer_ring.dart';

/// Redesigned Timer panel — the strongest interaction screen.
///
/// Time is the hero. Ring supports the time, doesn't dominate it.
/// Layout: Timer display → Actions → Adjustments → Presets → Options
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
  final ValueChanged<int> addTimeToRunningTimer;

  final int? armedPresetValue;
  final ValueChanged<int> onPresetTap;

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
    required this.addTimeToRunningTimer,
    this.armedPresetValue,
    required this.onPresetTap,
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

  double get _progress {
    if (sliderValue <= 0) return 0;
    return remainingSeconds / sliderValue;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final timerParts = _splitTimer(timerValue);
    final minutes = timerParts.$1;
    final seconds = timerParts.$2;
    final millis = timerParts.$3;
    final displayTime = millis != null ? '$minutes:$seconds.$millis' : '$minutes:$seconds';

    return SafeArea(
      child: ColoredBox(
        color: c.background,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            const SizedBox(height: 8),

            // ── Timer display area (subtle surface, not heavy card) ──
            GestureDetector(
              onTap: onFullscreenPressed,
              onDoubleTap: onFullscreenImmersivePressed,
              child: Center(
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 240),
                  padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: c.surfaceBorder),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Timer ring — always rendered (stable layout, no resize)
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (_progress > 0)
                              TimerRing(
                                progress: _progress,
                                primary: c.primaryAction,
                                trackColor: c.surfaceBorder,
                              ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Remaining',
                                  style: GoogleFonts.inter(
                                    color: c.textMuted,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    displayTime,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      color: c.textPrimary,
                                      fontSize: 56,
                                      height: 0.9,
                                      fontWeight: FontWeight.w800,
                                      fontFeatures: const [FontFeature.tabularFigures()],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // End time badge (when running)
                      if (isRunning && _endLabel().isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: c.accentLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.schedule_rounded, size: 14, color: c.accent),
                              const SizedBox(width: 4),
                              Text(
                                _endLabel(),
                                style: GoogleFonts.inter(
                                  color: c.accent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Chain progress
                      if (isRunning && chainModeOn) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: c.accentLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.link_rounded, size: 14, color: c.accent),
                              const SizedBox(width: 4),
                              Text(
                                'Step ${chainIndex + 1}',
                                style: GoogleFonts.inter(
                                  color: c.accent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── All actions in one row ────────────────────────
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: isRunning ? 'Pause' : 'Start',
                    icon: isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    onPressed: isRunning ? stopTimer : startTimer,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SecondaryButton(
                    label: 'Reset',
                    icon: Icons.refresh_rounded,
                    onPressed: resetTimer,
                    compact: true,
                  ),
                ),
                if (isRunning) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: SecondaryButton(
                      label: '−1m',
                      icon: Icons.remove_rounded,
                      onPressed: () => addTimeToRunningTimer(-60),
                      compact: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SecondaryButton(
                      label: '+5m',
                      icon: Icons.add_rounded,
                      onPressed: () => addTimeToRunningTimer(300),
                      compact: true,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),

            // ── Quick presets ──────────────────────────────────
            PresetGrid(
              presets: const [1, 2, 3, 5, 7, 10, 12, 15, 20, 25, 30, 35, 45, 60],
              selectedValue: sliderValue,
              armedValue: armedPresetValue,
              onTap: onPresetTap,
              showCustomButton: true,
              onCustomTap: () => _showCustomTimeDialog(context),
            ),
            const SizedBox(height: 24),

            // ── Sound / Speech toggle row (like clock panel) ───
            Row(
              children: [
                _FeatureToggle(
                  icon: Icons.record_voice_over_rounded,
                  label: 'Speech',
                  active: timerSpeakOn,
                  onTap: () => onTimerSpeakOnChanged(!timerSpeakOn),
                ),
                const SizedBox(width: 10),
                _FeatureToggle(
                  icon: Icons.music_note_rounded,
                  label: 'Noise',
                  active: timerNoiseOn,
                  onTap: () => onTimerNoiseOnChanged(!timerNoiseOn),
                ),
                const SizedBox(width: 10),
                _FeatureToggle(
                  icon: Icons.link_rounded,
                  label: 'Chain',
                  active: chainModeOn,
                  onTap: () => onChainModeChanged(!chainModeOn),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Inline timer options (no bottom sheet) ──────────
            SettingsRow(
              icon: Icons.timer_outlined,
              label: 'Announce every',
              value: '$timerAnnounceEvery min',
              onTap: () => _showAnnounceSheet(context),
            ),
            SettingsRow(
              icon: Icons.link_rounded,
              label: 'Chain mode',
              value: chainModeOn ? 'On' : 'Off',
              onTap: () => onChainModeChanged(!chainModeOn),
            ),
            if (chainModeOn)
              SettingsRow(
                icon: Icons.list_alt_rounded,
                label: 'Preset sequence',
                value: chainPresetKey,
                onTap: () => _showChainSheet(context),
                showDivider: false,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAnnounceSheet(BuildContext context) async {
    final c = context.appColors;
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Announcement interval',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              ...timerAnnounceOptions.map((mins) {
                final selected = mins == timerAnnounceEvery;
                return ListTile(
                  selected: selected,
                  selectedTileColor: c.accentLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: Icon(
                    selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: selected ? c.accent : c.textMuted,
                  ),
                  title: Text(
                    'Announce every $mins min',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: c.textPrimary,
                    ),
                  ),
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
    final c = context.appColors;
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chain preset',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              ...chainPresets.entries.map((entry) {
                final selected = entry.key == chainPresetKey;
                return ListTile(
                  selected: selected,
                  selectedTileColor: c.accentLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: Icon(
                    selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: selected ? c.accent : c.textMuted,
                  ),
                  title: Text(
                    entry.key,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: c.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    '${entry.value.join(' / ')} min',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: c.textSecondary,
                    ),
                  ),
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
    final c = context.appColors;
    final controller = TextEditingController(text: '25');
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Custom timer',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: c.textPrimary,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          style: GoogleFonts.inter(fontSize: 16, color: c.textPrimary),
          decoration: InputDecoration(
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
            child: const Text('Set'),
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

/// Feature toggle card — icon + label + active state (same as clock panel).
class _FeatureToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _FeatureToggle({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: active ? c.accentLight : c.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active ? c.accentBorder : c.surfaceBorder,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: active ? c.accent : c.textSecondary,
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: active ? c.textPrimary : c.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                active ? 'On' : 'Off',
                style: GoogleFonts.inter(
                  color: active ? c.accent : c.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
