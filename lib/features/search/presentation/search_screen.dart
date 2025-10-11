import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../core/providers/auth_provider.dart';
import 'search_provider.dart';
import '../../events/presentation/event_detail_screen.dart';
import '../../faculty/presentation/faculty_detail_screen.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/empty_state_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final searchProvider = context.read<SearchProvider>();
      final authProvider = context.read<AuthProvider>();
      
      if (authProvider.currentUser != null) {
        searchProvider.loadSearchHistory(authProvider.currentUser!.id);
        searchProvider.loadPopularSearches();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final searchProvider = context.read<SearchProvider>();
      searchProvider.search(query);
      
      // Save to history if query is not empty
      if (query.trim().isNotEmpty) {
        final authProvider = context.read<AuthProvider>();
        if (authProvider.currentUser != null) {
          searchProvider.saveToHistory(authProvider.currentUser!.id, query);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search events, faculty, locations...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<SearchProvider>().clearSearch();
                        },
                      )
                    : null,
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Consumer<SearchProvider>(
        builder: (context, searchProvider, child) {
          // Show category filters if searching
          return Column(
            children: [
              // Category filters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: SearchCategory.values.map((category) {
                    final isSelected = searchProvider.category == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(_getCategoryLabel(category)),
                        selected: isSelected,
                        onSelected: (selected) {
                          searchProvider.setCategory(category);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Results or suggestions
              Expanded(
                child: _buildBody(context, searchProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, SearchProvider searchProvider) {
    if (searchProvider.isLoading) {
      return const LoadingWidget(message: 'Searching...');
    }

    if (searchProvider.query.isEmpty) {
      return _buildSuggestions(context, searchProvider);
    }

    if (searchProvider.error != null) {
      return EmptyStateWidget(
        icon: Icons.error_outline,
        title: 'Search Error',
        message: searchProvider.error!,
        action: ElevatedButton(
          onPressed: () {
            searchProvider.search(searchProvider.query);
          },
          child: const Text('Try Again'),
        ),
      );
    }

    if (!searchProvider.hasResults) {
      return const EmptyStateWidget(
        icon: Icons.search_off,
        title: 'No Results Found',
        message: 'Try searching with different keywords',
      );
    }

    return _buildResults(context, searchProvider);
  }

  Widget _buildSuggestions(BuildContext context, SearchProvider searchProvider) {
    final theme = Theme.of(context);
    
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Search history
        if (searchProvider.searchHistory.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  final authProvider = context.read<AuthProvider>();
                  if (authProvider.currentUser != null) {
                    searchProvider.clearHistory(authProvider.currentUser!.id);
                  }
                },
                child: const Text('Clear'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...searchProvider.searchHistory.take(5).map((query) => ListTile(
                leading: const Icon(Icons.history),
                title: Text(query),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  _searchController.text = query;
                  searchProvider.search(query);
                },
              )),
          const Divider(),
        ],

        // Popular searches
        if (searchProvider.popularSearches.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Popular Searches',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: searchProvider.popularSearches.map((query) => ActionChip(
                  label: Text(query),
                  onPressed: () {
                    _searchController.text = query;
                    searchProvider.search(query);
                  },
                )).toList(),
          ),
        ],

        // Search tips
        const SizedBox(height: 24),
        Text(
          'Search Tips',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text('• Search by event name, date, or location'),
        const Text('• Find faculty by name or department'),
        const Text('• Locate campus buildings and facilities'),
        const Text('• Use filters to narrow down results'),
      ],
    );
  }

  Widget _buildResults(BuildContext context, SearchProvider searchProvider) {
    final theme = Theme.of(context);
    
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Result summary
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            '${searchProvider.totalResults} results for "${searchProvider.query}"',
            style: theme.textTheme.titleMedium,
          ),
        ),

        // Events
        if (searchProvider.events.isNotEmpty) ...[
          _buildSectionHeader('Events', searchProvider.events.length),
          ...searchProvider.events.map((event) => Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.event,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: Text(event.title),
                  subtitle: Text(
                    '${_formatDate(event.time)} • ${event.location}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailScreen(event: event),
                      ),
                    );
                  },
                ),
              )),
          const SizedBox(height: 16),
        ],

        // Faculty
        if (searchProvider.faculty.isNotEmpty) ...[
          _buildSectionHeader('Faculty', searchProvider.faculty.length),
          ...searchProvider.faculty.map((faculty) => Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    child: Icon(
                      Icons.person,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                  title: Text(faculty.userName ?? 'Unknown'),
                  subtitle: Text(
                    '${faculty.designation ?? 'Faculty'} • ${faculty.department}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FacultyDetailScreen(faculty: faculty),
                      ),
                    );
                  },
                ),
              )),
          const SizedBox(height: 16),
        ],

        // Locations
        if (searchProvider.locations.isNotEmpty) ...[
          _buildSectionHeader('Campus Locations', searchProvider.locations.length),
          ...searchProvider.locations.map((location) => Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.tertiaryContainer,
                    child: Icon(
                      Icons.location_on,
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                  ),
                  title: Text(location.name),
                  subtitle: Text(
                    location.buildingCode ?? location.description ?? 'Campus location',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to map with location selected
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Navigate to ${location.name} on map'),
                        action: SnackBarAction(
                          label: 'Go',
                          onPressed: () {
                            // TODO: Navigate to map screen with this location
                          },
                        ),
                      ),
                    );
                  },
                ),
              )),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryLabel(SearchCategory category) {
    switch (category) {
      case SearchCategory.all:
        return 'All';
      case SearchCategory.events:
        return 'Events';
      case SearchCategory.faculty:
        return 'Faculty';
      case SearchCategory.locations:
        return 'Locations';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final eventDate = DateTime(date.year, date.month, date.day);

    if (eventDate == today) {
      return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (eventDate == tomorrow) {
      return 'Tomorrow ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
