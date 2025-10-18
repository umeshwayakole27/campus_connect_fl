import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'm3_expressive_colors.dart';
import 'm3_expressive_typography.dart';
import 'm3_expressive_motion.dart';

/// Material 3 Expressive Theme
/// Complete theme implementation with expressive design language
class M3ExpressiveTheme {
  // Create Light Theme
  static ThemeData light() {
    final colorScheme = M3ExpressiveColorScheme.light;
    final textTheme = M3ExpressiveTypography.createTextTheme(colorScheme);
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      brightness: Brightness.light,
      
      // App Bar Theme - Expressive with elevation tint
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 3,
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: colorScheme.primary,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        titleTextStyle: M3ExpressiveTypography.titleLarge.copyWith(
          color: colorScheme.onSurface,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      
      // Card Theme - Elevated with expressive shapes
      cardTheme: const CardThemeData(
        elevation: 1,
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ).copyWith(
        surfaceTintColor: colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Elevated Button Theme - Primary actions
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 1,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          textStyle: M3ExpressiveTypography.labelLarge,
          animationDuration: M3Durations.medium2,
        ),
      ),
      
      // Filled Button Theme - Prominent actions
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          textStyle: M3ExpressiveTypography.labelLarge,
          animationDuration: M3Durations.medium2,
        ),
      ),
      
      // Outlined Button Theme - Secondary actions
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          side: BorderSide(color: colorScheme.outline),
          textStyle: M3ExpressiveTypography.labelLarge,
          animationDuration: M3Durations.medium2,
        ),
      ),
      
      // Text Button Theme - Tertiary actions
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          textStyle: M3ExpressiveTypography.labelLarge,
          animationDuration: M3Durations.medium2,
        ),
      ),
      
      // FAB Theme - Expressive floating actions
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 3,
        focusElevation: 4,
        hoverElevation: 4,
        highlightElevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        extendedPadding: const EdgeInsets.symmetric(horizontal: 24),
        extendedTextStyle: M3ExpressiveTypography.labelLarge,
      ),
      
      // Input Decoration Theme - Expressive text fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: M3ExpressiveTypography.bodyLarge,
        hintStyle: M3ExpressiveTypography.bodyLarge.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      
      // Chip Theme - Expressive selections
      chipTheme: ChipThemeData(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        labelStyle: M3ExpressiveTypography.labelMedium,
        elevation: 0,
        pressElevation: 1,
      ),
      
      // Dialog Theme - Expressive dialogs
      dialogTheme: DialogThemeData(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        titleTextStyle: M3ExpressiveTypography.headlineSmall,
        contentTextStyle: M3ExpressiveTypography.bodyMedium,
      ),
      
      // Bottom Sheet Theme - Expressive sheets
      bottomSheetTheme: BottomSheetThemeData(
        elevation: 3,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      
      // Navigation Bar Theme - Expressive navigation
      navigationBarTheme: NavigationBarThemeData(
        elevation: 3,
        height: 80,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return M3ExpressiveTypography.labelMedium.copyWith(
              color: colorScheme.onSecondaryContainer,
            );
          }
          return M3ExpressiveTypography.labelMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
          );
        }),
      ),
      
      // List Tile Theme - Expressive lists
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        titleTextStyle: M3ExpressiveTypography.bodyLarge,
        subtitleTextStyle: M3ExpressiveTypography.bodyMedium.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      
      // Divider Theme
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      
      // Icon Theme
      iconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: 24,
      ),
      
      // Page Transitions with expressive motion
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      
      // Scaffold
      scaffoldBackgroundColor: colorScheme.surface,
      
      // Splash and Highlight
      splashFactory: InkRipple.splashFactory,
      highlightColor: colorScheme.primary.withOpacity(0.08),
      splashColor: colorScheme.primary.withOpacity(0.12),
    );
  }
  
  // Create Dark Theme
  static ThemeData dark() {
    final colorScheme = M3ExpressiveColorScheme.dark;
    final textTheme = M3ExpressiveTypography.createTextTheme(colorScheme);
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      brightness: Brightness.dark,
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 3,
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: colorScheme.primary,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        titleTextStyle: M3ExpressiveTypography.titleLarge.copyWith(
          color: colorScheme.onSurface,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      
      // Card Theme
      cardTheme: const CardThemeData(
        elevation: 1,
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ).copyWith(
        surfaceTintColor: colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Button Themes (same as light)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 1,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          textStyle: M3ExpressiveTypography.labelLarge,
          animationDuration: M3Durations.medium2,
        ),
      ),
      
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          textStyle: M3ExpressiveTypography.labelLarge,
          animationDuration: M3Durations.medium2,
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          side: BorderSide(color: colorScheme.outline),
          textStyle: M3ExpressiveTypography.labelLarge,
          animationDuration: M3Durations.medium2,
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          textStyle: M3ExpressiveTypography.labelLarge,
          animationDuration: M3Durations.medium2,
        ),
      ),
      
      // FAB Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 3,
        focusElevation: 4,
        hoverElevation: 4,
        highlightElevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        extendedPadding: const EdgeInsets.symmetric(horizontal: 24),
        extendedTextStyle: M3ExpressiveTypography.labelLarge,
      ),
      
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: M3ExpressiveTypography.bodyLarge,
        hintStyle: M3ExpressiveTypography.bodyLarge.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      
      // Other themes (same structure as light)
      chipTheme: ChipThemeData(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        labelStyle: M3ExpressiveTypography.labelMedium,
        elevation: 0,
        pressElevation: 1,
      ),
      
      dialogTheme: DialogThemeData(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        titleTextStyle: M3ExpressiveTypography.headlineSmall.copyWith(
          color: colorScheme.onSurface,
        ),
        contentTextStyle: M3ExpressiveTypography.bodyMedium.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
      
      bottomSheetTheme: BottomSheetThemeData(
        elevation: 3,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        clipBehavior: Clip.antiAlias,
        backgroundColor: colorScheme.surface,
      ),
      
      navigationBarTheme: NavigationBarThemeData(
        elevation: 3,
        height: 80,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return M3ExpressiveTypography.labelMedium.copyWith(
              color: colorScheme.onSecondaryContainer,
            );
          }
          return M3ExpressiveTypography.labelMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
          );
        }),
      ),
      
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        titleTextStyle: M3ExpressiveTypography.bodyLarge.copyWith(
          color: colorScheme.onSurface,
        ),
        subtitleTextStyle: M3ExpressiveTypography.bodyMedium.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      
      iconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: 24,
      ),
      
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      
      scaffoldBackgroundColor: colorScheme.surface,
      
      splashFactory: InkRipple.splashFactory,
      highlightColor: colorScheme.primary.withOpacity(0.08),
      splashColor: colorScheme.primary.withOpacity(0.12),
    );
  }
}
