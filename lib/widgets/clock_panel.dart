import 'package:flutter/material.dart';
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    Widget dropdownField<T>({
      required T value,
      required List<DropdownMenuItem<T>> items,
      required ValueChanged<T?> onChanged,
    }) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          underline: const SizedBox(),
          iconEnabledColor: cs.onSurfaceVariant,
          dropdownColor: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          items: items,
          onChanged: onChanged,
        ),
      );
    }

    return panelContainer(
      context,
      active: clockOn,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headerTitle(context, 'Speaking Clock', icon: Icons.schedule),
          const SizedBox(height: 12),
          Builder(
            builder: (_) {
              final display = _splitClockDisplay(currentTimeDisplay);
              final mainTime = display.$1;
              final millis = display.$2;

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: cs.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CURRENT TIME',
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
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
                              style: tt.displayMedium?.copyWith(
                                color: cs.onSurface,
                                fontWeight: FontWeight.w300,
                                height: 1,
                                letterSpacing: 1.2,
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
                                  style: tt.bodyMedium?.copyWith(
                                    color: cs.onSurfaceVariant,
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
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: clockOn
                ? FilledButton.icon(
                    onPressed: toggleClock,
                    icon: const Icon(Icons.notifications_active, size: 18),
                    label: const Text('Clock On'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  )
                : FilledTonalButton.icon(
                    onPressed: toggleClock,
                    icon: const Icon(Icons.notifications_off_outlined, size: 18),
                    label: const Text('Clock Off'),
                    style: FilledTonalButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 12),

          // ── Advanced Controls ──────────────────────────────────────────
          Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            color: cs.surfaceContainerHigh,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                iconColor: cs.onSurfaceVariant,
                collapsedIconColor: cs.onSurfaceVariant,
                expansionAnimationStyle: AnimationStyle(
                  curve: Curves.easeOutCubic,
                  reverseCurve: Curves.easeInCubic,
                  duration: const Duration(milliseconds: 250),
                  reverseDuration: const Duration(milliseconds: 200),
                ),
                title: Row(
                  children: [
                    Icon(
                      Icons.tune_outlined,
                      color: cs.onSurfaceVariant,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Advanced',
                      style: tt.titleSmall?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                children: [
                  sectionLabel(context, 'Announcement interval'),
                  dropdownField<int>(
                    value: clockIntervalMins,
                    items: clockIntervalOptions
                        .map(
                          (mins) => DropdownMenuItem(
                            value: mins,
                            child: Text(
                              'Announce every $mins min',
                              style: tt.bodyMedium?.copyWith(
                                color: cs.onSurface,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: onClockIntervalChanged,
                  ),
                  CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    value: clockShowMilliseconds,
                    onChanged: onClockShowMillisecondsChanged,
                    title: Text(
                      'Show milliseconds',
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                  CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    value: motivationOn,
                    onChanged: onMotivationChanged,
                    title: Text(
                      'Speak motivational quotes',
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (motivationOn) ...[
                    const SizedBox(height: 4),
                    dropdownField<String>(
                      value: motivationCategory,
                      items: motivationCategories
                          .map(
                            (cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(
                                cat,
                                style: tt.bodyMedium?.copyWith(
                                  color: cs.onSurface,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: onMotivationCategoryChanged,
                    ),
                    const SizedBox(height: 8),
                    dropdownField<int>(
                      value: motivationDelaySeconds,
                      items: motivationDelayOptions
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(
                                'Motivation delay: $s sec',
                                style: tt.bodyMedium?.copyWith(
                                  color: cs.onSurface,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: onMotivationDelayChanged,
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
