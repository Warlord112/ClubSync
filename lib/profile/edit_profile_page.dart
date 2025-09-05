import 'package:flutter/material.dart';

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
  late TextEditingController _yearController;
  late TextEditingController _bioController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _yearController = TextEditingController(text: widget.userData['year']);
    _bioController = TextEditingController(text: widget.userData['bio'] ?? '');
  }

  @override
  void dispose() {
    _yearController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final updatedUserData = Map<String, dynamic>.from(widget.userData);
      updatedUserData['year'] = _yearController.text;
      updatedUserData['bio'] = _bioController.text;

      widget.onProfileUpdated(updatedUserData);
      Navigator.pop(context);
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
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: AssetImage(
                        widget.userData['profileImage'],
                      ),
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
                            // Image picker functionality would go here
                            // For now, we'll just show a snackbar
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
              _buildNonEditableField('Full Name', widget.userData['name']),
              const SizedBox(height: 16),
              _buildNonEditableField(
                'Department',
                widget.userData['department'],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _yearController,
                label: 'Year',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your year';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildNonEditableField(
                'Student ID',
                widget.userData['studentId'],
              ),
              const SizedBox(height: 16),
              _buildNonEditableField('Email', widget.userData['email']),
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
