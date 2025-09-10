import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/club_data.dart';
import '../utils/constants.dart';

class CreateEventPage extends StatefulWidget {
  final List<Club> clubs;
  const CreateEventPage({super.key, required this.clubs});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedClubName;
  bool _isSubmitting = false;

  // Format DateTime to a plain date string acceptable by Postgres DATE columns
  String _formatDateForDb(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '$y-$m-$dd';
  }

  @override
  void initState() {
    super.initState();
    _enforceInstructorOnly();
  }

  Future<void> _enforceInstructorOnly() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You must be logged in to create an event.'),
            ),
          );
          Navigator.pop(context);
        });
        return;
      }
      final resp = await supabase
          .from('users')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();
      final String? role = resp != null ? resp['role'] as String? : null;
      final bool isInstructor = role == kRoleInstructor || role == 'Instructor';
      if (!isInstructor) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Only instructors can create an event.'),
            ),
          );
          Navigator.pop(context);
        });
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error verifying permissions: $e')),
        );
        Navigator.pop(context);
      });
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initialDate = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? _startDate ?? DateTime.now());
    final firstDate = DateTime(DateTime.now().year - 1);
    final lastDate = DateTime(DateTime.now().year + 5);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;

    final supabase = Supabase.instance.client;

    // Map selected club name to its id
    final club = widget.clubs.firstWhere(
      (c) => c.name == _selectedClubName,
      orElse: () => widget.clubs.first,
    );

    final Map<String, dynamic> baseData = {
      'club_id': club.id,
      'title': _titleController.text.trim(),
      'description': _bioController.text.trim(),
    };

    // Extended fields (ensure DB-friendly formats)
    final Map<String, dynamic> extendedData = {
      ...baseData,
      if (_locationController.text.trim().isNotEmpty)
        'location': _locationController.text.trim(),
      if (_startDate != null) 'starting_date': _formatDateForDb(_startDate!),
      if (_endDate != null) 'ending_date': _formatDateForDb(_endDate!),
    };

    setState(() => _isSubmitting = true);
    try {
      // First attempt with extended data
      final inserted = await supabase
          .from(kActivitiesTable)
          .insert(extendedData)
          .select('*')
          .single();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event created successfully.')),
        );
        Navigator.pop(context, inserted);
      }
    } catch (e) {
      // Fallback: insert only base fields if extended columns are not available
      try {
        final inserted = await supabase
            .from(kActivitiesTable)
            .insert(baseData)
            .select('*')
            .single();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Event created (without date/location fields, not supported by current schema).',
              ),
            ),
          );
          Navigator.pop(context, inserted);
        }
      } catch (e2) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create event: $e2')),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clubNames = widget.clubs.map((c) => c.name).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
        backgroundColor: const Color(0xFF6a0e33),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Event title',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter an event title'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Event Bio',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter an event bio'
                    : null,
              ),
              const SizedBox(height: 16),
              // Location field
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickDate(isStart: true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Starting day',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _startDate == null
                              ? 'Select date'
                              : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickDate(isStart: false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Ending day',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _endDate == null
                              ? 'Select date'
                              : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedClubName,
                items: clubNames
                    .map(
                      (name) => DropdownMenuItem<String>(
                        value: name,
                        child: Text(name),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedClubName = val),
                decoration: const InputDecoration(
                  labelText: 'Club',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null ? 'Please select a club' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _createEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6a0e33),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
