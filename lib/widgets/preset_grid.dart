import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import 'section_header.dart';

/// Hierarchical preset duration grid.
///
/// Primary presets are prominent; secondary presets are visually muted.
/// Uses a Wrap layout for responsive behavior.
class PresetGrid extends StatelessWidget {
  final List<int> primaryPresets; // e.g. [5, 10, 15, 25, 45]
  final List<int> secondaryPresets; // e.g. [1, 2, 3, 7, 12, 20, 30, 35, 60]
  final int? selectedValue;
  final int? armedValue;
  final ValueChanged<int> onTap;
  final bool showCustomButton;
  final VoidCallback? onCustomTap;

  const PresetGrid({
    super.key,
    required this.primaryPresets,
    required this.secondaryPresets,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Primary presets
        const SectionHeader(label: 'Quick presets'),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: primaryPresets.map((p) {
            return _PresetChip(
              label: _formatLabel(p),
              selected: p == selectedValue,
              armed: p == armedValue,
              primary: true,
              colors: colors,
              onTap: () => onTap(p),
            );
          }).toList(),
        ),

        // Secondary presets
        if (secondaryPresets.isNotEmpty) ...[
          const SizedBox(height: 16),
          const SectionHeader(label: 'More durations'),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...secondaryPresets.map((p) {
                return _PresetChip(
                  label: _formatLabel(p),
                  selected: p == selectedValue,
                  armed: p == armedValue,
                  primary: false,
                  colors: colors,
                  onTap: () => onTap(p),
                );
              }),
              if (showCustomButton)
                _PresetChip(
                  label: 'Custom',
                  selected: false,
                  armed: false,
                  primary: false,
                  colors: colors,
                  onTap: onCustomTap ?? () {},
                  icon: Icons.edit_rounded,
                ),
            ],
          ),
        ],
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
  final bool primary;
  final ColorTokens colors;
  final VoidCallback onTap;
  final IconData? icon;

  const _PresetChip({
    required this.label,
    required this.selected,
    required this.armed,
    required this.primary,
    required this.colors,
    required this.onTap,
    this.icon,
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
      borderColor = primary ? colors.chipBorder : colors.surfaceBorder;
      textColor = primary ? colors.textPrimary : colors.textSecondary;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
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
