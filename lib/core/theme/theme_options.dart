import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Theme option with metadata for the theme chooser
class ThemeOption {
  final String id;
  final String name;
  final String tagline;
  final String description;
  final String bestFor;
  final ThemeData themeData;
  final Color previewBackground;
  final Color previewCard;
  final Color previewAccent;
  
  const ThemeOption({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.bestFor,
    required this.themeData,
    required this.previewBackground,
    required this.previewCard,
    required this.previewAccent,
  });
}

/// All available themes for Deep Dive
class ThemeOptions {
  ThemeOptions._();
  
  // ============================================
  // THEME 1: DEEP OCEAN (Current)
  // ============================================
  static final deepOcean = ThemeOption(
    id: 'deep_ocean',
    name: 'Deep Ocean',
    tagline: 'Submarine tech, digital feel',
    description: 'Dark navy with bright cyan accents. Modern and tech-forward.',
    bestFor: 'Modern/techy vibe',
    previewBackground: const Color(0xFF0D1520),
    previewCard: const Color(0xFF131D2A),
    previewAccent: const Color(0xFF00D9C4),
    themeData: _buildTheme(
      background: const Color(0xFF0D1520),
      card: const Color(0xFF131D2A),
      cardLight: const Color(0xFF1A2634),
      border: const Color(0xFF1E3A5F),
      accent: const Color(0xFF00D9C4),
      accentSecondary: const Color(0xFF0891B2),
      textBright: const Color(0xFFF1F5F9),
      textLight: const Color(0xFFCBD5E1),
      textMuted: const Color(0xFF64748B),
    ),
  );
  
  // ============================================
  // THEME 2: MIDNIGHT STEEL
  // ============================================
  static final midnightSteel = ThemeOption(
    id: 'midnight_steel',
    name: 'Midnight Steel',
    tagline: 'Control room, military-grade',
    description: 'Professional and understated. Steel blue with muted gold accents.',
    bestFor: 'Professional, understated',
    previewBackground: const Color(0xFF0F0F12),
    previewCard: const Color(0xFF18181C),
    previewAccent: const Color(0xFF8B9DC3),
    themeData: _buildTheme(
      background: const Color(0xFF0F0F12),
      card: const Color(0xFF18181C),
      cardLight: const Color(0xFF1F1F24),
      border: const Color(0xFF2A2A32),
      accent: const Color(0xFF8B9DC3),
      accentSecondary: const Color(0xFFC9A87C),
      textBright: const Color(0xFFE8E8ED),
      textLight: const Color(0xFFB8B8C0),
      textMuted: const Color(0xFF6B6B75),
    ),
  );
  
  // ============================================
  // THEME 3: ARCTIC DEPTHS
  // ============================================
  static final arcticDepths = ThemeOption(
    id: 'arctic_depths',
    name: 'Arctic Depths',
    tagline: 'Clinical, calm, ice under surface',
    description: 'Clean and minimal. Silver/ice blue tones for clarity.',
    bestFor: 'Clean, minimal feel',
    previewBackground: const Color(0xFF0A1014),
    previewCard: const Color(0xFF141B21),
    previewAccent: const Color(0xFF94A3B8),
    themeData: _buildTheme(
      background: const Color(0xFF0A1014),
      card: const Color(0xFF141B21),
      cardLight: const Color(0xFF1A2229),
      border: const Color(0xFF1F2937),
      accent: const Color(0xFF94A3B8),
      accentSecondary: const Color(0xFFE2E8F0),
      textBright: const Color(0xFFF8FAFC),
      textLight: const Color(0xFFCBD5E1),
      textMuted: const Color(0xFF64748B),
    ),
  );
  
  // ============================================
  // THEME 4: WARM DEPTHS
  // ============================================
  static final warmDepths = ThemeOption(
    id: 'warm_depths',
    name: 'Warm Depths',
    tagline: "Captain's quarters, grounded",
    description: 'Earthy and comforting. Bronze/amber tones feel human and warm.',
    bestFor: 'Comforting, human warmth',
    previewBackground: const Color(0xFF0E0D0B),
    previewCard: const Color(0xFF1A1815),
    previewAccent: const Color(0xFFD4A574),
    themeData: _buildTheme(
      background: const Color(0xFF0E0D0B),
      card: const Color(0xFF1A1815),
      cardLight: const Color(0xFF22201C),
      border: const Color(0xFF2D2924),
      accent: const Color(0xFFD4A574),
      accentSecondary: const Color(0xFF7C9A92),
      textBright: const Color(0xFFF5F3EF),
      textLight: const Color(0xFFD4D0C8),
      textMuted: const Color(0xFF8B8580),
    ),
  );
  
