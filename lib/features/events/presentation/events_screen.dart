import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/widgets/enhanced_cards.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/theme/app_decorations.dart';
import 'event_provider.dart';
import 'event_detail_screen.dart';
import 'create_edit_event_screen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().loadUpcomingEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final eventProvider = context.watch<EventProvider>();
    final isFaculty = authProvider.currentUser?.role == 'faculty';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        actions: [
          // Filter chips in a horizontal scrollable row
          PopupMenuButton<EventFilter>(
            icon: const Icon(Icons.filter_list),
            onSelected: (filter) {
              eventProvider.setFilter(filter);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: EventFilter.all,
                child: Text('All Events'),
              ),
              const PopupMenuItem(
                value: EventFilter.upcoming,
                child: Text('Upcoming'),
              ),
              const PopupMenuItem(
                value: EventFilter.today,
                child: Text('Today'),
              ),
              const PopupMenuItem(
                value: EventFilter.past,
                child: Text('Past Events'),
              ),
            ],
          ),
        ],
      ),
      body: CustomPullToRefresh(
        onRefresh: () => eventProvider.refresh(),
        child: eventProvider.isLoading
            ? const SkeletonPage(itemCount: 5, hasAppBar: false)
            : eventProvider.error != null
                ? EmptyStateWidget(
                    icon: Icons.error_outline,
                    title: 'Error loading events',
                    message: eventProvider.error!,
                    action: ElevatedButton.icon(
                      onPressed: () => eventProvider.refresh(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  )
                : eventProvider.filteredEvents.isEmpty
                    ? EmptyStateWidget(
                        icon: Icons.event_busy,
                        title: 'No events found',
                        message: isFaculty
                            ? 'Tap + to create your first event'
                            : 'Check back later for upcoming events',
                      )
                    : AnimationLimiter(
                        child: ListView.builder(
                          padding: EdgeInsets.all(AppDecorations.spaceSM),
                          itemCount: eventProvider.filteredEvents.length,
                          itemBuilder: (context, index) {
                            final event = eventProvider.filteredEvents[index];
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 375),
                              child: SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: EnhancedEventCard(
                                    event: event,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EventDetailScreen(event: event),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
      ),
      floatingActionButton: isFaculty
          ? AnimatedFAB(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateEditEventScreen(),
                  ),
                );
              },
              icon: Icons.add,
              tooltip: 'Create Event',
              isExtended: true,
              label: 'Create Event',
              backgroundColor: Theme.of(context).colorScheme.primary,
            )
          : null,
    );
  }
}

