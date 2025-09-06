import 'package:flutter/material.dart';
import '../data/club_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/constants.dart';
import 'edit_club_profile_page.dart'; // Added import for EditClubProfilePage

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
  bool _isCurrentUserInstructor = false;
  bool _isCurrentUserStudent = false; // Added to check if current user is a student
  bool _isClubCreator = false; // New: Tracks if the current user created this club
  bool _isMemberOfClub = false; // New: Tracks if the current user is a member of this club
  bool _hasPendingRequest = false; // New: Tracks if the current user has a pending join request
  Club? _currentClub; // New: Mutable club object
  final SupabaseClient supabase = Supabase.instance.client;

  List<Activity> _activities = []; // New: To store fetched activities
  List<Achievement> _achievements = []; // New: To store fetched achievements
  List<ClubJoinRequest> _pendingJoinRequests = []; // New: To store pending join requests

  @override
  void initState() {
    super.initState();
    _currentClub = widget.club; // Initialize _currentClub
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _fetchInitialData(); // Refactored to fetch all necessary initial data
  }

  Future<void> _fetchInitialData() async {
    // Fetch the latest club data from the database
    try {
      final response = await supabase
          .from(kClubsTable)
          .select('*, club_members(*)')
          .eq('id', widget.club.id)
          .single();

      final List<ClubMember> members = [];
      for (var memberData in response['club_members'] as List) {
        members.add(ClubMember(
          name: memberData['name'] as String,
          position: memberData['position'] as String,
          role: memberData['role'] as String,
          profileImagePath: memberData['profile_image_path'] as String?,
          studentId: memberData['student_id'] as String,
        ));
      }

      setState(() {
        _currentClub = Club(
          id: response['id'] as String,
          name: response['name'] as String,
          description: response['description'] as String,
          profileImagePath: response['profile_image_path'] as String? ?? 'assets/images/computer.svg',
          coverImagePath: response['cover_image_path'] as String? ?? 'assets/images/sunset.svg',
          members: members,
        );
      });
    } catch (e) {
      debugPrint('Error fetching club data: $e');
    }

    await _fetchUserRole();
    await _checkIfClubCreator(); // Call new method
    await _checkMembership();
    await _fetchActivities(); // Fetch activities
    await _fetchAchievements(); // Fetch achievements
    await _checkPendingRequest(); // New: Check for pending join requests
    await _fetchPendingJoinRequests(); // New: Fetch pending join requests for instructor
    setState(() {}); // Trigger rebuild after all data is fetched
  }

  Future<void> _fetchUserRole() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      final response = await supabase
          .from(kUsersTable)
          .select('role')
          .eq('id', user.id)
          .single();
      if (response.isNotEmpty) {
        final userRole = response['role'];
        setState(() {
          _isCurrentUserInstructor = userRole == kRoleInstructor;
          _isCurrentUserStudent = userRole == kRoleStudent; // Set student role
        });
      }
    }
  }

  Future<void> _checkIfClubCreator() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      // Check if the current user's ID matches the club's created_by ID
      final response = await supabase
          .from(kClubsTable)
          .select('id')
          .eq('id', _currentClub!.id)
          .eq('created_by', user.id)
          .limit(1)
          .single();
      setState(() {
        _isClubCreator = response.isNotEmpty; // If a record is found, they are the creator
      });
    }
  }

  Future<void> _checkMembership() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      debugPrint('DEBUG: _checkMembership - club_id: ${_currentClub!.id}, student_id: ${widget.currentStudentId}'); // DEBUG
      final response = await supabase
          .from(kClubMembersTable) // Assuming a 'club_members' table exists
          .select()
          .eq('club_id', _currentClub!.id)
          .eq('student_id', widget.currentStudentId) // Use widget.currentStudentId
          .limit(1)
          .single();

      setState(() {
        _isMemberOfClub = response.isNotEmpty; // If a record is found, they are a member
        debugPrint('DEBUG: _isMemberOfClub set to: $_isMemberOfClub. Supabase response: $response'); // DEBUG
      });
    }
  }

  Future<void> _checkPendingRequest() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      try {
        final response = await supabase
            .from(kJoinRequestsTable)
            .select('id')
            .eq('club_id', _currentClub!.id)
            .eq('student_id', widget.currentStudentId) // Use widget.currentStudentId
            .eq('status', kStatusPending)
            .limit(1)
            .single();
        setState(() {
          _hasPendingRequest = response.isNotEmpty;
        });
      } catch (e) {
        // Handle case where no pending request is found (response will be empty)
        setState(() {
          _hasPendingRequest = false;
        });
        debugPrint('Error checking pending request: $e');
      }
    }
  }

  Future<void> _fetchPendingJoinRequests() async {
    if (!_isCurrentUserInstructor || !_isClubCreator) {
      _pendingJoinRequests = [];
      return; // Only instructors who created the club can view requests
    }

    try {
      final response = await supabase
          .from(kJoinRequestsTable)
          .select('id, student_id, student_name, request_date, status')
          .eq('club_id', _currentClub!.id)
          .eq('status', kStatusPending);

      setState(() {
        _pendingJoinRequests = response.map((data) => ClubJoinRequest(
              id: data['id'] as String,
              studentId: data['student_id'] as String,
              studentName: data['student_name'] as String,
              requestDate: DateTime.parse(data['request_date'] as String),
              status: data['status'] as String,
              clubId: _currentClub!.id, // Add clubId here
            )).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$kErrorFetchingJoinRequests $e')),
        );
      }
      debugPrint('Error fetching pending join requests: $e');
    }
  }

  Future<void> _sendJoinRequest() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(kLoginRequiredMessage)),
          );
        }
        return;
      }

      // Fetch user's full name from the 'users' table
      final userData = await supabase
          .from(kUsersTable)
          .select('full_name')
          .eq('id', user.id)
          .single();

      if (userData.isEmpty || userData['full_name'] == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(kUserFullNameNotFound)),
          );
        }
        return;
      }

      final userName = userData['full_name'] as String;

      debugPrint('DEBUG: _sendJoinRequest - club_id: ${_currentClub!.id}, student_id: ${widget.currentStudentId}'); // DEBUG
      await supabase.from(kJoinRequestsTable).insert({
        'club_id': _currentClub!.id,
        'student_id': widget.currentStudentId, // Use widget.currentStudentId
        'student_name': userName,
        'request_date': DateTime.now().toIso8601String(),
        'status': kStatusPending,
      });

      setState(() {
        _hasPendingRequest = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(kJoinRequestSentSuccess)),
        );
      }
      await _checkMembership(); // Re-check membership status
      await _checkPendingRequest(); // Re-check pending request status
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$kErrorSendingJoinRequest $e')),
        );
      }
      debugPrint('Error sending join request: $e');
    }
  }

  Future<void> _cancelJoinRequest() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(kLoginRequiredMessage)),
          );
        }
        return;
      }

      debugPrint('DEBUG: _cancelJoinRequest - club_id: ${_currentClub!.id}, student_id: ${widget.currentStudentId}'); // DEBUG
      await supabase
          .from(kJoinRequestsTable)
          .delete()
          .eq('club_id', _currentClub!.id)
          .eq('student_id', widget.currentStudentId) // Use widget.currentStudentId
          .eq('status', kStatusPending);

      setState(() {
        _hasPendingRequest = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(kJoinRequestCancelledSuccess)),
        );
      }
      await _checkMembership(); // Re-check membership status
      await _checkPendingRequest(); // Re-check pending request status
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$kErrorCancellingJoinRequest $e')),
        );
      }
      debugPrint('Error cancelling join request: $e');
    }
  }

  Future<void> _fetchActivities() async {
    try {
      final response = await supabase
          .from(kActivitiesTable)
          .select('*')
          .eq('club_id', _currentClub!.id)
          .order('created_at', ascending: true);
      setState(() {
        _activities = response.map((data) => Activity(
              id: data['id'] as String,
              title: data['title'] as String,
              description: data['description'] as String,
            )).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$kErrorFetchingActivities $e')),
        );
      }
      debugPrint('Error fetching activities: $e');
    }
  }

  Future<void> _fetchAchievements() async {
    try {
      final response = await supabase
          .from(kAchievementsTable)
          .select('*')
          .eq('club_id', _currentClub!.id)
          .order('year', ascending: true);
      setState(() {
        _achievements = response.map((data) => Achievement(
              id: data['id'] as String,
              year: data['year'] as String,
              description: data['description'] as String,
            )).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$kErrorFetchingAchievements $e')),
        );
      }
      debugPrint('Error fetching achievements: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('DEBUG: Building ClubProfilePage - _isMemberOfClub: $_isMemberOfClub, _hasPendingRequest: $_hasPendingRequest'); // DEBUG
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
                  _currentClub!.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Club description
                Text(
                  _currentClub!.description,
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
        color: kPrimaryColor,
        child: TabBar(
          controller: _tabController,
          labelColor: kWhiteColor,
          unselectedLabelColor: Colors.white70,
          indicatorColor: kWhiteColor,
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
    // debugPrint('Rendering buttons: _isCurrentUserStudent: $_isCurrentUserStudent, _isMemberOfClub: $_isMemberOfClub, _hasPendingRequest: $_hasPendingRequest'); // Debug print moved here
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
              image: AssetImage(_currentClub!.coverImagePath),
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
                    color: kWhiteColor,
                    size: 20,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                kClubDetailsTitle,
                style: TextStyle(
                  color: kWhiteColor,
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
              actions: [
                // debugPrint('Rendering buttons: _isCurrentUserStudent: $_isCurrentUserStudent, _isMemberOfClub: $_isMemberOfClub, _hasPendingRequest: $_hasPendingRequest'); // Debug print (moved)
                if (_isCurrentUserInstructor && _currentClub!.isExecutiveOrAdvisorMember(widget.currentStudentId)) // Only show edit button to instructor who is an executive or advisor member
                  IconButton(
                    icon: const Icon(Icons.edit, color: kWhiteColor),
                    onPressed: _editClubProfile,
                  ),
                if (_isCurrentUserStudent) // Logic for student actions (Join/Leave/Cancel Request)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _isMemberOfClub
                        ? ElevatedButton(
                            onPressed: _leaveClub, // New: Leave Club button
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kRedColor,
                              foregroundColor: kWhiteColor,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              kLeaveGroupText,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          )
                        : _hasPendingRequest
                            ? ElevatedButton(
                                onPressed: _cancelJoinRequest,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kRedColor,
                                  foregroundColor: kWhiteColor,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  kCancelRequestText,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )
                            : ElevatedButton(
                                onPressed: _sendJoinRequest,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kPrimaryColor, // Maroon color
                                  foregroundColor: kWhiteColor, // Text color
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8), // Rounded corners
                                  ),
                                ),
                                child: const Text(
                                  kJoinClubText,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                  ),
              ],
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
              backgroundImage: AssetImage(_currentClub!.profileImagePath),
              backgroundColor: Colors.grey[300],
            ),
          ),
        ),
      ],
    );
  }

  void _promoteMember(ClubMember member) async {
    ClubMember? updatedMember; // Declare here
    setState(() {
      final int index = _currentClub!.members.indexOf(member);
      if (index != -1) {
        String? newRole;
        String? newPosition;

        if (member.role == kRoleGeneral) {
          newRole = kRoleSubExecutive;
          newPosition = kPositionSubExecutive; // Default sub-executive position
        } else if (member.role == kRoleSubExecutive) {
          newRole = kRoleExecutive;
          newPosition = kPositionExecutive; // Default executive position
        }

        if (newRole != null) {
          updatedMember = member.copyWith(role: newRole, position: newPosition);
          _currentClub!.members[index] = updatedMember!; // Use null assertion operator
        }
      }
    });

    if (updatedMember == null) return; // Exit if no update happened

    // Persist changes to the database
    try {
      await supabase.from(kClubMembersTable).update({
        'role': updatedMember!.role,
        'position': updatedMember!.position,
      }).eq('student_id', member.studentId).eq('club_id', _currentClub!.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(kPromoteMemberSuccessMessage)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$kErrorPromotingMember $e')),
        );
      }
      debugPrint('Error promoting member: $e');
    }
    // Refresh the club members list to reflect changes in UI
    // This will implicitly re-fetch the club data including updated members.
    await _fetchInitialData();
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
                      Icon(Icons.event_note, color: kPrimaryColor),
                      const SizedBox(width: 8),
                      const Text(
                        kOurActivitiesTitle,
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
                  if (_activities.isEmpty)
                    Text(kNoActivitiesFoundText, style: TextStyle(color: kGreyColor[600]))
                  else
                    ..._activities.map((activity) => _buildActivityItem(activity)),
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
                      Icon(Icons.emoji_events, color: kPrimaryColor),
                      const SizedBox(width: 8),
                      const Text(
                        kOurAchievementsTitle,
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
                  if (_achievements.isEmpty)
                    Text(kNoAchievementsFoundText, style: TextStyle(color: kGreyColor[600]))
                  else
                    ..._achievements.map((achievement) => _buildAchievementItem(achievement)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Activity activity) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bullet point icon
          Icon(Icons.circle, size: 10, color: kPrimaryColor),
          const SizedBox(width: 10),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.description,
                  style: TextStyle(fontSize: 14, color: kGreyColor[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementItem(Achievement achievement) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Year badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              achievement.year,
              style: const TextStyle(
                color: kWhiteColor,
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
              child: Text(achievement.description, style: const TextStyle(fontSize: 14)),
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
                  color: kPrimaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: kPrimaryColor,
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
                    backgroundColor: kGreyColor[300],
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
                    style: TextStyle(color: kGreyColor[700]),
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
    final member = _currentClub!.members.firstWhere(
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
                    child: Text(kViewProfileText),
                  ),
                ],
              ),
            ),
            if (_isCurrentUserInstructor) ...[
              if (member.role == kRoleGeneral || member.role == kRoleSubExecutive)
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
                          member.role == kRoleGeneral
                              ? kPromoteToSubExecutiveText
                              : kPromoteToExecutiveText,
                        ),
                      ),
                    ],
                  ),
                ),
              if (member.role == kRoleExecutive || member.role == kRoleSubExecutive)
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
                          member.role == kRoleExecutive
                              ? kDemoteToSubExecutiveText
                              : kDemoteToGeneralMemberText,
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
                    Icon(Icons.remove_circle_outline, color: kRedColor),
                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text(
                        kRemoveMemberText,
                        style: TextStyle(color: kRedColor),
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

  void _demoteMember(ClubMember member) async {
    ClubMember? updatedMember; // Declare here
    setState(() {
      final int index = _currentClub!.members.indexOf(member);
      if (index != -1) {
        String? newRole;
        String? newPosition;

        if (member.role == kRoleExecutive) {
          newRole = kRoleSubExecutive;
          newPosition = kPositionSubExecutive;
        } else if (member.role == kRoleSubExecutive) {
          newRole = kRoleGeneral;
          newPosition = kPositionGeneral;
        }

        if (newRole != null) {
          updatedMember = member.copyWith(role: newRole, position: newPosition);
          _currentClub!.members[index] = updatedMember!; // Use null assertion operator
        }
      }
    });

    if (updatedMember == null) return; // Exit if no update happened

    // Persist changes to the database
    try {
      await supabase.from(kClubMembersTable).update({
        'role': updatedMember!.role,
        'position': updatedMember!.position,
      }).eq('student_id', member.studentId).eq('club_id', _currentClub!.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(kDemoteMemberSuccessMessage)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$kErrorDemotingMember $e')),
        );
      }
      debugPrint('Error demoting member: $e');
    }
    // Refresh the club members list to reflect changes in UI
    await _fetchInitialData();
  }

  void _removeMember(ClubMember member) {
    setState(() {
      _currentClub!.members.remove(member);
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
                      Icon(Icons.event_note, color: kPrimaryColor),
                      const SizedBox(width: 8),
                      const Text(
                        kUpcomingEventsTitle,
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
                          Icon(Icons.event, size: 48, color: kGreyColor[400]),
                          const SizedBox(height: 12),
                          Text(
                            kNoUpcomingEventsText,
                            style: TextStyle(
                              fontSize: 16,
                              color: kGreyColor[600],
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
                      Icon(Icons.history, color: kPrimaryColor),
                      const SizedBox(width: 8),
                      const Text(
                        kPastEventsTitle,
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
                            color: kGreyColor[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            kNoPastEventsText,
                            style: TextStyle(
                              fontSize: 16,
                              color: kGreyColor[600],
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
    final advisorMembers = _currentClub!.members
        .where((m) => m.isAdvisor)
        .toList();
    final coAdvisorMembers = _currentClub!.members
        .where((m) => m.isCoAdvisor)
        .toList();
    final executiveMembers = _currentClub!.members
        .where((m) => m.role == kRoleExecutive)
        .toList();
    final subExecutiveMembers = _currentClub!.members
        .where((m) => m.role == kRoleSubExecutive)
        .toList();
    final generalMembers = _currentClub!.members
        .where((m) => m.role == kRoleGeneral)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pending Join Requests (only for club creator)
          if (_isCurrentUserInstructor && _isClubCreator) ...[
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
                    Row(
                      children: [
                        Icon(Icons.person_add, color: kPrimaryColor),
                        const SizedBox(width: 8),
                        const Text(
                          kPendingJoinRequestsTitle,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    if (_pendingJoinRequests.isEmpty)
                      Text(kNoPendingRequests, style: TextStyle(color: kGreyColor[600]))
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _pendingJoinRequests.length,
                        itemBuilder: (context, index) {
                          final request = _pendingJoinRequests[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: kGreyColor[300],
                                child: Text(request.studentName[0], style: const TextStyle(color: Colors.black)),
                              ),
                              title: Text(request.studentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('Requested on ${request.requestDate.day}/${request.requestDate.month}/${request.requestDate.year}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.check_circle, color: Colors.green),
                                    onPressed: () => _approveJoinRequest(request),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.cancel, color: kRedColor),
                                    onPressed: () => _declineJoinRequest(request),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Advisor
          if (advisorMembers.isNotEmpty) ...[
            _buildPositionSection(
              kAdvisorTitle,
              advisorMembers
                  .map((m) => {'name': m.name, 'position': m.position})
                  .toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Co-Advisor
          if (coAdvisorMembers.isNotEmpty) ...[
            _buildPositionSection(
              kCoAdvisorTitle,
              coAdvisorMembers
                  .map((m) => {'name': m.name, 'position': m.position})
                  .toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Executive body
          if (executiveMembers.isNotEmpty) ...[
            _buildPositionSection(
              kExecutiveBodyTitle,
              executiveMembers
                  .map((m) => {'name': m.name, 'position': m.position})
                  .toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Sub executive body
          if (subExecutiveMembers.isNotEmpty) ...[
            _buildPositionSection(
              kSubExecutiveBodyTitle,
              subExecutiveMembers
                  .map((m) => {'name': m.name, 'position': m.position})
                  .toList(),
            ),
            const SizedBox(height: 24),
          ],

          // General members
          if (generalMembers.isNotEmpty) ...[
            _buildPositionSection(
              kGeneralMembersTitle,
              generalMembers
                  .map((m) => {'name': m.name, 'position': m.position})
                  .toList(),
            ),
          ],

          if (_currentClub!.members.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(Icons.people_outline, size: 64, color: kGreyColor[400]),
                  const SizedBox(height: 16),
                  Text(
                    kNoMembersText,
                    style: TextStyle(fontSize: 18, color: kGreyColor[600]),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _approveJoinRequest(ClubJoinRequest request) async {
    try {
      // Add student to club_members table
      await supabase.from(kClubMembersTable).insert({
        'club_id': request.clubId,
        'student_id': request.studentId,
        'name': request.studentName,
        'position': kPositionMember,
        'role': kRoleGeneral,
        'joined_at': DateTime.now().toIso8601String(),
      });

      // Update join_request status to approved
      await supabase.from(kJoinRequestsTable).update({
        'status': kStatusApproved,
      }).eq('id', request.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(kJoinRequestApprovedSuccess)),
        );
      }
      _fetchPendingJoinRequests(); // Refresh pending requests
      _checkMembership(); // Refresh membership status
      await _checkPendingRequest(); // Explicitly re-check pending request status
      await _fetchInitialData(); // Refresh all club data after approval
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$kErrorApprovingJoinRequest $e')),
        );
      }
      debugPrint('Error approving join request: $e');
    }
  }

  Future<void> _declineJoinRequest(ClubJoinRequest request) async {
    try {
      // Update join_request status to declined (or delete the request)
      await supabase.from(kJoinRequestsTable).update({
        'status': kStatusDeclined,
      }).eq('id', request.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(kJoinRequestDeclinedSuccess)),
        );
      }
      _fetchPendingJoinRequests(); // Refresh pending requests
      await _checkMembership(); // Refresh membership status
      await _checkPendingRequest(); // Re-check pending request status
      await _fetchInitialData(); // Refresh all club data after decline
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$kErrorDecliningJoinRequest $e')),
        );
      }
      debugPrint('Error declining join request: $e');
    }
  }

  void _editClubProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditClubProfilePage(club: _currentClub!),
      ),
    );
  }

  Future<void> _leaveClub() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(kLoginRequiredMessage)),
          );
        }
        return;
      }

      // Remove the member from the club_members table
      await supabase
          .from(kClubMembersTable)
          .delete()
          .eq('club_id', _currentClub!.id)
          .eq('student_id', widget.currentStudentId); // Use widget.currentStudentId

      setState(() {
        _isMemberOfClub = false;
        _currentClub!.members.removeWhere((member) => member.studentId == user.id); // Remove from local list
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(kLeaveClubSuccessMessage)),
        );
      }
      await _checkMembership(); // Re-check membership status
      await _checkPendingRequest(); // Re-check pending request status
      await _fetchInitialData(); // Refresh all club data after leaving
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$kErrorLeavingClub $e')),
        );
      }
      debugPrint('Error leaving club: $e');
    }
  }
}
