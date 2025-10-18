import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../theme/m3_expressive_colors.dart';
import '../theme/m3_expressive_motion.dart';
import '../theme/m3_expressive_typography.dart';

/// Animated Material 3 Expressive Card
class M3ExpressiveCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? elevation;
  final BorderRadius? borderRadius;
  final bool enableHoverEffect;
  
  const M3ExpressiveCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.borderRadius,
    this.enableHoverEffect = true,
  });
  
  @override
  State<M3ExpressiveCard> createState() => _M3ExpressiveCardState();
}

class _M3ExpressiveCardState extends State<M3ExpressiveCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: M3Durations.short4,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: M3Easings.standard),
    );
    
    _elevationAnimation = Tween<double>(
      begin: widget.elevation ?? 1,
      end: (widget.elevation ?? 1) + 2,
    ).animate(
      CurvedAnimation(parent: _controller, curve: M3Easings.standard),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _onHover(bool hovering) {
    if (!widget.enableHoverEffect) return;
    
    setState(() => _isHovered = hovering);
    if (hovering) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: MouseRegion(
            onEnter: (_) => _onHover(true),
            onExit: (_) => _onHover(false),
            child: Card(
              elevation: _elevationAnimation.value,
              color: widget.color,
              margin: widget.margin,
              shape: RoundedRectangleBorder(
                borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
                child: Padding(
                  padding: widget.padding ?? const EdgeInsets.all(16),
                  child: widget.child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Animated Event Card with Iconsax Icons
class M3EventCard extends StatelessWidget {
  final String title;
  final String description;
  final String date;
  final String category;
  final VoidCallback? onTap;
  final String? imageUrl;
  
  const M3EventCard({
    super.key,
    required this.title,
    required this.description,
    required this.date,
    required this.category,
    this.onTap,
    this.imageUrl,
  });
  
  IconData _getCategoryIcon() {
    switch (category.toLowerCase()) {
      case 'academic':
        return Iconsax.book_1;
      case 'cultural':
        return Iconsax.music;
      case 'sports':
        return Iconsax.cup;
      case 'workshop':
        return Iconsax.teacher;
      case 'seminar':
        return Iconsax.microphone;
      default:
        return Iconsax.calendar;
    }
  }
  
  Color _getCategoryColor() {
    switch (category.toLowerCase()) {
      case 'academic':
        return M3ExpressiveColors.primaryBlue;
      case 'cultural':
        return M3ExpressiveColors.tertiaryAmber;
      case 'sports':
        return M3ExpressiveColors.success;
      case 'workshop':
        return M3ExpressiveColors.secondaryTeal;
      case 'seminar':
        return M3ExpressiveColors.info;
      default:
        return M3ExpressiveColors.neutral50;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final categoryColor = _getCategoryColor();
    
    return M3ExpressiveCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category badge with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getCategoryIcon(),
                      size: 16,
                      color: categoryColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      category,
                      style: M3ExpressiveTypography.labelSmall.copyWith(
                        color: categoryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Icon(
                Iconsax.arrow_right_3,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Title
          Text(
            title,
            style: M3ExpressiveTypography.titleLarge,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          
          // Description
          Text(
            description,
            style: M3ExpressiveTypography.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          
          // Date and location
          Row(
            children: [
              Icon(
                Iconsax.calendar_1,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  date,
                  style: M3ExpressiveTypography.bodySmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Animated Faculty Card with Iconsax Icons
class M3FacultyCard extends StatelessWidget {
  final String name;
  final String department;
  final String designation;
  final String? email;
  final String? phone;
  final VoidCallback? onTap;
  final String? imageUrl;
  
  const M3FacultyCard({
    super.key,
    required this.name,
    required this.department,
    required this.designation,
    this.email,
    this.phone,
    this.onTap,
    this.imageUrl,
  });
  
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return M3ExpressiveCard(
      onTap: onTap,
      child: Row(
        children: [
          // Avatar with animation
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: M3ExpressiveColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Iconsax.user,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: M3ExpressiveTypography.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  designation,
                  style: M3ExpressiveTypography.bodySmall.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Iconsax.building,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        department,
                        style: M3ExpressiveTypography.bodySmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Arrow
          Icon(
            Iconsax.arrow_right_3,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

/// Animated Statistics Card
class M3StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;
  
  const M3StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? M3ExpressiveColors.primaryBlue;
    
    return M3ExpressiveCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: cardColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: M3ExpressiveTypography.displaySmall.copyWith(
              color: cardColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: M3ExpressiveTypography.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated FAB with Iconsax
class M3ExpressiveFAB extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? label;
  final bool extended;
  
  const M3ExpressiveFAB({
    super.key,
    required this.onPressed,
    required this.icon,
    this.label,
    this.extended = false,
  });
  
  @override
  State<M3ExpressiveFAB> createState() => _M3ExpressiveFABState();
}

class _M3ExpressiveFABState extends State<M3ExpressiveFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: M3Durations.medium2,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: M3Easings.standard),
    );
    
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _controller, curve: M3Easings.expressiveSpring),
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: widget.extended && widget.label != null
                ? FloatingActionButton.extended(
                    onPressed: _handleTap,
                    icon: Icon(widget.icon),
                    label: Text(widget.label!),
                  )
                : FloatingActionButton(
                    onPressed: _handleTap,
                    child: Icon(widget.icon),
                  ),
          ),
        );
      },
    );
  }
}
