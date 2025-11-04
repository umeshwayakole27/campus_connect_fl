import 'package:flutter/material.dart';

/// Theme helper to provide context-aware colors and styles
/// Use this throughout the app instead of hardcoded colors
class ThemeHelper {
  ThemeHelper._();

  // Context-aware color getters
  static ColorScheme colorScheme(BuildContext context) {
    return Theme.of(context).colorScheme;
  }

  static TextTheme textTheme(BuildContext context) {
    return Theme.of(context).textTheme;
  }

  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  // Primary colors
  static Color primary(BuildContext context) {
    return colorScheme(context).primary;
  }

  static Color onPrimary(BuildContext context) {
    return colorScheme(context).onPrimary;
  }

  static Color primaryContainer(BuildContext context) {
    return colorScheme(context).primaryContainer;
  }

  static Color onPrimaryContainer(BuildContext context) {
    return colorScheme(context).onPrimaryContainer;
  }

  // Secondary colors
  static Color secondary(BuildContext context) {
    return colorScheme(context).secondary;
  }

  static Color onSecondary(BuildContext context) {
    return colorScheme(context).onSecondary;
  }

  static Color secondaryContainer(BuildContext context) {
    return colorScheme(context).secondaryContainer;
  }

  static Color onSecondaryContainer(BuildContext context) {
    return colorScheme(context).onSecondaryContainer;
  }

  // Tertiary colors
  static Color tertiary(BuildContext context) {
    return colorScheme(context).tertiary;
  }

  static Color onTertiary(BuildContext context) {
    return colorScheme(context).onTertiary;
  }

  static Color tertiaryContainer(BuildContext context) {
    return colorScheme(context).tertiaryContainer;
  }

  static Color onTertiaryContainer(BuildContext context) {
    return colorScheme(context).onTertiaryContainer;
  }

  // Surface colors
  static Color surface(BuildContext context) {
    return colorScheme(context).surface;
  }

  static Color onSurface(BuildContext context) {
    return colorScheme(context).onSurface;
  }

  static Color surfaceVariant(BuildContext context) {
    return colorScheme(context).surfaceVariant;
  }

  static Color onSurfaceVariant(BuildContext context) {
    return colorScheme(context).onSurfaceVariant;
  }

  // Background colors
  static Color background(BuildContext context) {
    return colorScheme(context).surface;
  }

  static Color onBackground(BuildContext context) {
    return colorScheme(context).onSurface;
  }

  // Error colors
  static Color error(BuildContext context) {
    return colorScheme(context).error;
  }

  static Color onError(BuildContext context) {
    return colorScheme(context).onError;
  }

  static Color errorContainer(BuildContext context) {
    return colorScheme(context).errorContainer;
  }

  static Color onErrorContainer(BuildContext context) {
    return colorScheme(context).onErrorContainer;
  }

  // Outline colors
  static Color outline(BuildContext context) {
    return colorScheme(context).outline;
  }

  static Color outlineVariant(BuildContext context) {
    return colorScheme(context).outlineVariant;
  }

  // Shadow colors
  static Color shadow(BuildContext context) {
    return colorScheme(context).shadow;
  }

  static Color scrim(BuildContext context) {
    return colorScheme(context).scrim;
  }

  // Inverse colors
  static Color inverseSurface(BuildContext context) {
    return colorScheme(context).inverseSurface;
  }

  static Color onInverseSurface(BuildContext context) {
    return colorScheme(context).onInverseSurface;
  }

  static Color inversePrimary(BuildContext context) {
    return colorScheme(context).inversePrimary;
  }

  // Semantic colors
  static Color success(BuildContext context) {
    return isDarkMode(context) 
        ? const Color(0xFF66BB6A) 
        : const Color(0xFF4CAF50);
  }

  static Color warning(BuildContext context) {
    return isDarkMode(context) 
        ? const Color(0xFFFFCA28) 
        : const Color(0xFFFFC107);
  }

