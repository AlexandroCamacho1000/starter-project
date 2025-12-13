// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemes {
  // Colors from Figma design
  static const Color primaryBlue = Color(0xFF007AFF);
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color cardGray = Color(0xFFF2F2F7);
  static const Color textBlack = Color(0xFF1D1D1F);
  static const Color textGray = Color(0xFF8E8E93);
  static const Color borderLight = Color(0xFFC7C7CC);

  // Light theme matching Figma design
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: false, // Keep as false for Material 2 compatibility
    brightness: Brightness.light,
    
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: backgroundWhite,
    
    // App Bar styling
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundWhite,
      elevation: 0.5,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textBlack,
        letterSpacing: -0.5,
      ),
      iconTheme: const IconThemeData(color: textBlack),
      actionsIconTheme: const IconThemeData(color: primaryBlue),
    ),
    
    // Text theme using Inter font - UPDATED PROPERTY NAMES
    textTheme: TextTheme(
      // Old: headline5 → New: headlineSmall
      headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textBlack,
      ),
      // Old: headline6 → New: titleLarge
      titleLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textBlack,
      ),
      // Old: bodyText1 → New: bodyLarge
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textBlack,
        height: 1.4,
      ),
      // Old: bodyText2 → New: bodyMedium
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textGray,
        height: 1.4,
      ),
      // Old: caption → New: bodySmall
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textGray,
      ),
      // Old: button → New: labelLarge
      labelLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    
    // Card styling
    cardTheme: const CardThemeData(
      color: cardGray,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      margin: EdgeInsets.only(bottom: 16),
    ),
    
    // Button styling
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Input field styling
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderLight, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderLight, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
    ),
    
    // Bottom navigation bar
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: backgroundWhite,
      selectedItemColor: primaryBlue,
      unselectedItemColor: textGray,
      selectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      elevation: 2,
      type: BottomNavigationBarType.fixed,
    ),
  );
}