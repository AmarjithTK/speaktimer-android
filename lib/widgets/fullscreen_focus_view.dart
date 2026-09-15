import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../theme/app_colors.dart';

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
  final bool initialShowClock;
  final double initialClockScale;
  final double initialDimBrightnessLevel;
  final bool startImmersive;
  final ValueChanged<bool>? onThemeChanged;
  final ValueChanged<bool>? onDimBrightnessChanged;
  final ValueChanged<bool>? onForceLandscapeChanged;
  final ValueChanged<bool>? onShowClockChanged;
  final ValueChanged<double>? onClockScaleChanged;
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
    this.initialShowClock = false,
    this.initialClockScale = 1.0,
    this.initialDimBrightnessLevel = 0.08,
    this.startImmersive = false,
    this.onThemeChanged,
    this.onDimBrightnessChanged,
    this.onForceLandscapeChanged,
    this.onShowClockChanged,
    this.onClockScaleChanged,
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
  double _dimBrightnessLevel = 0.08;
  bool _showClock = false;
  double _clockScale = 1.0;
  bool _showEntryHint = true;
  bool _showExitHint = true;
  FullscreenFocusMode _mode = FullscreenFocusMode.clock;
  bool _showControls = true;
  String _clockText = '';
  String _timerText = '00:00';
  String _stopwatchText = '00:00';
  bool _timerRunning = false;
  bool _stopwatchRunning = false;
  Future<void> _platformEffectTail = Future<void>.value();

  void _enqueuePlatformEffect(Future<void> Function() effect) {
    _platformEffectTail = _platformEffectTail
        .catchError((Object error, StackTrace stackTrace) {
          debugPrint('Fullscreen platform effect predecessor failed: $error');
        })
        .then((_) => effect())
        .catchError((Object error, StackTrace stackTrace) {
          debugPrint('Fullscreen platform effect failed: $error');
        });
  }

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    _darkTheme = widget.initialDarkTheme;
    _dimBrightness = widget.initialDimBrightness;
    _dimBrightnessLevel = widget.initialDimBrightnessLevel;
    _forceLandscape = widget.initialForceLandscape;
    _showClock = widget.initialShowClock;
    _clockScale = widget.initialClockScale;
    _showEntryHint = !widget.startImmersive;
    _showExitHint = !widget.startImmersive;

    _enqueuePlatformEffect(
      () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky),
    );
    _enqueuePlatformEffect(WakelockPlus.enable);
    _applyBrightness();
    _applyOrientation();
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

  void _applyOrientation() {
    final orientations = _forceLandscape
        ? <DeviceOrientation>[
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]
        : <DeviceOrientation>[];
    _enqueuePlatformEffect(
      () => SystemChrome.setPreferredOrientations(orientations),
    );
  }

  void _applyBrightness() {
    final shouldDim = _dimBrightness;
    final dimLevel = _dimBrightnessLevel;
    _enqueuePlatformEffect(() async {
      if (shouldDim) {
        await ScreenBrightness.instance.setApplicationScreenBrightness(
          dimLevel,
        );
      } else {
        await ScreenBrightness.instance.resetApplicationScreenBrightness();
      }
    });
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

  /// Strips AM/PM suffix from clock display
  String _stripClockSuffix(String value) {
    return value.replaceAll(RegExp(r'\s(AM|PM)$'), '');
  }

  void _cycleClockScale() {
    _onControlInteraction();
    final scales = [0.8, 1.0, 1.25, 1.5, 2.0];
    int nextIdx = 1;
    for (int i = 0; i < scales.length; i++) {
      if ((scales[i] - _clockScale).abs() < 0.05) {
        nextIdx = (i + 1) % scales.length;
        break;
      }
    }
    final newScale = scales[nextIdx];
    setState(() => _clockScale = newScale);
    widget.onClockScaleChanged?.call(newScale);
  }

  (String, String) _splitTimer(String value) {
    final base = value.split('.').first;
    final parts = base.split(':');
    if (parts.length == 2) {
      return (parts[0], parts[1]);
    }
    if (parts.length == 3) {
      return ('${parts[0]}:${parts[1]}', parts[2]);
    }
    return ('00', '00');
  }

  Widget _buildTimerLikeDisplay(
    Color fg,
    Color surface,
    Color outline, {
    required String value,
  }) {
    final timerParts = _splitTimer(value);
    final mins = timerParts.$1;
    final secs = timerParts.$2;

    final timerWidget = FittedBox(
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
              style: const TextStyle(
                fontSize: 600,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
            TextSpan(
              text: ':',
              style: TextStyle(
                fontSize: 480,
                fontWeight: FontWeight.w800,
                color: fg.withAlpha(190),
                height: 1,
              ),
            ),
            TextSpan(
              text: secs,
              style: const TextStyle(
                fontSize: 600,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );

    if (!_showClock) {
      return Center(child: timerWidget);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cleanClockTime = _stripClockSuffix(_clockText).split('.').first;
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final isLandscape = w > h * 1.2;

        // Flex allocation between timer and clock based on _clockScale
        final clockFlex = (_clockScale * (isLandscape ? 2.5 : 3.0))
            .round()
            .clamp(2, 6);
        final timerFlex = (10 - clockFlex).clamp(4, 8);

        final clockWidget = GestureDetector(
          onTap: _cycleClockScale,
          child: AnimatedOpacity(
            opacity: _showControls ? 0.95 : 0.85,
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: (14 * _clockScale).clamp(8.0, 24.0),
                vertical: (6 * _clockScale).clamp(4.0, 12.0),
              ),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(10 * _clockScale),
                border: Border.all(color: outline, width: 2),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  cleanClockTime,
                  style: TextStyle(
                    color: fg,
                    fontSize: 200,
                    fontWeight: FontWeight.w900,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
          ),
        );

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: timerFlex,
              child: Center(child: timerWidget),
            ),
            const SizedBox(height: 8),
            Expanded(
              flex: clockFlex,
              child: Center(child: clockWidget),
            ),
          ],
        );
      },
    );
  }

  Widget _buildClockDisplay(Color fg) {
    final mainTime = _stripClockSuffix(_clockText).split('.').first;

    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.center,
        child: Text(
          mainTime,
          style: TextStyle(
            color: fg,
            fontSize: 600,
            fontWeight: FontWeight.w900,
            height: 1,
            letterSpacing: 0,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
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
    _enqueuePlatformEffect(() async {
      if (_alwaysOn) await WakelockPlus.disable();
      try {
        await ScreenBrightness.instance.resetApplicationScreenBrightness();
      } catch (_) {}
      await SystemChrome.setPreferredOrientations([]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use AppColors tokens directly for consistent fullscreen theming
    final c = _darkTheme ? AppColors.dark : AppColors.light;
    final bg = c.background;
    final fg = c.textPrimary;
    final variant = c.textSecondary;
    final surface = c.surface;
    final outline = c.surfaceBorder;
    final selectedBg = c.accentLight;
    final primary = c.accent;

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
                      _showControls ? 60 : 4,
                      4,
                      _showControls ? (showActionButtons ? 78 : 16) : 4,
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
                                        surface,
                                        outline,
                                        value: _timerText,
                                      )
                                    : _buildTimerLikeDisplay(
                                        fg,
                                        surface,
                                        outline,
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
                            const SizedBox(width: 8),
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                reverse: true,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _topToggleChip(
                                      fg: fg,
                                      variant: variant,
                                      selectedBg: selectedBg,
                                      icon: Icons.lock_clock_rounded,
                                      label: 'Awake',
                                      selected: _alwaysOn,
                                      onTap: () {
                                        _onControlInteraction();
                                        final val = !_alwaysOn;
                                        setState(() => _alwaysOn = val);
                                        _enqueuePlatformEffect(
                                          val
                                              ? WakelockPlus.enable
                                              : WakelockPlus.disable,
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 6),
                                    _topToggleChip(
                                      fg: fg,
                                      variant: variant,
                                      selectedBg: selectedBg,
                                      icon: Icons.access_time_rounded,
                                      label: 'Clock',
                                      selected: _showClock,
                                      onTap: () {
                                        _onControlInteraction();
                                        final val = !_showClock;
                                        setState(() => _showClock = val);
                                        widget.onShowClockChanged?.call(val);
                                      },
                                    ),
                                    if (_showClock) ...[
                                      const SizedBox(width: 6),
                                      _topToggleChip(
                                        fg: fg,
                                        variant: variant,
                                        selectedBg: selectedBg,
                                        icon: Icons.format_size_rounded,
                                        label:
                                            '${_clockScale.toStringAsFixed(1)}x',
                                        selected: true,
                                        onTap: _cycleClockScale,
                                      ),
                                    ],
                                    const SizedBox(width: 6),
                                    IconButton(
                                      tooltip: _darkTheme
                                          ? 'Light theme'
                                          : 'Dark theme',
                                      onPressed: () async {
                                        _onControlInteraction();
                                        setState(
                                          () => _darkTheme = !_darkTheme,
                                        );
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
                                      onPressed: () {
                                        _onControlInteraction();
                                        setState(
                                          () =>
                                              _dimBrightness = !_dimBrightness,
                                        );
                                        widget.onDimBrightnessChanged?.call(
                                          _dimBrightness,
                                        );
                                        _applyBrightness();
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
                                      onPressed: () {
                                        _onControlInteraction();
                                        setState(
                                          () => _forceLandscape =
                                              !_forceLandscape,
                                        );
                                        widget.onForceLandscapeChanged?.call(
                                          _forceLandscape,
                                        );
                                        _applyOrientation();
                                      },
                                      icon: Icon(
                                        _forceLandscape
                                            ? Icons
                                                  .stay_current_landscape_rounded
                                            : Icons.screen_rotation_alt_rounded,
                                        color: fg,
                                      ),
                                    ),
                                  ],
                                ),
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
              if (_showEntryHint && !_showControls)
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
              if (_showExitHint && !_showControls)
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