  // ============================================
  // THEME 5: FOREST NIGHT
  // ============================================
  static final forestNight = ThemeOption(
    id: 'forest_night',
    name: 'Forest Night',
    tagline: 'Growth-oriented, natural calm',
    description: 'Natural greens for a sense of growth and renewal.',
    bestFor: 'Natural, calming greens',
    previewBackground: const Color(0xFF0B0F0D),
    previewCard: const Color(0xFF131A16),
    previewAccent: const Color(0xFF6EE7B7),
    themeData: _buildTheme(
      background: const Color(0xFF0B0F0D),
      card: const Color(0xFF131A16),
      cardLight: const Color(0xFF1A221E),
      border: const Color(0xFF1E2A24),
      accent: const Color(0xFF6EE7B7),
      accentSecondary: const Color(0xFF34D399),
      textBright: const Color(0xFFF0FDF4),
      textLight: const Color(0xFFBBF7D0),
      textMuted: const Color(0xFF4B6358),
    ),
  );
  
  // ============================================
  // THEME 6: SLATE & COPPER
  // ============================================
  static final slateCopper = ThemeOption(
    id: 'slate_copper',
    name: 'Slate & Copper',
    tagline: 'Prestigious, naval insignia',
    description: 'Classic copper tones on dark slate. Premium and distinctive.',
    bestFor: 'Premium, distinctive',
    previewBackground: const Color(0xFF111114),
    previewCard: const Color(0xFF1C1C20),
    previewAccent: const Color(0xFFCD7F32),
    themeData: _buildTheme(
      background: const Color(0xFF111114),
      card: const Color(0xFF1C1C20),
      cardLight: const Color(0xFF242428),
      border: const Color(0xFF2E2E34),
      accent: const Color(0xFFCD7F32),
      accentSecondary: const Color(0xFFB8860B),
      textBright: const Color(0xFFF3F4F6),
      textLight: const Color(0xFFD1D5DB),
      textMuted: const Color(0xFF6B7280),
    ),
  );
  
  // ============================================
  // THEME 7: DEEP SLATE
  // ============================================
  static final deepSlate = ThemeOption(
    id: 'deep_slate',
    name: 'Deep Slate',
    tagline: 'Ultra-minimal, serious',
    description: 'Maximum minimalism. White on dark grey, nothing distracting.',
    bestFor: 'Maximum seriousness',
    previewBackground: const Color(0xFF121317),
    previewCard: const Color(0xFF1E1F25),
    previewAccent: const Color(0xFFFFFFFF),
    themeData: _buildTheme(
      background: const Color(0xFF121317),
      card: const Color(0xFF1E1F25),
      cardLight: const Color(0xFF26272E),
      border: const Color(0xFF2D2F38),
      accent: const Color(0xFFFFFFFF),
      accentSecondary: const Color(0xFF9CA3AF),
      textBright: const Color(0xFFF9FAFB),
      textLight: const Color(0xFFD1D5DB),
      textMuted: const Color(0xFF6B7280),
    ),
  );
  
  // ============================================
  // THEME 8: NAUTICAL BRASS
  // ============================================
  static final nauticalBrass = ThemeOption(
    id: 'nautical_brass',
    name: 'Nautical Brass',
    tagline: "Officer's quarters, naval heritage",
    description: 'Traditional naval aesthetic. Brass gold with sea grey accents.',
    bestFor: 'Traditional naval heritage',
    previewBackground: const Color(0xFF0C0E10),
    previewCard: const Color(0xFF161A1D),
    previewAccent: const Color(0xFFB8860B),
    themeData: _buildTheme(
      background: const Color(0xFF0C0E10),
      card: const Color(0xFF161A1D),
      cardLight: const Color(0xFF1E2226),
      border: const Color(0xFF1F2428),
      accent: const Color(0xFFB8860B),
      accentSecondary: const Color(0xFF4A6572),
      textBright: const Color(0xFFE5E7EB),
      textLight: const Color(0xFFB8BCC2),
      textMuted: const Color(0xFF6B7280),
    ),
  );
  
