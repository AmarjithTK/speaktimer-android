import 'package:flutter/material.dart';

/// Wraps [child] in a Material You surface card (no borders).
/// When [active] is true, uses a tinted secondaryContainer surface.
Widget panelContainer(
  BuildContext context, {
  required Widget child,
  bool active = false,
}) {
  final cs = Theme.of(context).colorScheme;
  return Card(
    elevation: 0,
    margin: EdgeInsets.zero,
    color: active ? cs.secondaryContainer : cs.surfaceContainerHighest,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: child,
    ),
  );
}

/// Panel header with optional leading icon, using M3 titleMedium typography.
Widget headerTitle(
  BuildContext context,
  String title, {
  IconData? icon,
}) {
  final cs = Theme.of(context).colorScheme;
  final tt = Theme.of(context).textTheme;
  return Row(
    children: [
      if (icon != null) ...[
        Icon(icon, size: 18, color: cs.primary),
        const SizedBox(width: 8),
      ],
      Text(
        title,
        style: tt.titleMedium?.copyWith(
          color: cs.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

/// Muted label for form sections, using M3 labelMedium / onSurfaceVariant.
Widget sectionLabel(BuildContext context, String text) {
  final cs = Theme.of(context).colorScheme;
  final tt = Theme.of(context).textTheme;
  return Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 4),
    child: Text(
      text,
      style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
    ),
  );
}

/// Action button using FilledTonalButton — no borders, M3 compliant.
Widget actionBtn(
  BuildContext context,
  String text,
  VoidCallback onPressed, {
  IconData? icon,
}) {
  const btnStyle = ButtonStyle(
    padding: WidgetStatePropertyAll(
      EdgeInsets.symmetric(vertical: 10, horizontal: 12),
    ),
    minimumSize: WidgetStatePropertyAll(Size(0, 40)),
    textStyle: WidgetStatePropertyAll(
      TextStyle(fontWeight: FontWeight.w600, fontSize: 13, letterSpacing: 0.1),
    ),
  );
  if (icon != null) {
    return FilledTonalButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(text, overflow: TextOverflow.ellipsis),
      style: btnStyle,
    );
  }
  return FilledTonalButton(
    onPressed: onPressed,
    style: btnStyle,
    child: Text(text),
  );
}
