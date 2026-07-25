import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Minimal custom toggle switch.
///
/// 44x24 track with smooth animation. Cleaner than default Material switch.
/// Note: This is an alternative to the built-in Switch widget.
/// Use [Switch] directly in SettingsToggleRow for consistency with Material.
class MinimalToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const MinimalToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final colors = brightness == Brightness.light
        ? AppColors.light
        : AppColors.dark;

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 24,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value ? colors.toggleTrackOn : colors.toggleTrackOff,
          borderRadius: BorderRadius.circular(12),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: value ? colors.toggleThumbOn : colors.toggleThumbOff,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
