# Solas Flow

`Solas Flow` is a Flutter focus app that combines a speaking clock, a configurable timer, and an immersive fullscreen focus mode.

## What it does

### Speaking Clock
- Shows a live digital clock with large, readable typography.
- Speaks the current time at a configurable interval (`1, 2, 5, 10, 15, 20, 30, 60` minutes).
- Optional motivational quote after each spoken time.
- Quote category options:
	- `General`
	- `Focus`
	- `Discipline`
	- `Calm`
	- `Positivity`
	- `Historic Figures`
- Motivation delay options (`5, 10, 20, 30, 40, 60` seconds).

### Timer
- Adjustable duration (`1` to `120` minutes).
- Quick preset values include `5, 10, 15, 20, 25, 30, 45, 60, 90, 120`.
- Start / Stop / Reset controls.
- Optional background noise playback while timer runs.
- Optional spoken remaining time, configurable cadence (`1, 2, 5, 10, 15, 20, 30` minutes).
- Chain timer mode with built-in presets:
	- `Pomodoro 25-5x4`
	- `Sprint 50-10x2`
	- `Quick 15-3x3`

### Fullscreen Focus mode
- Dedicated fullscreen screen for clock/timer focus.
- Auto-hides controls after 5 seconds; tap anywhere to toggle controls.
- Immersive state increases visual emphasis of time display.
- In-view controls:
	- Always-on screen toggle (wakelock)
	- Dark/light theme toggle
	- Dim brightness toggle
	- Rotate horizontal / unlock rotation toggle
	- Switch between `SpeakClock` and `Timer` views
- Fullscreen defaults are configurable from settings:
	- Use dark theme by default
	- Dim screen brightness in fullscreen
	- Start fullscreen in horizontal orientation

### Notification + background behavior
- Foreground service keeps timer/clock state alive in background.
- Notification buttons can control timer and clock speech state.
- App provides full-exit behavior that stops timer/clock/audio and foreground service.

### Voice and audio settings
- Nature sound selection (local bundled assets).
- Separate noise volume and speech volume controls.
- Voice list mode (`pleasant` vs `all` English voices).
- Favorite voice selection.

### Quick Actions (launcher shortcuts)
- `Start 25m`
- `Resume Last`
- `Toggle Speech`

### Persistence
- Preferences are persisted with `shared_preferences`, including:
	- sound + volume choices
	- clock interval + motivation settings
	- timer speech/noise settings
	- fullscreen defaults
	- voice preferences

## Tech stack

- Flutter / Dart
- `flutter_tts`
- `audioplayers`
- `flutter_foreground_task`
- `flutter_local_notifications`
- `quick_actions`
- `wakelock_plus`
- `screen_brightness`
- `shared_preferences`

## Project structure (important paths)

- `lib/main.dart` — app orchestration, tabs, state, lifecycle
- `lib/widgets/clock_panel.dart` — speaking clock UI
- `lib/widgets/timer_panel.dart` — timer + chain timer UI
- `lib/widgets/fullscreen_focus_view.dart` — fullscreen focus mode
- `lib/widgets/settings_panel.dart` — settings UI
- `lib/services/settings_service.dart` — settings persistence
- `lib/models/app_settings.dart` — settings model
- `lib/core/pref_keys.dart` — preference keys
- `assets/audio/` — bundled local audio files

## Getting started

### Prerequisites

- Flutter stable with Dart `3.11.3` or newer (see `environment.sdk` in `pubspec.yaml`).
- Android Studio / Android SDK for Android builds.
- Xcode on macOS for iOS builds.

### Linux build prerequisites

Flutter's Linux desktop target needs GTK 3 development files. The Linux audio plugin also needs GStreamer development libraries when building and its base/good/ALSA plugins at runtime; install those with the compiler/build tools.

**Arch Linux**
```bash
sudo pacman -S --needed base-devel clang cmake flutter git \
  gstreamer gst-plugins-base-libs gst-plugins-good gtk3 libepoxy \
  ninja pkgconf alsa-lib
```

