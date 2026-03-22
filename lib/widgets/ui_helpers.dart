import 'package:flutter/material.dart';
import '../theme/palette.dart';

Widget panelContainer({required Widget child, bool active = false}) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
    decoration: BoxDecoration(
      color: palette.bg,
      border: Border.all(
        color: palette.primary,
        width: active ? 3 : 2,
      ),
      borderRadius: BorderRadius.circular(6),
    ),
    child: child,
  );
}

Widget headerTitle(
  String title,
  String tag, {
  IconData? icon,
}) {
  return Row(
    children: [
      if (icon != null) ...[
        Icon(icon, size: 16, color: palette.primary),
        const SizedBox(width: 6),
      ],
      Text(
        title,
        style: TextStyle(
          color: palette.primary,
          fontWeight: FontWeight.w700,
          fontSize: 14,
          letterSpacing: 0.2,
        ),
      ),
      const SizedBox(width: 6),
      if (tag.isNotEmpty)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(color: palette.primary, borderRadius: BorderRadius.circular(3)),
          child: Text(
            tag,
            style: TextStyle(
              color: palette.accent,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        )
    ],
  );
}

Widget sectionLabel(String text) {
  return Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 4),
    child: Text(
      text,
      style: TextStyle(
        color: palette.primary.withAlpha(150),
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
      ),
    ),
  );
}

Widget actionBtn(
  String text,
  VoidCallback onPressed, {
  IconData? icon,
}) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: palette.accent,
      foregroundColor: palette.primary,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      side: BorderSide(color: palette.primary, width: 2),
      textStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 12,
        letterSpacing: 0.2,
      ),
    ),
    child: icon == null
        ? Text(text)
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16),
              const SizedBox(width: 6),
              Flexible(child: Text(text, overflow: TextOverflow.ellipsis)),
            ],
          ),
  );
}