  // ============================================
  // THEME 9: AQUA - Bright aqua/turquoise accents
  // ============================================
  static final aqua = ThemeOption(
    id: 'aqua',
    name: 'Aqua',
    tagline: 'Bright turquoise, fresh and vibrant',
    description: 'Dark slate background with bright aqua/turquoise accents. Fresh and calming.',
    bestFor: 'Fresh, calming',
    previewBackground: const Color(0xFF1A2E35),  // Dark slate with slight teal tint
    previewCard: const Color(0xFF162D34),        // Slightly lighter card
    previewAccent: const Color(0xFF2EC4B6),      // Bright aqua!
    themeData: _buildTheme(
      background: const Color(0xFF1A2E35),       // Dark slate with teal hint
      card: const Color(0xFF1E3840),             // Slightly lighter
      cardLight: const Color(0xFF234550),        // Even lighter
      border: const Color(0xFF2A5058),           // Subtle border
      accent: const Color(0xFF2EC4B6),           // AQUA/TURQUOISE
      accentSecondary: const Color(0xFF3DD5C7),  // Lighter aqua
      textBright: const Color(0xFFF0F9F8),       // Clean white
      textLight: const Color(0xFFB8D4D0),        // Light grey (NOT aqua)
      textMuted: const Color(0xFF6B8C88),        // Muted grey-green
    ),
  );
  
  // ============================================
  // THEME 10: TURQUOISE - Deeper turquoise variant
  // ============================================
  static final turquoise = ThemeOption(
    id: 'turquoise',
    name: 'Turquoise',
    tagline: 'Deep waters, bright highlights',
    description: 'Darker background with punchy turquoise accents. Professional yet fresh.',
    bestFor: 'Professional, fresh',
    previewBackground: const Color(0xFF0F1E22),  // Darker slate
    previewCard: const Color(0xFF152830),        // Card
    previewAccent: const Color(0xFF3DD5C7),      // Bright turquoise
    themeData: _buildTheme(
      background: const Color(0xFF0F1E22),       // Darker slate
      card: const Color(0xFF152830),             // Slightly lighter
      cardLight: const Color(0xFF1A3038),        // Even lighter
      border: const Color(0xFF203840),           // Subtle border
      accent: const Color(0xFF3DD5C7),           // Bright turquoise
      accentSecondary: const Color(0xFF2EC4B6),  // Slightly darker aqua
      textBright: const Color(0xFFF5FAFA),       // Clean white
      textLight: const Color(0xFFB0C8C5),        // Light grey (NOT turquoise)
      textMuted: const Color(0xFF5A7A78),        // Muted grey
    ),
  );

  /// All available themes
  static final List<ThemeOption> all = [
    aqua,
    turquoise,
    deepOcean,
    midnightSteel,
    arcticDepths,
    warmDepths,
    forestNight,
    slateCopper,
    deepSlate,
    nauticalBrass,
  ];
  
  /// Get theme by ID
  static ThemeOption getById(String id) {
    return all.firstWhere(
      (t) => t.id == id,
      orElse: () => deepOcean,
    );
  }
  