**Debian / Ubuntu**
```bash
sudo apt update
sudo apt install clang cmake ninja-build pkg-config libgtk-3-dev \
  liblzma-dev libstdc++-12-dev libgstreamer1.0-dev \
  libgstreamer-plugins-base1.0-dev gstreamer1.0-plugins-base \
  gstreamer1.0-plugins-good gstreamer1.0-alsa libasound2
```

**Fedora**
```bash
sudo dnf install clang cmake ninja-build pkgconf-pkg-config gtk3-devel \
  xz-devel gstreamer1-devel gstreamer1-plugins-base-devel \
  gstreamer1-plugins-base gstreamer1-plugins-good alsa-lib
```

Install Flutter from your distribution or from the [official Flutter Linux installation guide](https://docs.flutter.dev/get-started/install/linux/desktop). Confirm that `flutter doctor -v` reports Linux desktop support and GTK development dependencies before building. The distro package names above cover the native dependencies; Flutter itself may need to be installed separately on Debian, Ubuntu, and Fedora.

### Resolve dependencies and run from source
```bash
flutter pub get
flutter run -d linux
```

### Build and install the Linux release bundle
```bash
flutter build linux --release
./build/linux/x64/release/bundle/install-linux.sh
```

The installer copies the relocatable bundle to `~/.local/opt/solasflow` and adds a desktop launcher under `~/.local/share/applications`. Launch `Solas Flow` from the desktop menu or run:
```bash
~/.local/opt/solasflow/solasflow
```

Keep the entire generated `build/linux/x64/release/bundle` directory together when distributing the application; the executable needs its adjacent `data/` and `lib/` directories. GTK 3 and GStreamer runtime packages must be present on the target distro.

### Linux speech models

Linux bundles offline Sherpa-ONNX, Piper voices for English and Malayalam, and eSpeak-NG language data. On first Linux launch, a consent dialog offers **Accept and download** for the optional 140 MiB INT8 Kokoro v1.1 English model, or **Keep Piper**. No Kokoro bytes are fetched before acceptance. If declined, the download can be started later from **Settings → Kokoro English voice → Download**. The Settings card shows live transfer percentage and byte counts, then SHA-256 verification and installation status; cancel is available during transfer, and failed or cancelled downloads can be retried. English speech continues with bundled Piper until Kokoro is installed, or if the download fails. The verified model is cached under `~/.local/share/solasflow_runtime/assets/tts/models/en/kokoro`. Linux-generated WAV audio plays through the app's GStreamer-backed audio player, rather than relying on `paplay` or `aplay`.

Kokoro v1.1 currently supplies natural-sounding US English (`af_maple`) on Linux; it does not speak Malayalam. Malayalam remains offline through the bundled Piper `ml_IN-meera-medium` voice. Quality differs by language and voice; use **Settings → Test voice** to check the selected language and installed audio output. The upstream [Kokoro model](https://huggingface.co/hexgrad/Kokoro-82M) is Apache-2.0. See `assets/tts/models_manifest.json` for runtime model selection.

### Arch Linux package
```bash
cd packaging/arch
makepkg -si
```

The `solasflow-git` package builds the Linux release from the current `master` branch and declares its GTK/GStreamer runtime dependencies. `makepkg` installs the package with pacman when `-i` is supplied.

### Debian, Ubuntu, Fedora, and other distributions

Install the Linux build prerequisites above, then build and install with the bundle commands. For a prebuilt release bundle, extract it without changing its directory structure, install the target distro's GTK 3 and GStreamer runtime packages, and run `./install-linux.sh` from inside the extracted bundle. The installer creates a per-user launcher and does not register distro package dependencies. Do not copy only the `solasflow` executable.

### Other platforms
```bash
flutter pub get
flutter run
```

Build Android or iOS from the corresponding Flutter target. Desktop Kokoro bootstrap is Linux-only; existing platform speech engines remain in use elsewhere.

### Test
```bash
flutter test
```
## Notes

- App display name is `Solas Flow`.
- Android package namespace and notification metadata still use `com.example.speakertimer` in platform config for compatibility.
- Audio assets are local (`assets/audio/`) to support offline/background behavior.
