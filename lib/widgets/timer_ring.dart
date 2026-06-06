import 'dart:math' as math;

import 'package:flutter/material.dart';

/// An animated circular progress ring for the timer display.
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
    final strokeWidth = math.max(size.width * 0.028, 7.0);
    final halfStroke = strokeWidth / 2;
    final rect = Rect.fromLTWH(
      halfStroke,
      halfStroke,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    // Outer shadow ring
    final shadowPaint = Paint()
      ..color = primary.withAlpha(25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 4;
    canvas.drawArc(rect, 0, math.pi * 2, false, shadowPaint);

    // Track ring
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, trackPaint);

    if (progress > 0) {
      // Progress arc with gradient effect
      final sweep = math.pi * 2 * progress;
      final progressPaint = Paint()
        ..shader = SweepGradient(
          center: Alignment.center,
          startAngle: -math.pi / 2,
          endAngle: -math.pi / 2 + sweep,
          colors: [
            primary.withAlpha(180),
            primary,
            primary.withAlpha(230),
          ],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, -math.pi / 2, sweep, false, progressPaint);

      // Knob glow
      final angle = -math.pi / 2 + sweep;
      final radius = rect.width / 2;
      final center = rect.center;
      final knobPos = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      final glowPaint = Paint()
        ..color = primary.withAlpha(40)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(knobPos, strokeWidth * 1.5, glowPaint);

      // Knob
      canvas.drawCircle(knobPos, strokeWidth * 0.9, Paint()..color = primary);

      // Knob highlight
      final highlightPaint = Paint()
        ..color = Colors.white.withAlpha(100);
      canvas.drawCircle(
        Offset(knobPos.dx - strokeWidth * 0.2, knobPos.dy - strokeWidth * 0.2),
        strokeWidth * 0.3,
        highlightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.primary != primary;
  }
}
