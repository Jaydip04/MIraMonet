import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WantText2 extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color textColor;
  final TextAlign? textAlign;
  final TextOverflow textOverflow;
  WantText2({
    required this.text,
    required this.fontSize,
    required this.fontWeight,
    required this.textColor,
    this.textAlign,
    this.textOverflow = TextOverflow.ellipsis,
  });
  @override
  Widget build(BuildContext context) {
    return Text(
      overflow: textOverflow,
      textAlign: textAlign ?? TextAlign.start,
      text,
      style: GoogleFonts.poppins(
          color: textColor,
          fontSize: fontSize,
          fontWeight: fontWeight,
          letterSpacing: 1.5),
    );
  }
}
