import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Builds the SolasFlow theme using hand-crafted colors and Inter typography.
class AppTheme {
  AppTheme._();

  // ── Light Theme ─────────────────────────────────────────────────────────

  static ThemeData light() => _build(AppColors.light, Brightness.light);

  // ── Dark Theme ──────────────────────────────────────────────────────────

  static ThemeData dark() => _build(AppColors.dark, Brightness.dark);

  // ── Builder ─────────────────────────────────────────────────────────────

  static ThemeData _build(ColorTokens c, Brightness brightness) {
    final isLight = brightness == Brightness.light;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: c.primaryAction,
      onPrimary: c.primaryActionOn,
      primaryContainer: c.accentLight,
      onPrimaryContainer: c.accent,
      secondary: c.accent,
      onSecondary: Colors.white,
      secondaryContainer: c.accentLight,
      onSecondaryContainer: c.accent,
      tertiary: c.accent,
      onTertiary: Colors.white,
      tertiaryContainer: c.accentLight,
      onTertiaryContainer: c.accent,
      error: c.destructive,
      onError: c.destructiveOn,
      errorContainer: isLight
          ? const Color(0xFFFFF1F1)
          : const Color(0xFF2D1515),
      onErrorContainer: c.destructive,
      surface: c.surface,
      onSurface: c.textPrimary,
      onSurfaceVariant: c.textSecondary,
      outline: c.divider,
      outlineVariant: c.surfaceBorder,
      shadow: Colors.black,
      scrim: Colors.black,
      surfaceContainerLowest: c.surface,
      surfaceContainerLow: c.surfaceSubtle,
      surfaceContainer: c.surfaceSubtle,
      surfaceContainerHigh: c.surfaceBorder,
      surfaceContainerHighest: isLight
          ? const Color(0xFFEEEEEE)
          : const Color(0xFF1E1E1E),
      surfaceTint: Colors.transparent,
    );

    final textTheme = GoogleFonts.interTextTheme(
      ThemeData(brightness: brightness).textTheme,
    ).apply(
      bodyColor: c.textPrimary,
      displayColor: c.textPrimary,
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: c.background,
      fontFamily: GoogleFonts.inter().fontFamily,
      fontFamilyFallback: const ['Arial', 'sans-serif'],
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: c.surface,
        foregroundColor: c.textPrimary,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: c.textPrimary,
        ),
        toolbarHeight: 52,
      ),
      dividerTheme: DividerThemeData(
        color: c.divider,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: c.surfaceBorder),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.transparent,
        disabledColor: c.surfaceSubtle,
        selectedColor: c.accentLight,
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: c.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: c.chipBorder),
        ),
        side: BorderSide(color: c.chipBorder),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return c.toggleThumbOn;
          }
          return c.toggleThumbOff;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return c.toggleTrackOn;
          }
          return c.toggleTrackOff;
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.primaryAction,
          foregroundColor: c.primaryActionOn,
          disabledBackgroundColor: isLight
              ? const Color(0xFFD4D4D4)
              : const Color(0xFF333333),
          disabledForegroundColor: c.textMuted,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(0, 48),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.textPrimary,
          disabledForegroundColor: c.textMuted,
          side: BorderSide(color: c.chipBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          minimumSize: const Size(0, 44),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.accent,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: c.surface,
        modalBarrierColor: Colors.black54,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        showDragHandle: true,
        dragHandleColor: c.sheetDragHandle,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceSubtle,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.surfaceBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.surfaceBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.accent, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          color: c.textSecondary,
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: c.textMuted,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        elevation: 0,
        backgroundColor: c.navBackground,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.inter(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? c.navActive : c.navInactive,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? c.navActive : c.navInactive,
            size: 22,
          );
        }),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        shape: const RoundedRectangleBorder(),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: c.textPrimary,
        ),
        subtitleTextStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: c.textSecondary,
        ),
        iconColor: c.textSecondary,
      ),
      expansionTileTheme: ExpansionTileThemeData(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        iconColor: c.textSecondary,
        collapsedIconColor: c.textMuted,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isLight ? const Color(0xFF262626) : const Color(0xFFEEEEEE),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isLight ? Colors.white : const Color(0xFF111111),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
