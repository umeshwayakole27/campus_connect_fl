# Phase 7: UI/UX Polish - Quick Reference

## 🎨 Theme System

### Colors
```dart
import 'package:campus_connect_fl/core/theme/app_colors.dart';

// Primary
AppColors.primaryBlue     // #1976D2
AppColors.primaryDark     // #1565C0
AppColors.primaryLight    // #64B5F6

// Secondary  
AppColors.secondaryGreen  // #388E3C

// Accent
AppColors.accentOrange    // #FF9800
AppColors.accentRed       // #D32F2F

// Status
AppColors.success         // #4CAF50
AppColors.warning         // #FFC107
AppColors.error           // #F44336

// Grey Scale
AppColors.grey100 to AppColors.grey900

// Gradients
AppColors.primaryGradient
AppColors.secondaryGradient
AppColors.accentGradient
```

### Typography
```dart
import 'package:campus_connect_fl/core/theme/app_text_styles.dart' as theme_styles;

// Headings (Poppins)
theme_styles.AppTextStyles.h1    // 32px Bold
theme_styles.AppTextStyles.h2    // 24px Bold
theme_styles.AppTextStyles.h3    // 20px SemiBold
theme_styles.AppTextStyles.h4    // 18px SemiBold
theme_styles.AppTextStyles.h5    // 16px SemiBold

// Body (Roboto)
theme_styles.AppTextStyles.bodyLarge   // 16px
theme_styles.AppTextStyles.bodyMedium  // 14px
theme_styles.AppTextStyles.bodySmall   // 12px

// Special
theme_styles.AppTextStyles.button      // 16px SemiBold
theme_styles.AppTextStyles.buttonSmall // 14px SemiBold
theme_styles.AppTextStyles.label       // 12px Medium
theme_styles.AppTextStyles.caption     // 12px Regular
theme_styles.AppTextStyles.link        // 14px Underlined
```

### Decorations
```dart
import 'package:campus_connect_fl/core/theme/app_decorations.dart';

// Border Radius
AppDecorations.borderRadiusSM    // 8px
AppDecorations.borderRadiusMD    // 12px
AppDecorations.borderRadiusLG    // 16px
AppDecorations.borderRadiusXL    // 24px
AppDecorations.borderRadiusCircle

// Spacing
AppDecorations.spaceXS    // 4px
AppDecorations.spaceSM    // 8px
AppDecorations.spaceMD    // 16px
AppDecorations.spaceLG    // 24px
AppDecorations.spaceXL    // 32px
AppDecorations.spaceXXL   // 48px

// Decorations
AppDecorations.cardDecoration()
AppDecorations.elevatedCardDecoration()
AppDecorations.gradientCardDecoration(gradient: gradient)
AppDecorations.inputDecoration(hintText: 'Enter text')
AppDecorations.primaryButtonDecoration()
AppDecorations.secondaryButtonDecoration()
AppDecorations.chipDecoration(selected: true)
AppDecorations.badgeDecoration()
AppDecorations.bottomSheetDecoration()
```

### Animations
```dart
import 'package:campus_connect_fl/core/theme/app_animations.dart';

// Durations
AppAnimations.durationFast       // 200ms
AppAnimations.durationNormal     // 300ms
AppAnimations.durationSlow       // 500ms

// Curves
AppAnimations.curveDefault       // easeInOut
AppAnimations.curveSmooth        // easeInOutCubic
AppAnimations.curveBounce        // bounceOut
AppAnimations.curveElastic       // elasticOut

// Page Transitions
Navigator.push(
  context,
  AppPageTransitions.slideFromRight(MyPage()),
);

AppPageTransitions.slideFromBottom(MyPage())
AppPageTransitions.fade(MyPage())
AppPageTransitions.scale(MyPage())
AppPageTransitions.slideAndFade(MyPage())
```

---

## 🧩 UI Components

### Shimmer Loading
```dart
import 'package:campus_connect_fl/core/widgets/shimmer_loading.dart';

// Base shimmer
ShimmerLoading(
  width: 100,
  height: 20,
  borderRadius: 8,
)

// List item skeleton
SkeletonListItem(
  hasImage: true,
  lines: 2,
)

// Card skeleton
SkeletonCard(
  height: 200,
  hasImage: true,
)

// Grid item skeleton
SkeletonGridItem()

// Full page skeleton
SkeletonPage(
  itemCount: 5,
  hasAppBar: true,
)
```

### Custom Buttons
```dart
import 'package:campus_connect_fl/core/widgets/custom_buttons.dart';

// Primary button (gradient)
PrimaryButton(
  text: 'Submit',
  icon: Icons.check,
  onPressed: () {},
  isLoading: false,
  width: 200,
)

// Secondary button (outline)
SecondaryButton(
  text: 'Cancel',
  icon: Icons.close,
  onPressed: () {},
)

// Icon button
CustomIconButton(
  icon: Icons.add,
  onPressed: () {},
  backgroundColor: AppColors.primaryBlue,
  iconColor: AppColors.white,
  size: 48,
  tooltip: 'Add item',
)
```

### Loading & Empty States
```dart
import 'package:campus_connect_fl/core/widgets/loading_widget.dart';
import 'package:campus_connect_fl/core/widgets/empty_state_widget.dart';
import 'package:campus_connect_fl/core/widgets/error_widget.dart' as custom;

// Loading
LoadingWidget(message: 'Loading data...')

// Empty state
EmptyStateWidget(
  icon: Icons.inbox,
  title: 'No items found',
  message: 'Try adjusting your filters',
  action: ElevatedButton(
    onPressed: () {},
    child: Text('Refresh'),
  ),
)

// Error state
custom.ErrorWidget(
  message: 'Failed to load data',
  onRetry: () {},
)
```

