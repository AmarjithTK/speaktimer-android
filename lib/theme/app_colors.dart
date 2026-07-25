import 'package:flutter/material.dart';

/// Hand-crafted color tokens for SolasFlow.
///
/// Provides a consistent, premium neutral palette with a refined indigo-violet
/// accent. No generic Tailwind blue — the accent derives from the app's identity.
class AppColors {
  AppColors._();

  // ── Light Mode ──────────────────────────────────────────────────────────

  static const light = ColorTokens(
    background: Color(0xFFFAFAFA),
    surface: Color(0xFFFFFFFF),
    surfaceBorder: Color(0xFFE8E8E8),
    surfaceSubtle: Color(0xFFF5F5F5),
    textPrimary: Color(0xFF111111),
    textSecondary: Color(0xFF6B6B6B),
    textMuted: Color(0xFFA0A0A0),
    accent: Color(0xFF5B5BD6),
    accentLight: Color(0xFFF0F0FF),
    accentBorder: Color(0xFFC7C7F0),
    primaryAction: Color(0xFF4F46E5),
    primaryActionOn: Color(0xFFFFFFFF),
    destructive: Color(0xFFDC2626),
    destructiveOn: Color(0xFFFFFFFF),
    divider: Color(0xFFE8E8E8),
    chipBorder: Color(0xFFDCDCDC),
    navBackground: Color(0xFFFFFFFF),
    navBorder: Color(0xFFEBEBEB),
    navActive: Color(0xFF5B5BD6),
    navInactive: Color(0xFF9A9A9A),
    toggleTrackOff: Color(0xFFE0E0E0),
    toggleThumbOff: Color(0xFFFFFFFF),
    toggleTrackOn: Color(0xFF5B5BD6),
    toggleThumbOn: Color(0xFFFFFFFF),
    sheetDragHandle: Color(0xFFD4D4D4),
  );

  // ── Dark Mode ───────────────────────────────────────────────────────────

  static const dark = ColorTokens(
    background: Color(0xFF0A0A0A),
    surface: Color(0xFF141414),
    surfaceBorder: Color(0xFF262626),
    surfaceSubtle: Color(0xFF1A1A1A),
    textPrimary: Color(0xFFF0F0F0),
    textSecondary: Color(0xFF9A9A9A),
    textMuted: Color(0xFF555555),
    accent: Color(0xFF7C7CEF),
    accentLight: Color(0xFF1A1A2E),
    accentBorder: Color(0xFF2A2A4A),
    primaryAction: Color(0xFF6366F1),
    primaryActionOn: Color(0xFFFFFFFF),
    destructive: Color(0xFFEF4444),
    destructiveOn: Color(0xFFFFFFFF),
    divider: Color(0xFF262626),
    chipBorder: Color(0xFF333333),
    navBackground: Color(0xFF141414),
    navBorder: Color(0xFF222222),
    navActive: Color(0xFF7C7CEF),
    navInactive: Color(0xFF666666),
    toggleTrackOff: Color(0xFF333333),
    toggleThumbOff: Color(0xFF999999),
    toggleTrackOn: Color(0xFF7C7CEF),
    toggleThumbOn: Color(0xFFFFFFFF),
    sheetDragHandle: Color(0xFF444444),
  );
}

/// Color token container holding all color values for a theme mode.
class ColorTokens {
  const ColorTokens({
    required this.background,
    required this.surface,
    required this.surfaceBorder,
    required this.surfaceSubtle,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.accentLight,
    required this.accentBorder,
    required this.primaryAction,
    required this.primaryActionOn,
    required this.destructive,
    required this.destructiveOn,
    required this.divider,
    required this.chipBorder,
    required this.navBackground,
    required this.navBorder,
    required this.navActive,
    required this.navInactive,
    required this.toggleTrackOff,
    required this.toggleThumbOff,
    required this.toggleTrackOn,
    required this.toggleThumbOn,
    required this.sheetDragHandle,
  });

  final Color background;
  final Color surface;
  final Color surfaceBorder;
  final Color surfaceSubtle;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color accent;
  final Color accentLight;
  final Color accentBorder;
  final Color primaryAction;
  final Color primaryActionOn;
  final Color destructive;
  final Color destructiveOn;
  final Color divider;
  final Color chipBorder;
  final Color navBackground;
  final Color navBorder;
  final Color navActive;
  final Color navInactive;
  final Color toggleTrackOff;
  final Color toggleThumbOff;
  final Color toggleTrackOn;
  final Color toggleThumbOn;
  final Color sheetDragHandle;
}
