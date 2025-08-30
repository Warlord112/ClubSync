import 'package:flutter/material.dart';
import 'package:clubsync/data/club_data.dart';

class ProfilePage extends StatefulWidget {
  final String studentId;
  final List<Club> clubs;

  const ProfilePage({
    super.key,
    required this.studentId,
    required this.clubs,
  });

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Sample user data
  final Map<String, dynamic> _userData = {
    'name': 'Alex Johnson',
    'studentId': '2020001',
    'department': 'Computer Science',
    'year': '3rd Year',
    'email': 'alex.johnson@example.edu',
    'profileImage': 'assets/images/profile.svg',
  };

  @override
  void initState() {
    super.initState();
    // In a real app, you would fetch user data based on studentId
    // For now, we'll use the sample data
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
              // Navigate to settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 16),
            _buildInfoSection(),
            const SizedBox(height: 16),
            _buildClubsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[300],
            backgroundImage: AssetImage(_userData['profileImage']),
          ),
          const SizedBox(height: 16),
          Text(
            _userData['name'],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _userData['department'],
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          const SizedBox(height: 4),
          Text(
            _userData['year'],
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Edit profile
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6a0e33),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Edit Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildInfoItem(Icons.badge_outlined, 'Student ID', _userData['studentId']),
          _buildInfoItem(Icons.email_outlined, 'Email', _userData['email']),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClubsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Clubs',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _userClubs.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(Icons.groups_outlined, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'You are not a member of any club yet',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/clubs');
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
      leading: CircleAvatar(
        backgroundImage: AssetImage(club.profileImagePath),
      ),
      title: Text(club.name),
      subtitle: Text(_getUserRoleInClub(club)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.pushNamed(
          context,
          '/club_profile',
          arguments: club,
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