---

## 📱 Screen Patterns

### List with Loading
```dart
class MyListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return isLoading
        ? SkeletonPage(itemCount: 5)
        : ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) => MyListItem(items[index]),
          );
  }
}
```

### Card Layout
```dart
Card(
  child: Padding(
    padding: EdgeInsets.all(AppDecorations.spaceMD),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Title',
          style: theme_styles.AppTextStyles.h3,
        ),
        SizedBox(height: AppDecorations.spaceSM),
        Text(
          'Description',
          style: theme_styles.AppTextStyles.bodyMedium,
        ),
      ],
    ),
  ),
)
```

### Custom Decorated Container
```dart
Container(
  decoration: AppDecorations.cardDecoration(
    color: AppColors.white,
  ),
  padding: EdgeInsets.all(AppDecorations.spaceMD),
  child: child,
)
```

### Form with Custom Input
```dart
TextField(
  decoration: AppDecorations.inputDecoration(
    hintText: 'Enter your name',
    prefixIcon: Icon(Icons.person),
  ),
  style: theme_styles.AppTextStyles.bodyLarge,
)
```

---

## 🎨 Common Patterns

### Gradient Background
```dart
Container(
  decoration: BoxDecoration(
    gradient: AppColors.primaryGradient,
  ),
  child: child,
)
```

### Elevated Card with Shadow
```dart
Container(
  decoration: AppDecorations.elevatedCardDecoration(),
  child: child,
)
```

### Chip with Selection
```dart
Container(
  decoration: AppDecorations.chipDecoration(
    selected: isSelected,
    backgroundColor: AppColors.primaryBlue,
  ),
  padding: EdgeInsets.symmetric(
    horizontal: AppDecorations.spaceMD,
    vertical: AppDecorations.spaceSM,
  ),
  child: Text(label),
)
```

### Badge/Notification Dot
```dart
Container(
  width: 20,
  height: 20,
  decoration: AppDecorations.badgeDecoration(
    color: AppColors.accentRed,
  ),
  child: Center(
    child: Text(
      '5',
      style: theme_styles.AppTextStyles.labelSmall.copyWith(
        color: AppColors.white,
      ),
    ),
  ),
)
```

### Bottom Sheet
```dart
showModalBottomSheet(
  context: context,
  builder: (context) => Container(
    decoration: AppDecorations.bottomSheetDecoration(),
    padding: EdgeInsets.all(AppDecorations.spaceLG),
    child: content,
  ),
);
```

---

## 🚀 Animation Examples

### Fade In Animation
```dart
TweenAnimationBuilder<double>(
  tween: Tween(begin: 0.0, end: 1.0),
  duration: AppAnimations.durationNormal,
  builder: (context, value, child) {
    return Opacity(
      opacity: value,
      child: child,
    );
  },
  child: YourWidget(),
)
```

### Scale Animation
```dart
TweenAnimationBuilder<double>(
  tween: Tween(begin: 0.8, end: 1.0),
  duration: AppAnimations.durationNormal,
  curve: AppAnimations.curveSmooth,
  builder: (context, value, child) {
    return Transform.scale(
      scale: value,
      child: child,
    );
  },
  child: YourWidget(),
)
```

### Slide Animation
```dart
TweenAnimationBuilder<Offset>(
  tween: Tween(
    begin: Offset(0.3, 0),
    end: Offset.zero,
  ),
  duration: AppAnimations.durationNormal,
  builder: (context, value, child) {
    return SlideTransition(
      position: AlwaysStoppedAnimation(value),
      child: child,
    );
  },
  child: YourWidget(),
)
```

---

## 📋 Checklist

### Before Using Theme
- [x] Import theme files
- [x] Use `theme_styles.AppTextStyles` for text
- [x] Use `AppColors` for colors
- [x] Use `AppDecorations` for decorations
- [x] Use `AppAnimations` for durations/curves

### For New Components
- [ ] Follow spacing system
- [ ] Use defined border radius
- [ ] Apply consistent colors
- [ ] Add loading states
- [ ] Handle empty states
- [ ] Include error handling
- [ ] Add animations where appropriate
- [ ] Test dark mode

### For Screens
- [ ] Use skeleton loading
- [ ] Add pull-to-refresh
- [ ] Implement empty states
- [ ] Add error handling
- [ ] Use consistent padding
- [ ] Apply page transitions
- [ ] Test on different sizes

---

## 🔧 Troubleshooting

### Import Conflicts
```dart
// If AppTextStyles conflicts, use alias
import 'package:campus_connect_fl/core/theme/app_text_styles.dart' as theme_styles;

// Then use
theme_styles.AppTextStyles.h1
```

### Theme Not Applied
- Ensure MaterialApp uses `AppTheme.lightTheme`
- Check that widgets use Theme.of(context)
- Verify imports are correct

### Animations Not Smooth
- Use `AppAnimations` durations
- Apply appropriate curves
- Avoid heavy computations in builders
- Use const widgets where possible

---

## 📚 Resources

### Documentation Files
- `PHASE7_SETUP.md` - Complete setup guide
- `PHASE7_SUMMARY.md` - Implementation summary
- `PHASE7_QUICK_REF.md` - This file

### Code Files
- `lib/core/theme/` - Theme system
- `lib/core/widgets/` - Reusable widgets
- `lib/core/theme.dart` - Main theme

### External Resources
- Material Design 3: https://m3.material.io/
- Flutter Animations: https://docs.flutter.dev/ui/animations

---

**Quick Reference Version**: 1.0  
**Last Updated**: October 11, 2025  
**Phase 7 Status**: Foundation Complete (40%)
