import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme.dart';
import '../../../core/utils.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _departmentController;
  late TextEditingController _officeController;
  late TextEditingController _officeHoursController;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _departmentController = TextEditingController(text: user?.department ?? '');
    _officeController = TextEditingController(text: user?.office ?? '');
    _officeHoursController = TextEditingController(text: user?.officeHours ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _departmentController.dispose();
    _officeController.dispose();
    _officeHoursController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    
    final success = await authProvider.updateProfile(
      name: _nameController.text.trim(),
      department: _departmentController.text.trim().isNotEmpty
          ? _departmentController.text.trim()
          : null,
      office: _officeController.text.trim().isNotEmpty
          ? _officeController.text.trim()
          : null,
      officeHours: _officeHoursController.text.trim().isNotEmpty
          ? _officeHoursController.text.trim()
          : null,
    );

    if (mounted) {
      if (success) {
        AppUtils.showSnackBar(context, AppConstants.successUpdate);
        Navigator.pop(context);
      } else {
        AppUtils.showSnackBar(
          context,
          authProvider.errorMessage ?? 'Failed to update profile',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Name field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outlined),
                  ),
                  validator: (value) => AppUtils.validateRequired(value, 'Name'),
                ),
                const SizedBox(height: 16),
                
                // Department field (if faculty or already set)
                if (user?.isFaculty == true || user?.department != null) ...[
                  TextFormField(
                    controller: _departmentController,
                    decoration: const InputDecoration(
                      labelText: 'Department',
                      prefixIcon: Icon(Icons.business_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Office field (if faculty or already set)
                if (user?.isFaculty == true || user?.office != null) ...[
                  TextFormField(
                    controller: _officeController,
                    decoration: const InputDecoration(
                      labelText: 'Office',
                      hintText: 'e.g., Room 101, Building A',
                      prefixIcon: Icon(Icons.room_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Office hours field (if faculty or already set)
                if (user?.isFaculty == true || user?.officeHours != null) ...[
                  TextFormField(
                    controller: _officeHoursController,
                    decoration: const InputDecoration(
                      labelText: 'Office Hours',
                      hintText: 'e.g., Mon-Fri 9AM-5PM',
                      prefixIcon: Icon(Icons.schedule_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                const SizedBox(height: 24),
                
                // Save button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                      child: authProvider.isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: AppTextStyles.button,
                            ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
