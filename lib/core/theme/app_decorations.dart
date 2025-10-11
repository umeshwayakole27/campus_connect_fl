import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Application decorations (borders, shadows, gradients)
class AppDecorations {
  // Border Radius
  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusCircle = 9999.0;
  
  static BorderRadius borderRadiusXS = BorderRadius.circular(radiusXS);
  static BorderRadius borderRadiusSM = BorderRadius.circular(radiusSM);
  static BorderRadius borderRadiusMD = BorderRadius.circular(radiusMD);
  static BorderRadius borderRadiusLG = BorderRadius.circular(radiusLG);
  static BorderRadius borderRadiusXL = BorderRadius.circular(radiusXL);
  static BorderRadius borderRadiusCircle = BorderRadius.circular(radiusCircle);
  
  // Spacing
  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 16.0;
  static const double spaceLG = 24.0;
  static const double spaceXL = 32.0;
  static const double spaceXXL = 48.0;
  
  // Card Decorations
  static BoxDecoration cardDecoration({Color? color}) => BoxDecoration(
    color: color ?? AppColors.white,
    borderRadius: borderRadiusMD,
    boxShadow: AppColors.cardShadow,
  );
  
  static BoxDecoration elevatedCardDecoration({Color? color}) => BoxDecoration(
    color: color ?? AppColors.white,
    borderRadius: borderRadiusMD,
    boxShadow: AppColors.elevatedShadow,
  );
  
  static BoxDecoration gradientCardDecoration({
    required Gradient gradient,
  }) => BoxDecoration(
    gradient: gradient,
    borderRadius: borderRadiusMD,
    boxShadow: AppColors.cardShadow,
  );
  
  // Input Decorations
  static InputDecoration inputDecoration({
    String? hintText,
    String? labelText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool filled = true,
  }) => InputDecoration(
    hintText: hintText,
    labelText: labelText,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    filled: filled,
    fillColor: AppColors.grey100,
    border: OutlineInputBorder(
      borderRadius: borderRadiusSM,
      borderSide: const BorderSide(color: AppColors.grey300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: borderRadiusSM,
      borderSide: const BorderSide(color: AppColors.grey300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: borderRadiusSM,
      borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: borderRadiusSM,
      borderSide: const BorderSide(color: AppColors.error),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: spaceMD,
      vertical: spaceMD,
    ),
  );
  
  // Button Decorations
  static BoxDecoration primaryButtonDecoration({bool enabled = true}) => BoxDecoration(
    gradient: enabled ? AppColors.primaryGradient : null,
    color: enabled ? null : AppColors.grey300,
    borderRadius: borderRadiusSM,
    boxShadow: enabled ? AppColors.buttonShadow : null,
  );
  
  static BoxDecoration secondaryButtonDecoration({bool enabled = true}) => BoxDecoration(
    border: Border.all(
      color: enabled ? AppColors.primaryBlue : AppColors.grey300,
      width: 2,
    ),
    borderRadius: borderRadiusSM,
  );
  
  static BoxDecoration outlinedButtonDecoration({
    Color? borderColor,
    double borderWidth = 1,
  }) => BoxDecoration(
    border: Border.all(
      color: borderColor ?? AppColors.grey300,
      width: borderWidth,
    ),
    borderRadius: borderRadiusSM,
  );
  
  // Chip Decorations
  static BoxDecoration chipDecoration({
    Color? backgroundColor,
    Color? borderColor,
    bool selected = false,
  }) => BoxDecoration(
    color: selected 
        ? (backgroundColor ?? AppColors.primaryBlue) 
        : AppColors.grey100,
    border: Border.all(
      color: selected 
          ? (borderColor ?? AppColors.primaryBlue) 
          : AppColors.grey300,
    ),
    borderRadius: borderRadiusCircle,
  );
  
  // Badge Decorations
  static BoxDecoration badgeDecoration({Color? color}) => BoxDecoration(
    color: color ?? AppColors.accentRed,
    borderRadius: borderRadiusCircle,
    boxShadow: [
      BoxShadow(
        color: (color ?? AppColors.accentRed).withOpacity(0.3),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );
  
  // Divider
  static BoxDecoration dividerDecoration({
    Color? color,
    double height = 1,
  }) => BoxDecoration(
    color: color ?? AppColors.grey200,
  );
  
  // Search Bar Decoration
  static BoxDecoration searchBarDecoration({
    Color? backgroundColor,
  }) => BoxDecoration(
    color: backgroundColor ?? AppColors.grey100,
    borderRadius: borderRadiusCircle,
  );
  
  // Modal Bottom Sheet Decoration
  static BoxDecoration bottomSheetDecoration({Color? color}) => BoxDecoration(
    color: color ?? AppColors.white,
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(radiusLG),
      topRight: Radius.circular(radiusLG),
    ),
  );
  
  // Gradient Overlay
  static BoxDecoration gradientOverlay({
    List<Color>? colors,
    AlignmentGeometry begin = Alignment.topCenter,
    AlignmentGeometry end = Alignment.bottomCenter,
  }) => BoxDecoration(
    gradient: LinearGradient(
      begin: begin,
      end: end,
      colors: colors ?? [
        Colors.transparent,
        Colors.black.withOpacity(0.7),
      ],
    ),
  );
  
  // Shimmer Decoration (for loading states)
  static BoxDecoration shimmerDecoration() => BoxDecoration(
    gradient: LinearGradient(
      colors: [
        AppColors.grey200,
        AppColors.grey100,
        AppColors.grey200,
      ],
    ),
    borderRadius: borderRadiusSM,
  );
}
