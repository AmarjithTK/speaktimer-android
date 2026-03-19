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
  bool _alwaysOn = false;
  bool _showTimer = false;
  String _clockText = '';
  String _timerText = '00:00';
  bool _timerRunning = false;

  @override
  void initState() {
    super.initState();
    _showTimer = widget.startInTimerMode;

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
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
    final value = _showTimer ? _timerText : _clockText;

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
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: fg,
                  fontSize: _showTimer ? 110 : 80,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0,
                ),
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