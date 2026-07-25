import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/palette.dart' show AppColorAccess;

/// Section title row with optional icon badge.
Widget sectionTitle(
  BuildContext context,
  String title, {
  String? tag,
  IconData? icon,
}) {
  final c = context.appColors;
  return Row(
    children: [
      if (icon != null) ...[
        Icon(icon, size: 18, color: c.accent),
        const SizedBox(width: 8),
      ],
      Text(
        title,
        style: GoogleFonts.inter(
          color: c.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
      if (tag != null && tag.isNotEmpty) ...[
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: c.accentLight,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            tag,
            style: GoogleFonts.inter(
              color: c.accent,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ),
      ],
    ],
  );
}
