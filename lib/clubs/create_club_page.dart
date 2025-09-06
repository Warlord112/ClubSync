import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreateClubPage extends StatefulWidget {
  const CreateClubPage({super.key});

  @override
  State<CreateClubPage> createState() => _CreateClubPageState();
}

class _CreateClubPageState extends State<CreateClubPage> {
  final _formKey = GlobalKey<FormState>();
  final _clubNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final SupabaseClient supabase = Supabase.instance.client;
  File? _profileImage;
  File? _coverImage;

  @override
  void dispose() {
    _clubNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createClub() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      // For simplicity, we are not handling image uploads here.
      // In a real application, you would upload images to Supabase Storage
      // and store the URLs in the database.
      final response = await supabase.from('clubs').insert({
        'name': _clubNameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'profile_image_path': _profileImage != null ? await _uploadImage(_profileImage!) : 'assets/images/computer.svg', // Upload if available
        'cover_image_path': _coverImage != null ? await _uploadImage(_coverImage!) : 'assets/images/sunset.svg', // Upload if available
        'created_by': supabase.auth.currentUser!.id,
      }).select('id').single(); // Select the ID of the newly created club

      final newClubId = response['id'] as String;
      final userId = supabase.auth.currentUser!.id;

      // Fetch the full name of the user who created the club
      final userData = await supabase
          .from('users')
          .select('full_name')
          .eq('id', userId)
          .single();

      if (userData.isNotEmpty && userData['full_name'] != null) {
        final userName = userData['full_name'] as String;

        // Insert the creator as an advisor into club_members table
        await supabase.from('club_members').insert({
          'club_id': newClubId,
          'student_id': userId,
          'name': userName,
          'position': 'Faculty Advisor',
          'role': 'advisor',
          'joined_at': DateTime.now().toIso8601String(),
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Club created successfully and you are now its Advisor!')),
        );
        Navigator.of(context).pop(); // Go back to the clubs page
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating club: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create New Club',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF6a0e33),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _clubNameController,
                decoration: _buildInputDecoration('Club Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a club name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: _buildInputDecoration('Club Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a club description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildImagePicker( 'Profile Picture', _profileImage, (image) => setState(() => _profileImage = image)),
              const SizedBox(height: 16),
              _buildImagePicker( 'Cover Photo', _coverImage, (image) => setState(() => _coverImage = image)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _createClub,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6a0e33),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Create Club',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF6a0e33)),
      ),
    );
  }

  Widget _buildImagePicker(String label, File? image, Function(File?) onImagePicked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
            if (pickedFile != null) {
              onImagePicked(File(pickedFile.path));
            }
          },
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade400),
              image: image != null
                  ? DecorationImage(image: FileImage(image), fit: BoxFit.cover)
                  : null,
            ),
            child: image == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 40, color: Colors.grey[600]),
                      const SizedBox(height: 8),
                      Text(
                        'Select $label',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Future<String> _uploadImage(File image) async {
    final String fileName = '${supabase.auth.currentUser!.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String path = await supabase.storage.from('club_images').upload(
          fileName,
          image,
          fileOptions: const FileOptions(upsert: true),
        );
    return supabase.storage.from('club_images').getPublicUrl(fileName);
  }
}
