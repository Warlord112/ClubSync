import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase

class ClubMember {
  final String name;
  final String position;
  final String
  role; // 'executive', 'sub-executive', 'general', 'advisor', 'co-advisor'
  final String? profileImagePath;
  final String studentId;

  ClubMember({
    required this.name,
    required this.position,
    required this.role,
    this.profileImagePath,
    required this.studentId,
  });

  ClubMember copyWith({
    String? name,
    String? position,
    String? role,
    String? profileImagePath,
    String? studentId,
  }) {
    return ClubMember(
      name: name ?? this.name,
      position: position ?? this.position,
      role: role ?? this.role,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      studentId: studentId ?? this.studentId,
    );
  }

  bool get isExecutive => role == 'executive';
  bool get isSubExecutive => role == 'sub-executive';
  bool get isAdvisor => role == 'advisor';
  bool get isCoAdvisor => role == 'co-advisor';
  bool get isGeneralMember =>
      role == 'general'; // New: check for general member
}

class ClubJoinRequest {
  final String studentId;
  final String studentName;
  final String? profileImagePath;
  final DateTime requestDate;
  final String status; // 'pending', 'approved', 'declined'
  final String id; // New: Added id field
  final String clubId; // New: Added clubId field

  ClubJoinRequest({
    required this.studentId,
    required this.studentName,
    this.profileImagePath,
    required this.requestDate,
    this.status = 'pending',
    required this.id, // New: Added id to constructor
    required this.clubId, // New: Added clubId to constructor
  });
}

class Activity {
  final String id;
  final String title;
  final String description;

  Activity({required this.id, required this.title, required this.description});
}

class Achievement {
  final String id;
  final String year;
  final String description;

  Achievement({
    required this.id,
    required this.year,
    required this.description,
  });
}

class Club {
  final String name;
  final String coverImagePath;
  final String profileImagePath;
  final String description;
  final List<ClubMember> members;
  final List<ClubJoinRequest> joinRequests;
  final List<Activity> activities;
  final List<Achievement> achievements;
  final String id; // Added id field

  Club({
    required this.name,
    required this.coverImagePath,
    required this.profileImagePath,
    required this.description,
    List<ClubMember>? members,
    List<ClubJoinRequest>? joinRequests,
    List<Activity>? activities,
    List<Achievement>? achievements,
    required this.id, // Added id to constructor
  }) : members = members ?? [],
       joinRequests = joinRequests ?? [],
       activities = activities ?? [],
       achievements = achievements ?? [];

  // Check if a student is an executive member of this club
  bool isExecutiveMember(String studentId) {
    return members.any(
      (member) => member.studentId == studentId && member.isExecutive,
    );
  }

  // Check if a student is an advisor member of this club
  bool isAdvisorMember(String studentId) {
    return members.any(
      (member) => member.studentId == studentId && member.isAdvisor,
    );
  }

  // Check if a student is an executive or advisor member of this club
  bool isExecutiveOrAdvisorMember(String studentId) {
    return members.any(
      (member) =>
          member.studentId == studentId &&
          (member.isExecutive || member.isAdvisor || member.isCoAdvisor),
    );
  }

  // Check if a student is a general member of this club
  bool isGeneralClubMember(String studentId) {
    return members.any(
      (member) => member.studentId == studentId && member.isGeneralMember,
    );
  }

  // Add a join request
  void addJoinRequest(ClubJoinRequest request) {
    joinRequests.add(request);
  }

  // Approve a join request
  void approveJoinRequest(String studentId) {
    final requestIndex = joinRequests.indexWhere(
      (req) => req.studentId == studentId,
    );
    if (requestIndex != -1) {
      final request = joinRequests[requestIndex];
      // Add as a general member
      members.add(
        ClubMember(
          name: request.studentName,
          position: 'Member',
          role: 'general',
          profileImagePath: request.profileImagePath,
          studentId: request.studentId,
        ),
      );
      // Remove the request
      joinRequests.removeAt(requestIndex);
    }
  }

  // Decline a join request
  void declineJoinRequest(String studentId) {
    joinRequests.removeWhere((req) => req.studentId == studentId);
  }
}

Future<List<Club>> getClubs() async {
  final SupabaseClient supabase = Supabase.instance.client;
  try {
    final response = await supabase
        .from('clubs')
        .select(
          '*, club_members(*)', // Select all club fields and related club_members
        );

    final List<Club> clubs = [];
    for (var clubData in response as List) {
      final List<ClubMember> members = [];
      for (var memberData in clubData['club_members'] as List) {
        members.add(
          ClubMember(
            name: memberData['name'] as String,
            position: memberData['position'] as String,
            role: memberData['role'] as String,
            profileImagePath: memberData['profile_image_path'] as String?,
            studentId: memberData['student_id'] as String,
          ),
        );
      }

      clubs.add(
        Club(
          id: clubData['id'] as String,
          name: clubData['name'] as String,
          description: clubData['description'] as String,
          profileImagePath:
              clubData['profile_image_path'] as String? ??
              'assets/images/computer.svg', // Default image
          coverImagePath:
              clubData['cover_image_path'] as String? ??
              'assets/images/sunset.svg', // Default image
          members: members,
          // Initialize other lists as empty for now
          joinRequests: [],
          activities: [],
          achievements: [],
        ),
      );
    }
    return clubs;
  } catch (e) {
    print('Error fetching clubs: $e');
    return [];
  }
}
