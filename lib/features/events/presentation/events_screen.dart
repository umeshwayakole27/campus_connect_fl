import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/event_model.dart';
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
          // Filter dropdown
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
      body: RefreshIndicator(
        onRefresh: () => eventProvider.refresh(),
        child: eventProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : eventProvider.error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading events',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          eventProvider.error!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => eventProvider.refresh(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : eventProvider.filteredEvents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No events found',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isFaculty
                                  ? 'Tap + to create your first event'
                                  : 'Check back later for upcoming events',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: eventProvider.filteredEvents.length,
                        itemBuilder: (context, index) {
                          final event = eventProvider.filteredEvents[index];
                          return EventCard(
                            event: event,
                            isFaculty: isFaculty,
                            isMyEvent: event.createdBy == authProvider.currentUser?.id,
                          );
                        },
                      ),
      ),
      floatingActionButton: isFaculty
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateEditEventScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Event'),
            )
          : null,
    );
  }
}

class EventCard extends StatelessWidget {
  final Event event;
  final bool isFaculty;
  final bool isMyEvent;

  const EventCard({
    super.key,
    required this.event,
    required this.isFaculty,
    required this.isMyEvent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final isPast = event.time.isBefore(now);
    final isToday = event.time.year == now.year &&
        event.time.month == now.month &&
        event.time.day == now.day;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: isPast ? 1 : 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailScreen(event: event),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date badge
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isPast
                      ? Colors.grey[300]
                      : isToday
                          ? theme.colorScheme.primary
                          : theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('MMM').format(event.time).toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isPast
                            ? Colors.grey[600]
                            : isToday
                                ? Colors.white
                                : theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      DateFormat('dd').format(event.time),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isPast
                            ? Colors.grey[600]
                            : isToday
                                ? Colors.white
                                : theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Event details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isPast ? Colors.grey[600] : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isMyEvent)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'My Event',
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('h:mm a').format(event.time),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    if (event.location != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.location!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (event.description != null && event.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        event.description!,
                        style: theme.textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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
