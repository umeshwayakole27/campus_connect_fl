import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../core/models/faculty_model.dart';
import '../../../core/widgets/enhanced_cards.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import 'faculty_provider.dart';
import 'faculty_detail_screen.dart';

class FacultyListScreen extends StatefulWidget {
  const FacultyListScreen({super.key});

  @override
  State<FacultyListScreen> createState() => _FacultyListScreenState();
}

class _FacultyListScreenState extends State<FacultyListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FacultyProvider>().loadFaculty();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty Directory'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            tooltip: _isGridView ? 'List View' : 'Grid View',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(AppDecorations.spaceMD),
            child: AnimatedSearchBar(
              controller: _searchController,
              hintText: 'Search faculty by name, department...',
              onChanged: (value) {
                context.read<FacultyProvider>().setSearchQuery(value);
              },
              onClear: () {
                context.read<FacultyProvider>().setSearchQuery('');
              },
            ),
          ),

          // Active Filter Chip
          Consumer<FacultyProvider>(
            builder: (context, provider, _) {
              if (provider.selectedDepartment != null) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppDecorations.spaceMD),
                  child: Row(
                    children: [
                      AnimatedFilterChip(
                        label: provider.selectedDepartment!,
                        selected: true,
                        onTap: () {
                          provider.setDepartmentFilter(null);
                        },
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => provider.clearFilters(),
                        child: const Text('Clear all filters'),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Faculty List
          Expanded(
            child: Consumer<FacultyProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.facultyList.isEmpty) {
                  return const SkeletonPage(itemCount: 8, hasAppBar: false);
                }

                if (provider.error != null) {
                  return EmptyStateWidget(
                    icon: Icons.error_outline,
                    title: 'Error loading faculty',
                    message: provider.error!,
                    action: ElevatedButton.icon(
                      onPressed: () => provider.loadFaculty(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  );
                }

                final filteredFaculty = provider.filteredFaculty;

                if (filteredFaculty.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.people_outline,
                    title: provider.searchQuery.isNotEmpty
                        ? 'No faculty found'
                        : 'No faculty members found',
                    message: provider.searchQuery.isNotEmpty
                        ? 'Try adjusting your search'
                        : 'Faculty will appear here',
                  );
                }

                return CustomPullToRefresh(
                  onRefresh: () => provider.refresh(),
                  child: _isGridView
                      ? AnimationLimiter(
                          child: GridView.builder(
                            padding: EdgeInsets.all(AppDecorations.spaceMD),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: filteredFaculty.length,
                            itemBuilder: (context, index) {
                              final faculty = filteredFaculty[index];
                              return AnimationConfiguration.staggeredGrid(
                                position: index,
                                duration: const Duration(milliseconds: 375),
                                columnCount: 2,
                                child: ScaleAnimation(
                                  child: FadeInAnimation(
                                    child: EnhancedFacultyCard(
                                      faculty: faculty,
                                      isGridView: true,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => FacultyDetailScreen(faculty: faculty),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : AnimationLimiter(
                          child: ListView.builder(
                            padding: EdgeInsets.all(AppDecorations.spaceSM),
                            itemCount: filteredFaculty.length,
                            itemBuilder: (context, index) {
                              final faculty = filteredFaculty[index];
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 375),
                                child: SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: FadeInAnimation(
                                    child: EnhancedFacultyCard(
                                      faculty: faculty,
                                      isGridView: false,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => FacultyDetailScreen(faculty: faculty),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final provider = context.read<FacultyProvider>();
        return AlertDialog(
          title: const Text('Filter by Department'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('All Departments'),
                  leading: Radio<String?>(
                    value: null,
                    groupValue: provider.selectedDepartment,
                    onChanged: (value) {
                      provider.setDepartmentFilter(value);
                      Navigator.pop(context);
                    },
                  ),
                ),
                ...provider.departments.map((dept) {
                  return ListTile(
                    title: Text(dept),
                    leading: Radio<String?>(
                      value: dept,
                      groupValue: provider.selectedDepartment,
                      onChanged: (value) {
                        provider.setDepartmentFilter(value);
                        Navigator.pop(context);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class _FacultyCard extends StatelessWidget {
  final Faculty faculty;

  const _FacultyCard({required this.faculty});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FacultyDetailScreen(faculty: faculty),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 32,
                backgroundColor: theme.colorScheme.primaryContainer,
                backgroundImage: faculty.userAvatarUrl != null
                    ? NetworkImage(faculty.userAvatarUrl!)
                    : null,
                child: faculty.userAvatarUrl == null
                    ? Text(
                        _getInitials(faculty.userName ?? 'Faculty'),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      faculty.userName ?? 'Unknown',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (faculty.designation != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        faculty.designation!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      faculty.department,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    if (faculty.officeLocation != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: theme.colorScheme.secondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              faculty.officeLocation!,
                              style: theme.textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              // Arrow
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length > 2 ? 2 : name.length).toUpperCase();
  }
}
