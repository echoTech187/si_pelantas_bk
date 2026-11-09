import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BkAcademicColors {
  static const Color slateBackground = Color(0xFF0F172A);
  static const Color slateSurface = Color(0xFF1E293B);
  static const Color emeraldAccent = Color(0xFF10B981);
  static const Color skyAccent = Color(0xFF38BDF8);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color crimsonAlert = Color(0xFFEF4444);
  static const Color textPrimary = Color(0xFFF8FAFC);
}

class BkAcademicTheme {
  static ThemeData get theme {
    final baseText = GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: BkAcademicColors.slateBackground,
      colorScheme: const ColorScheme.dark(
        primary: BkAcademicColors.emeraldAccent,
        secondary: BkAcademicColors.skyAccent,
        surface: BkAcademicColors.slateSurface,
        error: BkAcademicColors.crimsonAlert,
      ),
      textTheme: baseText,
      appBarTheme: AppBarTheme(
        backgroundColor: BkAcademicColors.slateSurface,
        elevation: 0,
        titleTextStyle: GoogleFonts.rajdhani(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          color: BkAcademicColors.emeraldAccent,
        ),
      ),
      cardTheme: CardThemeData(
        color: BkAcademicColors.slateSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: BkAcademicColors.emeraldAccent.withValues(alpha: 0.28), width: 1.2),
        ),
      ),
    );
  }
}
