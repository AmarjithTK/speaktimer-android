import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A clean, minimal circular progress ring for the timer display.
///
/// Removed: outer shadow glow, knob highlight/specular, gradient sweep.
/// Kept: track ring, progress arc, small dot at arc end.
/// Thinner stroke for a more refined look.
class TimerRing extends StatelessWidget {
  final double progress;
  final Color primary;
  final Color trackColor;
  final double? size;

  const TimerRing({
    super.key,
    required this.progress,
    required this.primary,
    required this.trackColor,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _TimerRingPainter(
          progress: progress,
          primary: primary,
          trackColor: trackColor,
        ),
      ),
    );
  }
}

class _TimerRingPainter extends CustomPainter {
  final double progress;
  final Color primary;
  final Color trackColor;

  const _TimerRingPainter({
    required this.progress,
    required this.primary,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Thinner, more refined stroke
    final strokeWidth = math.max(size.width * 0.022, 3.0);
    final halfStroke = strokeWidth / 2;
    final rect = Rect.fromLTWH(
      halfStroke,
      halfStroke,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    // Track ring (subtle background)
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, trackPaint);

    if (progress > 0) {
      // Progress arc (solid accent color, no gradient)
      final sweep = math.pi * 2 * progress;
      final progressPaint = Paint()
        ..color = primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, -math.pi / 2, sweep, false, progressPaint);

      // Small dot at arc end
      final angle = -math.pi / 2 + sweep;
      final radius = rect.width / 2;
      final center = rect.center;
      final knobPos = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      canvas.drawCircle(knobPos, strokeWidth * 0.8, Paint()..color = primary);
    }
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.primary != primary;
  }
}
