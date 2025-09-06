import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../data/club_data.dart';
import '../utils/constants.dart';

class EditClubProfilePage extends StatefulWidget {
  final Club club;

  const EditClubProfilePage({super.key, required this.club});

  @override
  State<EditClubProfilePage> createState() => _EditClubProfilePageState();
}

class _EditClubProfilePageState extends State<EditClubProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _clubNameController;
  late TextEditingController _descriptionController;
  File? _profileImage;
  File? _coverImage;
  bool _isLoading = false;
  final SupabaseClient supabase = Supabase.instance.client;

  // For activities
  List<Map<String, dynamic>> _activities = [];
  final TextEditingController _newActivityTitleController = TextEditingController();
  final TextEditingController _newActivityDescriptionController = TextEditingController();

  // For achievements
  List<Map<String, dynamic>> _achievements = [];
  final TextEditingController _newAchievementYearController = TextEditingController();
  final TextEditingController _newAchievementDescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _clubNameController = TextEditingController(text: widget.club.name);
    _descriptionController = TextEditingController(text: widget.club.description);
    _fetchActivities();
    _fetchAchievements();
  }

  @override
  void dispose() {
    _clubNameController.dispose();
    _descriptionController.dispose();
    _newActivityTitleController.dispose();
    _newActivityDescriptionController.dispose();
    _newAchievementYearController.dispose();
    _newAchievementDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchActivities() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await supabase
          .from(kActivitiesTable)
          .select('*')
          .eq('club_id', widget.club.id)
          .order('created_at', ascending: true);
      setState(() {
        _activities = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$kErrorFetchingActivities $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addActivity() async {
    if (_newActivityTitleController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(kPleaseEnterActivityTitle)),
        );
      }
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await supabase.from(kActivitiesTable).insert({
        'club_id': widget.club.id,
        'title': _newActivityTitleController.text.trim(),
        'description': _newActivityDescriptionController.text.trim(),
      }).select('*').single();

      setState(() {
        _activities.add(response);
        _newActivityTitleController.clear();
        _newActivityDescriptionController.clear();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(kActivityAddedSuccessMessage)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$kErrorAddingActivity $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateActivity(String activityId, String newTitle, String newDescription) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await supabase.from(kActivitiesTable).update({
        'title': newTitle.trim(),
        'description': newDescription.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', activityId);

      await _fetchActivities(); // Refresh the list
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(kActivityUpdatedSuccessMessage)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$kErrorUpdatingActivity $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showEditActivityDialog(BuildContext context, Map<String, dynamic> activity) {
    final TextEditingController titleController = TextEditingController(text: activity['title'] as String);
    final TextEditingController descriptionController = TextEditingController(text: activity['description'] as String);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(kEditActivityTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleController,
                decoration: _buildInputDecoration(kActivityTitleLabel),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: descriptionController,
                decoration: _buildInputDecoration(kActivityDescriptionLabel),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(kCancelButtonText),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _updateActivity(activity['id'] as String, titleController.text, descriptionController.text);
              },
              child: const Text(kUpdateActivityButtonText),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteActivity(String activityId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await supabase.from(kActivitiesTable).delete().eq('id', activityId);
      await _fetchActivities(); // Refresh the list
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(kActivityDeletedSuccessMessage)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$kErrorDeletingActivity $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchAchievements() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await supabase
          .from(kAchievementsTable)
          .select('*')
          .eq('club_id', widget.club.id)
          .order('year', ascending: true);
      setState(() {
        _achievements = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$kErrorFetchingAchievements $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addAchievement() async {
    if (_newAchievementYearController.text.trim().isEmpty || _newAchievementDescriptionController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(kPleaseEnterAchievementDetails)),
        );
      }
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await supabase.from(kAchievementsTable).insert({
        'club_id': widget.club.id,
        'year': _newAchievementYearController.text.trim(),
        'description': _newAchievementDescriptionController.text.trim(),
      }).select('*').single();

      setState(() {
        _achievements.add(response);
        _newAchievementYearController.clear();
        _newAchievementDescriptionController.clear();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(kAchievementAddedSuccessMessage)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$kErrorAddingAchievement $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateAchievement(String achievementId, String newYear, String newDescription) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await supabase.from(kAchievementsTable).update({
        'year': newYear.trim(),
        'description': newDescription.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', achievementId);

      await _fetchAchievements(); // Refresh the list
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(kAchievementUpdatedSuccessMessage)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$kErrorUpdatingAchievement $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showEditAchievementDialog(BuildContext context, Map<String, dynamic> achievement) {
    final TextEditingController yearController = TextEditingController(text: achievement['year'] as String);
    final TextEditingController descriptionController = TextEditingController(text: achievement['description'] as String);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(kEditAchievementTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: yearController,
                decoration: _buildInputDecoration(kAchievementYearLabel),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: descriptionController,
                decoration: _buildInputDecoration(kAchievementDescriptionLabel),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(kCancelButtonText),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _updateAchievement(achievement['id'] as String, yearController.text, descriptionController.text);
              },
              child: const Text(kUpdateAchievementButtonText),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAchievement(String achievementId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await supabase.from(kAchievementsTable).delete().eq('id', achievementId);
      await _fetchAchievements(); // Refresh the list
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(kAchievementDeletedSuccessMessage)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$kErrorDeletingAchievement $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source, Function(File?) onImagePicked) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      onImagePicked(File(pickedFile.path));
    } else {
      // Handle case where user cancels image picking
    }
  }

  Future<void> _updateClubProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? profileImageUrl;
      if (_profileImage != null) {
        profileImageUrl = await _uploadImage(_profileImage!);
      } else if (widget.club.profileImagePath.startsWith('http')) {
        profileImageUrl = widget.club.profileImagePath; // Retain existing URL if not changed
      } else {
        profileImageUrl = kDefaultProfileImagePath; // Use default if no new image and no existing URL
      }

      String? coverImageUrl;
      if (_coverImage != null) {
        coverImageUrl = await _uploadImage(_coverImage!);
      } else if (widget.club.coverImagePath.startsWith('http')) {
        coverImageUrl = widget.club.coverImagePath; // Retain existing URL if not changed
      } else {
        coverImageUrl = kDefaultCoverImagePath; // Use default if no new image and no existing URL
      }

      await supabase.from(kClubsTable).update({
        'name': _clubNameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'profile_image_path': profileImageUrl,
        'cover_image_path': coverImageUrl,
        'updated_at': DateTime.now().toIso8601String(), // Add updated_at timestamp
      }).eq('id', widget.club.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(kClubProfileUpdatedSuccessMessage)),
        );
        Navigator.of(context).pop(); // Go back to the club profile page
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$kErrorUpdatingClubProfile $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> _uploadImage(File image) async {
    final String fileName = '${widget.club.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String publicUrl = await supabase.storage.from('club_images').upload(
          fileName,
          image,
          fileOptions: const FileOptions(upsert: true),
        );
    return publicUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(kEditClubProfileTitle, style: TextStyle(color: kWhiteColor, fontWeight: FontWeight.w600)),
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: kWhiteColor),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(color: kWhiteColor),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _clubNameController,
                      decoration: _buildInputDecoration(kClubNameLabel),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return kPleaseEnterClubName;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: _buildInputDecoration(kClubDescriptionLabel),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return kPleaseEnterClubDescription;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Profile Picture Picker
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(kProfilePictureLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _pickImage(ImageSource.gallery, (image) => setState(() => _profileImage = image)),
                          child: Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: kGreyColor[200],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: kGreyColor.shade400),
                              image: _profileImage != null
                                  ? DecorationImage(image: FileImage(_profileImage!), fit: BoxFit.cover)
                                  : widget.club.profileImagePath.startsWith('http')
                                      ? DecorationImage(image: NetworkImage(widget.club.profileImagePath), fit: BoxFit.cover)
                                      : DecorationImage(image: AssetImage(widget.club.profileImagePath), fit: BoxFit.cover),
                            ),
                            child: _profileImage == null && !widget.club.profileImagePath.startsWith('http')
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.camera_alt, size: 40, color: kGreyColor[600]),
                                      const SizedBox(height: 8),
                                      Text(kSelectProfilePicture, style: TextStyle(color: kGreyColor[600])),
                                    ],
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Cover Photo Picker
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(kCoverPhotoLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _pickImage(ImageSource.gallery, (image) => setState(() => _coverImage = image)),
                          child: Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: kGreyColor[200],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: kGreyColor.shade400),
                              image: _coverImage != null
                                  ? DecorationImage(image: FileImage(_coverImage!), fit: BoxFit.cover)
                                  : widget.club.coverImagePath.startsWith('http')
                                      ? DecorationImage(image: NetworkImage(widget.club.coverImagePath), fit: BoxFit.cover)
                                      : DecorationImage(image: AssetImage(widget.club.coverImagePath), fit: BoxFit.cover),
                            ),
                            child: _coverImage == null && !widget.club.coverImagePath.startsWith('http')
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.camera_alt, size: 40, color: kGreyColor[600]),
                                      const SizedBox(height: 8),
                                      Text(kSelectCoverPhoto, style: TextStyle(color: kGreyColor[600])),
                                    ],
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Activities Section
                    Text(kOurActivitiesTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    // List current activities
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _activities.length,
                      itemBuilder: (context, index) {
                        final activity = _activities[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(activity['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(activity['description'] as String),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: kPrimaryColor),
                                  onPressed: () => _showEditActivityDialog(context, activity),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: kRedColor),
                                  onPressed: () => _deleteActivity(activity['id'] as String),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    // Add new activity form
                    Text(kAddActivityTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _newActivityTitleController,
                      decoration: _buildInputDecoration(kActivityTitleLabel),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _newActivityDescriptionController,
                      decoration: _buildInputDecoration(kActivityDescriptionLabel),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addActivity,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor: kWhiteColor,
                        ),
                        child: const Text(kAddActivityButtonText),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Achievements Section
                    Text(kOurAchievementsTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    // List current achievements
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _achievements.length,
                      itemBuilder: (context, index) {
                        final achievement = _achievements[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text('${achievement['year']} - ${achievement['description']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: kPrimaryColor),
                                  onPressed: () => _showEditAchievementDialog(context, achievement),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: kRedColor),
                                  onPressed: () => _deleteAchievement(achievement['id'] as String),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    // Add new achievement form
                    Text(kAddAchievementTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _newAchievementYearController,
                      decoration: _buildInputDecoration(kAchievementYearLabel),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _newAchievementDescriptionController,
                      decoration: _buildInputDecoration(kAchievementDescriptionLabel),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addAchievement,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor: kWhiteColor,
                        ),
                        child: const Text(kAddAchievementButtonText),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _updateClubProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor: kWhiteColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: kWhiteColor)
                            : const Text(
                                kUpdateClubProfileButtonText,
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
        borderSide: const BorderSide(color: kGreyColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kPrimaryColor),
      ),
    );
  }
}
