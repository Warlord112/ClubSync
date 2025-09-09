import 'package:flutter/material.dart';
import '../data/club_data.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreatePostPage extends StatefulWidget {
  final String studentId;
  final List<Club> clubs;
  const CreatePostPage({
    super.key,
    required this.studentId,
    required this.clubs,
  });

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _captionController = TextEditingController();
  XFile? _imageFile;
  String? _selectedClubId; // Added: selected club id
  final SupabaseClient supabase = Supabase.instance.client; // Supabase client

  @override
  void initState() {
    super.initState();
    // Preselect the first club if available
    if (widget.clubs.isNotEmpty) {
      _selectedClubId = widget.clubs.first.id;
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = image;
    });
  }

  Future<void> _submitPost() async {
    final String title = _titleController.text.trim();
    final String caption = _captionController.text.trim();
    final String? clubId = _selectedClubId;

    try {
      await supabase.from('posts').insert({
        'title': title,
        'caption': caption,
        'club_id': clubId,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post created successfully')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error creating post: $e')));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Post'),
        backgroundColor: const Color(0xFF6a0e33),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Added: Club selector
            DropdownButtonFormField<String>(
              value: _selectedClubId,
              decoration: const InputDecoration(
                labelText: 'Select a club',
                border: OutlineInputBorder(),
              ),
              items: widget.clubs
                  .map(
                    (club) => DropdownMenuItem<String>(
                      value: club.id,
                      child: Text(club.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedClubId = value;
                });
              },
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _captionController,
              decoration: const InputDecoration(
                labelText: 'Caption',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Add Photo'),
            ),
            const SizedBox(height: 12.0),
            // Added: Post button below the Add Photo button
            ElevatedButton(onPressed: _submitPost, child: const Text('Post')),
            if (_imageFile != null)
              Column(
                children: [
                  const SizedBox(height: 16.0),
                  Image.file(File(_imageFile!.path), height: 200),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
