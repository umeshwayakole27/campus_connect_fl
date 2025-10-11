import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/models/faculty_model.dart';
import '../../../core/providers/auth_provider.dart';
import 'edit_faculty_screen.dart';

class FacultyDetailScreen extends StatelessWidget {
  final Faculty faculty;

  const FacultyDetailScreen({super.key, required this.faculty});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final isOwnProfile = authProvider.currentUser?.id == faculty.userId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty Profile'),
        actions: [
          if (isOwnProfile)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditFacultyScreen(faculty: faculty),
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with Avatar
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primaryContainer,
                    theme.colorScheme.secondaryContainer,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: theme.colorScheme.surface,
                    backgroundImage: faculty.userAvatarUrl != null
                        ? NetworkImage(faculty.userAvatarUrl!)
                        : null,
                    child: faculty.userAvatarUrl == null
                        ? Text(
                            _getInitials(faculty.userName ?? 'Faculty'),
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    faculty.userName ?? 'Unknown',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (faculty.designation != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      faculty.designation!,
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    faculty.department,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Contact Information
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Information',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Email
                  if (faculty.userEmail != null)
                    _ContactCard(
                      icon: Icons.email_outlined,
                      title: 'Email',
                      value: faculty.userEmail!,
                      onTap: () => _launchEmail(faculty.userEmail!),
                    ),

                  // Phone
                  if (faculty.phone != null)
                    _ContactCard(
                      icon: Icons.phone_outlined,
                      title: 'Phone',
                      value: faculty.phone!,
                      onTap: () => _launchPhone(faculty.phone!),
                    ),

                  // Office Location
                  if (faculty.officeLocation != null)
                    _ContactCard(
                      icon: Icons.location_on_outlined,
                      title: 'Office Location',
                      value: faculty.officeLocation!,
                      onTap: null, // TODO: Navigate to map in future
                    ),

                  // Office Hours
                  if (faculty.officeHours != null)
                    _ContactCard(
                      icon: Icons.access_time_outlined,
                      title: 'Office Hours',
                      value: faculty.officeHours!,
                      onTap: null,
                    ),

                  // Research Interests
                  if (faculty.researchInterests != null &&
                      faculty.researchInterests!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Research Interests',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: faculty.researchInterests!.map((interest) {
                        return Chip(
                          label: Text(interest),
                          backgroundColor: theme.colorScheme.primaryContainer,
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
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

  void _launchEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _launchPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              if (onTap != null)
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
}
