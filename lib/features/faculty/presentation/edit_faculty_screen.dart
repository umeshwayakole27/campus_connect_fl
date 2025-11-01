import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/faculty_model.dart';
import 'faculty_provider.dart';

class EditFacultyScreen extends StatefulWidget {
  final Faculty faculty;

  const EditFacultyScreen({super.key, required this.faculty});

  @override
  State<EditFacultyScreen> createState() => _EditFacultyScreenState();
}

class _EditFacultyScreenState extends State<EditFacultyScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _departmentController;
  late final TextEditingController _designationController;
  late final TextEditingController _officeLocationController;
  late final TextEditingController _officeHoursController;
  late final TextEditingController _phoneController;
  late final TextEditingController _researchInterestsController;

  @override
  void initState() {
    super.initState();
    _departmentController = TextEditingController(text: widget.faculty.department);
    _designationController = TextEditingController(text: widget.faculty.designation);
    _officeLocationController = TextEditingController(text: widget.faculty.officeLocation);
    _officeHoursController = TextEditingController(text: widget.faculty.officeHours);
    _phoneController = TextEditingController(text: widget.faculty.phone);
    _researchInterestsController = TextEditingController(
      text: widget.faculty.researchInterests?.join(', ') ?? '',
    );
  }

  @override
  void dispose() {
    _departmentController.dispose();
    _designationController.dispose();
    _officeLocationController.dispose();
    _officeHoursController.dispose();
    _phoneController.dispose();
    _researchInterestsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Department
              TextFormField(
                controller: _departmentController,
                decoration: const InputDecoration(
                  labelText: 'Department',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                  helperText: 'Your academic department',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your department';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Designation
              TextFormField(
                controller: _designationController,
                decoration: const InputDecoration(
                  labelText: 'Designation',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work_outline),
                  helperText: 'e.g., Professor, Assistant Professor, HOD',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your designation';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Office Location
              TextFormField(
                controller: _officeLocationController,
                decoration: const InputDecoration(
                  labelText: 'Office Location',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on_outlined),
                  helperText: 'e.g., CSE Block, Room 301',
                ),
              ),
              const SizedBox(height: 16),

              // Office Hours
              TextFormField(
                controller: _officeHoursController,
                decoration: const InputDecoration(
                  labelText: 'Office Hours',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.access_time_outlined),
                  helperText: 'e.g., Mon-Fri: 10:00 AM - 12:00 PM',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Phone
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone_outlined),
                  helperText: 'Include country code (e.g., +91-9876543210)',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    // Basic phone validation
                    if (value.length < 10) {
                      return 'Please enter a valid phone number';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Research Interests
              TextFormField(
                controller: _researchInterestsController,
                decoration: const InputDecoration(
                  labelText: 'Research Interests',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.science_outlined),
                  helperText: 'Separate multiple interests with commas',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Save Button
              FilledButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save),
                label: const Text('Save Changes'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 12),

              // Cancel Button
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Parse research interests
    List<String>? researchInterests;
    if (_researchInterestsController.text.trim().isNotEmpty) {
      researchInterests = _researchInterestsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    final updatedFaculty = widget.faculty.copyWith(
      department: _departmentController.text.trim(),
      designation: _designationController.text.trim().isEmpty
          ? null
          : _designationController.text.trim(),
      officeLocation: _officeLocationController.text.trim().isEmpty
          ? null
          : _officeLocationController.text.trim(),
      officeHours: _officeHoursController.text.trim().isEmpty
          ? null
          : _officeHoursController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      researchInterests: researchInterests,
      updatedAt: DateTime.now(),
    );

    final provider = context.read<FacultyProvider>();
    final success = await provider.updateFaculty(
      widget.faculty.id,
      updatedFaculty,
    );

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.error ?? 'Failed to update profile',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
