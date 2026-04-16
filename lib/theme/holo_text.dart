import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'si_colors.dart';

class HoloText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final TextAlign textAlign;

  const HoloText(
    this.text, {
    super.key,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w700,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: SiColors.textGlow,
        letterSpacing: fontSize > 20 ? 2.0 : 1.0,
        shadows: [
          Shadow(color: SiColors.primary.withAlpha(180), blurRadius: 8),
          Shadow(color: SiColors.primary.withAlpha(80), blurRadius: 20),
        ],
      ),
    );
  }
}
