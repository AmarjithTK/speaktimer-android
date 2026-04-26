import 'package:flutter/material.dart';

const _surface = Color(0xFFFEFBFF);
const _onSurface = Color(0xFF1C1B1F);
const _onSurfaceVariant = Color(0xFF49454F);
const _outline = Color(0xFFE6E0EA);
const _primary = Color(0xFF3F55F6);
const _softBlue = Color(0xFFEFF2FF);

class ClockPanel extends StatelessWidget {
  final VoidCallback onFullscreenPressed;
  final VoidCallback onFullscreenImmersivePressed;
  final bool clockOn;
  final String currentTimeDisplay;
  final VoidCallback toggleClock;
  final VoidCallback onExitApp;

  final int clockIntervalMins;
  final bool clockShowMilliseconds;
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
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: _onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              ...values.map((value) {
                final selected = value == selectedValue;
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
    );
  }

  Future<void> _showStringSheet({
    required BuildContext context,
    required String title,
    required List<String> values,
    required String selectedValue,
    required ValueChanged<String?> onSelected,
  }) async {
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
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: _onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              ...values.map((value) {
                final selected = value == selectedValue;
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
    final display = _splitClockDisplay(currentTimeDisplay);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onFullscreenPressed,
      onDoubleTap: onFullscreenImmersivePressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5667FF), Color(0xFF3048E8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            const Text(
              'CURRENT TIME',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    display.time,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      height: 1,
                      fontWeight: FontWeight.w800,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  if (display.fraction != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '.${display.fraction}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  if (display.suffix != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 5),
                      child: Text(
                        display.suffix!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tap for fullscreen',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.82),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _speakingRow() {
    return _card(
      child: SwitchListTile(
        value: clockOn,
        onChanged: (_) => toggleClock(),
        activeThumbColor: Colors.white,
        activeTrackColor: _primary,
        secondary: Icon(
          clockOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
          color: _primary,
          size: 20,
        ),
        title: Text(
          clockOn ? 'Speaking is ON' : 'Speaking is OFF',
          style: const TextStyle(
            color: _onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _outline),
      ),
      child: child,
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
          fontSize: 13,
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

  Widget _switchRow({
    required IconData icon,
    required String title,
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
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _settingsList(BuildContext context) {
    return _card(
      child: Column(
        children: [
          _optionRow(
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
            icon: Icons.timer_rounded,
            title: 'Show milliseconds',
            value: clockShowMilliseconds,
            onChanged: onClockShowMillisecondsChanged,
          ),
          _switchRow(
            icon: Icons.record_voice_over_rounded,
            title: 'Announce time',
            value: clockSpeakTime,
            onChanged: onClockSpeakTimeChanged,
          ),
          _optionRow(
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
            icon: Icons.graphic_eq_rounded,
            title: 'Background sound',
            value: clockNoiseOn,
            onChanged: onClockNoiseOnChanged,
          ),
          _switchRow(
            icon: Icons.format_quote_rounded,
            title: 'Motivational quotes',
            value: motivationOn,
            onChanged: onMotivationChanged,
          ),
          if (motivationOn) ...[
            _optionRow(
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
                        'Speaking Clock',
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
                const SizedBox(height: 16),
                _timeCard(context),
                const SizedBox(height: 12),
                _speakingRow(),
                const SizedBox(height: 16),
                Text(
                  'Clock options',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: _onSurfaceVariant,
                    fontWeight: FontWeight.w800,
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
  }
}
