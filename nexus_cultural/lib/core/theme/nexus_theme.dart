import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NexusColors {
  // Primary Colombian Terracotta
  static const Color primary = Color(0xFF994422);
  static const Color primaryContainer = Color(0xFFB85C38);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFFFFFFF);
  static const Color primaryFixed = Color(0xFFFFDBCF);
  static const Color primaryFixedDim = Color(0xFFFFB59A);

  // Colombian Forest / Fair Trade Green
  static const Color greenProtection = Color(0xFF3B6753);
  static const Color greenProtectionContainer = Color(0xFFD5E8DC);
  static const Color onGreenProtection = Color(0xFFFFFFFF);
  static const Color greenDark = Color(0xFF24503E);

  // Warm Heritage Surfaces
  static const Color surfaceBackground = Color(0xFFFDF8F5);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceDim = Color(0xFFF7ECE5);
  static const Color surfaceContainer = Color(0xFFFAE4D7);
  static const Color surfaceHighlight = Color(0xFFFFF1EA);

  // High Contrast Text for Elderly Readability
  static const Color textPrimary = Color(0xFF241912);
  static const Color textSecondary = Color(0xFF55433C);
  static const Color textTertiary = Color(0xFF7D675E);

  // Borders & Accents
  static const Color border = Color(0xFFDBC1B8);
  static const Color borderLight = Color(0xFFF4DED2);
  static const Color goldAccent = Color(0xFFC07D33);
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
}

class NexusAccessibility {
  // Strict accessibility constraints for older adults
  static const double minTouchTarget = 56.0;
  static const double minFontSize = 16.0;
  static const double borderRadius = 16.0;
  static const double cardElevation = 1.0;
}

class NexusTheme {
  static ThemeData get lightTheme {
    final textTheme = TextTheme(
      headlineLarge: GoogleFonts.playfairDisplay(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: NexusColors.textPrimary,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.playfairDisplay(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: NexusColors.textPrimary,
        height: 1.25,
      ),
      headlineSmall: GoogleFonts.playfairDisplay(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: NexusColors.textPrimary,
        height: 1.3,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: NexusColors.textPrimary,
        height: 1.3,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: NexusColors.textPrimary,
        height: 1.35,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.normal,
        color: NexusColors.textPrimary,
        height: 1.45,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: NexusColors.textSecondary,
        height: 1.45,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: NexusColors.onPrimary,
        height: 1.2,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: NexusColors.textSecondary,
        height: 1.2,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: NexusColors.primary,
        onPrimary: NexusColors.onPrimary,
        primaryContainer: NexusColors.primaryContainer,
        onPrimaryContainer: NexusColors.onPrimaryContainer,
        secondary: NexusColors.greenProtection,
        onSecondary: NexusColors.onGreenProtection,
        secondaryContainer: NexusColors.greenProtectionContainer,
        onSecondaryContainer: NexusColors.greenDark,
        surface: NexusColors.surfaceBackground,
        onSurface: NexusColors.textPrimary,
        error: NexusColors.error,
        onError: Colors.white,
        errorContainer: NexusColors.errorContainer,
        onErrorContainer: NexusColors.error,
        outline: NexusColors.border,
      ),
      scaffoldBackgroundColor: NexusColors.surfaceBackground,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: NexusColors.surfaceBackground,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 1,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: NexusColors.textPrimary,
        ),
        iconTheme: const IconThemeData(
          color: NexusColors.primary,
          size: 28,
        ),
      ),
      cardTheme: CardThemeData(
        color: NexusColors.surfaceCard,
        elevation: NexusAccessibility.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
          side: const BorderSide(color: NexusColors.border, width: 1.2),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: NexusColors.primary,
          foregroundColor: NexusColors.onPrimary,
          minimumSize: const Size(double.infinity, NexusAccessibility.minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
          elevation: 2,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: NexusColors.primary,
          minimumSize: const Size(double.infinity, NexusAccessibility.minTouchTarget),
          side: const BorderSide(color: NexusColors.border, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
          borderSide: const BorderSide(color: NexusColors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
          borderSide: const BorderSide(color: NexusColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
          borderSide: const BorderSide(color: NexusColors.primary, width: 2.2),
        ),
        hintStyle: const TextStyle(
          color: NexusColors.textTertiary,
          fontSize: 16,
        ),
        labelStyle: const TextStyle(
          color: NexusColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
