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
  final ValueChanged<bool>? onThemeChanged;
  final ValueChanged<bool>? onDimBrightnessChanged;
  final ValueChanged<bool>? onForceLandscapeChanged;

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
    this.onThemeChanged,
    this.onDimBrightnessChanged,
    this.onForceLandscapeChanged,
  });

  @override
  State<FullscreenFocusView> createState() => _FullscreenFocusViewState();
}

class _FullscreenFocusViewState extends State<FullscreenFocusView> {
  Timer? _tick;
  Timer? _controlsHideTimer;
  bool _darkTheme = true;
  bool _alwaysOn = true;
  bool _forceLandscape = false;
  bool _dimBrightness = false;
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

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    unawaited(WakelockPlus.enable());
    unawaited(_applyBrightness());
    unawaited(_applyOrientation());
    _restartControlsHideTimer();
    _refresh();
    _tick = Timer.periodic(const Duration(milliseconds: 120), (_) {
      _refresh();
    });
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
    required bool immersive,
    required String label,
    required String value,
  }) {
    final timerParts = _splitTimer(value);
    final mins = timerParts.$1;
    final secs = timerParts.$2;
    final millis = timerParts.$3;
    final labelSize = immersive ? 16.0 : 13.0;
    final valueSize = immersive ? 140.0 : 112.0;
    final separatorSize = immersive ? 112.0 : 88.0;
    final millisSize = immersive ? 36.0 : 28.0;
    return LayoutBuilder(
      builder: (_, constraints) {
        final maxHeight = constraints.maxHeight;
        final showLabel = maxHeight.isInfinite || maxHeight > 120;

        return Column(
          children: [
            if (showLabel) ...[
              Text(
                label,
                style: TextStyle(
                  color: fg.withAlpha(165),
                  fontSize: labelSize,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 6),
            ],
            Expanded(
              child: SizedBox(
                width: double.infinity,
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
            ),
          ],
        );
      },
    );
  }

  Widget _buildClockDisplay(Color fg, {required bool immersive}) {
    final clockParts = _splitClockDisplay(_clockText);
    final mainTime = clockParts.$1;
    final millis = clockParts.$2;
    final labelSize = immersive ? 16.0 : 13.0;
    final valueSize = immersive ? 112.0 : 88.0;
    final millisSize = immersive ? 36.0 : 28.0;

    return LayoutBuilder(
      builder: (_, constraints) {
        final maxHeight = constraints.maxHeight;
        final showLabel = maxHeight.isInfinite || maxHeight > 120;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showLabel) ...[
              Text(
                'CURRENT TIME',
                style: TextStyle(
                  color: fg.withAlpha(165),
                  fontSize: labelSize,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 6),
            ],
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.contain,
                  alignment: Alignment.centerLeft,
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
                          letterSpacing: 1.6,
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
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _tick?.cancel();
    _controlsHideTimer?.cancel();
    if (_alwaysOn) {
      WakelockPlus.disable();
    }
    unawaited(ScreenBrightness.instance.resetApplicationScreenBrightness());
    SystemChrome.setPreferredOrientations([]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = _darkTheme ? Colors.black : Colors.white;
    final fg = _darkTheme ? Colors.white : Colors.black;
    final cardBg = _darkTheme
        ? Colors.white.withAlpha(20)
        : Colors.black.withAlpha(20);
    final cardBorder = _darkTheme
        ? Colors.white.withAlpha(45)
        : Colors.black.withAlpha(45);

    return Scaffold(
      backgroundColor: bg,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onScreenTap,
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: Center(
                  child: AnimatedPadding(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    padding: EdgeInsets.fromLTRB(
                      12,
                      _showControls ? 120 : 12,
                      12,
                      _showControls ? 70 : 12,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: cardBorder, width: 1.6),
                      ),
                      child: _mode == FullscreenFocusMode.clock
                          ? _buildClockDisplay(fg, immersive: !_showControls)
                          : (_mode == FullscreenFocusMode.timer
                                ? _buildTimerLikeDisplay(
                                    fg,
                                    immersive: !_showControls,
                                    label: 'REMAINING',
                                    value: _timerText,
                                  )
                                : _buildTimerLikeDisplay(
                                    fg,
                                    immersive: !_showControls,
                                    label: 'ELAPSED',
                                    value: _stopwatchText,
                                  )),
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
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                _onControlInteraction();
                                Navigator.of(context).pop();
                              },
                              icon: Icon(Icons.close, color: fg),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                Text(
                                  'Always On',
                                  style: TextStyle(color: fg, fontSize: 12),
                                ),
                                Switch(
                                  value: _alwaysOn,
                                  onChanged: (val) async {
                                    _onControlInteraction();
                                    setState(() => _alwaysOn = val);
                                    if (val) {
                                      await WakelockPlus.enable();
                                    } else {
                                      await WakelockPlus.disable();
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () {
                                _onControlInteraction();
                                setState(() => _darkTheme = !_darkTheme);
                                widget.onThemeChanged?.call(_darkTheme);
                              },
                              icon: Icon(
                                _darkTheme ? Icons.light_mode : Icons.dark_mode,
                                color: fg,
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              tooltip: _dimBrightness
                                  ? 'Disable Dim'
                                  : 'Dim Brightness',
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
                                    ? Icons.brightness_2
                                    : Icons.brightness_6,
                                color: fg,
                              ),
                            ),
                            const SizedBox(width: 4),
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
                                    ? Icons.stay_current_landscape
                                    : Icons.screen_rotation_alt,
                                color: fg,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  _onControlInteraction();
                                  setState(
                                    () => _mode = FullscreenFocusMode.clock,
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: fg,
                                  side: BorderSide(color: fg),
                                  backgroundColor:
                                      _mode == FullscreenFocusMode.clock
                                      ? fg.withAlpha(35)
                                      : Colors.transparent,
                                ),
                                child: const Text('SpeakClock'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  _onControlInteraction();
                                  setState(
                                    () => _mode = FullscreenFocusMode.timer,
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: fg,
                                  side: BorderSide(color: fg),
                                  backgroundColor:
                                      _mode == FullscreenFocusMode.timer
                                      ? fg.withAlpha(35)
                                      : Colors.transparent,
                                ),
                                child: const Text('Timer'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  _onControlInteraction();
                                  setState(
                                    () => _mode = FullscreenFocusMode.moduleC,
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: fg,
                                  side: BorderSide(color: fg),
                                  backgroundColor:
                                      _mode == FullscreenFocusMode.moduleC
                                      ? fg.withAlpha(35)
                                      : Colors.transparent,
                                ),
                                child: const Text('Stopwatch'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          _mode == FullscreenFocusMode.clock
                              ? 'Speaking Clock'
                              : (_mode == FullscreenFocusMode.timer
                                    ? (_timerRunning
                                          ? 'Timer Running'
                                          : 'Timer Idle')
                                    : (_stopwatchRunning
                                          ? 'Stopwatch Running'
                                          : 'Stopwatch Paused')),
                          style: TextStyle(
                            color: fg.withAlpha(180),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
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
