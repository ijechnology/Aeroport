// lib/config/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlue = Color(
    0xFF0D47A1,
  ); // Biru utama (AppBar, tombol)
  static const Color lightBlue = Color(0xFFE3F2FD); // Biru muda (Card)
  static const Color backgroundGray = Color(0xFFF4F6FA); // Latar belakang utama
  static const Color white = Colors.white;
  static const Color darkText = Color(0xFF333333);
  static const Color successGreen = Color(0xFF00C853);
  static const Color warningYellow = Color(0xFFFFD43B);
  static const Color dangerRed = Color(0xFFD32F2F);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: backgroundGray,
      splashColor: primaryBlue.withOpacity(0.1),
      highlightColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: white,
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: lightBlue,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: darkText,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: darkText,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: darkText,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400,
          fontSize: 12,
          color: Color(0xFF6E6E6E),
        ),
      ),
    );
  }
}
