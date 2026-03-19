import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class FullscreenFocusView extends StatefulWidget {
  final String Function() clockTextBuilder;
  final String Function() timerTextBuilder;
  final bool Function() isTimerRunningBuilder;
  final bool startInTimerMode;

  const FullscreenFocusView({
    super.key,
    required this.clockTextBuilder,
    required this.timerTextBuilder,
    required this.isTimerRunningBuilder,
    required this.startInTimerMode,
  });

  @override
  State<FullscreenFocusView> createState() => _FullscreenFocusViewState();
}

class _FullscreenFocusViewState extends State<FullscreenFocusView> {
  Timer? _tick;
  bool _darkTheme = true;
  bool _alwaysOn = true;
  bool _showTimer = false;
  String _clockText = '';
  String _timerText = '00:00';
  bool _timerRunning = false;

  @override
  void initState() {
    super.initState();
    _showTimer = widget.startInTimerMode;

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    unawaited(WakelockPlus.enable());
    _refresh();
    _tick = Timer.periodic(const Duration(milliseconds: 120), (_) {
      _refresh();
    });
  }

  void _refresh() {
    if (!mounted) return;
    setState(() {
      _clockText = widget.clockTextBuilder();
      _timerText = widget.timerTextBuilder();
      _timerRunning = widget.isTimerRunningBuilder();
    });
  }

  (String, String?) _splitClockDisplay(String value) {
    if (value.contains('.')) {
      final parts = value.split('.');
      return (parts.first, parts.length > 1 ? parts[1] : null);
    }
    return (value, null);
  }

  (String, String) _splitTimer(String value) {
    final parts = value.split(':');
    if (parts.length == 2) {
      return (parts[0], parts[1]);
    }
    return ('00', '00');
  }

  Widget _buildTimerDisplay(Color fg) {
    final timerParts = _splitTimer(_timerText);
    final mins = timerParts.$1;
    final secs = timerParts.$2;

    return Column(
      children: [
        Text(
          'REMAINING',
          style: TextStyle(
            color: fg.withAlpha(165),
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FittedBox(
            fit: BoxFit.scaleDown,
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
                      fontSize: 112,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                  TextSpan(
                    text: ':',
                    style: TextStyle(
                      fontSize: 88,
                      fontWeight: FontWeight.w700,
                      color: fg.withAlpha(190),
                      height: 1,
                    ),
                  ),
                  TextSpan(
                    text: secs,
                    style: const TextStyle(
                      fontSize: 112,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClockDisplay(Color fg) {
    final clockParts = _splitClockDisplay(_clockText);
    final mainTime = clockParts.$1;
    final millis = clockParts.$2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CURRENT TIME',
          style: TextStyle(
            color: fg.withAlpha(165),
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  mainTime,
                  style: TextStyle(
                    color: fg,
                    fontSize: 88,
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
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _tick?.cancel();
    if (_alwaysOn) {
      WakelockPlus.disable();
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = _darkTheme ? Colors.black : Colors.white;
    final fg = _darkTheme ? Colors.white : Colors.black;
    final cardBg = _darkTheme ? Colors.white.withAlpha(20) : Colors.black.withAlpha(20);
    final cardBorder = _darkTheme ? Colors.white.withAlpha(45) : Colors.black.withAlpha(45);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: fg),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text('Always On', style: TextStyle(color: fg, fontSize: 12)),
                      Switch(
                        value: _alwaysOn,
                        onChanged: (val) async {
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
                    onPressed: () => setState(() => _darkTheme = !_darkTheme),
                    icon: Icon(_darkTheme ? Icons.light_mode : Icons.dark_mode, color: fg),
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
                      onPressed: () => setState(() => _showTimer = false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: fg,
                        side: BorderSide(color: fg),
                        backgroundColor: !_showTimer ? fg.withAlpha(35) : Colors.transparent,
                      ),
                      child: const Text('SpeakClock'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _showTimer = true),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: fg,
                        side: BorderSide(color: fg),
                        backgroundColor: _showTimer ? fg.withAlpha(35) : Colors.transparent,
                      ),
                      child: const Text('Timer'),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cardBorder, width: 1.6),
                ),
                child: _showTimer ? _buildTimerDisplay(fg) : _buildClockDisplay(fg),
                          ),
            ),
            const SizedBox(height: 20),
            Text(
              _showTimer
                  ? (_timerRunning ? 'Timer Running' : 'Timer Idle')
                  : 'Speaking Clock',
              style: TextStyle(color: fg.withAlpha(180), fontSize: 16),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}