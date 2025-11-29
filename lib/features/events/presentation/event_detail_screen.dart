import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/event_model.dart';
import '../../campus_map/data/location_repository.dart';
import '../../campus_map/presentation/campus_map_screen.dart';
import 'event_provider.dart';
import 'create_edit_event_screen.dart';

class EventDetailScreen extends StatelessWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final eventProvider = context.watch<EventProvider>();
    final theme = Theme.of(context);
    
    final isFaculty = authProvider.currentUser?.role == 'faculty';
    final isMyEvent = event.createdBy == authProvider.currentUser?.id;
    final canManage = isFaculty && isMyEvent;

    final now = DateTime.now();
    final isPast = event.time.isBefore(now);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: canManage
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateEditEventScreen(event: event),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _showDeleteDialog(context, eventProvider),
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event header with date/time
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isPast
                      ? [
                          theme.colorScheme.surfaceVariant,
                          theme.colorScheme.outline,
                        ]
                      : [
                          theme.colorScheme.primary,
                          theme.colorScheme.primaryContainer,
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isMyEvent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onPrimary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Your Event',
                        style: TextStyle(
                          color: isPast ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.onPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (isMyEvent) const SizedBox(height: 8),
                  Text(
                    event.title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: isPast ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, 
                        color: isPast ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.onPrimary, 
                        size: 20),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('EEEE, MMMM dd, yyyy').format(event.time),
                        style: TextStyle(
                          color: isPast ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.onPrimary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, 
                        color: isPast ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.onPrimary, 
                        size: 20),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('h:mm a').format(event.time),
                        style: TextStyle(
                          color: isPast ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.onPrimary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Event details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  if (event.description != null && event.description!.isNotEmpty) ...[
                    _buildSectionTitle(context, 'Description'),
                    const SizedBox(height: 8),
                    Text(
                      event.description!,
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Location
                  if (event.location != null) ...[
                    _buildSectionTitle(context, 'Location'),
                    const SizedBox(height: 8),
                    Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.location_on,
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(
                          event.location!,
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                        subtitle: event.locationId != null
                            ? Text(
                                'Tap to view on map',
                                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                              )
                            : null,
                        trailing: event.locationId != null
                            ? Icon(
                                Icons.arrow_forward_ios, 
                                size: 16,
                                color: theme.colorScheme.onSurfaceVariant,
                              )
                            : null,
                        onTap: event.locationId != null
                            ? () => _navigateToMap(context, event.locationId!, event.location!)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Organizer info
                  _buildSectionTitle(context, 'Organized By'),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Icon(
                          Icons.person,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      title: Text(
                        event.createdBy ?? 'Unknown',
                        style: TextStyle(color: theme.colorScheme.onSurface),
                      ),
                      subtitle: Text(
                        'Faculty',
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
    );
  }

  Future<void> _navigateToMap(BuildContext context, String locationId, String locationName) async {
    try {
      final locationRepository = LocationRepository();
      final location = await locationRepository.getLocationById(locationId);
      
      if (location != null && context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CampusMapScreen(
              targetLocation: LatLng(location.lat, location.lng),
              targetLocationName: locationName,
            ),
          ),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location not found'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load location: $e'),
          ),
        );
      }
    }
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    EventProvider eventProvider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text(
          'Are you sure you want to delete this event? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await eventProvider.deleteEvent(event.id);
      if (success && context.mounted) {
        Navigator.pop(context); // Return to events list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event deleted successfully')),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to delete event'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
