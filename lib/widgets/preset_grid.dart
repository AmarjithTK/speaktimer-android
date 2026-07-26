import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import 'section_header.dart';

/// Unified preset duration grid — single flat list, no primary/secondary split.
///
/// Uses a Wrap layout for responsive behavior.
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SectionHeader(label: 'Quick presets'),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...presets.map((p) {
              return _PresetChip(
                label: _formatLabel(p),
                selected: p == selectedValue,
                armed: p == armedValue,
                colors: colors,
                onTap: () => onTap(p),
              );
            }),
            if (showCustomButton)
              _PresetChip(
                label: 'Custom',
                selected: false,
                armed: false,
                colors: colors,
                onTap: onCustomTap ?? () {},
                icon: Icons.edit_rounded,
              ),
          ],
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

  const _PresetChip({
    required this.label,
    required this.selected,
    required this.armed,
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
      borderColor = colors.chipBorder;
      textColor = colors.textPrimary;
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
