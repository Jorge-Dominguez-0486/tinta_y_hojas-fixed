import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tinta_y_hojas/nucleo/configuracion/constantes.dart';

class TintaYHojasTheme {
  TintaYHojasTheme._();

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Constantes.beige,
      colorScheme: ColorScheme.light(
        primary: Constantes.vinoPrimary,
        secondary: Constantes.vinoSoft,
        surface: Constantes.cream,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Constantes.textDark,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Constantes.textDark,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Constantes.textDark,
        ),
        headlineLarge: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Constantes.textDark,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Constantes.textDark,
        ),
        titleLarge: GoogleFonts.playfairDisplay(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Constantes.textDark,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Constantes.textDark,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Constantes.textDark,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: Constantes.textDark,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: Constantes.textDark,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          color: Constantes.textDark,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Constantes.textDark,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          color: Constantes.textDark,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Constantes.vinoDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Constantes.vinoPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Constantes.vinoPrimary,
          side: const BorderSide(color: Constantes.vinoPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Constantes.vinoSoft,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Constantes.cream,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Constantes.vinoSoft),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Constantes.vinoSoft.withAlpha(128)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Constantes.vinoPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: GoogleFonts.inter(color: Constantes.textDark),
        hintStyle: GoogleFonts.inter(color: Constantes.textDark.withAlpha(128)),
      ),
      cardTheme: CardThemeData(
        color: Constantes.cream,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Constantes.cream,
        selectedItemColor: Constantes.vinoPrimary,
        unselectedItemColor: Constantes.vinoSoft,
      ),
    );
  }
}
