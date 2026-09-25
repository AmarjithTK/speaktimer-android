#!/usr/bin/env bash
set -eu

bundle_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
app="$bundle_dir/solasflow"
if [ ! -x "$app" ]; then
  printf 'Solas Flow release binary not found in %s\n' "$bundle_dir" >&2
  exit 1
fi

share_dir=${XDG_DATA_HOME:-"$HOME/.local/share"}
install_dir=${SOLASFLOW_INSTALL_DIR:-"$HOME/.local/opt/solasflow"}
launcher_dir="$share_dir/applications"
icons_dir="$share_dir/icons/hicolor"
icon_48_dir="$icons_dir/48x48/apps"
icon_128_dir="$icons_dir/128x128/apps"
icon_256_dir="$icons_dir/256x256/apps"
icon_512_dir="$icons_dir/512x512/apps"
mkdir -p "$install_dir" "$launcher_dir" "$icon_48_dir" "$icon_128_dir" \
  "$icon_256_dir" "$icon_512_dir"

if [ "$(realpath -- "$bundle_dir")" != "$(realpath -- "$install_dir")" ]; then
  cp -a "$bundle_dir/." "$install_dir/"
fi
rm -f "$icons_dir/scalable/apps/solasflow.svg" \
  "$icons_dir/scalable/apps/com.atherpulse.solasflow.svg" \
  "$install_dir/share/icons/hicolor/scalable/apps/solasflow.svg" \
  "$install_dir/share/icons/hicolor/scalable/apps/com.atherpulse.solasflow.svg"
cp "$install_dir/share/icons/hicolor/48x48/apps/solasflow-48.png" \
  "$icon_48_dir/solasflow.png"
cp "$install_dir/share/icons/hicolor/128x128/apps/solasflow-128.png" \
  "$icon_128_dir/solasflow.png"
cp "$install_dir/share/icons/hicolor/256x256/apps/solasflow-256.png" \
  "$icon_256_dir/solasflow.png"
cp "$install_dir/share/icons/hicolor/512x512/apps/solasflow-512.png" \
  "$icon_512_dir/solasflow.png"

cat > "$launcher_dir/com.atherpulse.solasflow.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Solas Flow
Comment=Speaking clock, focus timer, and meditation companion
Exec="$install_dir/solasflow"
TryExec=$install_dir/solasflow
Icon=$icon_256_dir/solasflow.png
Terminal=false
Categories=Utility;Clock;
StartupWMClass=com.atherpulse.solasflow
EOF

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$launcher_dir" >/dev/null 2>&1 || true
fi
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache --force "$icons_dir" >/dev/null 2>&1 || true
fi
if command -v kbuildsycoca6 >/dev/null 2>&1; then
  kbuildsycoca6 --noincremental >/dev/null 2>&1 || true
elif command -v kbuildsycoca5 >/dev/null 2>&1; then
  kbuildsycoca5 --noincremental >/dev/null 2>&1 || true
fi
printf 'Installed Solas Flow. Launch it from your applications menu or run:\n%s\n' \
  "$install_dir/solasflow"
