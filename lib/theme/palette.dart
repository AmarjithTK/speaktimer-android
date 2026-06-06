import 'package:flutter/material.dart';

/// Convenience extensions on [BuildContext] for Material 3 color tokens.
///
/// These replace the old [Palette] class and provide consistent access to
/// the active [ColorScheme] using [Theme.of] rather than a global variable.
extension ThemeColors on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  // ── Primary ────────────────────────────────────────────────────────────
  Color get primary => colorScheme.primary;
  Color get onPrimary => colorScheme.onPrimary;
  Color get primaryContainer => colorScheme.primaryContainer;
  Color get onPrimaryContainer => colorScheme.onPrimaryContainer;

  // ── Secondary ──────────────────────────────────────────────────────────
  Color get secondary => colorScheme.secondary;
  Color get onSecondary => colorScheme.onSecondary;
  Color get secondaryContainer => colorScheme.secondaryContainer;

  // ── Surface ────────────────────────────────────────────────────────────
  Color get surface => colorScheme.surface;
  Color get onSurface => colorScheme.onSurface;
  Color get surfaceContainerLowest => colorScheme.surfaceContainerLowest;
  Color get surfaceContainerLow => colorScheme.surfaceContainerLow;
  Color get surfaceContainer => colorScheme.surfaceContainer;
  Color get surfaceContainerHigh => colorScheme.surfaceContainerHigh;
  Color get surfaceContainerHighest => colorScheme.surfaceContainerHighest;
  Color get surfaceTint => colorScheme.surfaceTint;

  // ── Variant / Outline ──────────────────────────────────────────────────
  Color get onSurfaceVariant => colorScheme.onSurfaceVariant;
  Color get outline => colorScheme.outline;
  Color get outlineVariant => colorScheme.outlineVariant;

  // ── Error ──────────────────────────────────────────────────────────────
  Color get error => colorScheme.error;
  Color get onError => colorScheme.onError;

  // ── Shadows ────────────────────────────────────────────────────────────
  Color get shadow => colorScheme.shadow;
  Color get scrim => colorScheme.scrim;
}

/// Typography extension for quick access to text styles.
extension ThemeTypography on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
}

/// Tinted surface helpers — replaces grey surface containers with subtle
/// primary-tinted backgrounds for a cleaner, less grey look.
extension TintedSurfaces on BuildContext {
  ColorScheme get cs => Theme.of(this).colorScheme;

  /// Very subtle primary tint (for hero cards, option sections)
  Color get tintedSurface => cs.primaryContainer.withValues(alpha: 0.15);

  /// Subtle tint (for inactive chips, preset items)
  Color get tintedSurfaceLow => cs.primaryContainer.withValues(alpha: 0.08);

  /// Moderate tint (for sections needing slightly more presence)
  Color get tintedSurfaceMedium => cs.primaryContainer.withValues(alpha: 0.12);
}

/// Deprecated — kept to avoid breaking imports during migration.
/// Do NOT use in new code. Use [ThemeColors] extension instead.
@Deprecated('Use BuildContext.colorScheme instead')
class Palette {
  final Color primary;
  final Color accent;
  final Color bg;
  const Palette(this.primary, this.accent, this.bg);
}

@Deprecated('Use BuildContext.colorScheme instead')
const Palette _lightPalette = Palette(
  Color(0xFF1E1B4B),
  Color(0xFFE8EAFD),
  Color(0xFFF7F7FC),
);

@Deprecated('Use BuildContext.colorScheme instead')
const Palette _darkPalette = Palette(
  Color(0xFFE0E7FF),
  Color(0xFF1E293B),
  Color(0xFF0F172A),
);

@Deprecated('Use ThemeMode / ThemeData instead')
bool _isDarkMode = false;

@Deprecated('Use ThemeMode / ThemeData instead')
void setPaletteDarkMode(bool isDarkMode) {
  _isDarkMode = isDarkMode;
}

@Deprecated('Use BuildContext.colorScheme instead')
Palette get palette => _isDarkMode ? _darkPalette : _lightPalette;
