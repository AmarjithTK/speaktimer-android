import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

enum FullscreenFocusMode { clock, timer, moduleC }

class FullscreenFocusView extends StatefulWidget {
  final String Function() clockTextBuilder;
  final String Function() timerTextBuilder;
  final String Function() stopwatchTextBuilder;
  final bool Function() isTimerRunningBuilder;
  final bool Function() isStopwatchRunningBuilder;
  final FullscreenFocusMode initialMode;
  final bool initialDarkTheme;
  final bool initialDimBrightness;
  final bool initialForceLandscape;
  final bool startImmersive;
  final ValueChanged<bool>? onThemeChanged;
  final ValueChanged<bool>? onDimBrightnessChanged;
  final ValueChanged<bool>? onForceLandscapeChanged;

  // Timer controls
  final VoidCallback? onTimerStart;
  final VoidCallback? onTimerStop;
  final VoidCallback? onTimerReset;

  // Stopwatch controls
  final VoidCallback? onStopwatchStart;
  final VoidCallback? onStopwatchStop;
  final VoidCallback? onStopwatchReset;

  const FullscreenFocusView({
    super.key,
    required this.clockTextBuilder,
    required this.timerTextBuilder,
    required this.stopwatchTextBuilder,
    required this.isTimerRunningBuilder,
    required this.isStopwatchRunningBuilder,
    required this.initialMode,
    required this.initialDarkTheme,
    required this.initialDimBrightness,
    required this.initialForceLandscape,
    this.startImmersive = false,
    this.onThemeChanged,
    this.onDimBrightnessChanged,
    this.onForceLandscapeChanged,
    this.onTimerStart,
    this.onTimerStop,
    this.onTimerReset,
    this.onStopwatchStart,
    this.onStopwatchStop,
    this.onStopwatchReset,
  });

  @override
  State<FullscreenFocusView> createState() => _FullscreenFocusViewState();
}

class _FullscreenFocusViewState extends State<FullscreenFocusView> {
  Timer? _tick;
  Timer? _controlsHideTimer;
  bool _alwaysOn = true;
  bool _darkTheme = true;
  bool _forceLandscape = false;
  bool _dimBrightness = false;
  bool _showEntryHint = true;
  bool _showExitHint = true;
  FullscreenFocusMode _mode = FullscreenFocusMode.clock;
  bool _showControls = true;
  String _clockText = '';
  String _timerText = '00:00';
  String _stopwatchText = '00:00';
  bool _timerRunning = false;
  bool _stopwatchRunning = false;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    _darkTheme = widget.initialDarkTheme;
    _dimBrightness = widget.initialDimBrightness;
    _forceLandscape = widget.initialForceLandscape;
    _showControls = !widget.startImmersive;
    _showEntryHint = !widget.startImmersive;
    _showExitHint = !widget.startImmersive;

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    unawaited(WakelockPlus.enable());
    unawaited(_applyBrightness());
    unawaited(_applyOrientation());
    if (_showControls) {
      _restartControlsHideTimer();
    }
    _refresh();
    _tick = Timer.periodic(const Duration(milliseconds: 120), (_) {
      _refresh();
    });

