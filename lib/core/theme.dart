import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'theme/app_decorations.dart';
import 'theme/app_text_styles.dart' as theme_styles;

class AppTheme {
  // Legacy color constants for backward compatibility
  static const Color primaryColor = AppColors.primaryBlue;
  static const Color secondaryColor = AppColors.secondaryGreen;
  static const Color accentColor = AppColors.accentOrange;
  
  static const Color lightBackground = AppColors.lightBackground;
  static const Color lightSurface = AppColors.lightSurface;
  static const Color lightError = AppColors.error;
  
  static const Color darkBackground = AppColors.darkBackground;
  static const Color darkSurface = AppColors.darkSurface;
  static const Color darkError = AppColors.error;
  
  static const Color lightTextPrimary = AppColors.lightTextPrimary;
  static const Color lightTextSecondary = AppColors.lightTextSecondary;
  static const Color darkTextPrimary = AppColors.darkTextPrimary;
  static const Color darkTextSecondary = AppColors.darkTextSecondary;
  
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: AppColors.primaryBlue,
      secondary: AppColors.secondaryGreen,
      tertiary: AppColors.accentOrange,
      surface: AppColors.lightSurface,
      error: AppColors.error,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.lightTextPrimary,
      onError: AppColors.white,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: AppColors.white,
      iconTheme: const IconThemeData(color: AppColors.white),
      titleTextStyle: theme_styles.AppTextStyles.h4.copyWith(color: AppColors.white),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: AppDecorations.borderRadiusMD,
      ),
      color: AppColors.lightSurface,
      shadowColor: AppColors.grey900.withOpacity(0.1),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDecorations.spaceLG,
          vertical: AppDecorations.spaceMD,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppDecorations.borderRadiusSM,
        ),
        textStyle: theme_styles.AppTextStyles.button,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDecorations.spaceMD,
          vertical: AppDecorations.spaceSM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppDecorations.borderRadiusSM,
        ),
        textStyle: theme_styles.AppTextStyles.buttonSmall,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDecorations.spaceLG,
          vertical: AppDecorations.spaceMD,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppDecorations.borderRadiusSM,
        ),
        side: const BorderSide(color: AppColors.primaryBlue, width: 2),
        textStyle: theme_styles.AppTextStyles.button,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightSurface,
      border: OutlineInputBorder(
        borderRadius: AppDecorations.borderRadiusSM,
        borderSide: const BorderSide(color: AppColors.grey300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppDecorations.borderRadiusSM,
        borderSide: const BorderSide(color: AppColors.grey300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppDecorations.borderRadiusSM,
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppDecorations.borderRadiusSM,
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDecorations.spaceMD,
        vertical: AppDecorations.spaceMD,
      ),
      hintStyle: theme_styles.AppTextStyles.bodyMedium.copyWith(color: AppColors.grey400),
      labelStyle: theme_styles.AppTextStyles.label,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: AppColors.primaryBlue,
      unselectedItemColor: AppColors.grey500,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.grey100,
      selectedColor: AppColors.primaryBlue,
      labelStyle: theme_styles.AppTextStyles.label,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDecorations.spaceMD,
        vertical: AppDecorations.spaceSM,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppDecorations.borderRadiusCircle,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: AppColors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: AppDecorations.borderRadiusCircle,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.grey200,
      thickness: 1,
      space: 1,
    ),
    textTheme: TextTheme(
      displayLarge: theme_styles.AppTextStyles.h1,
      displayMedium: theme_styles.AppTextStyles.h2,
      displaySmall: theme_styles.AppTextStyles.h3,
      headlineMedium: theme_styles.AppTextStyles.h4,
      headlineSmall: theme_styles.AppTextStyles.h5,
      bodyLarge: theme_styles.AppTextStyles.bodyLarge,
      bodyMedium: theme_styles.AppTextStyles.bodyMedium,
      bodySmall: theme_styles.AppTextStyles.bodySmall,
      labelLarge: theme_styles.AppTextStyles.button,
      labelMedium: theme_styles.AppTextStyles.label,
      labelSmall: theme_styles.AppTextStyles.labelSmall,
    ),
  );
  
  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryBlue,
      secondary: AppColors.secondaryGreen,
      tertiary: AppColors.accentOrange,
      surface: AppColors.darkSurface,
      error: AppColors.error,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.darkTextPrimary,
      onError: AppColors.white,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: AppColors.darkSurface,
      foregroundColor: AppColors.darkTextPrimary,
      iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
      titleTextStyle: theme_styles.AppTextStyles.h4.copyWith(color: AppColors.darkTextPrimary),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: AppDecorations.borderRadiusMD,
      ),
      color: AppColors.darkSurface,
      shadowColor: AppColors.black.withOpacity(0.3),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDecorations.spaceLG,
          vertical: AppDecorations.spaceMD,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppDecorations.borderRadiusSM,
        ),
        textStyle: theme_styles.AppTextStyles.button,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDecorations.spaceMD,
          vertical: AppDecorations.spaceSM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppDecorations.borderRadiusSM,
        ),
        textStyle: theme_styles.AppTextStyles.buttonSmall,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDecorations.spaceLG,
          vertical: AppDecorations.spaceMD,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppDecorations.borderRadiusSM,
        ),
        side: const BorderSide(color: AppColors.primaryBlue, width: 2),
        textStyle: theme_styles.AppTextStyles.button,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      border: OutlineInputBorder(
        borderRadius: AppDecorations.borderRadiusSM,
        borderSide: const BorderSide(color: AppColors.grey700),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppDecorations.borderRadiusSM,
        borderSide: const BorderSide(color: AppColors.grey700),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppDecorations.borderRadiusSM,
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppDecorations.borderRadiusSM,
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDecorations.spaceMD,
        vertical: AppDecorations.spaceMD,
      ),
      hintStyle: theme_styles.AppTextStyles.bodyMedium.copyWith(color: AppColors.grey600),
      labelStyle: theme_styles.AppTextStyles.label,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: AppColors.primaryBlue,
      unselectedItemColor: AppColors.grey500,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.darkSurface,
      elevation: 8,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedColor: AppColors.primaryBlue,
      labelStyle: theme_styles.AppTextStyles.label,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDecorations.spaceMD,
        vertical: AppDecorations.spaceSM,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppDecorations.borderRadiusCircle,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: AppColors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: AppDecorations.borderRadiusCircle,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.grey700,
      thickness: 1,
      space: 1,
    ),
    textTheme: TextTheme(
      displayLarge: theme_styles.AppTextStyles.h1,
      displayMedium: theme_styles.AppTextStyles.h2,
      displaySmall: theme_styles.AppTextStyles.h3,
      headlineMedium: theme_styles.AppTextStyles.h4,
      headlineSmall: theme_styles.AppTextStyles.h5,
      bodyLarge: theme_styles.AppTextStyles.bodyLarge,
      bodyMedium: theme_styles.AppTextStyles.bodyMedium,
      bodySmall: theme_styles.AppTextStyles.bodySmall,
      labelLarge: theme_styles.AppTextStyles.button,
      labelMedium: theme_styles.AppTextStyles.label,
      labelSmall: theme_styles.AppTextStyles.labelSmall,
    ),
  );
}

// Legacy text styles for backward compatibility
class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );
  
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: Colors.grey,
  );
}
