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

Widget headerTitle(String title, String tag) {
  return Row(
    children: [
      Text(title, style: TextStyle(color: palette.primary, fontWeight: FontWeight.bold, fontSize: 13)),
      const SizedBox(width: 6),
      if (tag.isNotEmpty)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(color: palette.primary, borderRadius: BorderRadius.circular(3)),
          child: Text(tag, style: TextStyle(color: palette.accent, fontWeight: FontWeight.bold, fontSize: 9)),
        )
    ],
  );
}

Widget sectionLabel(String text) {
  return Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 4),
    child: Text(text, style: TextStyle(color: palette.primary.withAlpha(140), fontSize: 11, fontWeight: FontWeight.w500)),
  );
}

Widget actionBtn(String text, VoidCallback onPressed) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: palette.accent,
      foregroundColor: palette.primary,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      side: BorderSide(color: palette.primary, width: 2),
    ),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
  );
}
