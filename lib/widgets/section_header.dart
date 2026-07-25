import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

/// Small uppercase section label with letter-spacing.
///
/// Used above groups of controls (e.g., "QUICK PRESETS", "OPTIONS").
class SectionHeader extends StatelessWidget {
  final String label;

  const SectionHeader({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final colors = brightness == Brightness.light
        ? AppColors.light
        : AppColors.dark;

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(
          color: colors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
