import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

/// Clean settings row: label on the left, value + chevron on the right.
///
/// Uses bottom border separator instead of card wrapper.
/// Replaces the old optionRow, toggleRow, and ListTile-based settings.
class SettingsRow extends StatelessWidget {
  final String label;
  final String? value;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool showChevron;
  final Widget? trailing;
  final bool showDivider;

  const SettingsRow({
    super.key,
    required this.label,
    this.value,
    this.icon,
    this.onTap,
    this.showChevron = true,
    this.trailing,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final colors = brightness == Brightness.light
        ? AppColors.light
        : AppColors.dark;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: colors.textSecondary),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
                if (trailing == null && value != null) ...[
                  Text(
                    value!,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
                if (showChevron && onTap != null) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: colors.textMuted,
                  ),
                ],
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: icon != null ? 38 : 4,
            endIndent: 4,
            color: colors.divider,
          ),
      ],
    );
  }
}

/// Toggle settings row: label on the left, custom toggle on the right.
class SettingsToggleRow extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showDivider;

  const SettingsToggleRow({
    super.key,
    required this.label,
    this.icon,
    required this.value,
    required this.onChanged,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final colors = brightness == Brightness.light
        ? AppColors.light
        : AppColors.dark;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: colors.textSecondary),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: icon != null ? 38 : 4,
            endIndent: 4,
            color: colors.divider,
          ),
      ],
    );
  }
}
