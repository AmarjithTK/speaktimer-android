import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Convenience extensions on [BuildContext] for accessing color tokens
/// from the new [AppColors] system.
extension ThemeColors on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
}

/// Access the app's color tokens based on current brightness.
///
/// Usage: `final c = context.appColors;`
extension AppColorAccess on BuildContext {
  ColorTokens get appColors {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.light
        ? AppColors.light
        : AppColors.dark;
  }
}
