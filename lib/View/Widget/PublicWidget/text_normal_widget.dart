import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget textNormal(
  text,
  color,
  size,
  weight, {
  bool center = false,
  bool multi = false,
  int numOfRow = 0,
  bool bgcolor = false,
  int? maxLines,
  TextOverflow? overflow,
  TextDirection? textDirection,
  TextAlign? textAlign,
}) {
  return Text(
    text ?? "",
    textAlign: center ? TextAlign.center : null,
    maxLines: multi
        ? (numOfRow > 0 ? numOfRow : null)
        : (maxLines ?? 2), // ✅ المرونة في عدد الأسطر
    overflow: overflow ?? TextOverflow.ellipsis, // ✅ يستخدم ellipsis كـ default
    style: GoogleFonts.ibmPlexSansArabic(
      decoration: TextDecoration.none,
      backgroundColor: bgcolor ? Colors.black12 : null,
      color: color,
      fontSize: size,
      fontWeight: weight,
    ),
  );
}
