import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme.dart';
import '../../../core/utils.dart';
import '../../../core/services/image_upload_service.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EditProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;

          if (user == null) {
            return const Center(
              child: Text('No user data available'),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),
                
                // Profile picture with upload button
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: AppTheme.primaryColor,
                      child: user.profilePic != null && user.profilePic!.isNotEmpty
                          ? ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: user.profilePic!,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const CircularProgressIndicator(),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.person,
                              size: 60,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Material(
                        color: Theme.of(context).colorScheme.primary,
                        shape: const CircleBorder(),
                        elevation: 4,
                        child: InkWell(
                          onTap: () => _showImageSourceDialog(context, authProvider),
                          customBorder: const CircleBorder(),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Name
                Text(
                  user.name,
                  style: AppTextStyles.heading2,
                ),
                const SizedBox(height: 4),
                
                // Role badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: user.isFaculty
                        ? AppTheme.secondaryColor
                        : AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    AppUtils.capitalize(user.role),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: user.isFaculty
                          ? Theme.of(context).colorScheme.onSecondary
                          : Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Info cards
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildInfoCard(
                        context,
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: user.email,
                      ),
                      if (user.department != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoCard(
                          context,
                          icon: Icons.business_outlined,
                          label: 'Department',
                          value: user.department!,
                        ),
                      ],
                      if (user.office != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoCard(
                          context,
                          icon: Icons.room_outlined,
                          label: 'Office',
                          value: user.office!,
                        ),
                      ],
                      if (user.officeHours != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoCard(
                          context,
                          icon: Icons.schedule_outlined,
                          label: 'Office Hours',
                          value: user.officeHours!,
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Logout button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final confirmed = await AppUtils.showConfirmDialog(
                        context,
                        title: 'Logout',
                        message: 'Are you sure you want to logout?',
                        confirmText: 'Logout',
                        cancelText: 'Cancel',
                      );

                      if (confirmed && context.mounted) {
                        await context.read<AuthProvider>().signOut();
                        AppUtils.showSnackBar(
                          context,
                          AppConstants.successLogout,
                        );
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        subtitle: Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context, AuthProvider authProvider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _uploadProfilePicture(context, authProvider, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _uploadProfilePicture(context, authProvider, ImageSource.gallery);
              },
            ),
            if (authProvider.currentUser?.profilePic != null &&
                authProvider.currentUser!.profilePic!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _removeProfilePicture(context, authProvider);
                },
              ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadProfilePicture(
    BuildContext context,
    AuthProvider authProvider,
    ImageSource source,
  ) async {
    try {
      final user = authProvider.currentUser;
      if (user == null) return;

      // Step 1: Pick and crop image (with its own UI)
      final imageUrl = await ImageUploadService.instance.pickCropCompressAndUpload(
        source: source,
        userId: user.id,
        oldImageUrl: user.profilePic,
      );

      if (imageUrl == null) {
        // User cancelled
        return;
      }

      // Step 2: Show uploading dialog ONLY during database update
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Saving profile picture...'),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      // Step 3: Update profile in database
      final success = await authProvider.updateProfile(profilePic: imageUrl);

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        
        if (success) {
          AppUtils.showSnackBar(
            context,
            'Profile picture updated successfully',
          );
        } else {
          AppUtils.showSnackBar(
            context,
            'Failed to update profile picture',
            isError: true,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        AppUtils.showSnackBar(
          context,
          'Error: ${e.toString()}',
          isError: true,
        );
      }
    }
  }

  Future<void> _removeProfilePicture(
    BuildContext context,
    AuthProvider authProvider,
  ) async {
    final confirmed = await AppUtils.showConfirmDialog(
      context,
      title: 'Remove Profile Picture',
      message: 'Are you sure you want to remove your profile picture?',
      confirmText: 'Remove',
      cancelText: 'Cancel',
    );

    if (confirmed && context.mounted) {
      final success = await authProvider.updateProfile(profilePic: '');
      
      if (context.mounted) {
        if (success) {
          AppUtils.showSnackBar(
            context,
            'Profile picture removed successfully',
          );
        } else {
          AppUtils.showSnackBar(
            context,
            'Failed to remove profile picture',
            isError: true,
          );
        }
      }
    }
  }
}
