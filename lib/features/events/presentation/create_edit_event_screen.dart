import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/event_model.dart';
import '../../../core/models/location_model.dart';
import '../../campus_map/data/location_repository.dart';
import 'event_provider.dart';

class CreateEditEventScreen extends StatefulWidget {
  final Event? event;

  const CreateEditEventScreen({super.key, this.event});

  @override
  State<CreateEditEventScreen> createState() => _CreateEditEventScreenState();
}

class _CreateEditEventScreenState extends State<CreateEditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  CampusLocation? _selectedLocation;
  List<CampusLocation> _campusLocations = [];

  bool get isEditMode => widget.event != null;

  @override
  void initState() {
    super.initState();
    _loadCampusLocations();
    
    if (isEditMode) {
      _titleController.text = widget.event!.title;
      _descriptionController.text = widget.event!.description ?? '';
      _locationController.text = widget.event!.location ?? '';
      _selectedDate = widget.event!.time;
      _selectedTime = TimeOfDay.fromDateTime(widget.event!.time);
    }
  }

  Future<void> _loadCampusLocations() async {
    try {
      final repository = LocationRepository();
      _campusLocations = await repository.getAllLocations();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load locations: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Event' : 'Create Event'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Event Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.event),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter event title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter event description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date picker
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedDate != null
                        ? DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDate!)
                        : 'Select date',
                    style: TextStyle(
                      color: _selectedDate != null
                          ? theme.textTheme.bodyLarge?.color
                          : theme.hintColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Time picker
              InkWell(
                onTap: _pickTime,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Time',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  child: Text(
                    _selectedTime != null
                        ? _selectedTime!.format(context)
                        : 'Select time',
                    style: TextStyle(
                      color: _selectedTime != null
                          ? theme.textTheme.bodyLarge?.color
                          : theme.hintColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Location dropdown
              DropdownButtonFormField<CampusLocation>(
                decoration: const InputDecoration(
                  labelText: 'Campus Location',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                isExpanded: true,
                initialValue: _selectedLocation,
                hint: const Text('Select campus location'),
                items: _campusLocations.map((location) {
                  return DropdownMenuItem(
                    value: location,
                    child: Text(
                      location.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (location) {
                  setState(() {
                    _selectedLocation = location;
                    if (location != null) {
                      _locationController.text = location.name;
                    }
                  });
                },
              ),
              const SizedBox(height: 8),
              
              // OR custom location
              const Text(
                'OR',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Custom Location',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit_location),
                  hintText: 'Enter custom location',
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    setState(() => _selectedLocation = null);
                  }
                },
              ),
              const SizedBox(height: 32),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: _saveEvent,
                      child: Text(isEditMode ? 'Update Event' : 'Create Event'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select event date')),
      );
      return;
    }

    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select event time')),
      );
      return;
    }

    if (_locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter or select a location')),
      );
      return;
    }

    final eventDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final authProvider = context.read<AuthProvider>();
    final eventProvider = context.read<EventProvider>();

    final event = Event(
      id: isEditMode ? widget.event!.id : '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      location: _locationController.text.trim(),
      locationId: _selectedLocation?.id,
      time: eventDateTime,
      createdBy: authProvider.currentUser!.id,
      createdAt: isEditMode ? widget.event!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = isEditMode
        ? await eventProvider.updateEvent(widget.event!.id, event)
        : await eventProvider.createEvent(event);

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditMode
                  ? 'Event updated successfully'
                  : 'Event created successfully',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              eventProvider.error ?? 'Failed to save event',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
