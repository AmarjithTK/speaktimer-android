import 'dart:math';
import 'package:flutter/material.dart';

class Palette {
  final Color primary;
  final Color accent;
  final Color bg;
  const Palette(this.primary, this.accent, this.bg);
}

const List<Palette> palettes = [
  Palette(Color(0xFF1A051D), Color(0xFFE5D4F5), Color(0xFFF4EFFF)),
  Palette(Color(0xFF0A1824), Color(0xFFCDE8F5), Color(0xFFEAF6FF)),
  Palette(Color(0xFF201004), Color(0xFFFCEFD4), Color(0xFFFFF8EA)),
  Palette(Color(0xFF0D1E16), Color(0xFFC8F0DA), Color(0xFFEEFAF3)),
  Palette(Color(0xFF2A0B0B), Color(0xFFF5DCD4), Color(0xFFFFF0EB)),
  Palette(Color(0xFF0D0D2A), Color(0xFFD8DBF5), Color(0xFFF1F2FF)),
  Palette(Color(0xFF210D2C), Color(0xFFEEDDF7), Color(0xFFF8F0FF)),
  Palette(Color(0xFF051A1A), Color(0xFFC4EEEC), Color(0xFFEFFFFD)),
  Palette(Color(0xFF2A1C00), Color(0xFFFAEFD4), Color(0xFFFFFBEA)),
  Palette(Color(0xFF14051D), Color(0xFFE5D4F5), Color(0xFFF6EEFF)),
  Palette(Color(0xFF200D00), Color(0xFFFFE8C8), Color(0xFFFFF4EA)),
  Palette(Color(0xFF001E1E), Color(0xFFC0F5EE), Color(0xFFEAFFFC)),
  Palette(Color(0xFF000000), Color(0xFFE0E0E0), Color(0xFFFFFFFF)),
  Palette(Color(0xFF1C0017), Color(0xFFFAD4F2), Color(0xFFFFF0FA)),
  Palette(Color(0xFF001C0C), Color(0xFFD4FAE0), Color(0xFFEEFFF3)),
  Palette(Color(0xFF0B141C), Color(0xFFD4E0F5), Color(0xFFF0F5FF)),
  Palette(Color(0xFF1A1A00), Color(0xFFF5F0C8), Color(0xFFFEFFEA)),
  Palette(Color(0xFF25000F), Color(0xFFFAD4DC), Color(0xFFFFF0F4)),
  Palette(Color(0xFF000B1C), Color(0xFFD4E4FA), Color(0xFFF0F6FF)),
  Palette(Color(0xFF0B1C00), Color(0xFFDFF5C4), Color(0xFFF4FFEA)),
];

final Palette palette = palettes[Random().nextInt(palettes.length)];
