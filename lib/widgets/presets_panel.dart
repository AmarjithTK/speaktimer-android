import 'package:flutter/material.dart';
import 'ui_helpers.dart';

class PresetsPanel extends StatelessWidget {
  final List<int> presetValues;
  final ValueChanged<int> choosePreset;

  const PresetsPanel({
    super.key,
    required this.presetValues,
    required this.choosePreset,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return panelContainer(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headerTitle(context, 'Quick Presets', icon: Icons.flash_on_outlined),
          sectionLabel(context, 'Tap to start quickly'),
          const SizedBox(height: 4),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 5,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 1.8,
            children: presetValues.map((p) {
              final isHighlighted = p == 25;
              return Material(
                color: isHighlighted
                    ? cs.secondaryContainer
                    : cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => choosePreset(p),
                  child: Center(
                    child: Text(
                      p.toString(),
                      style: tt.labelMedium?.copyWith(
                        color: isHighlighted
                            ? cs.onSecondaryContainer
                            : cs.onSurface,
                        fontWeight:
                            p >= 90 ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 6),
          Text(
            '25 = Pomodoro  ·  bold = deep work',
            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
