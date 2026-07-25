import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

/// Large time/clock display component.
///
/// The TIME itself is the hero — not a ring, not a card.
/// Uses Inter w800 with tabular figures for crisp, premium time display.
class DisplayText extends StatelessWidget {
  final String time;
  final String? suffix; // e.g. "PM"
  final String? label; // e.g. "Remaining", "ELAPSED"
  final bool isFullscreen;
  final Color? timeColor;
  final Color? suffixColor;

  const DisplayText({
    super.key,
    required this.time,
    this.suffix,
    this.label,
    this.isFullscreen = false,
    this.timeColor,
    this.suffixColor,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final colors = brightness == Brightness.light
        ? AppColors.light
        : AppColors.dark;

    final resolvedTimeColor = timeColor ?? colors.textPrimary;
    final resolvedSuffixColor = suffixColor ?? colors.accent;
    final mutedColor = colors.textMuted;

    if (isFullscreen) {
      return _buildFullscreen(colors, resolvedTimeColor, resolvedSuffixColor, mutedColor);
    }
    return _buildInline(colors, resolvedTimeColor, resolvedSuffixColor, mutedColor);
  }

  Widget _buildFullscreen(
    ColorTokens colors,
    Color timeColor,
    Color suffixColor,
    Color mutedColor,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: timeColor,
                  fontSize: 80,
                  height: 0.9,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              if (suffix != null) ...[
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    suffix!,
                    style: GoogleFonts.inter(
                      color: suffixColor,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _buildDateLabel(),
          style: GoogleFonts.inter(
            color: mutedColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildInline(
    ColorTokens colors,
    Color timeColor,
    Color suffixColor,
    Color mutedColor,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: GoogleFonts.inter(
              color: mutedColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
        ],
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                maxLines: 1,
                softWrap: false,
                textAlign: TextAlign.center,
                overflow: TextOverflow.clip,
                style: GoogleFonts.inter(
                  color: timeColor,
                  fontSize: 64,
                  height: 0.9,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              if (suffix != null) ...[
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    suffix!,
                    style: GoogleFonts.inter(
                      color: suffixColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _buildDateLabel() {
    final now = DateTime.now();
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }
}
