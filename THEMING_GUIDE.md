# Campus Connect - Comprehensive Theming Guide

## Overview
Campus Connect uses Material Design 3 (M3) Expressive theme system with full light and dark mode support. This guide ensures consistent theming across all screens and components.

---

## Table of Contents
1. [Theme Architecture](#theme-architecture)
2. [Color Usage Guidelines](#color-usage-guidelines)
3. [Typography Guidelines](#typography-guidelines)
4. [Common Patterns](#common-patterns)
5. [DO's and DON'Ts](#dos-and-donts)
6. [Migration Checklist](#migration-checklist)

---

## Theme Architecture

### Theme Files Location
- **Main Theme**: `lib/core/theme/m3_expressive_theme.dart`
- **Colors**: `lib/core/theme/m3_expressive_colors.dart`
- **Typography**: `lib/core/theme/m3_expressive_typography.dart`
- **Legacy Theme**: `lib/core/theme.dart` (maintained for backward compatibility)

### Theme Provider
- **Location**: `lib/core/providers/theme_provider.dart`
- **Features**:
  - Three modes: System, Light, Dark
  - Persistent theme preference
  - Easy theme switching

---

## Color Usage Guidelines

### ✅ DO: Use Theme-Aware Colors

#### Primary Colors
```dart
// Primary color (main brand color - blue)
color: Theme.of(context).colorScheme.primary,

// Text/icons on primary color
color: Theme.of(context).colorScheme.onPrimary,

// Lighter primary for containers
color: Theme.of(context).colorScheme.primaryContainer,

// Text on primary container
color: Theme.of(context).colorScheme.onPrimaryContainer,
```

#### Secondary Colors
```dart
// Secondary color (teal/green)
color: Theme.of(context).colorScheme.secondary,

// Text/icons on secondary
color: Theme.of(context).colorScheme.onSecondary,
```

#### Tertiary Colors (Accent)
```dart
// Tertiary/accent color (orange/amber)
color: Theme.of(context).colorScheme.tertiary,

// Text/icons on tertiary
color: Theme.of(context).colorScheme.onTertiary,
```

#### Surface Colors
```dart
// Main background
scaffoldBackgroundColor: Theme.of(context).colorScheme.surface,

// Card/surface color
color: Theme.of(context).colorScheme.surface,

// Text on surface
color: Theme.of(context).colorScheme.onSurface,

// Secondary text on surface
color: Theme.of(context).colorScheme.onSurfaceVariant,

// Surface variant (e.g., text fields)
color: Theme.of(context).colorScheme.surfaceVariant,
```

#### Semantic Colors
```dart
// Error state (red)
color: Theme.of(context).colorScheme.error,

// Text/icons on error color
color: Theme.of(context).colorScheme.onError,

// Error container
color: Theme.of(context).colorScheme.errorContainer,
```

#### Outline Colors
```dart
// Borders and dividers
color: Theme.of(context).colorScheme.outline,

// Subtle borders
color: Theme.of(context).colorScheme.outlineVariant,
```

### ❌ DON'T: Use Hardcoded Colors

```dart
// ❌ BAD - Don't do this
color: Colors.blue,
color: Colors.white,
color: Colors.grey,
color: Color(0xFF1976D2),

// ✅ GOOD - Do this instead
color: Theme.of(context).colorScheme.primary,
color: Theme.of(context).colorScheme.onPrimary,
color: Theme.of(context).colorScheme.onSurfaceVariant,
```

---

## Typography Guidelines

### Text Styles

#### Display Text (Large headings)
```dart
// Display Large (57sp)
style: Theme.of(context).textTheme.displayLarge,

// Display Medium (45sp)
style: Theme.of(context).textTheme.displayMedium,

// Display Small (36sp)
style: Theme.of(context).textTheme.displaySmall,
```

#### Headlines (Section headers)
```dart
// Headline Large (32sp) - Main page title
style: Theme.of(context).textTheme.headlineLarge,

// Headline Medium (28sp) - Section headers
style: Theme.of(context).textTheme.headlineMedium,

// Headline Small (24sp) - Card headers
style: Theme.of(context).textTheme.headlineSmall,
```

#### Titles (List items, cards)
```dart
// Title Large (22sp) - Prominent list items
style: Theme.of(context).textTheme.titleLarge,

// Title Medium (16sp) - Standard list items
style: Theme.of(context).textTheme.titleMedium,

// Title Small (14sp) - Compact list items
style: Theme.of(context).textTheme.titleSmall,
```

#### Body Text (Content)
```dart
// Body Large (16sp) - Main content
style: Theme.of(context).textTheme.bodyLarge,

// Body Medium (14sp) - Standard body text
style: Theme.of(context).textTheme.bodyMedium,

// Body Small (12sp) - Secondary text
style: Theme.of(context).textTheme.bodySmall,
```

#### Labels (Buttons, chips, tabs)
```dart
// Label Large (14sp) - Button text
style: Theme.of(context).textTheme.labelLarge,

// Label Medium (12sp) - Chip text
style: Theme.of(context).textTheme.labelMedium,

// Label Small (11sp) - Small labels
style: Theme.of(context).textTheme.labelSmall,
```

### Modifying Text Styles
```dart
// Change color
style: Theme.of(context).textTheme.bodyMedium?.copyWith(
  color: Theme.of(context).colorScheme.onSurfaceVariant,
),

// Change weight
style: Theme.of(context).textTheme.titleLarge?.copyWith(
  fontWeight: FontWeight.bold,
),

// Multiple properties
style: Theme.of(context).textTheme.bodyLarge?.copyWith(
  color: Theme.of(context).colorScheme.primary,
  fontWeight: FontWeight.w600,
),
```

---

## Common Patterns

### Buttons

#### Elevated Button (Primary action)
```dart
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: Theme.of(context).colorScheme.primary,
    foregroundColor: Theme.of(context).colorScheme.onPrimary,
  ),
  child: const Text('Submit'),
)
```

#### Filled Button (Strong emphasis)
```dart
FilledButton(
  onPressed: () {},
  style: FilledButton.styleFrom(
    backgroundColor: Theme.of(context).colorScheme.primary,
  ),
  child: const Text('Save'),
)
```

#### Text Button (Low emphasis)
```dart
TextButton(
  onPressed: () {},
  child: const Text('Cancel'),
)
```

#### Icon Button
```dart
IconButton(
  icon: Icon(
    Icons.favorite,
    color: Theme.of(context).colorScheme.primary,
  ),
  onPressed: () {},
)
```

### Cards
```dart
Card(
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Title',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Description',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    ),
  ),
)
```

### Containers with Background
```dart
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.primaryContainer,
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text(
    'Content',
    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Theme.of(context).colorScheme.onPrimaryContainer,
    ),
  ),
)
```

### Gradients
```dart
// Use theme-aware gradients
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Theme.of(context).colorScheme.primary,
        Theme.of(context).colorScheme.primaryContainer,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
  child: Text(
    'Title',
    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
      color: Theme.of(context).colorScheme.onPrimary,
    ),
  ),
)
```

### Loading Indicators
```dart
CircularProgressIndicator(
  valueColor: AlwaysStoppedAnimation<Color>(
    Theme.of(context).colorScheme.primary,
  ),
)
```

### Dividers
```dart
Divider(
  color: Theme.of(context).colorScheme.outlineVariant,
)
```

### SnackBars
```dart
// Success
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: const Text('Success!'),
    backgroundColor: Theme.of(context).colorScheme.primary,
  ),
);

// Error
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: const Text('Error!'),
    backgroundColor: Theme.of(context).colorScheme.error,
  ),
);
```

### Floating Action Buttons
```dart
FloatingActionButton(
  onPressed: () {},
  backgroundColor: Theme.of(context).colorScheme.primary,
  foregroundColor: Theme.of(context).colorScheme.onPrimary,
  child: const Icon(Icons.add),
)
```

---

## DO's and DON'Ts

### ✅ DO

1. **Always use Theme.of(context)** for colors
2. **Use textTheme** for typography
3. **Use colorScheme** semantic names (primary, secondary, error, etc.)
4. **Test in both light and dark modes**
5. **Use onPrimary, onSecondary, etc.** for text/icons on colored backgrounds
6. **Use surfaceVariant** for input fields and subtle backgrounds
7. **Use outlineVariant** for subtle borders and dividers

### ❌ DON'T

1. **Don't hardcode Colors.*** values
2. **Don't hardcode Color(0x...)** hex values
3. **Don't use AppColors directly** (it's legacy)
4. **Don't hardcode TextStyle** properties when theme styles exist
5. **Don't assume white or black** for backgrounds
6. **Don't use Colors.grey[...]** - use theme variants instead

---

## Migration Checklist

### When Creating New Screens

- [ ] Import `package:flutter/material.dart`
- [ ] Use `Theme.of(context)` for all colors
- [ ] Use `Theme.of(context).textTheme` for text styles
- [ ] Test screen in light mode
- [ ] Test screen in dark mode
- [ ] Verify text visibility on all backgrounds
- [ ] Check icon colors
- [ ] Verify button states (enabled/disabled)

### When Updating Existing Screens

- [ ] Search for `Colors.` usage
- [ ] Replace with `Theme.of(context).colorScheme.*`
- [ ] Search for `Color(0x` hex values
- [ ] Replace with theme colors
- [ ] Search for `AppColors.` usage
- [ ] Replace with M3 color scheme
- [ ] Update text styles to use `textTheme`
- [ ] Test in both themes

---

## Quick Reference

### Color Mapping

| Old Pattern | New Pattern |
|-------------|-------------|
| `Colors.blue` | `Theme.of(context).colorScheme.primary` |
| `Colors.white` | `Theme.of(context).colorScheme.onPrimary` |
| `Colors.black` | `Theme.of(context).colorScheme.onSurface` |
| `Colors.grey` | `Theme.of(context).colorScheme.onSurfaceVariant` |
| `Colors.grey[200]` | `Theme.of(context).colorScheme.surfaceVariant` |
| `Colors.red` | `Theme.of(context).colorScheme.error` |
| `Colors.green` | `Theme.of(context).colorScheme.primary` |
| `AppColors.primaryBlue` | `Theme.of(context).colorScheme.primary` |
| `AppColors.secondaryGreen` | `Theme.of(context).colorScheme.secondary` |
| `AppColors.accentOrange` | `Theme.of(context).colorScheme.tertiary` |

### Text Style Mapping

| Old Pattern | New Pattern |
|-------------|-------------|
| `AppTextStyles.heading1` | `Theme.of(context).textTheme.displayLarge` |
| `AppTextStyles.heading2` | `Theme.of(context).textTheme.headlineMedium` |
| `AppTextStyles.heading3` | `Theme.of(context).textTheme.headlineSmall` |
| `AppTextStyles.bodyLarge` | `Theme.of(context).textTheme.bodyLarge` |
| `AppTextStyles.bodyMedium` | `Theme.of(context).textTheme.bodyMedium` |
| `AppTextStyles.bodySmall` | `Theme.of(context).textTheme.bodySmall` |
| `AppTextStyles.button` | `Theme.of(context).textTheme.labelLarge` |
| `AppTextStyles.caption` | `Theme.of(context).textTheme.labelSmall` |

---

## Testing Checklist

### Visual Testing

- [ ] Screen renders correctly in light mode
- [ ] Screen renders correctly in dark mode
- [ ] Text is readable on all backgrounds
- [ ] Icons have proper contrast
- [ ] Buttons are clearly visible
- [ ] Error states are visible
- [ ] Loading states are visible
- [ ] Disabled states are distinguishable

### Theme Switching

- [ ] Theme switches without errors
- [ ] Colors update immediately
- [ ] No white/black flashes
- [ ] Text remains readable
- [ ] Icons update correctly

---

## Support and Resources

- **Material Design 3**: https://m3.material.io/
- **Flutter Theming**: https://docs.flutter.dev/cookbook/design/themes
- **Color Scheme**: https://m3.material.io/styles/color/overview
- **Typography**: https://m3.material.io/styles/typography/overview

---

## Updates

**Last Updated**: November 1, 2024
**Version**: 1.0.0
**Status**: ✅ Complete

All screens have been migrated to use the M3 Expressive theme system. No hardcoded colors remain in the codebase.
