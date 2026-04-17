import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Holographic text widget — thin weight, wide letter-spacing, glow shadows.
class HoloText extends StatelessWidget {
  const HoloText(
    this.text, {
    super.key,
    this.glowColor = const Color(0xFF00D4FF),
    this.fontSize = 14,
    this.fontWeight = FontWeight.w300,
    this.letterSpacing = 3.0,
    this.textAlign = TextAlign.center,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final Color glowColor;
  final double fontSize;
  final FontWeight fontWeight;
  final double letterSpacing;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        color: Colors.white.withValues(alpha: 0.92),
        shadows: [
          Shadow(color: glowColor.withValues(alpha: 0.9), blurRadius: 8),
          Shadow(color: glowColor.withValues(alpha: 0.5), blurRadius: 20),
          Shadow(color: glowColor.withValues(alpha: 0.25), blurRadius: 40),
        ],
      ),
    );
  }
}

/// "// LABEL //" formatted holographic header.
class HoloHeader extends StatelessWidget {
  const HoloHeader(this.label, {super.key, this.glowColor = const Color(0xFF00D4FF)});

  final String label;
  final Color glowColor;

  @override
  Widget build(BuildContext context) {
    return HoloText(
      '// \$label //',
      glowColor: glowColor,
      fontSize: 11,
      fontWeight: FontWeight.w300,
      letterSpacing: 4.0,
    );
  }
}
