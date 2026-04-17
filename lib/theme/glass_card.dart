import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Glassmorphism card — blurred backdrop, gradient fill, coloured border.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.borderColor = const Color(0xFF00D4FF),
    this.borderOpacity = 0.20,
    this.borderRadius = 20.0,
    this.blurSigma = 12.0,
    this.padding = const EdgeInsets.all(20),
    this.width,
    this.height,
  });

  final Widget child;
  final Color borderColor;
  final double borderOpacity;
  final double borderRadius;
  final double blurSigma;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.07),
                Colors.white.withValues(alpha: 0.03),
              ],
            ),
            border: Border.all(
              color: borderColor.withValues(alpha: borderOpacity),
              width: 1.0,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
