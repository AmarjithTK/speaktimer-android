import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import 'section_header.dart';

/// Unified preset duration grid — single flat list, no primary/secondary split.
///
/// Uses a grid layout where every row has the same number of equally-wide
/// columns so the section always looks uniform.
class PresetGrid extends StatelessWidget {
  final List<int> presets;
  final int? selectedValue;
  final int? armedValue;
  final ValueChanged<int> onTap;
  final bool showCustomButton;
  final VoidCallback? onCustomTap;

  const PresetGrid({
    super.key,
    required this.presets,
    this.selectedValue,
    this.armedValue,
    required this.onTap,
    this.showCustomButton = true,
    this.onCustomTap,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final colors = brightness == Brightness.light
        ? AppColors.light
        : AppColors.dark;

    // Total items including optional Custom button
    final itemCount = presets.length + (showCustomButton ? 1 : 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SectionHeader(label: 'Quick presets'),
        const SizedBox(height: 4),
        LayoutBuilder(
          builder: (context, constraints) {
            // Minimum chip width to keep labels readable
            const double minChipWidth = 64;
            const double spacing = 8;

            // Max columns that fit, at least 2
            int columns = ((constraints.maxWidth + spacing) /
                    (minChipWidth + spacing))
                .floor();
            if (columns < 2) columns = 2;

            final rows = (itemCount / columns).ceil();

            return Column(
              children: List.generate(rows, (rowIndex) {
                final start = rowIndex * columns;
                final end = (start + columns).clamp(0, itemCount);
                final rowItems = <Widget>[];

                for (int i = start; i < end; i++) {
                  if (i < presets.length) {
                    rowItems.add(
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: spacing),
                          child: _PresetChip(
                            label: _formatLabel(presets[i]),
                            selected: presets[i] == selectedValue,
                            armed: presets[i] == armedValue,
                            colors: colors,
                            onTap: () => onTap(presets[i]),
                          ),
                        ),
                      ),
                    );
                  } else if (showCustomButton && i == presets.length) {
                    rowItems.add(
                      Expanded(
                        child: _PresetChip(
                          label: '',
                          selected: false,
                          armed: false,
                          colors: colors,
                          onTap: onCustomTap ?? () {},
                          iconOnly: true,
                        ),
                      ),
                    );
                  }
                }

                // Pad incomplete rows to maintain grid alignment
                while (rowItems.length < columns) {
                  rowItems.add(const Expanded(child: SizedBox()));
                }

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: rowIndex < rows - 1 ? spacing : 0,
                  ),
                  child: Row(children: rowItems),
                );
              }),
            );
          },
        ),
      ],
    );
  }

  String _formatLabel(int minutes) {
    if (minutes >= 60) return '${minutes ~/ 60}h';
    return '${minutes}m';
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool armed;
  final ColorTokens colors;
  final VoidCallback onTap;
  final IconData? icon;
  final bool iconOnly;

  const _PresetChip({
    required this.label,
    required this.selected,
    required this.armed,
    required this.colors,
    required this.onTap,
    this.icon,
    this.iconOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    Color textColor;

    if (armed) {
      bgColor = colors.accentLight;
      borderColor = colors.accent;
      textColor = colors.accent;
    } else if (selected) {
      bgColor = colors.accent;
      borderColor = colors.accent;
      textColor = Colors.white;
    } else {
      bgColor = Colors.transparent;
      borderColor = colors.chipBorder;
      textColor = colors.textPrimary;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 36,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: iconOnly
            ? Center(
                child: Icon(
                  icon ?? Icons.edit_rounded,
                  size: 16,
                  color: textColor,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 14, color: textColor),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      color: textColor,
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
