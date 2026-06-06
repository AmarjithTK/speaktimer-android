import 'package:flutter/material.dart';

/// A themed card wrapper replacing the old panelContainer.
/// Uses [colorScheme] colors and optional border/glow.
Widget themedCard(
  BuildContext context, {
  required Widget child,
  bool elevated = false,
}) {
  final cs = Theme.of(context).colorScheme;
  return Material(
    color: cs.surfaceContainerLow,
    borderRadius: BorderRadius.circular(18),
    elevation: elevated ? 2 : 0,
    shadowColor: cs.shadow.withValues(alpha: 0.3),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: child,
    ),
  );
}

/// Section title row with optional icon badge.
Widget sectionTitle(
  BuildContext context,
  String title, {
  String? tag,
  IconData? icon,
}) {
  final cs = Theme.of(context).colorScheme;
  return Row(
    children: [
      if (icon != null) ...[
        Icon(icon, size: 18, color: cs.primary),
        const SizedBox(width: 8),
      ],
      Text(
        title,
        style: TextStyle(
          color: cs.onSurface,
          fontWeight: FontWeight.w800,
          fontSize: 15,
        ),
      ),
      if (tag != null && tag.isNotEmpty) ...[
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            tag,
            style: TextStyle(
              color: cs.onPrimaryContainer,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ),
      ],
    ],
  );
}

/// A small label used above setting groups.
Widget sectionLabel(BuildContext context, String text) {
  final cs = Theme.of(context).colorScheme;
  return Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 4, left: 2),
    child: Text(
      text,
      style: TextStyle(
        color: cs.onSurfaceVariant,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    ),
  );
}

/// A primary action button with icon support.
Widget primaryAction(
  BuildContext context, {
  required String label,
  required VoidCallback onPressed,
  IconData? icon,
  bool filled = true,
  Color? backgroundColor,
}) {
  final cs = Theme.of(context).colorScheme;
  final bg = backgroundColor ?? cs.primary;
  final fg = backgroundColor != null ? cs.onSurface : cs.onPrimary;

  if (filled) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
        child: icon == null
            ? Text(label)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                  Text(label),
                ],
              ),
      ),
    );
  }

  return SizedBox(
    width: double.infinity,
    height: 48,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: cs.onSurface,
        side: BorderSide(color: cs.outlineVariant),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 14,
        ),
      ),
      child: icon == null
          ? Text(label)
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(label),
              ],
            ),
    ),
  );
}

/// A toggle switch row with icon and description.
Widget toggleRow(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String subtitle,
  required bool value,
  required ValueChanged<bool> onChanged,
}) {
  final cs = Theme.of(context).colorScheme;
  return SwitchListTile(
    value: value,
    onChanged: onChanged,
    activeThumbColor: cs.onPrimary,
    activeTrackColor: cs.primary,
    secondary: Icon(icon, color: cs.primary, size: 22),
    title: Text(
      title,
      style: TextStyle(
        color: cs.onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w800,
      ),
    ),
    subtitle: Text(
      subtitle,
      style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
    ),
  );
}

/// A selectable option row with trailing chevron.
Widget optionRow(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String value,
  required VoidCallback onTap,
}) {
  final cs = Theme.of(context).colorScheme;
  return ListTile(
    leading: Icon(icon, color: cs.primary, size: 22),
    title: Text(
      title,
      style: TextStyle(
        color: cs.onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w800,
      ),
    ),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            color: cs.onSurfaceVariant,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 4),
        Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant, size: 20),
      ],
    ),
    onTap: onTap,
  );
}

/// A compact status chip showing an active service.
Widget statusChip(
  BuildContext context, {
  required IconData icon,
  required String label,
  required bool active,
  Color? activeColor,
}) {
  final cs = Theme.of(context).colorScheme;
  final chipColor = active ? (activeColor ?? cs.primaryContainer) : cs.surfaceContainerHighest;
  final textColor = active ? (activeColor != null ? cs.onPrimaryContainer : cs.onSurface) : cs.onSurfaceVariant;

  return AnimatedContainer(
    duration: const Duration(milliseconds: 250),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: chipColor,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: textColor),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}
