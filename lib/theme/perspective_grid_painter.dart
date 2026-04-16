import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'si_colors.dart';

class PerspectiveGridPainter extends CustomPainter {
  final double animationValue;
  const PerspectiveGridPainter({this.animationValue = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final vp = Offset(size.width / 2, size.height * 0.4);
    const lineCount = 20;
    final horizonY = size.height * 0.4;

    final faintPaint = Paint()
      ..color = SiColors.outline.withAlpha(60)
      ..strokeWidth = 0.5;

    final glowPaint = Paint()
      ..color = SiColors.primary.withAlpha(20)
      ..strokeWidth = 1;

    for (int i = 1; i <= lineCount; i++) {
      final t = i / lineCount;
      final y = horizonY + (size.height - horizonY) * math.pow(t, 1.5);
      canvas.drawLine(Offset(0, y), Offset(size.width, y),
          (i % 5 == 0) ? glowPaint : faintPaint);
    }

    const vLineCount = 16;
    for (int i = 0; i <= vLineCount; i++) {
      final x = size.width * i / vLineCount;
      canvas.drawLine(Offset(x, size.height), vp,
          (i % 4 == 0) ? glowPaint : faintPaint);
    }

    final horizonPaint = Paint()
      ..color = SiColors.primary.withAlpha(40)
      ..strokeWidth = 1
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawLine(
        Offset(0, horizonY), Offset(size.width, horizonY), horizonPaint);
  }

  @override
  bool shouldRepaint(PerspectiveGridPainter old) =>
      old.animationValue != animationValue;
}
