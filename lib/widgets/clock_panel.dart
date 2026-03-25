import 'package:flutter/material.dart';
import '../theme/palette.dart';
import 'ui_helpers.dart';

class ClockPanel extends StatelessWidget {
  final bool clockOn;
  final String currentTimeDisplay;
  final VoidCallback toggleClock;

  // Advanced controls
  final int clockIntervalMins;
  final bool clockShowMilliseconds;
  final bool motivationOn;
  final String motivationCategory;
  final int motivationDelaySeconds;
  final List<int> clockIntervalOptions;
  final List<String> motivationCategories;
  final List<int> motivationDelayOptions;
  final ValueChanged<int?> onClockIntervalChanged;
  final ValueChanged<bool?> onClockShowMillisecondsChanged;
  final ValueChanged<bool?> onMotivationChanged;
  final ValueChanged<String?> onMotivationCategoryChanged;
  final ValueChanged<int?> onMotivationDelayChanged;

  const ClockPanel({
    super.key,
    required this.clockOn,
    required this.currentTimeDisplay,
    required this.toggleClock,
    required this.clockIntervalMins,
    required this.clockShowMilliseconds,
    required this.motivationOn,
    required this.motivationCategory,
    required this.motivationDelaySeconds,
    required this.clockIntervalOptions,
    required this.motivationCategories,
    required this.motivationDelayOptions,
    required this.onClockIntervalChanged,
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
    Widget dropdownContainer(Widget child) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: palette.accent,
        border: Border.all(color: palette.primary, width: 2),
        borderRadius: BorderRadius.circular(5),
      ),
      child: child,
    );

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
          const SizedBox(height: 8),

          // ── Advanced Controls (collapsed by default) ────────────────────
          Container(
            decoration: BoxDecoration(
              color: palette.accent,
              border: Border.all(color: palette.primary, width: 2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 10),
                childrenPadding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                iconColor: palette.primary,
                collapsedIconColor: palette.primary,
                textColor: palette.primary,
                collapsedTextColor: palette.primary,
                expansionAnimationStyle: AnimationStyle(
                  curve: Curves.easeOutCubic,
                  reverseCurve: Curves.easeInCubic,
                  duration: const Duration(milliseconds: 250),
                  reverseDuration: const Duration(milliseconds: 200),
                ),
                title: Row(
                  children: [
                    Icon(Icons.tune_outlined, color: palette.primary, size: 15),
                    const SizedBox(width: 6),
                    Text(
                      'Advanced',
                      style: TextStyle(
                        color: palette.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                children: [
                  sectionLabel('Announcement interval'),
                  dropdownContainer(
                    DropdownButton<int>(
                      value: clockIntervalMins,
                      isExpanded: true,
                      underline: const SizedBox(),
                      iconEnabledColor: palette.primary,
                      dropdownColor: palette.accent,
                      items: clockIntervalOptions
                          .map(
                            (mins) => DropdownMenuItem(
                              value: mins,
                              child: Text(
                                'Announce every $mins min',
                                style: TextStyle(
                                  color: palette.primary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: onClockIntervalChanged,
                    ),
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: clockShowMilliseconds,
                        activeColor: palette.primary,
                        checkColor: palette.accent,
                        onChanged: onClockShowMillisecondsChanged,
                      ),
                      Expanded(child: sectionLabel('Show milliseconds')),
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: motivationOn,
                        activeColor: palette.primary,
                        checkColor: palette.accent,
                        onChanged: onMotivationChanged,
                      ),
                      Expanded(child: sectionLabel('Speak motivational quotes')),
                    ],
                  ),
                  if (motivationOn) ...[
                    const SizedBox(height: 4),
                    dropdownContainer(
                      DropdownButton<String>(
                        value: motivationCategory,
                        isExpanded: true,
                        underline: const SizedBox(),
                        iconEnabledColor: palette.primary,
                        dropdownColor: palette.accent,
                        items: motivationCategories
                            .map(
                              (cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(
                                  cat,
                                  style: TextStyle(
                                    color: palette.primary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: onMotivationCategoryChanged,
                      ),
                    ),
                    const SizedBox(height: 6),
                    dropdownContainer(
                      DropdownButton<int>(
                        value: motivationDelaySeconds,
                        isExpanded: true,
                        underline: const SizedBox(),
                        iconEnabledColor: palette.primary,
                        dropdownColor: palette.accent,
                        items: motivationDelayOptions
                            .map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text(
                                  'Motivation delay: $s sec',
                                  style: TextStyle(
                                    color: palette.primary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: onMotivationDelayChanged,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
