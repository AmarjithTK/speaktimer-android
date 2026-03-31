// Palette is kept for legacy compatibility.
// All UI widgets use Theme.of(context).colorScheme for Material You colors.

bool _isDarkMode = false;

void setPaletteDarkMode(bool isDarkMode) {
  _isDarkMode = isDarkMode;
}

bool get isDarkMode => _isDarkMode;
