import 'package:flutter/material.dart';

class Palette {
  final Color primary;
  final Color accent;
  final Color bg;
  const Palette(this.primary, this.accent, this.bg);
}

const Palette _lightPalette = Palette(
  Color(0xFF1E1B4B),
  Color(0xFFE8EAFD),
  Color(0xFFF7F7FC),
);

const Palette _darkPalette = Palette(
  Color(0xFFE0E7FF),
  Color(0xFF1E293B),
  Color(0xFF0F172A),
);

bool _isDarkMode = false;

void setPaletteDarkMode(bool isDarkMode) {
  _isDarkMode = isDarkMode;
}

Palette get palette => _isDarkMode ? _darkPalette : _lightPalette;
