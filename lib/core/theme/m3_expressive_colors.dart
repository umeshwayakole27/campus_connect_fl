import 'package:flutter/material.dart';

/// Material 3 Expressive Design Colors
/// Following Material Design 3 Expressive guidelines
class M3ExpressiveColors {
  // Primary Colors - Vibrant and Expressive
  static const Color primaryBlue = Color(0xFF0061A4);
  static const Color primaryLight = Color(0xFF5C92C5);
  static const Color primaryDark = Color(0xFF00416A);
  
  // Secondary Colors - Complementary Expressive
  static const Color secondaryTeal = Color(0xFF00897B);
  static const Color secondaryLight = Color(0xFF4DB6AC);
  static const Color secondaryDark = Color(0xFF00695C);
  
  // Tertiary Colors - Accent & Energy
  static const Color tertiaryAmber = Color(0xFFFF6F00);
  static const Color tertiaryLight = Color(0xFFFF9E40);
  static const Color tertiaryDark = Color(0xFFC43E00);
  
  // Neutral Colors - Background & Surface
  static const Color surface = Color(0xFFFFFBFE);
  static const Color surfaceVariant = Color(0xFFF5F1F7);
  static const Color surfaceDim = Color(0xFFE5E1E6);
  static const Color surfaceBright = Color(0xFFFFFFFF);
  
  // Neutral Tones
  static const Color neutral10 = Color(0xFF1A1C1E);
  static const Color neutral20 = Color(0xFF2F3033);
  static const Color neutral30 = Color(0xFF45474A);
  static const Color neutral40 = Color(0xFF5C5E61);
  static const Color neutral50 = Color(0xFF747679);
  static const Color neutral60 = Color(0xFF8E9092);
  static const Color neutral70 = Color(0xFFA9ABAD);
  static const Color neutral80 = Color(0xFFC4C6C8);
  static const Color neutral90 = Color(0xFFE1E2E4);
  static const Color neutral95 = Color(0xFFF0F1F2);
  static const Color neutral99 = Color(0xFFFCFCFD);
  
  // Semantic Colors - Expressive States
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFEF5350);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);
  
  // Gradient Colors for Expressive UI
  static const List<Color> primaryGradient = [
    Color(0xFF0061A4),
    Color(0xFF00897B),
  ];
  
  static const List<Color> accentGradient = [
    Color(0xFFFF6F00),
    Color(0xFFFF9E40),
  ];
  
  static const List<Color> surfaceGradient = [
    Color(0xFFFFFBFE),
    Color(0xFFF5F1F7),
  ];
  
  // Elevation Tints (Material 3 Expressive)
  static Color surfaceTint(int elevation) {
    final opacity = (elevation * 0.02).clamp(0.0, 0.15);
    return primaryBlue.withOpacity(opacity);
  }
  
  // Dynamic Color Overlay
  static Color overlay({required Color base, required double elevation}) {
    return Color.alphaBlend(
      surfaceTint(elevation.toInt()),
      base,
    );
  }
}

/// M3 Expressive Color Schemes
class M3ExpressiveColorScheme {
  static ColorScheme light = ColorScheme(
    brightness: Brightness.light,
    primary: M3ExpressiveColors.primaryBlue,
    onPrimary: Colors.white,
    primaryContainer: M3ExpressiveColors.primaryLight,
    onPrimaryContainer: M3ExpressiveColors.primaryDark,
    secondary: M3ExpressiveColors.secondaryTeal,
    onSecondary: Colors.white,
    secondaryContainer: M3ExpressiveColors.secondaryLight,
    onSecondaryContainer: M3ExpressiveColors.secondaryDark,
    tertiary: M3ExpressiveColors.tertiaryAmber,
    onTertiary: Colors.white,
    tertiaryContainer: M3ExpressiveColors.tertiaryLight,
    onTertiaryContainer: M3ExpressiveColors.tertiaryDark,
    error: M3ExpressiveColors.error,
    onError: Colors.white,
    errorContainer: M3ExpressiveColors.errorLight,
    onErrorContainer: M3ExpressiveColors.primaryDark,
    surface: M3ExpressiveColors.surface,
    onSurface: M3ExpressiveColors.neutral10,
    surfaceVariant: M3ExpressiveColors.surfaceVariant,
    onSurfaceVariant: M3ExpressiveColors.neutral30,
    outline: M3ExpressiveColors.neutral50,
    outlineVariant: M3ExpressiveColors.neutral80,
    shadow: M3ExpressiveColors.neutral10,
    scrim: M3ExpressiveColors.neutral10,
    inverseSurface: M3ExpressiveColors.neutral20,
    onInverseSurface: M3ExpressiveColors.neutral95,
    inversePrimary: M3ExpressiveColors.primaryLight,
  );
  
  static ColorScheme dark = ColorScheme(
    brightness: Brightness.dark,
    primary: M3ExpressiveColors.primaryLight,
    onPrimary: M3ExpressiveColors.primaryDark,
    primaryContainer: M3ExpressiveColors.primaryDark,
    onPrimaryContainer: M3ExpressiveColors.primaryLight,
    secondary: M3ExpressiveColors.secondaryLight,
    onSecondary: M3ExpressiveColors.secondaryDark,
    secondaryContainer: M3ExpressiveColors.secondaryDark,
    onSecondaryContainer: M3ExpressiveColors.secondaryLight,
    tertiary: M3ExpressiveColors.tertiaryLight,
    onTertiary: M3ExpressiveColors.tertiaryDark,
    tertiaryContainer: M3ExpressiveColors.tertiaryDark,
    onTertiaryContainer: M3ExpressiveColors.tertiaryLight,
    error: M3ExpressiveColors.errorLight,
    onError: M3ExpressiveColors.primaryDark,
    errorContainer: M3ExpressiveColors.error,
    onErrorContainer: M3ExpressiveColors.errorLight,
    surface: M3ExpressiveColors.neutral10,
    onSurface: M3ExpressiveColors.neutral90,
    surfaceVariant: M3ExpressiveColors.neutral30,
    onSurfaceVariant: M3ExpressiveColors.neutral80,
    outline: M3ExpressiveColors.neutral60,
    outlineVariant: M3ExpressiveColors.neutral30,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: M3ExpressiveColors.neutral90,
    onInverseSurface: M3ExpressiveColors.neutral20,
    inversePrimary: M3ExpressiveColors.primaryBlue,
  );
}