  static Color info(BuildContext context) {
    return isDarkMode(context) 
        ? const Color(0xFF64B5F6) 
        : const Color(0xFF2196F3);
  }

  // Card colors
  static Color cardBackground(BuildContext context) {
    return isDarkMode(context)
        ? colorScheme(context).surfaceVariant
        : colorScheme(context).surface;
  }

  static Color cardBorder(BuildContext context) {
    return isDarkMode(context)
        ? outlineVariant(context).withOpacity(0.3)
        : outlineVariant(context).withOpacity(0.1);
  }

  // Icon colors
  static Color iconPrimary(BuildContext context) {
    return onSurface(context);
  }

  static Color iconSecondary(BuildContext context) {
    return onSurfaceVariant(context);
  }

  static Color iconDisabled(BuildContext context) {
    return onSurface(context).withOpacity(0.38);
  }

  // Divider color
  static Color divider(BuildContext context) {
    return outlineVariant(context);
  }

  // Hover and focus colors
  static Color hover(BuildContext context) {
    return primary(context).withOpacity(0.08);
  }

  static Color focus(BuildContext context) {
    return primary(context).withOpacity(0.12);
  }

  static Color pressed(BuildContext context) {
    return primary(context).withOpacity(0.16);
  }

  // Text colors
  static Color textPrimary(BuildContext context) {
    return onSurface(context);
  }

  static Color textSecondary(BuildContext context) {
    return onSurfaceVariant(context);
  }

  static Color textDisabled(BuildContext context) {
    return onSurface(context).withOpacity(0.38);
  }

  static Color textHint(BuildContext context) {
    return onSurfaceVariant(context).withOpacity(0.6);
  }

  // Badge colors
  static Color badgeError(BuildContext context) {
    return error(context);
  }

  static Color badgeWarning(BuildContext context) {
    return warning(context);
  }

  static Color badgeSuccess(BuildContext context) {
    return success(context);
  }

  static Color badgeInfo(BuildContext context) {
    return info(context);
  }

  // Shimmer colors for loading states
  static Color shimmerBase(BuildContext context) {
    return isDarkMode(context)
        ? const Color(0xFF2C2C2C)
        : const Color(0xFFE0E0E0);
  }

  static Color shimmerHighlight(BuildContext context) {
    return isDarkMode(context)
        ? const Color(0xFF3C3C3C)
        : const Color(0xFFF5F5F5);
  }

  // Status bar colors
  static Color statusBarColor(BuildContext context) {
    return isDarkMode(context)
        ? const Color(0xFF000000)
        : primary(context);
  }

  // Bottom nav colors
  static Color bottomNavBackground(BuildContext context) {
    return isDarkMode(context)
        ? surfaceVariant(context)
        : surface(context);
  }

  // Elevation overlay (for Material 3 dark theme)
  static Color elevatedSurface(BuildContext context, [double elevation = 1]) {
    if (!isDarkMode(context)) return surface(context);
    
    final overlay = primary(context);
    double opacity = 0.05 + (elevation * 0.005);
    opacity = opacity.clamp(0.0, 0.15);
    
    return Color.alphaBlend(
      overlay.withOpacity(opacity),
      surface(context),
    );
  }

  // Container colors with opacity
  static Color containerPrimary(BuildContext context) {
    return primary(context).withOpacity(0.12);
  }

  static Color containerSecondary(BuildContext context) {
    return secondary(context).withOpacity(0.12);
  }

  static Color containerTertiary(BuildContext context) {
    return tertiary(context).withOpacity(0.12);
  }

  static Color containerError(BuildContext context) {
    return error(context).withOpacity(0.12);
  }

  static Color containerSuccess(BuildContext context) {
    return success(context).withOpacity(0.12);
  }

  static Color containerWarning(BuildContext context) {
    return warning(context).withOpacity(0.12);
  }

  static Color containerInfo(BuildContext context) {
    return info(context).withOpacity(0.12);
  }
}
