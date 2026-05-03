import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SashTheme {
  // Brand Colors
  static const Color primary = Color(0xFF6366F1); // Sash Indigo
  static const Color accent = Color(0xFF10B981);  // Success Emerald
  static const Color error = Color(0xFFF43F5E);   // Warning Rose
  
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Colors.white;

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: backgroundDark,
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ).copyWith(
        bodyLarge: GoogleFonts.inter(textStyle: const TextStyle(fontSize: 16, color: Colors.white)),
        bodyMedium: GoogleFonts.inter(textStyle: const TextStyle(fontSize: 14, color: Colors.white70)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: backgroundLight,
      cardTheme: CardThemeData(
        color: surfaceLight,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Color(0xFF1E293B),
          ),
        ),
      ).copyWith(
        bodyLarge: GoogleFonts.inter(textStyle: const TextStyle(fontSize: 16, color: Color(0xFF1E293B))),
        bodyMedium: GoogleFonts.inter(textStyle: const TextStyle(fontSize: 14, color: Color(0xFF475569))),
      ),
    );
  }
}
