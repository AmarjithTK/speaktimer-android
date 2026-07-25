import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/palette.dart' show AppColorAccess;
import 'display_text.dart';
import 'settings_row.dart';

/// Redesigned Clock panel — premium minimalist clock experience.
///
/// Layout: Hero time display → Announce row → Sound/Noise/Quotes toggles → Options
class ClockPanel extends StatelessWidget {
  final VoidCallback onFullscreenPressed;
  final VoidCallback onFullscreenImmersivePressed;
  final String currentTimeDisplay;
  final VoidCallback onExitApp;

  final int clockIntervalMins;
  final bool clockShowMilliseconds;
  final bool clockShowSeconds;
  final bool clockSpeakTime;
  final int clockSpeakRepeatCount;
  final bool clockNoiseOn;
  final bool motivationOn;
  final String motivationCategory;
  final int motivationDelaySeconds;
  final List<int> clockIntervalOptions;
  final List<int> clockSpeakRepeatOptions;
  final List<String> motivationCategories;
  final List<int> motivationDelayOptions;
  final ValueChanged<int?> onClockIntervalChanged;
  final ValueChanged<bool?> onClockShowMillisecondsChanged;
  final ValueChanged<bool?> onClockShowSecondsChanged;
  final ValueChanged<bool?> onClockSpeakTimeChanged;
  final ValueChanged<int?> onClockSpeakRepeatCountChanged;
  final ValueChanged<bool?> onClockNoiseOnChanged;
  final ValueChanged<bool?> onMotivationChanged;
  final ValueChanged<String?> onMotivationCategoryChanged;
  final ValueChanged<int?> onMotivationDelayChanged;

  const ClockPanel({
    super.key,
    required this.onFullscreenPressed,
    required this.onFullscreenImmersivePressed,
    required this.currentTimeDisplay,
    required this.onExitApp,
    required this.clockIntervalMins,
    required this.clockShowMilliseconds,
    required this.clockShowSeconds,
    required this.clockSpeakTime,
    required this.clockSpeakRepeatCount,
    required this.clockNoiseOn,
    required this.motivationOn,
    required this.motivationCategory,
    required this.motivationDelaySeconds,
    required this.clockIntervalOptions,
    required this.clockSpeakRepeatOptions,
    required this.motivationCategories,
    required this.motivationDelayOptions,
    required this.onClockIntervalChanged,
    required this.onClockShowMillisecondsChanged,
    required this.onClockShowSecondsChanged,
    required this.onClockSpeakTimeChanged,
    required this.onClockSpeakRepeatCountChanged,
    required this.onClockNoiseOnChanged,
    required this.onMotivationChanged,
    required this.onMotivationCategoryChanged,
    required this.onMotivationDelayChanged,
  });

