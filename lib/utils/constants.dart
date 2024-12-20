import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const primaryColor = Color(0xFF22A45D);
  static const secondaryColor = Color(0xFF31B9CC);
  static const backgroundColor = Color(0xFFF8F9FB);
  static const textColor = Color(0xFF1A1D1E);

  static TextStyle get headline1 => GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textColor,
      );

  static TextStyle get subtitle1 => GoogleFonts.poppins(
        fontSize: 16,
        color: Colors.grey[600],
      );
}
