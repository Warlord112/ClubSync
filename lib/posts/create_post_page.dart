import 'package:flutter/material.dart';
import 'package:clubsync/data/club_data.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreatePostPage extends StatefulWidget {
  final String studentId;
  final List<Club> clubs;
  const CreatePostPage({super.key, required this.studentId, required this.clubs});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _captionController = TextEditingController();
  XFile? _imageFile;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = image;
    });
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


