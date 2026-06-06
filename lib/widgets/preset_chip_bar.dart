import 'package:flutter/material.dart';

/// A horizontal scrollable row of preset timer chips.
class PresetChipBar extends StatelessWidget {
  final List<int> presetValues;
  final int selectedValue;
  final ValueChanged<int> onSelected;

  const PresetChipBar({
    super.key,
    required this.presetValues,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: presetValues.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final value = presetValues[index];
          final selected = value == selectedValue;
          return Semantics(
            button: true,
            label: '$value minutes',
            child: Material(
              color: selected
                  ? cs.primaryContainer
                  : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: () => onSelected(value),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$value',
                    style: TextStyle(
                      color: selected
                          ? cs.onPrimaryContainer
                          : cs.onSurface,
                      fontWeight:
                          selected ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
