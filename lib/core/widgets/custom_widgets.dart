import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart' as theme_styles;
import '../theme/app_decorations.dart';
import '../theme/app_animations.dart';
import '../theme/theme_helper.dart';

/// Animated Search Bar with focus animations
class AnimatedSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final VoidCallback? onSearch;
  final bool autofocus;

  const AnimatedSearchBar({
    super.key,
    required this.controller,
    this.hintText = 'Search...',
    this.onChanged,
    this.onClear,
    this.onSearch,
    this.autofocus = false,
  });

  @override
  State<AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppAnimations.durationNormal,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.curveSmooth,
      ),
    );

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });

    if (widget.autofocus) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        onChanged: widget.onChanged,
        onSubmitted: (_) => widget.onSearch?.call(),
        style: theme_styles.AppTextStyles.bodyLarge.copyWith(
          color: ThemeHelper.textPrimary(context),
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: theme_styles.AppTextStyles.bodyMedium.copyWith(
            color: ThemeHelper.textHint(context),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: ThemeHelper.iconSecondary(context),
          ),
          suffixIcon: widget.controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: ThemeHelper.iconSecondary(context),
                  ),
                  onPressed: () {
                    widget.controller.clear();
                    widget.onClear?.call();
                  },
                )
              : null,
          filled: true,
          fillColor: ThemeHelper.surfaceVariant(context),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDecorations.radiusLG),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDecorations.radiusLG),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDecorations.radiusLG),
            borderSide: BorderSide(
              color: ThemeHelper.primary(context),
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppDecorations.spaceMD,
            vertical: AppDecorations.spaceSM,
          ),
        ),
      ),
    );
  }
}

/// Filter Chip with selection animation
class AnimatedFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  const AnimatedFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: AppDecorations.spaceSM),
      child: AnimatedContainer(
        duration: AppAnimations.durationFast,
        curve: AppAnimations.curveSmooth,
        decoration: AppDecorations.chipDecoration(
          selected: selected,
          backgroundColor: selected 
              ? ThemeHelper.primary(context) 
              : ThemeHelper.surfaceVariant(context),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppDecorations.radiusCircle),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDecorations.spaceMD,
                vertical: AppDecorations.spaceSM,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 16,
                      color: selected 
                          ? ThemeHelper.onPrimary(context) 
                          : ThemeHelper.onSurfaceVariant(context),
                    ),
                    SizedBox(width: AppDecorations.spaceXS),
                  ],
                  Text(
                    label,
                    style: theme_styles.AppTextStyles.bodySmall.copyWith(
                      color: selected 
                          ? ThemeHelper.onPrimary(context) 
                          : ThemeHelper.onSurfaceVariant(context),
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom Badge with pulse animation
class AnimatedBadge extends StatefulWidget {
  final String text;
  final Color color;
  final bool animate;

  const AnimatedBadge({
    super.key,
    required this.text,
    this.color = Colors.red,
    this.animate = true,
  });

  @override
  State<AnimatedBadge> createState() => _AnimatedBadgeState();
}

class _AnimatedBadgeState extends State<AnimatedBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppDecorations.spaceXS,
          vertical: 2,
        ),
        decoration: AppDecorations.badgeDecoration(
          color: widget.color,
        ),
        constraints: const BoxConstraints(
          minWidth: 20,
          minHeight: 20,
        ),
        child: Center(
          child: Text(
            widget.text,
            style: theme_styles.AppTextStyles.labelSmall.copyWith(
              color: ThemeHelper.onPrimary(context),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated FAB with rotation
class AnimatedFAB extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String tooltip;
  final Color? backgroundColor;
  final bool isExtended;
  final String? label;

  const AnimatedFAB({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.tooltip,
    this.backgroundColor,
    this.isExtended = false,
    this.label,
  });

  @override
  State<AnimatedFAB> createState() => _AnimatedFABState();
}

class _AnimatedFABState extends State<AnimatedFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.durationNormal,
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.125).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppAnimations.curveSmooth,
      ),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppAnimations.curveSmooth,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: RotationTransition(
        turns: _rotationAnimation,
        child: widget.isExtended && widget.label != null
            ? FloatingActionButton.extended(
                onPressed: _handleTap,
                icon: Icon(
                  widget.icon,
                  color: ThemeHelper.onPrimary(context),
                ),
                label: Text(
                  widget.label!,
                  style: TextStyle(color: ThemeHelper.onPrimary(context)),
                ),
                tooltip: widget.tooltip,
                backgroundColor: widget.backgroundColor ?? ThemeHelper.primary(context),
              )
            : FloatingActionButton(
                onPressed: _handleTap,
                tooltip: widget.tooltip,
                backgroundColor: widget.backgroundColor ?? ThemeHelper.primary(context),
                child: Icon(
                  widget.icon,
                  color: ThemeHelper.onPrimary(context),
                ),
              ),
      ),
    );
  }
}

/// Pull to Refresh Wrapper
class CustomPullToRefresh extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const CustomPullToRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: ThemeHelper.primary(context),
      backgroundColor: ThemeHelper.surface(context),
      strokeWidth: 3,
      displacement: 40,
      child: child,
    );
  }
}

/// Section Header with action button
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;
  final IconData? icon;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onActionTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppDecorations.spaceMD,
        vertical: AppDecorations.spaceSM,
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 24,
              color: ThemeHelper.iconPrimary(context),
            ),
            SizedBox(width: AppDecorations.spaceSM),
          ],
          Expanded(
            child: Text(
              title,
              style: theme_styles.AppTextStyles.h4.copyWith(
                color: ThemeHelper.textPrimary(context),
              ),
            ),
          ),
          if (actionText != null && onActionTap != null)
            TextButton(
              onPressed: onActionTap,
              child: Text(
                actionText!,
                style: theme_styles.AppTextStyles.link.copyWith(
                  color: ThemeHelper.primary(context),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Custom Bottom Sheet
class CustomBottomSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: AppDecorations.bottomSheetDecoration(),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null) ...[
              Padding(
                padding: EdgeInsets.all(AppDecorations.spaceMD),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: theme_styles.AppTextStyles.h4.copyWith(
                          color: ThemeHelper.textPrimary(context),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: ThemeHelper.divider(context)),
            ],
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppDecorations.spaceMD),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Divider with text
class DividerWithText extends StatelessWidget {
  final String text;

  const DividerWithText({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: ThemeHelper.divider(context),
            thickness: 1,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDecorations.spaceMD),
          child: Text(
            text,
            style: theme_styles.AppTextStyles.bodySmall.copyWith(
              color: ThemeHelper.textSecondary(context),
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: ThemeHelper.divider(context),
            thickness: 1,
          ),
        ),
      ],
    );
  }
}

/// Quick Action Button
class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? ThemeHelper.primary(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDecorations.radiusMD),
      child: Container(
        padding: EdgeInsets.all(AppDecorations.spaceMD),
        decoration: AppDecorations.cardDecoration(context: context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(AppDecorations.spaceMD),
              decoration: BoxDecoration(
                color: buttonColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDecorations.radiusMD),
              ),
              child: Icon(
                icon,
                size: 32,
                color: buttonColor,
              ),
            ),
            SizedBox(height: AppDecorations.spaceSM),
            Text(
              label,
              style: theme_styles.AppTextStyles.bodySmall.copyWith(
                color: ThemeHelper.textPrimary(context),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