    if (!widget.startImmersive) {
      Timer(const Duration(seconds: 4), () {
        if (!mounted) return;
        setState(() {
          _showEntryHint = false;
        });
      });

      Timer(const Duration(seconds: 7), () {
        if (!mounted) return;
        setState(() {
          _showExitHint = false;
        });
      });
    }
  }

  void _restartControlsHideTimer() {
    _controlsHideTimer?.cancel();
    _controlsHideTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      setState(() {
        _showControls = false;
      });
    });
  }

  void _onScreenTap() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _restartControlsHideTimer();
    } else {
      _controlsHideTimer?.cancel();
    }
  }

  void _onControlInteraction() {
    if (!_showControls) {
      setState(() {
        _showControls = true;
      });
    }
    _restartControlsHideTimer();
  }

  Future<void> _applyOrientation() {
    if (_forceLandscape) {
      return SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    return SystemChrome.setPreferredOrientations([]);
  }

  Future<void> _applyBrightness() async {
    try {
      if (_dimBrightness) {
        await ScreenBrightness.instance.setApplicationScreenBrightness(0.08);
      } else {
        await ScreenBrightness.instance.resetApplicationScreenBrightness();
      }
    } catch (_) {}
  }

  void _refresh() {
    if (!mounted) return;
    setState(() {
      _clockText = widget.clockTextBuilder();
      _timerText = widget.timerTextBuilder();
      _stopwatchText = widget.stopwatchTextBuilder();
      _timerRunning = widget.isTimerRunningBuilder();
      _stopwatchRunning = widget.isStopwatchRunningBuilder();
    });
  }

  (String, String?) _splitClockDisplay(String value) {
    if (value.contains('.')) {
      final parts = value.split('.');
      return (parts.first, parts.length > 1 ? parts[1] : null);
    }
    return (value, null);
  }

  (String, String, String?) _splitTimer(String value) {
    final dotParts = value.split('.');
    final base = dotParts.first;
    final millis = dotParts.length > 1 ? dotParts[1] : null;
    final parts = base.split(':');
    if (parts.length == 2) {
      return (parts[0], parts[1], millis);
    }
    if (parts.length == 3) {
      return ('${parts[0]}:${parts[1]}', parts[2], millis);
    }
    return ('00', '00', null);
  }

  Widget _buildTimerLikeDisplay(
    Color fg, {
    required String value,
  }) {
    final timerParts = _splitTimer(value);
    final mins = timerParts.$1;
    final secs = timerParts.$2;
    final millis = timerParts.$3;
    const valueSize = 160.0;
    const separatorSize = 128.0;
    const millisSize = 42.0;

    return LayoutBuilder(
      builder: (_, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : double.infinity;
        final height = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : double.infinity;

        return Center(
          child: SizedBox(
            width: width,
            height: height,
            child: FittedBox(
              fit: BoxFit.contain,
              alignment: Alignment.center,
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    color: fg,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                  children: [
                    TextSpan(
                      text: mins,
                      style: TextStyle(
                        fontSize: valueSize,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    TextSpan(
                      text: ':',
                      style: TextStyle(
                        fontSize: separatorSize,
                        fontWeight: FontWeight.w700,
                        color: fg.withAlpha(190),
                        height: 1,
                      ),
                    ),
                    TextSpan(
                      text: secs,
                      style: TextStyle(
                        fontSize: valueSize,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    if (millis != null)
                      TextSpan(
                        text: '.$millis',
                        style: TextStyle(
                          fontSize: millisSize,
                          fontWeight: FontWeight.w700,
                          color: fg.withAlpha(190),
                          height: 1,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildClockDisplay(Color fg) {
    final clockParts = _splitClockDisplay(_clockText);
    final mainTime = clockParts.$1;
    final millis = clockParts.$2;
    const valueSize = 132.0;
    const millisSize = 42.0;

    return LayoutBuilder(
      builder: (_, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : double.infinity;
        final height = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : double.infinity;

        return Center(
          child: SizedBox(
            width: width,
            height: height,
            child: FittedBox(
              fit: BoxFit.contain,
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    mainTime,
                    style: TextStyle(
                      color: fg,
                      fontSize: valueSize,
                      fontWeight: FontWeight.w800,
                      height: 1,
                      letterSpacing: 0,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  if (millis != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        '.$millis',
                        style: TextStyle(
                          color: fg.withAlpha(190),
                          fontSize: millisSize,
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _topToggleChip({
    required Color fg,
    required Color variant,
    required Color selectedBg,
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: selected ? selectedBg : Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: selected ? fg : variant, size: 17),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: selected ? fg : variant,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Start / Stop / Reset row shown at the bottom for Timer and Stopwatch.
  Widget _buildActionButtons(Color fg, Color primary, Color outline) {
    final bool isTimer = _mode == FullscreenFocusMode.timer;
    final bool running = isTimer ? _timerRunning : _stopwatchRunning;

    Widget actionBtn(
      String label,
      IconData icon,
      VoidCallback? onPressed, {
      bool isPrimary = false,
    }) {
      return Expanded(
        child: Material(
          color: isPrimary ? primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onPressed == null
                ? null
                : () {
                    _onControlInteraction();
                    onPressed();
                  },
            child: Container(
              height: isPrimary ? 52 : 48,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isPrimary ? Colors.transparent : outline,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: isPrimary ? Colors.white : fg, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: isPrimary ? Colors.white : fg,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          actionBtn(
            running ? 'Stop' : 'Start',
            running ? Icons.pause_rounded : Icons.play_arrow_rounded,
            running
                ? (isTimer ? widget.onTimerStop : widget.onStopwatchStop)
                : (isTimer ? widget.onTimerStart : widget.onStopwatchStart),
            isPrimary: true,
          ),
          const SizedBox(width: 10),
          actionBtn(
            'Reset',
            Icons.refresh_rounded,
            isTimer ? widget.onTimerReset : widget.onStopwatchReset,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tick?.cancel();
    _controlsHideTimer?.cancel();
    if (_alwaysOn) {
      WakelockPlus.disable();
    }
    unawaited(_resetBrightnessSafe());
    SystemChrome.setPreferredOrientations([]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _resetBrightnessSafe() async {
    try {
      await ScreenBrightness.instance.resetApplicationScreenBrightness();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Use the proper Monet dark scheme when _darkTheme is active
    final Color bg, fg, variant, surface, outline, selectedBg;
    if (_darkTheme) {
      final darkScheme = ColorScheme.fromSeed(
        seedColor: cs.primary,
        brightness: Brightness.dark,
      );
      bg = darkScheme.surface;
      fg = darkScheme.onSurface;
      variant = darkScheme.onSurfaceVariant;
      surface = darkScheme.surfaceContainerLow;
      outline = darkScheme.outlineVariant;
      selectedBg = darkScheme.secondaryContainer;
    } else {
      bg = cs.surface;
      fg = cs.onSurface;
      variant = cs.onSurfaceVariant;
      surface = cs.surfaceContainerLow;
      outline = cs.outlineVariant;
      selectedBg = cs.secondaryContainer;
    }
    final primary = cs.primary;

    final showActionButtons =
        _mode == FullscreenFocusMode.timer ||
        _mode == FullscreenFocusMode.moduleC;

    return Scaffold(
      backgroundColor: bg,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onScreenTap,
        onDoubleTap: () => Navigator.of(context).pop(),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: Center(
                  child: AnimatedPadding(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    padding: EdgeInsets.fromLTRB(
                      4,
                      _showControls ? 72 : 4,
                      4,
                      _showControls ? (showActionButtons ? 92 : 20) : 4,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: _showControls ? surface : Colors.transparent,
                          borderRadius: BorderRadius.circular(28),
                          border: _showControls
                              ? Border.all(color: outline, width: 1)
                              : null,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: _showControls ? 22 : 4,
                            vertical: _showControls ? 24 : 4,
                          ),
                          child: _mode == FullscreenFocusMode.clock
                              ? _buildClockDisplay(fg)
                              : (_mode == FullscreenFocusMode.timer
                                    ? _buildTimerLikeDisplay(
                                        fg,
                                        value: _timerText,
                                      )
                                    : _buildTimerLikeDisplay(
                                        fg,
                                        value: _stopwatchText,
                                      )),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              IgnorePointer(
                ignoring: !_showControls,
                child: AnimatedOpacity(
                  opacity: _showControls ? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Column(
                    children: [
                      // ── Top bar: close + settings icons ─────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: Row(
                          children: [
                            IconButton.filledTonal(
                              onPressed: () {
                                _onControlInteraction();
                                Navigator.of(context).pop();
                              },
                              style: IconButton.styleFrom(
                                backgroundColor: selectedBg,
                                foregroundColor: fg,
                              ),
                              icon: const Icon(Icons.close_rounded),
                            ),
                            const Spacer(),
                            _topToggleChip(
                              fg: fg,
                              variant: variant,
                              selectedBg: selectedBg,
                              icon: Icons.lock_clock_rounded,
                              label: 'Awake',
                              selected: _alwaysOn,
                              onTap: () async {
                                _onControlInteraction();
                                final val = !_alwaysOn;
                                setState(() => _alwaysOn = val);
                                if (val) {
                                  await WakelockPlus.enable();
                                } else {
                                  await WakelockPlus.disable();
                                }
                              },
                            ),
                            const SizedBox(width: 6),
                            IconButton(
                              tooltip: _darkTheme
                                  ? 'Light theme'
                                  : 'Dark theme',
                              onPressed: () async {
                                _onControlInteraction();
                                setState(() => _darkTheme = !_darkTheme);
                                widget.onThemeChanged?.call(_darkTheme);
                              },
                              icon: Icon(
                                _darkTheme
                                    ? Icons.dark_mode_rounded
                                    : Icons.light_mode_rounded,
                                color: fg,
                              ),
                            ),
                            IconButton(
                              tooltip: _dimBrightness
                                  ? 'Disable dim'
                                  : 'Dim brightness',
                              onPressed: () async {
                                _onControlInteraction();
                                setState(
                                  () => _dimBrightness = !_dimBrightness,
                                );
                                widget.onDimBrightnessChanged?.call(
                                  _dimBrightness,
                                );
                                await _applyBrightness();
                              },
                              icon: Icon(
                                _dimBrightness
                                    ? Icons.brightness_2_rounded
                                    : Icons.brightness_6_rounded,
                                color: fg,
                              ),
                            ),
                            IconButton(
                              tooltip: _forceLandscape
                                  ? 'Unlock Rotation'
                                  : 'Rotate Horizontal',
                              onPressed: () async {
                                _onControlInteraction();
                                setState(
                                  () => _forceLandscape = !_forceLandscape,
                                );
                                widget.onForceLandscapeChanged?.call(
                                  _forceLandscape,
                                );
                                await _applyOrientation();
                              },
                              icon: Icon(
                                _forceLandscape
                                    ? Icons.stay_current_landscape_rounded
                                    : Icons.screen_rotation_alt_rounded,
                                color: fg,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // ── Start/Stop/Reset (Timer & Stopwatch modes) ────────
                      if (showActionButtons) ...[
                        _buildActionButtons(fg, primary, outline),
                        const SizedBox(height: 14),
                      ],
                    ],
                  ),
                ),
              ),
              if (_showEntryHint)
                Positioned(
                  top: 14,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: selectedBg,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Fullscreen mode entered',
                          style: TextStyle(
                            color: fg,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (_showExitHint)
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: selectedBg,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Double tap anywhere to exit',
                          style: TextStyle(
                            color: fg,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
