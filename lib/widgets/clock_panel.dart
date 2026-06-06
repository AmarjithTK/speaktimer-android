import 'package:flutter/material.dart';
import '../theme/palette.dart' show TintedSurfaces;

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

  ({String time, String? fraction, String? suffix}) _splitClockDisplay(
    String value,
  ) {
    final trimmed = value.trim();
    final suffixMatch = RegExp(r'\s(AM|PM)$').firstMatch(trimmed);
    final suffix = suffixMatch?.group(1);
    final withoutSuffix = suffix == null
        ? trimmed
        : trimmed.substring(0, suffixMatch!.start);
    final dotParts = withoutSuffix.split('.');
    return (
      time: dotParts.first,
      fraction: dotParts.length > 1 ? dotParts[1] : null,
      suffix: suffix,
    );
  }

  /// Strips AM/PM suffix and milliseconds for the main time display
  String _stripSuffix(String value) {
    final noSuffix = value.replaceAll(RegExp(r'\s(AM|PM)$'), '');
    return noSuffix.split('.').first;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final display = _splitClockDisplay(currentTimeDisplay);
    final timeOnly = _stripSuffix(currentTimeDisplay);

    return SafeArea(
      child: ColoredBox(
        color: cs.surface,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            // ── Status chips ─────────────────────────────────────
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (clockSpeakTime)
                  _statusChip(cs, Icons.record_voice_over_rounded, 'Speech',
                      cs.secondaryContainer, cs.onSecondaryContainer),
                if (clockNoiseOn)
                  _statusChip(cs, Icons.music_note_rounded, 'Noise',
                      cs.tertiaryContainer, cs.onTertiaryContainer),
                if (motivationOn)
                  _statusChip(cs, Icons.auto_awesome_rounded, 'Quotes',
                      cs.primaryContainer, cs.onPrimaryContainer),
              ],
            ),
            const SizedBox(height: 20),

            // ── Hero clock display ───────────────────────────────
            GestureDetector(
              onTap: onFullscreenPressed,
              onDoubleTap: onFullscreenImmersivePressed,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = constraints.maxWidth * 0.92;
                  return Center(
                    child: Container(
                      width: maxWidth,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 28,
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
                            timeOnly,
                            maxLines: 1,
                            softWrap: false,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                              color: cs.onSurface,
                              fontSize: 56,
                              height: 0.9,
                              fontWeight: FontWeight.w900,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          // AM/PM badge + Interval
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (display.suffix != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: cs.primaryContainer,
                                    borderRadius:
                                        BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    display.suffix!,
                                    style: TextStyle(
                                      color: cs.onPrimaryContainer,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              if (display.suffix != null)
                                const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: context.tintedSurfaceLow,
                                  borderRadius:
                                      BorderRadius.circular(16),
                                ),
                                child: Text(
                                  'Every $clockIntervalMins min',
                                  style: TextStyle(
                                    color: cs.onSurfaceVariant,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
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
            const SizedBox(height: 24),

            // ── Quick-toggle row ─────────────────────────────────
            Row(
              children: [
                _quickToggle(
                  context,
                  icon: Icons.record_voice_over_rounded,
                  label: 'Speech',
                  active: clockSpeakTime,
                  activeColor: cs.secondaryContainer,
                  onToggle: () => onClockSpeakTimeChanged(!clockSpeakTime),
                ),
                const SizedBox(width: 8),
                _quickToggle(
                  context,
                  icon: Icons.music_note_rounded,
                  label: 'Noise',
                  active: clockNoiseOn,
                  activeColor: cs.tertiaryContainer,
                  onToggle: () => onClockNoiseOnChanged(!clockNoiseOn),
                ),
                const SizedBox(width: 8),
                _quickToggle(
                  context,
                  icon: Icons.auto_awesome_rounded,
                  label: 'Quotes',
                  active: motivationOn,
                  activeColor: cs.primaryContainer,
                  onToggle: () => onMotivationChanged(!motivationOn),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Collapsible clock options ────────────────────────
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

  Widget _statusChip(
    ColorScheme cs,
    IconData icon,
    String label,
    Color bg,
    Color fg,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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
              'Clock Options',
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
            leading:
                Icon(Icons.timer_outlined, color: cs.primary, size: 22),
            title: Text('Announce interval',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: cs.onSurface)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$clockIntervalMins min',
                    style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded,
                    color: cs.onSurfaceVariant, size: 20),
              ],
            ),
            onTap: () => _showIntSheet(
              context: context,
              title: 'Announce interval',
              values: clockIntervalOptions,
              selectedValue: clockIntervalMins,
              labelBuilder: (v) => 'Every $v min',
              onSelected: onClockIntervalChanged,
            ),
          ),
          ListTile(
            leading:
                Icon(Icons.repeat_rounded, color: cs.primary, size: 22),
            title: Text('Repeat count',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: cs.onSurface)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$clockSpeakRepeatCount time${clockSpeakRepeatCount > 1 ? 's' : ''}',
                    style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded,
                    color: cs.onSurfaceVariant, size: 20),
              ],
            ),
            onTap: () => _showIntSheet(
              context: context,
              title: 'Repeat count',
              values: clockSpeakRepeatOptions,
              selectedValue: clockSpeakRepeatCount,
              labelBuilder: (v) => '$v time${v > 1 ? 's' : ''}',
              onSelected: onClockSpeakRepeatCountChanged,
            ),
          ),
          ListTile(
            leading: Icon(Icons.format_quote_rounded,
                color: cs.primary, size: 22),
            title: Text('Quote category',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: cs.onSurface)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(motivationCategory,
                    style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded,
                    color: cs.onSurfaceVariant, size: 20),
              ],
            ),
            onTap: () => _showStringSheet(
              context: context,
              title: 'Quote category',
              values: motivationCategories,
              selectedValue: motivationCategory,
              onSelected: onMotivationCategoryChanged,
            ),
          ),
          ListTile(
            leading: Icon(Icons.timer_outlined,
                color: cs.primary, size: 22),
            title: Text('Quote delay',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: cs.onSurface)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$motivationDelaySeconds sec delay',
                    style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded,
                    color: cs.onSurfaceVariant, size: 20),
              ],
            ),
            onTap: () => _showIntSheet(
              context: context,
              title: 'Quote delay',
              values: motivationDelayOptions,
              selectedValue: motivationDelaySeconds,
              labelBuilder: (v) => '$v sec delay',
              onSelected: onMotivationDelayChanged,
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          SwitchListTile(
            value: clockShowSeconds,
            onChanged: (val) => onClockShowSecondsChanged(val),
            activeThumbColor: cs.onPrimary,
            activeTrackColor: cs.primary,
            secondary: Icon(Icons.visibility_rounded,
                color: cs.primary, size: 22),
            title: Text('Show seconds',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: cs.onSurface)),
            subtitle: Text('Display seconds in clock',
                style:
                    TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
          ),
        ],
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
    final cs = Theme.of(context).colorScheme;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: cs.surfaceContainerLow,
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
                Text(title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: cs.onSurface, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                ...values.map((value) {
                  final selected = value == selectedValue;
                  return ListTile(
                    selected: selected,
                    selectedTileColor: cs.primaryContainer.withAlpha(80),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    leading: Icon(
                      selected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color:
                          selected ? cs.primary : cs.onSurfaceVariant,
                    ),
                    title: Text(labelBuilder(value)),
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
    final cs = Theme.of(context).colorScheme;
    await showModalBottomSheet<void>(
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
              Text(title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: cs.onSurface, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              ...values.map((value) {
                final selected = value == selectedValue;
                return ListTile(
                  selected: selected,
                  selectedTileColor: cs.primaryContainer.withAlpha(80),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  leading: Icon(
                    selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color:
                        selected ? cs.primary : cs.onSurfaceVariant,
                  ),
                  title: Text(value),
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
