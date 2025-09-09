import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import '../data/club_data.dart';
import 'settings_page.dart';
import '../clubs/clubs_page.dart';

class ProfilePage extends StatefulWidget {
  final String studentId;
  final List<Club> clubs;

  const ProfilePage({super.key, required this.studentId, required this.clubs});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _userData; // Make nullable and remove sample data
  bool _isLoading = true; // Add loading state
  final SupabaseClient supabase =
      Supabase.instance.client; // Initialize Supabase client

  @override
  void initState() {
    super.initState();
    _fetchUserProfile(); // Fetch user profile when the page initializes
  }

  Future<void> _fetchUserProfile() async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        final response = await supabase
            .from('users')
            .select(
              'id, full_name, email, role, student_id, field_of_study, semester, department, instructor_id',
            )
            .eq('id', user.id)
            .maybeSingle();

        debugPrint('Supabase user response: \$response');
        if (response != null) {
          setState(() {
            _userData = response;
          });
        } else {
          debugPrint('No user data found for id: ${user.id}');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('User not logged in.')));
        }
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Get clubs where the user is a member
  List<Club> get _userClubs {
    return widget.clubs.where((club) {
      return club.members.any((member) => member.studentId == widget.studentId);
    }).toList();
  }

  // Get the user's role in a specific club
  String _getUserRoleInClub(Club club) {
    try {
      final member = club.members.firstWhere(
        (member) => member.studentId == widget.studentId,
      );
      return '${member.position} (${member.role.capitalize()})';
    } catch (e) {
      return 'Member';
    }
  }

  // Helper to safely display values as String
  String _formatValue(dynamic value) {
    if (value == null) return 'N/A';
    final s = value.toString();
    if (s.trim().isEmpty) return 'N/A';
    return s;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF6a0e33),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(
                    userData: _userData ?? {},
                    onProfileUpdated: (updatedData) {
                      setState(() {
                        _userData = updatedData;
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 8),
                  _buildInfoSection(),
                  const SizedBox(height: 8),
                  _buildClubsSection(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: Colors.grey[300],
            backgroundImage: AssetImage(
              _userData?['profileImage'] ?? 'assets/images/profile.svg',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _userData?['full_name'] ?? 'N/A',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            _userData?['role'] == 'Student'
                ? '${_userData?['field_of_study'] ?? 'N/A'} • ${_userData?['semester'] ?? 'N/A'}'
                : '${_userData?['department'] ?? 'N/A'}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Information',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          if (_userData?['role'] == 'Student') ...[
            _buildInfoItem(
              Icons.badge_outlined,
              'Student ID',
              _formatValue(_userData?['student_id']),
            ),
            _buildInfoItem(
              Icons.school_outlined,
              'Field of Study',
              _formatValue(_userData?['field_of_study']),
            ),
            _buildInfoItem(
              Icons.calendar_today_outlined,
              'Semester',
              _formatValue(_userData?['semester']),
            ),
          ] else if (_userData?['role'] == 'Instructor') ...[
            _buildInfoItem(
              Icons.badge_outlined,
              'Instructor ID',
              _formatValue(_userData?['instructor_id']),
            ),
            _buildInfoItem(
              Icons.business_outlined,
              'Department',
              _formatValue(_userData?['department']),
            ),
          ],
          _buildInfoItem(
            Icons.email_outlined,
            'Email',
            _formatValue(_userData?['email']),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                Flexible(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClubsSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Clubs',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _userClubs.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.groups_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'You are not a member of any club yet',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClubsPage(
                                  studentId: widget.studentId,
                                  clubs: widget.clubs,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6a0e33),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Explore Clubs'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _userClubs.length,
                  itemBuilder: (context, index) {
                    final club = _userClubs[index];
                    return _buildClubItem(club);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildClubItem(Club club) {
    return ListTile(
      leading: CircleAvatar(backgroundImage: AssetImage(club.profileImagePath)),
      title: Text(club.name),
      subtitle: Text(_getUserRoleInClub(club)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.pushNamed(
          context,
          '/club_profile',
          arguments: {'club': club, 'studentId': widget.studentId},
        );
      },
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