  /// Build a theme from colour parameters
  static ThemeData _buildTheme({
    required Color background,
    required Color card,
    required Color cardLight,
    required Color border,
    required Color accent,
    required Color accentSecondary,
    required Color textBright,
    required Color textLight,
    required Color textMuted,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      colorScheme: ColorScheme.dark(
        primary: accent,
        secondary: accentSecondary,
        surface: card,
        error: const Color(0xFFFB7185),
        onPrimary: background,
        onSecondary: textBright,
        onSurface: textBright,
        onError: textBright,
      ),
      
      scaffoldBackgroundColor: background,
      
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
        iconTheme: IconThemeData(color: textLight, size: 24),
      ),
      
      cardTheme: CardThemeData(
        elevation: 0,
        color: card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border, width: 1),
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: background,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          side: BorderSide(color: accent, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accent, width: 2),
        ),
        hintStyle: GoogleFonts.inter(color: textMuted, fontSize: 16),
        labelStyle: GoogleFonts.inter(color: textLight, fontSize: 16),
      ),
      
      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w700, color: textBright, letterSpacing: -1.0, height: 1.2),
        displayMedium: GoogleFonts.inter(fontSize: 30, fontWeight: FontWeight.w600, color: textBright, letterSpacing: -0.8, height: 1.2),
        displaySmall: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, color: textBright, letterSpacing: -0.5, height: 1.3),
        headlineMedium: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: textBright, letterSpacing: -0.4),
        headlineSmall: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: textBright, letterSpacing: -0.3),
        titleLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: textBright, letterSpacing: -0.2),
        titleMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: textLight),
        bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: textLight, height: 1.6),
        bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: textLight, height: 1.5),
        bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: textMuted),
        labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: textBright, letterSpacing: 0.1),
        labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: textLight),
      ),
      
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: card,
        selectedItemColor: accent,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400),
      ),
      
      dialogTheme: DialogThemeData(
        backgroundColor: card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: textBright),
        contentTextStyle: GoogleFonts.inter(fontSize: 16, color: textLight),
      ),
      
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardLight,
        contentTextStyle: GoogleFonts.inter(color: textBright),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accent,
        linearTrackColor: border,
        circularTrackColor: border,
      ),
      
      sliderTheme: SliderThemeData(
        activeTrackColor: accent,
        inactiveTrackColor: border,
        thumbColor: accent,
        overlayColor: accent.withOpacity(0.2),
      ),
      
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return accent;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(background),
        side: BorderSide(color: textMuted, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return accent;
          return textMuted;
        }),
      ),
      
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        iconColor: textLight,
        textColor: textBright,
      ),
      
      iconTheme: IconThemeData(color: textLight, size: 24),
      
      // Store custom colours in extensions
      extensions: [
        AppColours(
          background: background,
          card: card,
          cardLight: cardLight,
          border: border,
          accent: accent,
          accentSecondary: accentSecondary,
          textBright: textBright,
          textLight: textLight,
          textMuted: textMuted,
          success: const Color(0xFF34D399),
          warning: const Color(0xFFFBBF24),
          error: const Color(0xFFFB7185),
        ),
      ],
    );
  }
}

/// Custom colour extension for accessing theme colours
class AppColours extends ThemeExtension<AppColours> {
  final Color background;
  final Color card;
  final Color cardLight;
  final Color border;
  final Color accent;
  final Color accentSecondary;
  final Color textBright;
  final Color textLight;
  final Color textMuted;
  final Color success;
  final Color warning;
  final Color error;
  
  const AppColours({
    required this.background,
    required this.card,
    required this.cardLight,
    required this.border,
    required this.accent,
    required this.accentSecondary,
    required this.textBright,
    required this.textLight,
    required this.textMuted,
    required this.success,
    required this.warning,
    required this.error,
  });
  
  @override
  AppColours copyWith({
    Color? background,
    Color? card,
    Color? cardLight,
    Color? border,
    Color? accent,
    Color? accentSecondary,
    Color? textBright,
    Color? textLight,
    Color? textMuted,
    Color? success,
    Color? warning,
    Color? error,
  }) {
    return AppColours(
      background: background ?? this.background,
      card: card ?? this.card,
      cardLight: cardLight ?? this.cardLight,
      border: border ?? this.border,
      accent: accent ?? this.accent,
      accentSecondary: accentSecondary ?? this.accentSecondary,
      textBright: textBright ?? this.textBright,
      textLight: textLight ?? this.textLight,
      textMuted: textMuted ?? this.textMuted,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
    );
  }
  
  @override
  AppColours lerp(ThemeExtension<AppColours>? other, double t) {
    if (other is! AppColours) return this;
    return AppColours(
      background: Color.lerp(background, other.background, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardLight: Color.lerp(cardLight, other.cardLight, t)!,
      border: Color.lerp(border, other.border, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSecondary: Color.lerp(accentSecondary, other.accentSecondary, t)!,
      textBright: Color.lerp(textBright, other.textBright, t)!,
      textLight: Color.lerp(textLight, other.textLight, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
    );
  }
}

/// Extension to easily access AppColours from BuildContext
extension AppColoursExtension on BuildContext {
  AppColours get colours => Theme.of(this).extension<AppColours>()!;
}

