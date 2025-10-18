import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Material 3 Expressive Typography
/// Using Inter for display and body text (modern, readable, expressive)
class M3ExpressiveTypography {
  // Display styles - Large, expressive text
  static TextStyle displayLarge = GoogleFonts.inter(
    fontSize: 57,
    height: 64 / 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
  );
  
  static TextStyle displayMedium = GoogleFonts.inter(
    fontSize: 45,
    height: 52 / 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );
  
  static TextStyle displaySmall = GoogleFonts.inter(
    fontSize: 36,
    height: 44 / 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );
  
  // Headline styles - Expressive section headers
  static TextStyle headlineLarge = GoogleFonts.inter(
    fontSize: 32,
    height: 40 / 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );
  
  static TextStyle headlineMedium = GoogleFonts.inter(
    fontSize: 28,
    height: 36 / 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );
  
  static TextStyle headlineSmall = GoogleFonts.inter(
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );
  
  // Title styles - List items and card headers
  static TextStyle titleLarge = GoogleFonts.inter(
    fontSize: 22,
    height: 28 / 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );
  
  static TextStyle titleMedium = GoogleFonts.inter(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
  );
  
  static TextStyle titleSmall = GoogleFonts.inter(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );
  
  // Label styles - Buttons, tabs, chips
  static TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );
  
  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );
  
  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 11,
    height: 16 / 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );
  
  // Body styles - Main content text
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );
  
  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );
  
  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  );
  
  // Create Material 3 Text Theme
  static TextTheme createTextTheme(ColorScheme colorScheme) {
    return TextTheme(
      displayLarge: displayLarge.copyWith(color: colorScheme.onSurface),
      displayMedium: displayMedium.copyWith(color: colorScheme.onSurface),
      displaySmall: displaySmall.copyWith(color: colorScheme.onSurface),
      headlineLarge: headlineLarge.copyWith(color: colorScheme.onSurface),
      headlineMedium: headlineMedium.copyWith(color: colorScheme.onSurface),
      headlineSmall: headlineSmall.copyWith(color: colorScheme.onSurface),
      titleLarge: titleLarge.copyWith(color: colorScheme.onSurface),
      titleMedium: titleMedium.copyWith(color: colorScheme.onSurface),
      titleSmall: titleSmall.copyWith(color: colorScheme.onSurfaceVariant),
      labelLarge: labelLarge.copyWith(color: colorScheme.onSurface),
      labelMedium: labelMedium.copyWith(color: colorScheme.onSurfaceVariant),
      labelSmall: labelSmall.copyWith(color: colorScheme.onSurfaceVariant),
      bodyLarge: bodyLarge.copyWith(color: colorScheme.onSurface),
      bodyMedium: bodyMedium.copyWith(color: colorScheme.onSurface),
      bodySmall: bodySmall.copyWith(color: colorScheme.onSurfaceVariant),
    );
  }
}

/// Typography Extensions
extension TypographyExtensions on TextStyle {
  TextStyle get bold => copyWith(fontWeight: FontWeight.w700);
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
  TextStyle get regular => copyWith(fontWeight: FontWeight.w400);
  TextStyle get light => copyWith(fontWeight: FontWeight.w300);
  
  TextStyle withColor(Color color) => copyWith(color: color);
  TextStyle withSize(double size) => copyWith(fontSize: size);
  TextStyle withHeight(double height) => copyWith(height: height);
  TextStyle withLetterSpacing(double spacing) => copyWith(letterSpacing: spacing);
}
