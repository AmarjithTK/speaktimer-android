import 'package:flutter/material.dart';
import '../theme/palette.dart';
import 'ui_helpers.dart';

class ClockPanel extends StatelessWidget {
  final bool clockOn;
  final String currentTimeDisplay;
  final int clockIntervalMins;
  final bool clockShowMilliseconds;
  final bool motivationOn;
  final String motivationCategory;
  final int motivationDelaySeconds;
  final List<int> clockIntervalOptions;
  final List<String> motivationCategories;
  final List<int> motivationDelayOptions;
  final VoidCallback toggleClock;
  final ValueChanged<int?> onIntervalChanged;
  final ValueChanged<bool?> onClockShowMillisecondsChanged;
  final ValueChanged<bool?> onMotivationChanged;
  final ValueChanged<String?> onMotivationCategoryChanged;
  final ValueChanged<int?> onMotivationDelayChanged;

  const ClockPanel({
    super.key,
    required this.clockOn,
    required this.currentTimeDisplay,
    required this.clockIntervalMins,
    required this.clockShowMilliseconds,
    required this.motivationOn,
    required this.motivationCategory,
    required this.motivationDelaySeconds,
    required this.clockIntervalOptions,
    required this.motivationCategories,
    required this.motivationDelayOptions,
    required this.toggleClock,
    required this.onIntervalChanged,
    required this.onClockShowMillisecondsChanged,
    required this.onMotivationChanged,
    required this.onMotivationCategoryChanged,
    required this.onMotivationDelayChanged,
  });

  (String, String?) _splitClockDisplay(String value) {
    if (value.contains('.')) {
      final parts = value.split('.');
      return (parts.first, parts.length > 1 ? parts[1] : null);
    }
    return (value, null);
  }

  @override
  Widget build(BuildContext context) {
    return panelContainer(
      active: clockOn,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headerTitle('Speaking Clock', 'A', icon: Icons.schedule),
          const SizedBox(height: 8),
          Builder(
            builder: (_) {
              final display = _splitClockDisplay(currentTimeDisplay);
              final mainTime = display.$1;
              final millis = display.$2;

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: palette.accent,
                  border: Border.all(color: palette.primary, width: 2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CURRENT TIME',
                      style: TextStyle(
                        color: palette.primary.withAlpha(150),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    SizedBox(
                      width: double.infinity,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              mainTime,
                              style: TextStyle(
                                fontSize: 44,
                                height: 1,
                                fontWeight: FontWeight.w800,
                                color: palette.primary,
                                letterSpacing: 1.4,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                            if (millis != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  '.$millis',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: palette.primary.withAlpha(170),
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          sectionLabel("Announce every"),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            decoration: BoxDecoration(
              color: palette.accent,
              border: Border.all(color: palette.primary, width: 2),
              borderRadius: BorderRadius.circular(5),
            ),
            child: DropdownButton<int>(
              value: clockIntervalMins,
              isExpanded: true,
              underline: const SizedBox(),
              iconEnabledColor: palette.primary,
              dropdownColor: palette.accent,
              items: clockIntervalOptions
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        "$e min",
                        style: TextStyle(
                          color: palette.primary,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onIntervalChanged,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Checkbox(
                value: clockShowMilliseconds,
                activeColor: palette.primary,
                checkColor: palette.accent,
                onChanged: onClockShowMillisecondsChanged,
              ),
              Expanded(
                child: sectionLabel('Show milliseconds in Speaking Clock'),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Checkbox(
                value: motivationOn,
                activeColor: palette.primary,
                checkColor: palette.accent,
                onChanged: onMotivationChanged,
              ),
              Expanded(
                child: sectionLabel("Speak motivational quote after time"),
              ),
            ],
          ),
          sectionLabel("Motivation category"),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            decoration: BoxDecoration(
              color: palette.accent,
              border: Border.all(color: palette.primary, width: 2),
              borderRadius: BorderRadius.circular(5),
            ),
            child: DropdownButton<String>(
              value: motivationCategory,
              isExpanded: true,
              underline: const SizedBox(),
              iconEnabledColor: palette.primary,
              dropdownColor: palette.accent,
              items: motivationCategories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(
                        category,
                        style: TextStyle(
                          color: palette.primary,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: motivationOn ? onMotivationCategoryChanged : null,
            ),
          ),
          const SizedBox(height: 8),
          sectionLabel("Motivation delay after time"),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            decoration: BoxDecoration(
              color: palette.accent,
              border: Border.all(color: palette.primary, width: 2),
              borderRadius: BorderRadius.circular(5),
            ),
            child: DropdownButton<int>(
              value: motivationDelaySeconds,
              isExpanded: true,
              underline: const SizedBox(),
              iconEnabledColor: palette.primary,
              dropdownColor: palette.accent,
              items: motivationDelayOptions
                  .map(
                    (seconds) => DropdownMenuItem(
                      value: seconds,
                      child: Text(
                        '$seconds sec',
                        style: TextStyle(
                          color: palette.primary,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: motivationOn ? onMotivationDelayChanged : null,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: toggleClock,
            icon: Icon(
              clockOn ? Icons.notifications_active : Icons.notifications_off,
              size: 18,
            ),
            label: Text(
              clockOn ? 'Clock On' : 'Clock Off',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: clockOn ? palette.primary : palette.accent,
              foregroundColor: clockOn ? palette.accent : palette.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              side: BorderSide(color: palette.primary, width: 2),
            ),
          ),
        ],
      ),
    );
  }
}
