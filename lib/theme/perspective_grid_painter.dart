import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Minority Report-style receding perspective grid.
class PerspectiveGridPainter extends CustomPainter {
  const PerspectiveGridPainter({
    this.lineColor = const Color(0xFF00D4FF),
    this.lineOpacity = 0.06,
    this.horizonGlowOpacity = 0.12,
    this.verticalLines = 14,
    this.horizontalLines = 16,
  });

  final Color lineColor;
  final double lineOpacity;
  final double horizonGlowOpacity;
  final int verticalLines;
  final int horizontalLines;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor.withValues(alpha: lineOpacity)
      ..strokeWidth = 0.7
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final horizonY = size.height * 0.35;

    final halfSpread = size.width * 0.65;
    for (int i = 0; i <= verticalLines; i++) {
      final t = i / verticalLines;
      final bottomX = cx - halfSpread + t * halfSpread * 2;
      canvas.drawLine(Offset(cx, horizonY), Offset(bottomX, size.height), paint);
    }

    for (int i = 0; i < horizontalLines; i++) {
      final t = math.pow((i + 1) / horizontalLines, 2.2).toDouble();
      final y = horizonY + t * (size.height - horizonY);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    final glowPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, horizonY),
        Offset(0, horizonY + 100),
        [lineColor.withValues(alpha: horizonGlowOpacity), Colors.transparent],
      );
    canvas.drawRect(Rect.fromLTWH(0, horizonY - 2, size.width, 104), glowPaint);
  }

  @override
  bool shouldRepaint(PerspectiveGridPainter old) =>
      old.lineOpacity != lineOpacity;
}
