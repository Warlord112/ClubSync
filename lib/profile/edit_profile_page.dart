import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Function(Map<String, dynamic>) onProfileUpdated;

  const EditProfilePage({
    super.key,
    required this.userData,
    required this.onProfileUpdated,
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  String? _selectedSemester;
  late TextEditingController _bioController;
  final _formKey = GlobalKey<FormState>();

  final List<String> _semesters = const [
    '1st semester',
    '2nd semester',
    '3rd semester',
    '4th semester',
    '5th semester',
    '6th semester',
    '7th semester',
    '8th semester',
    '9th semester',
    '10th semester',
    '11th semester',
    '12th semester',
  ];

  @override
  void initState() {
    super.initState();
    _selectedSemester = (widget.userData['semester'] ?? widget.userData['year'])
        ?.toString();
    if (_selectedSemester != null && !_semesters.contains(_selectedSemester)) {
      _selectedSemester = null;
    }
    _bioController = TextEditingController(
      text: (widget.userData['bio'] ?? '').toString(),
    );
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final updatedUserData = Map<String, dynamic>.from(widget.userData);
      updatedUserData['semester'] = _selectedSemester;
      updatedUserData['bio'] = _bioController.text;

      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Not authenticated. Please log in again.'),
          ),
        );
        return;
      }

      try {
        await supabase
            .from('users')
            .update({'bio': _bioController.text, 'semester': _selectedSemester})
            .eq('id', user.id);

        widget.onProfileUpdated(updatedUserData);
        if (mounted) Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save profile: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF6a0e33),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    Builder(
                      builder: (context) {
                        ImageProvider? avatarProvider;
                        final img = widget.userData['profileImage'];
                        if (img is String && img.isNotEmpty) {
                          final lower = img.toLowerCase();
                          if (lower.startsWith('http')) {
                            avatarProvider = NetworkImage(img);
                          } else if (lower.startsWith('assets/') &&
                              !lower.endsWith('.svg')) {
                            avatarProvider = AssetImage(img);
                          }
                        }
                        return CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: avatarProvider,
                          child: avatarProvider == null
                              ? const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.white,
                                )
                              : null,
                        );
                      },
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF6a0e33),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Profile picture upload not implemented yet',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Personal Information'),
              const SizedBox(height: 16),
              _buildNonEditableField(
                'Full Name',
                (widget.userData['name'] ??
                        widget.userData['full_name'] ??
                        'N/A')
                    .toString(),
              ),
              const SizedBox(height: 16),
              _buildNonEditableField(
                'Department',
                (widget.userData['department'] ?? 'N/A').toString(),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedSemester,
                decoration: InputDecoration(
                  labelText: 'Semester',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                items: _semesters
                    .map(
                      (semester) => DropdownMenuItem(
                        value: semester,
                        child: Text(semester),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedSemester = value),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Select semester' : null,
              ),
              const SizedBox(height: 16),
              _buildNonEditableField(
                'Student ID',
                (widget.userData['studentId'] ??
                        widget.userData['student_id'] ??
                        'N/A')
                    .toString(),
              ),
              const SizedBox(height: 16),
              _buildNonEditableField(
                'Email',
                (widget.userData['email'] ?? 'N/A').toString(),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('About Me'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _bioController,
                label: 'Bio',
                maxLines: 4,
                validator: null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6a0e33),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _buildNonEditableField(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
