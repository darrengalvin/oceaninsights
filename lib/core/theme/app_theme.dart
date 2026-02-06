import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Below the Surface App Theme
/// 
/// Dark ocean theme - immersive, calm, professional
/// Designed for military personnel in confined/low-light environments
class AppTheme {
  AppTheme._();
  
  // ============================================
  // DARK OCEAN COLOUR PALETTE
  // ============================================
  
  // Primary depths - dark to light
  static const Color abyssBlack = Color(0xFF0A0E14);      // Deepest - true dark
  static const Color deepOcean = Color(0xFF0D1520);       // Main background
  static const Color midnightBlue = Color(0xFF131D2A);    // Cards/elevated surfaces
  static const Color slateDepth = Color(0xFF1A2634);      // Lighter cards
  static const Color steelBlue = Color(0xFF243447);       // Borders, dividers
  
  // Accent colours - bioluminescent feel
  static const Color aquaGlow = Color(0xFF00D9C4);        // Primary accent - cyan/teal
  static const Color deepTeal = Color(0xFF0891B2);        // Secondary accent
  static const Color softCyan = Color(0xFF67E8F9);        // Highlights
  static const Color warmAmber = Color(0xFFFBBF24);       // Warnings, quotes
  static const Color coralPink = Color(0xFFFB7185);       // Alerts, affirmations
  static const Color seaGreen = Color(0xFF34D399);        // Success, positive
  
  // Text colours
  static const Color textBright = Color(0xFFF1F5F9);      // Primary text (almost white)
  static const Color textLight = Color(0xFFCBD5E1);       // Secondary text
  static const Color textMuted = Color(0xFF64748B);       // Muted/disabled text
  static const Color textDim = Color(0xFF475569);         // Very subtle text
  
  // Mood colours (for assessments) - softer versions
  static const Color moodExcellent = Color(0xFF34D399);   // Green
  static const Color moodGood = Color(0xFF5EEAD4);        // Teal
  static const Color moodOkay = Color(0xFFFCD34D);        // Yellow
  static const Color moodLow = Color(0xFFFB923C);         // Orange
  static const Color moodStruggling = Color(0xFFFB7185);  // Pink/coral
  
  // Functional
  static const Color cardBorder = Color(0xFF1E3A5F);      // Subtle blue border
  static const Color divider = Color(0xFF1E293B);         // Divider lines
  
  static ThemeData get darkTheme {
    final textTheme = GoogleFonts.interTextTheme();
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Colour scheme
      colorScheme: const ColorScheme.dark(
        primary: aquaGlow,
        secondary: deepTeal,
        surface: midnightBlue,
        error: coralPink,
        onPrimary: abyssBlack,
        onSecondary: textBright,
        onSurface: textBright,
        onError: textBright,
      ),
      
      // Scaffold - deep ocean background
      scaffoldBackgroundColor: deepOcean,
      
      // App Bar - transparent, blends with background
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: textBright,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textBright,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(
          color: textLight,
          size: 24,
        ),
      ),
      
      // Cards - elevated dark surfaces
      cardTheme: CardThemeData(
        elevation: 0,
        color: midnightBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: cardBorder,
            width: 1,
          ),
        ),
      ),
      
      // Elevated Buttons - glowing accent
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: aquaGlow,
          foregroundColor: abyssBlack,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
      
      // Outlined Buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: aquaGlow,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          side: const BorderSide(color: aquaGlow, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
      
      // Text Buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: aquaGlow,
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: slateDepth,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: aquaGlow, width: 2),
        ),
        hintStyle: GoogleFonts.inter(
          color: textMuted,
          fontSize: 16,
        ),
        labelStyle: GoogleFonts.inter(
          color: textLight,
          fontSize: 16,
        ),
      ),
      
      // Text Theme - Inter for clean readability
      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: textBright,
          letterSpacing: -1.0,
          height: 1.2,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 30,
          fontWeight: FontWeight.w600,
          color: textBright,
          letterSpacing: -0.8,
          height: 1.2,
        ),
        displaySmall: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textBright,
          letterSpacing: -0.5,
          height: 1.3,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textBright,
          letterSpacing: -0.4,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textBright,
          letterSpacing: -0.3,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textBright,
          letterSpacing: -0.2,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textLight,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textLight,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textLight,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textMuted,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textBright,
          letterSpacing: 0.1,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textLight,
        ),
      ),
      
      // Divider
      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
        space: 1,
      ),
      
      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: midnightBlue,
        selectedItemColor: aquaGlow,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      
      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: midnightBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textBright,
        ),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 16,
          color: textLight,
        ),
      ),
      
      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: slateDepth,
        contentTextStyle: GoogleFonts.inter(
          color: textBright,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: aquaGlow,
        linearTrackColor: steelBlue,
        circularTrackColor: steelBlue,
      ),
      
      // Slider
      sliderTheme: SliderThemeData(
        activeTrackColor: aquaGlow,
        inactiveTrackColor: steelBlue,
        thumbColor: aquaGlow,
        overlayColor: aquaGlow.withOpacity(0.2),
      ),
      
      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return aquaGlow;
          }
          return textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return aquaGlow.withOpacity(0.3);
          }
          return steelBlue;
        }),
      ),
      
      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return aquaGlow;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(abyssBlack),
        side: const BorderSide(color: textMuted, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      
      // Radio
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return aquaGlow;
          }
          return textMuted;
        }),
      ),
      
      // List Tile
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        iconColor: textLight,
        textColor: textBright,
      ),
      
      // Icon
      iconTheme: const IconThemeData(
        color: textLight,
        size: 24,
      ),
    );
  }
  
  // Keep reference to key colours for use in widgets
  static const Color primaryAccent = aquaGlow;
  static const Color background = deepOcean;
  static const Color cardBackground = midnightBlue;
  static const Color cardBackgroundLight = slateDepth;
}
