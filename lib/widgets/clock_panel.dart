import 'package:flutter/material.dart';

class ClockPanel extends StatelessWidget {
  final VoidCallback onFullscreenPressed;
  final VoidCallback onFullscreenImmersivePressed;
  final bool clockOn;
  final String currentTimeDisplay;
  final VoidCallback toggleClock;
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
    required this.clockOn,
    required this.currentTimeDisplay,
    required this.toggleClock,
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
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                ...values.map((value) {
                  final selected = value == selectedValue;
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
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              ...values.map((value) {
                final selected = value == selectedValue;
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

  Widget _timeCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final display = _splitClockDisplay(currentTimeDisplay);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onFullscreenPressed,
      onDoubleTap: onFullscreenImmersivePressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 42),
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
              'CURRENT TIME',
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
                    display.time,
                    style: TextStyle(
                      color: cs.onPrimary,
                      fontSize: 48,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  if (display.fraction != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '.${display.fraction}',
                        style: TextStyle(
                          color: cs.onPrimary.withValues(alpha: 0.7),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  if (display.suffix != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 5),
                      child: Text(
                        display.suffix!,
                        style: TextStyle(
                          color: cs.onPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Tap for fullscreen',
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

  Widget _speakingRow() {
    return Builder(
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return _card(
          context,
          child: SwitchListTile(
            value: clockOn,
            onChanged: (_) => toggleClock(),
            activeThumbColor: cs.onPrimary,
            activeTrackColor: cs.primary,
            secondary: Icon(
              clockOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              color: cs.primary,
              size: 20,
            ),
            title: Text(
              clockOn ? 'Speaking is ON' : 'Speaking is OFF',
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _card(BuildContext context, {required Widget child}) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: child,
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
              color: cs.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w700,
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

  Widget _switchRow(
    BuildContext context, {
    required IconData icon,
    required String title,
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
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _settingsList(BuildContext context) {
    return _card(
      context,
      child: Column(
        children: [
          _optionRow(
            context,
            icon: Icons.schedule_rounded,
            title: 'Announcement interval',
            value: '$clockIntervalMins min',
            onTap: () => _showIntSheet(
              context: context,
              title: 'Announcement interval',
              values: clockIntervalOptions,
              selectedValue: clockIntervalMins,
              labelBuilder: (mins) => 'Announce every $mins min',
              onSelected: onClockIntervalChanged,
            ),
          ),
          _switchRow(
            context,
            icon: Icons.access_time_filled_rounded,
            title: 'Show seconds',
            value: clockShowSeconds,
            onChanged: onClockShowSecondsChanged,
          ),
          _switchRow(
            context,
            icon: Icons.timer_rounded,
            title: 'Show milliseconds',
            value: clockShowMilliseconds,
            onChanged: onClockShowMillisecondsChanged,
          ),
          _switchRow(
            context,
            icon: Icons.record_voice_over_rounded,
            title: 'Announce time',
            value: clockSpeakTime,
            onChanged: onClockSpeakTimeChanged,
          ),
          _optionRow(
            context,
            icon: Icons.repeat_rounded,
            title: 'Repeat announcement',
            value:
                '$clockSpeakRepeatCount time${clockSpeakRepeatCount == 1 ? '' : 's'}',
            onTap: () => _showIntSheet(
              context: context,
              title: 'Repeat announcement',
              values: clockSpeakRepeatOptions,
              selectedValue: clockSpeakRepeatCount,
              labelBuilder: (count) => '$count time${count == 1 ? '' : 's'}',
              onSelected: onClockSpeakRepeatCountChanged,
            ),
          ),
          _switchRow(
            context,
            icon: Icons.graphic_eq_rounded,
            title: 'Background sound',
            value: clockNoiseOn,
            onChanged: onClockNoiseOnChanged,
          ),
          _switchRow(
            context,
            icon: Icons.format_quote_rounded,
            title: 'Motivational quotes',
            value: motivationOn,
            onChanged: onMotivationChanged,
          ),
          if (motivationOn) ...[
            _optionRow(
              context,
              icon: Icons.category_rounded,
              title: 'Quote category',
              value: motivationCategory,
              onTap: () => _showStringSheet(
                context: context,
                title: 'Quote category',
                values: motivationCategories,
                selectedValue: motivationCategory,
                onSelected: onMotivationCategoryChanged,
              ),
            ),
            _optionRow(
              context,
              icon: Icons.timelapse_rounded,
              title: 'Motivation delay',
              value: '$motivationDelaySeconds sec',
              onTap: () => _showIntSheet(
                context: context,
                title: 'Motivation delay',
                values: motivationDelayOptions,
                selectedValue: motivationDelaySeconds,
                labelBuilder: (seconds) => '$seconds sec',
                onSelected: onMotivationDelayChanged,
              ),
            ),
          ],
        ],
      ),
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
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isLandscape ? double.infinity : 430,
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
                            'Speaking Clock',
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
                        _topAction(
                          context,
                          icon: Icons.fullscreen_rounded,
                          tooltip: 'Fullscreen',
                          onPressed: onFullscreenPressed,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _timeCard(context),
                    const SizedBox(height: 12),
                    _speakingRow(),
                    const SizedBox(height: 16),
                    Text(
                      'Clock options',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _settingsList(context),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
