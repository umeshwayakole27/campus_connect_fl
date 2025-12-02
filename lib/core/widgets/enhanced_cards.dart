import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../theme/app_text_styles.dart' as theme_styles;
import '../theme/app_decorations.dart';
import '../theme/app_animations.dart';
import '../theme/theme_helper.dart';
import '../models/event_model.dart';
import '../models/faculty_model.dart';

/// Enhanced Event Card with image, gradient overlay, and animations
class EnhancedEventCard extends StatefulWidget {
  final Event event;
  final VoidCallback onTap;
  final bool showImage;

  const EnhancedEventCard({
    super.key,
    required this.event,
    required this.onTap,
    this.showImage = true,
  });

  @override
  State<EnhancedEventCard> createState() => _EnhancedEventCardState();
}

class _EnhancedEventCardState extends State<EnhancedEventCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.durationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.curveSmooth),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final eventDate = widget.event.time;
    final isUpcoming = eventDate.isAfter(DateTime.now());
    final isPast = eventDate.isBefore(DateTime.now());
    final timeString = DateFormat('hh:mm a').format(eventDate);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: AppDecorations.spaceMD,
            vertical: AppDecorations.spaceSM,
          ),
          decoration: AppDecorations.elevatedCardDecoration(context: context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Details
              Padding(
                padding: EdgeInsets.all(AppDecorations.spaceMD),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with Event Icon
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(AppDecorations.spaceSM),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(AppDecorations.radiusSM),
                          ),
                          child: Icon(
                            Icons.event,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: AppDecorations.spaceSM),
                        Expanded(
                          child: Text(
                            widget.event.title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppDecorations.spaceSM),

                    // Description
                    if (widget.event.description != null && widget.event.description!.isNotEmpty)
                      Text(
                        widget.event.description!,
                        style: theme_styles.AppTextStyles.bodyMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    SizedBox(height: AppDecorations.spaceMD),

                    // Date, Time, Location
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: AppDecorations.spaceXS),
                        Text(
                          DateFormat('MMM dd, yyyy').format(eventDate),
                          style: theme_styles.AppTextStyles.bodySmall.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(width: AppDecorations.spaceMD),
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: AppDecorations.spaceXS),
                        Text(
                          timeString,
                          style: theme_styles.AppTextStyles.bodySmall.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    if (widget.event.location != null && widget.event.location!.isNotEmpty) ...[
                      SizedBox(height: AppDecorations.spaceXS),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          SizedBox(width: AppDecorations.spaceXS),
                          Expanded(
                            child: Text(
                              widget.event.location!,
                              style: theme_styles.AppTextStyles.bodySmall.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Status Badge
                    SizedBox(height: AppDecorations.spaceSM),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDecorations.spaceSM,
                        vertical: AppDecorations.spaceXS,
                      ),
                      decoration: BoxDecoration(
                        color: isPast
                            ? Theme.of(context).colorScheme.surfaceVariant
                            : isUpcoming
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Theme.of(context).colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(AppDecorations.radiusSM),
                      ),
                      child: Text(
                        isPast
                            ? 'Past Event'
                            : isUpcoming
                                ? 'Upcoming'
                                : 'Today',
                        style: theme_styles.AppTextStyles.labelSmall.copyWith(
                          color: isPast
                              ? Theme.of(context).colorScheme.onSurfaceVariant
                              : isUpcoming
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.tertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Enhanced Faculty Card with avatar and contact actions
class EnhancedFacultyCard extends StatefulWidget {
  final Faculty faculty;
  final VoidCallback onTap;
  final bool isGridView;

  const EnhancedFacultyCard({
    super.key,
    required this.faculty,
    required this.onTap,
    this.isGridView = false,
  });

  @override
  State<EnhancedFacultyCard> createState() => _EnhancedFacultyCardState();
}

class _EnhancedFacultyCardState extends State<EnhancedFacultyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.durationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.curveSmooth),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isGridView) {
      return _buildGridCard();
    } else {
      return _buildListCard();
    }
  }

  Widget _buildGridCard() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: Container(
          decoration: AppDecorations.cardDecoration(context: context),
          padding: EdgeInsets.all(AppDecorations.spaceMD),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar
              CircleAvatar(
                radius: 40,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: widget.faculty.userAvatarUrl != null
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: widget.faculty.userAvatarUrl!,
                          fit: BoxFit.cover,
                          width: 80,
                          height: 80,
                          errorWidget: (context, url, error) => Icon(
                            Icons.person,
                            size: 40,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.person,
                        size: 40,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
              ),
              SizedBox(height: AppDecorations.spaceSM),

              // Name
              Text(
                widget.faculty.userName ?? 'Unknown',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: AppDecorations.spaceXS),

              // Department
              Text(
                widget.faculty.department,
                style: theme_styles.AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListCard() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: AppDecorations.spaceMD,
            vertical: AppDecorations.spaceXS,
          ),
          decoration: AppDecorations.cardDecoration(context: context),
          child: ListTile(
            contentPadding: EdgeInsets.all(AppDecorations.spaceMD),
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: widget.faculty.userAvatarUrl != null
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: widget.faculty.userAvatarUrl!,
                        fit: BoxFit.cover,
                        width: 60,
                        height: 60,
                        errorWidget: (context, url, error) => Icon(
                          Icons.person,
                          size: 30,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: 30,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
            ),
            title: Text(
              widget.faculty.userName ?? 'Unknown',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppDecorations.spaceXS),
                Text(
                  widget.faculty.department,
                  style: theme_styles.AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (widget.faculty.officeLocation != null && widget.faculty.officeLocation!.isNotEmpty) ...[
                  SizedBox(height: AppDecorations.spaceXS),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.faculty.officeLocation!,
                          style: theme_styles.AppTextStyles.bodySmall.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: ThemeHelper.iconSecondary(context),
            ),
          ),
        ),
      ),
    );
  }
}

/// Stats Card with icon and animated number
class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppDecorations.spaceXS),
        decoration: AppDecorations.gradientCardDecoration(
          context: context,
          gradient: LinearGradient(
            colors: [
              color,
              color.withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppDecorations.spaceXS),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(AppDecorations.radiusSM),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    if (onTap != null)
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 16,
                      ),
                  ],
                ),
                Text(
                  value,
                  style: theme_styles.AppTextStyles.h2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: theme_styles.AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Notification Card with swipe to delete
class NotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final VoidCallback onTap;
  final VoidCallback onDismiss;
  final String type;

  const NotificationCard({
    super.key,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
    required this.onTap,
    required this.onDismiss,
    this.type = 'general',
  });

  Color _getTypeColor(BuildContext context) {
    switch (type.toLowerCase()) {
      case 'event':
        return Theme.of(context).colorScheme.primary;
      case 'announcement':
        return Theme.of(context).colorScheme.tertiary;
      case 'alert':
        return Theme.of(context).colorScheme.error;
      default:
        return Theme.of(context).colorScheme.outline;
    }
  }

  IconData _getTypeIcon() {
    switch (type.toLowerCase()) {
      case 'event':
        return Icons.event;
      case 'announcement':
        return Icons.campaign;
      case 'alert':
        return Icons.warning;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    String timeAgo;

    if (difference.inDays > 0) {
      timeAgo = '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      timeAgo = '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      timeAgo = '${difference.inMinutes}m ago';
    } else {
      timeAgo = 'Just now';
    }

    return Dismissible(
      key: Key(timestamp.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: AppDecorations.spaceLG),
        color: Theme.of(context).colorScheme.error,
        child: Icon(
          Icons.delete,
          color: Theme.of(context).colorScheme.onError,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: AppDecorations.spaceMD,
            vertical: AppDecorations.spaceXS,
          ),
          decoration: AppDecorations.elevatedCardDecoration(
            context: context,
            color: isRead 
                ? null  // Use default surfaceContainerHighest
                : Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2),
          ),
          child: Padding(
            padding: EdgeInsets.all(AppDecorations.spaceMD),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type Icon
                Container(
                  padding: EdgeInsets.all(AppDecorations.spaceSM),
                  decoration: BoxDecoration(
                    color: _getTypeColor(context).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDecorations.radiusSM),
                  ),
                  child: Icon(
                    _getTypeIcon(),
                    color: _getTypeColor(context),
                    size: 24,
                  ),
                ),
                SizedBox(width: AppDecorations.spaceMD),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              margin: EdgeInsets.only(left: AppDecorations.spaceXS),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: AppDecorations.spaceXS),
                      Text(
                        message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: AppDecorations.spaceXS),
                      Text(
                        timeAgo,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
