import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart' as theme_styles;
import '../../core/theme/app_decorations.dart';
import '../../core/widgets/enhanced_cards.dart';
import '../../core/widgets/custom_widgets.dart';
import '../events/presentation/event_provider.dart';
import '../faculty/presentation/faculty_provider.dart';
import '../notifications/presentation/notification_provider.dart';
import '../auth/presentation/profile_screen.dart';
import '../events/presentation/create_edit_event_screen.dart';
import '../notifications/presentation/notifications_screen.dart';

class EnhancedHomeScreen extends StatefulWidget {
  const EnhancedHomeScreen({super.key});

  @override
  State<EnhancedHomeScreen> createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends State<EnhancedHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();

    // Load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) return;
    
    await Future.wait([
      context.read<EventProvider>().loadUpcomingEvents(),
      context.read<FacultyProvider>().loadFaculty(),
      context.read<NotificationProvider>().loadNotifications(userId),
    ]);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPullToRefresh(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            SizedBox(height: AppDecorations.spaceLG),
            _buildStatsSection(),
            SizedBox(height: AppDecorations.spaceLG),
            _buildQuickActionsSection(),
            SizedBox(height: AppDecorations.spaceLG),
            _buildRecentEventsSection(),
            SizedBox(height: AppDecorations.spaceLG),
            _buildFacultyFeatures(),
            SizedBox(height: AppDecorations.spaceXL),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final user = context.watch<AuthProvider>().currentUser;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                user?.isFaculty == true
                    ? AppColors.secondaryGreen
                    : AppColors.primaryBlue,
                user?.isFaculty == true
                    ? AppColors.secondaryDark
                    : AppColors.primaryDark,
              ],
            ),
          ),
          padding: EdgeInsets.all(AppDecorations.spaceLG),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getGreeting(),
                            style: theme_styles.AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          SizedBox(height: AppDecorations.spaceXS),
                          Text(
                            user?.name ?? 'User',
                            style: theme_styles.AppTextStyles.h2.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.white,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.person,
                          color: AppColors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppDecorations.spaceSM),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDecorations.spaceMD,
                    vertical: AppDecorations.spaceXS,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppDecorations.radiusCircle),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        user?.isFaculty == true
                            ? Icons.school
                            : Icons.person_outline,
                        size: 16,
                        color: AppColors.white,
                      ),
                      SizedBox(width: AppDecorations.spaceXS),
                      Text(
                        user?.isFaculty == true ? 'Faculty' : 'Student',
                        style: theme_styles.AppTextStyles.bodySmall.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
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

  Widget _buildStatsSection() {
    final eventProvider = context.watch<EventProvider>();
    final facultyProvider = context.watch<FacultyProvider>();
    final notificationProvider = context.watch<NotificationProvider>();

    return AnimationLimiter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppDecorations.spaceMD),
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: AppDecorations.spaceMD,
          crossAxisSpacing: AppDecorations.spaceMD,
          childAspectRatio: 1.5,
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 375),
            childAnimationBuilder: (widget) => SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: widget,
              ),
            ),
            children: [
              StatsCard(
                title: 'Upcoming Events',
                value: '${eventProvider.events.length}',
                icon: Icons.event,
                color: AppColors.primaryBlue,
              ),
              StatsCard(
                title: 'Faculty Members',
                value: '${facultyProvider.filteredFaculty.length}',
                icon: Icons.people,
                color: AppColors.secondaryGreen,
              ),
              StatsCard(
                title: 'Notifications',
                value: '${notificationProvider.unreadCount}',
                icon: Icons.notifications,
                color: AppColors.accentOrange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
              ),
              StatsCard(
                title: 'Campus Locations',
                value: '10+',
                icon: Icons.location_on,
                color: AppColors.accentRed,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(AppDecorations.spaceMD),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDecorations.radiusMD),
          ),
          child: Icon(
            Icons.flash_on,
            color: AppColors.primaryBlue,
            size: 24,
          ),
        ),
        SizedBox(height: AppDecorations.spaceSM),
        Text(
          'Quick Actions',
          style: theme_styles.AppTextStyles.h4,
        ),
      ],
    );
  }

  Widget _buildRecentEventsSection() {
    final eventProvider = context.watch<EventProvider>();
    final recentEvents = eventProvider.events.take(3).toList();

    if (recentEvents.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDecorations.spaceMD),
          child: Row(
            children: [
              Icon(Icons.event_note, color: AppColors.grey700),
              SizedBox(width: AppDecorations.spaceSM),
              Text(
                'Upcoming Events',
                style: theme_styles.AppTextStyles.h4,
              ),
            ],
          ),
        ),
        SizedBox(height: AppDecorations.spaceMD),
        AnimationLimiter(
          child: Column(
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 375),
              childAnimationBuilder: (widget) => SlideAnimation(
                horizontalOffset: 50.0,
                child: FadeInAnimation(
                  child: widget,
                ),
              ),
              children: recentEvents
                  .map((event) => Padding(
                        padding: EdgeInsets.only(
                          bottom: AppDecorations.spaceSM,
                        ),
                        child: EnhancedEventCard(
                          event: event,
                          showImage: true,
                          onTap: () {
                            // Navigate to event detail
                          },
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFacultyFeatures() {
    final user = context.watch<AuthProvider>().currentUser;
    if (user?.isFaculty != true) {
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: AppDecorations.spaceMD),
        padding: EdgeInsets.all(AppDecorations.spaceLG),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.secondaryGreen.withValues(alpha: 0.1),
              AppColors.secondaryLight.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(AppDecorations.radiusLG),
          border: Border.all(
            color: AppColors.secondaryGreen.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppDecorations.spaceSM),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryGreen.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppDecorations.radiusSM),
                  ),
                  child: Icon(
                    Icons.admin_panel_settings,
                    color: AppColors.secondaryGreen,
                    size: 32,
                  ),
                ),
                SizedBox(width: AppDecorations.spaceMD),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Faculty Dashboard',
                        style: theme_styles.AppTextStyles.h4.copyWith(
                          color: AppColors.secondaryDark,
                        ),
                      ),
                      SizedBox(height: AppDecorations.spaceXS),
                      Text(
                        'Manage events and announcements',
                        style: theme_styles.AppTextStyles.bodySmall.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppDecorations.spaceMD),
            const DividerWithText(text: 'Available Actions'),
            SizedBox(height: AppDecorations.spaceMD),
            _buildFacultyAction(
              icon: Icons.add_circle,
              title: 'Create Event',
              description: 'Add a new campus event',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateEditEventScreen(),
                  ),
                );
              },
            ),
            SizedBox(height: AppDecorations.spaceSM),
            _buildFacultyAction(
              icon: Icons.campaign,
              title: 'Send Announcement',
              description: 'Broadcast to all users',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacultyAction({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDecorations.radiusMD),
      child: Padding(
        padding: EdgeInsets.all(AppDecorations.spaceSM),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.secondaryGreen,
              size: 24,
            ),
            SizedBox(width: AppDecorations.spaceMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme_styles.AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    description,
                    style: theme_styles.AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.grey400,
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }
}