  ({String time, String? suffix}) _splitClockDisplay(String value) {
    final trimmed = value.trim();
    final suffixMatch = RegExp(r'\s(AM|PM)$').firstMatch(trimmed);
    final suffix = suffixMatch?.group(1);
    final time = suffix == null
        ? trimmed
        : trimmed.substring(0, suffixMatch!.start);
    return (time: time, suffix: suffix);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final display = _splitClockDisplay(currentTimeDisplay);

    return SafeArea(
      child: ColoredBox(
        color: c.background,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            const SizedBox(height: 16),

            // ── Hero clock display ───────────────────────────────
            GestureDetector(
              onTap: onFullscreenPressed,
              onDoubleTap: onFullscreenImmersivePressed,
              child: DisplayText(
                time: display.time,
                suffix: display.suffix,
              ),
            ),
            const SizedBox(height: 32),

            // ── Announce interval row ────────────────────────────
            _AnnounceRow(
              label: 'Announce every $clockIntervalMins min',
              onTap: () => _showIntSheet(
                context: context,
                title: 'Announce interval',
                values: clockIntervalOptions,
                selectedValue: clockIntervalMins,
                labelBuilder: (v) => 'Every $v min',
                onSelected: onClockIntervalChanged,
              ),
            ),
            const SizedBox(height: 28),

            // ── Sound / Noise / Quotes toggle row ────────────────
            Row(
              children: [
                _FeatureToggle(
                  icon: Icons.volume_up_rounded,
                  label: 'Sound',
                  active: clockSpeakTime,
                  onTap: () => onClockSpeakTimeChanged(!clockSpeakTime),
                ),
                const SizedBox(width: 10),
                _FeatureToggle(
                  icon: Icons.music_note_rounded,
                  label: 'Noise',
                  active: clockNoiseOn,
                  onTap: () => onClockNoiseOnChanged(!clockNoiseOn),
                ),
                const SizedBox(width: 10),
                _FeatureToggle(
                  icon: Icons.format_quote_rounded,
                  label: 'Quotes',
                  active: motivationOn,
                  onTap: () => onMotivationChanged(!motivationOn),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── Clock options ────────────────────────────────────
            SettingsRow(
              icon: Icons.tune_rounded,
              label: 'Clock options',
              onTap: () => _showClockOptionsSheet(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showClockOptionsSheet(BuildContext context) {
    final c = context.appColors;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, scrollController) => SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  children: [
                    Text(
                      'Clock options',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: c.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Announce interval
                    SettingsRow(
                      icon: Icons.timer_outlined,
                      label: 'Announce interval',
                      value: '$clockIntervalMins min',
                      onTap: () {
                        Navigator.pop(ctx);
                        _showIntSheet(
                          context: context,
                          title: 'Announce interval',
                          values: clockIntervalOptions,
                          selectedValue: clockIntervalMins,
                          labelBuilder: (v) => 'Every $v min',
                          onSelected: onClockIntervalChanged,
                        );
                      },
                    ),

                    // Repeat count
                    SettingsRow(
                      icon: Icons.repeat_rounded,
                      label: 'Repeat count',
                      value: '$clockSpeakRepeatCount time${clockSpeakRepeatCount > 1 ? 's' : ''}',
                      onTap: () {
                        Navigator.pop(ctx);
                        _showIntSheet(
                          context: context,
                          title: 'Repeat count',
                          values: clockSpeakRepeatOptions,
                          selectedValue: clockSpeakRepeatCount,
                          labelBuilder: (v) => '$v time${v > 1 ? 's' : ''}',
                          onSelected: onClockSpeakRepeatCountChanged,
                        );
                      },
                    ),

                    // Quote category
                    SettingsRow(
                      icon: Icons.format_quote_rounded,
                      label: 'Quote category',
                      value: motivationCategory,
                      onTap: () {
                        Navigator.pop(ctx);
                        _showStringSheet(
                          context: context,
                          title: 'Quote category',
                          values: motivationCategories,
                          selectedValue: motivationCategory,
                          onSelected: onMotivationCategoryChanged,
                        );
                      },
                    ),

                    // Quote delay
                    SettingsRow(
                      icon: Icons.timer_outlined,
                      label: 'Quote delay',
                      value: '$motivationDelaySeconds sec delay',
                      onTap: () {
                        Navigator.pop(ctx);
                        _showIntSheet(
                          context: context,
                          title: 'Quote delay',
                          values: motivationDelayOptions,
                          selectedValue: motivationDelaySeconds,
                          labelBuilder: (v) => '$v sec delay',
                          onSelected: onMotivationDelayChanged,
                        );
                      },
                    ),

                    // Show seconds
                    SettingsToggleRow(
                      icon: Icons.visibility_rounded,
                      label: 'Show seconds',
                      value: clockShowSeconds,
                      onChanged: (val) => onClockShowSecondsChanged(val),
                    ),

                    // Show milliseconds
                    SettingsToggleRow(
                      icon: Icons.speed_rounded,
                      label: 'Show milliseconds',
                      value: clockShowMilliseconds,
                      onChanged: (val) => onClockShowMillisecondsChanged(val),
                      showDivider: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showIntSheet({
    required BuildContext context,
    required String title,
    required List<int> values,
    required int selectedValue,
    required String Function(int) labelBuilder,
    required ValueChanged<int?> onSelected,
  }) async {
    final c = context.appColors;
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
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
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                ...values.map((value) {
                  final selected = value == selectedValue;
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
                      labelBuilder(value),
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: c.textPrimary,
                      ),
                    ),
                    onTap: () {
                      onSelected(value);
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

  Future<void> _showStringSheet({
    required BuildContext context,
    required String title,
    required List<String> values,
    required String selectedValue,
    required ValueChanged<String?> onSelected,
  }) async {
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
                title,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              ...values.map((value) {
                final selected = value == selectedValue;
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
                    value,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: c.textPrimary,
                    ),
                  ),
                  onTap: () {
                    onSelected(value);
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
}

/// Compact row showing announce interval with chevron.
class _AnnounceRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AnnounceRow({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.surfaceBorder),
        ),
        child: Row(
          children: [
            Icon(Icons.volume_up_rounded, size: 18, color: c.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: c.textPrimary,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: c.textMuted),
          ],
        ),
      ),
    );
  }
}

/// Feature toggle card — icon + label + active state.
///
/// Three of these sit in a row: Sound, Noise, Quotes.
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
