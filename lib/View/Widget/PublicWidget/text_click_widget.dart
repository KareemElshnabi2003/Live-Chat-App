import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget textClick(text, decoration, onPress, color, size) {
  return InkWell(
    onTap: onPress,
    child: Text(
      text,
      style: GoogleFonts.ibmPlexSansArabic(
          decoration: decoration == true ? TextDecoration.underline : null,
          decorationColor: color,
          color: color,
          fontSize: size,
          fontWeight: FontWeight.w500),
    ),
  );
}