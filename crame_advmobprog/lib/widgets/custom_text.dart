import 'package:flutter/material.dart';

/// A reusable text widget providing standard typography styling.
class CustomText extends StatelessWidget {
  const CustomText({
    super.key,
    required this.text,
    this.fontSize = 12.0,
    this.fontFamily = 'Poppins',
    this.fontWeight = FontWeight.normal,
    this.textAlign = TextAlign.left,
    this.letterSpacing = 0.0,
    this.fontStyle = FontStyle.normal,
    this.color,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final double fontSize;
  final String fontFamily;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final double letterSpacing;
  final FontStyle fontStyle;
  final Color? color;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      style: TextStyle(
        fontFamily: fontFamily,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
        color: color,
      ),
    );
  }
}

