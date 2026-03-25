import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class FullscreenStopwatchView extends StatefulWidget {
  final String Function() stopwatchTextBuilder;
  final bool Function() isRunningBuilder;
  final bool initialDarkTheme;
  final bool initialDimBrightness;
  final bool initialForceLandscape;
  final ValueChanged<bool>? onThemeChanged;
  final ValueChanged<bool>? onDimBrightnessChanged;
  final ValueChanged<bool>? onForceLandscapeChanged;

  const FullscreenStopwatchView({
    super.key,
    required this.stopwatchTextBuilder,
    required this.isRunningBuilder,
    required this.initialDarkTheme,
    required this.initialDimBrightness,
    required this.initialForceLandscape,
    this.onThemeChanged,
    this.onDimBrightnessChanged,
    this.onForceLandscapeChanged,
  });

  @override
  State<FullscreenStopwatchView> createState() =>
      _FullscreenStopwatchViewState();
}

class _FullscreenStopwatchViewState extends State<FullscreenStopwatchView> {
  Timer? _tick;
  Timer? _controlsHideTimer;
  bool _darkTheme = true;
  bool _alwaysOn = true;
  bool _forceLandscape = false;
  bool _dimBrightness = false;
  bool _showControls = true;
  String _elapsedText = '00:00';
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _darkTheme = widget.initialDarkTheme;
    _dimBrightness = widget.initialDimBrightness;
    _forceLandscape = widget.initialForceLandscape;

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    unawaited(WakelockPlus.enable());
    unawaited(_applyBrightness());
    unawaited(_applyOrientation());
    _restartControlsHideTimer();
    _refresh();
    _tick = Timer.periodic(const Duration(milliseconds: 150), (_) {
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
      _elapsedText = widget.stopwatchTextBuilder();
      _running = widget.isRunningBuilder();
    });
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
                      child: Column(
                        children: [
                          Text(
                            'ELAPSED',
                            style: TextStyle(
                              color: fg.withAlpha(165),
                              fontSize: _showControls ? 13 : 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: SizedBox(
                              width: double.infinity,
                              child: FittedBox(
                                fit: BoxFit.contain,
                                alignment: Alignment.center,
                                child: Text(
                                  _elapsedText,
                                  style: TextStyle(
                                    color: fg,
                                    fontSize: _showControls ? 110 : 140,
                                    fontWeight: FontWeight.w800,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
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
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          _running ? 'Stopwatch Running' : 'Stopwatch Paused',
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
