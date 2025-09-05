import 'package:flutter/material.dart';
import '../data/club_data.dart';
import 'club_join_requests_page.dart';

class ClubProfilePage extends StatefulWidget {
  final Club club;
  final String currentStudentId;

  const ClubProfilePage({
    super.key,
    required this.club,
    required this.currentStudentId,
  });

  @override
  _ClubProfilePageState createState() => _ClubProfilePageState();
}

class _ClubProfilePageState extends State<ClubProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isCurrentUserInstructor =
      false; // Added to check if current user is an instructor

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });

    // For demonstration, assume instructor IDs start with 'inst'
    _isCurrentUserInstructor = widget.currentStudentId.startsWith('inst');
    debugPrint(
      'ClubProfilePage - currentStudentId: ${widget.currentStudentId}',
    );
    debugPrint(
      'ClubProfilePage - _isCurrentUserInstructor: $_isCurrentUserInstructor',
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Cover photo and profile picture
          _buildCoverAndProfile(),

          // Club name and description
          Container(
            padding: const EdgeInsets.fromLTRB(16.0, 70.0, 16.0, 8.0),
            child: Column(
              children: [
                // Club name
                Text(
                  widget.club.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6a0e33),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Club description
                Text(
                  widget.club.description,
                  style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildClubProfileTab(),
                _buildEventDetailsTab(),
                _buildClubMembersTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFF6a0e33),
        child: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Club Profile', icon: Icon(Icons.info)),
            Tab(text: 'Event Details', icon: Icon(Icons.event)),
            Tab(text: 'Club Members', icon: Icon(Icons.people)),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverAndProfile() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // Cover photo with gradient overlay
        Container(
          height: 200, // Reduced height
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(widget.club.coverImagePath),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
              ),
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Club Details',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Profile picture overlapping the cover
        Positioned(
          bottom: -50, // Reduced overlap
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 4,
              ), // Thinner border
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 50, // Smaller radius
              backgroundImage: AssetImage(widget.club.profileImagePath),
              backgroundColor: Colors.grey[300],
            ),
          ),
        ),
      ],
    );
  }

  void _promoteMember(ClubMember member) {
    setState(() {
      final int index = widget.club.members.indexOf(member);
      if (index != -1) {
        ClubMember updatedMember = member; // Create a mutable copy
        String? newRole;
        String? newPosition;

        if (member.role == 'general') {
          newRole = 'sub-executive';
          newPosition =
              'Sub-Executive Member'; // Default sub-executive position
        } else if (member.role == 'sub-executive') {
          newRole = 'executive';
          newPosition = 'Executive Member'; // Default executive position
        }

        if (newRole != null) {
          updatedMember = member.copyWith(role: newRole, position: newPosition);
          widget.club.members[index] = updatedMember;
        }
      }
    });
  }

  Widget _buildClubProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Club activities section with card layout
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section header with icon
                  Row(
                    children: [
                      Icon(Icons.event_note, color: const Color(0xFF6a0e33)),
                      const SizedBox(width: 8),
                      const Text(
                        'Our Activities',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Activities list
                  _buildActivityItem(
                    'Regular Meetings',
                    'We meet every week to discuss new ideas and plan upcoming events.',
                  ),
                  _buildActivityItem(
                    'Workshops',
                    'We organize workshops to help members develop their skills.',
                  ),
                  _buildActivityItem(
                    'Community Outreach',
                    'We engage with the wider community through various initiatives.',
                  ),
                ],
              ),
            ),
          ),

          // Club achievements section with card layout
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section header with icon
                  Row(
                    children: [
                      Icon(Icons.emoji_events, color: const Color(0xFF6a0e33)),
                      const SizedBox(width: 8),
                      const Text(
                        'Our Achievements',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Achievements list
                  _buildAchievementItem(
                    '2023',
                    'Won the Best Club Award at the Annual Club Fair',
                  ),
                  _buildAchievementItem(
                    '2022',
                    'Successfully organized 10+ events with over 500 participants',
                  ),
                  _buildAchievementItem(
                    '2021',
                    'Raised funds for local charity organizations',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bullet point icon
          Icon(Icons.circle, size: 10, color: const Color(0xFF6a0e33)),
          const SizedBox(width: 10),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementItem(String year, String achievement) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Year badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF6a0e33),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              year,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Achievement text
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(achievement, style: const TextStyle(fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPositionSection(
    String title,
    List<Map<String, String>> members,
  ) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header with icon
            Row(
              children: [
                Icon(
                  title.contains('Advisor')
                      ? Icons.school
                      : title.contains('Executive')
                      ? Icons.stars
                      : Icons.people,
                  color: const Color(0xFF6a0e33),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6a0e33),
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 4),
            // Member list
            ...members.map(
              (member) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    child: Text(
                      member['name']![0],
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  title: Text(
                    member['name']!,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    member['position']!,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  onTap: () {
                    _showMemberOptionsDialog(member);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMemberOptionsDialog(Map<String, String> memberMap) {
    final member = widget.club.members.firstWhere(
      (m) => m.name == memberMap['name'] && m.position == memberMap['position'],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(member.name),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Navigate to member profile page
                print('View Profile for ${member.name}');
              },
              child: const Row(
                children: <Widget>[
                  Icon(Icons.person),
                  Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text('View Profile'),
                  ),
                ],
              ),
            ),
            if (_isCurrentUserInstructor) ...[
              if (member.role == 'general' || member.role == 'sub-executive')
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                    _promoteMember(member);
                  },
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.arrow_circle_up),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          member.role == 'general'
                              ? 'Promote to Sub-Executive'
                              : 'Promote to Executive',
                        ),
                      ),
                    ],
                  ),
                ),
              if (member.role == 'executive' || member.role == 'sub-executive')
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                    _demoteMember(member);
                  },
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.arrow_circle_down),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          member.role == 'executive'
                              ? 'Demote to Sub-Executive'
                              : 'Demote to General Member',
                        ),
                      ),
                    ],
                  ),
                ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  _removeMember(member);
                },
                child: const Row(
                  children: <Widget>[
                    Icon(Icons.remove_circle_outline, color: Colors.red),
                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text(
                        'Remove Member',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  void _demoteMember(ClubMember member) {
    setState(() {
      final int index = widget.club.members.indexOf(member);
      if (index != -1) {
        ClubMember updatedMember = member;
        String? newRole;
        String? newPosition;

        if (member.role == 'executive') {
          newRole = 'sub-executive';
          newPosition = 'Sub-Executive Member';
        } else if (member.role == 'sub-executive') {
          newRole = 'general';
          newPosition = 'Member';
        }

        if (newRole != null) {
          updatedMember = member.copyWith(role: newRole, position: newPosition);
          widget.club.members[index] = updatedMember;
        }
      }
    });
  }

  void _removeMember(ClubMember member) {
    setState(() {
      widget.club.members.remove(member);
    });
  }

  Widget _buildEventDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Upcoming events section
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section header with icon
                  Row(
                    children: [
                      Icon(Icons.event_note, color: const Color(0xFF6a0e33)),
                      const SizedBox(width: 8),
                      const Text(
                        'Upcoming Events',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),

                  // If there are no upcoming events
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        children: [
                          Icon(Icons.event, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          Text(
                            'No upcoming events',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Past events section
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section header with icon
                  Row(
                    children: [
                      Icon(Icons.history, color: const Color(0xFF6a0e33)),
                      const SizedBox(width: 8),
                      const Text(
                        'Past Events',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),

                  // If there are no past events
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.event_available,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No past events',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClubMembersTab() {
    // Filter members by role
    final advisorMembers = widget.club.members
        .where((m) => m.isAdvisor)
        .toList();
    final coAdvisorMembers = widget.club.members
        .where((m) => m.isCoAdvisor)
        .toList();
    final executiveMembers = widget.club.members
        .where((m) => m.role == 'executive')
        .toList();
    final subExecutiveMembers = widget.club.members
        .where((m) => m.role == 'sub-executive')
        .toList();
    final generalMembers = widget.club.members
        .where((m) => m.role == 'general')
        .toList();

    // Check if current user is an executive member to show join requests button
    final bool canViewJoinRequests =
        _isCurrentUserInstructor ||
        executiveMembers.any(
          (m) => m.studentId == '2020001',
        ); // Assuming current user ID

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Join Requests Button (only for executives)
          if (canViewJoinRequests) ...[
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ClubJoinRequestsPage(club: widget.club),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6a0e33).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.person_add,
                          color: Color(0xFF6a0e33),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Join Requests',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${widget.club.joinRequests.length} pending requests',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          // Advisor
          if (advisorMembers.isNotEmpty) ...[
            _buildPositionSection(
              'Advisor',
              advisorMembers
                  .map((m) => {'name': m.name, 'position': m.position})
                  .toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Co-Advisor
          if (coAdvisorMembers.isNotEmpty) ...[
            _buildPositionSection(
              'Co-Advisor',
              coAdvisorMembers
                  .map((m) => {'name': m.name, 'position': m.position})
                  .toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Executive body
          if (executiveMembers.isNotEmpty) ...[
            _buildPositionSection(
              'Executive Body',
              executiveMembers
                  .map((m) => {'name': m.name, 'position': m.position})
                  .toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Sub executive body
          if (subExecutiveMembers.isNotEmpty) ...[
            _buildPositionSection(
              'Sub Executive Body',
              subExecutiveMembers
                  .map((m) => {'name': m.name, 'position': m.position})
                  .toList(),
            ),
            const SizedBox(height: 24),
          ],

          // General members
          if (generalMembers.isNotEmpty) ...[
            _buildPositionSection(
              'General Members',
              generalMembers
                  .map((m) => {'name': m.name, 'position': m.position})
                  .toList(),
            ),
          ],

          if (widget.club.members.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No members yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
