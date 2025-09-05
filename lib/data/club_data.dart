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
}

class ClubJoinRequest {
  final String studentId;
  final String studentName;
  final String? profileImagePath;
  final DateTime requestDate;
  final String status; // 'pending', 'approved', 'declined'

  ClubJoinRequest({
    required this.studentId,
    required this.studentName,
    this.profileImagePath,
    required this.requestDate,
    this.status = 'pending',
  });
}

class Club {
  final String name;
  final String coverImagePath;
  final String profileImagePath;
  final String description;
  final List<ClubMember> members;
  final List<ClubJoinRequest> joinRequests;

  Club({
    required this.name,
    required this.coverImagePath,
    required this.profileImagePath,
    required this.description,
    List<ClubMember>? members,
    List<ClubJoinRequest>? joinRequests,
  }) : members = members ?? [],
       joinRequests = joinRequests ?? [];

  // Check if a student is an executive member of this club
  bool isExecutiveMember(String studentId) {
    return members.any(
      (member) => member.studentId == studentId && member.isExecutive,
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

List<Club> getClubs() {
  List<Club> clubs = [
    Club(
      name: 'Art Club',
      coverImagePath: 'assets/images/art.svg',
      profileImagePath: 'assets/images/art.svg',
      description: 'A club for art enthusiasts to share and create artwork.',
      members: [
        ClubMember(
          name: 'John Doe',
          position: 'President',
          role: 'executive',
          studentId: '2020001',
        ),
        ClubMember(
          name: 'Jane Smith',
          position: 'Vice President',
          role: 'executive',
          studentId: '2020002',
        ),
        ClubMember(
          name: 'Sarah Williams',
          position: 'Treasurer',
          role: 'sub-executive',
          studentId: '2020003',
        ),
        ClubMember(
          name: 'Alex Wilson',
          position: 'Member',
          role: 'general',
          studentId: '2020004',
        ),
      ],
      joinRequests: [
        ClubJoinRequest(
          studentId: '2020101',
          studentName: 'Michael Johnson',
          requestDate: DateTime.now().subtract(const Duration(days: 2)),
        ),
        ClubJoinRequest(
          studentId: '2020102',
          studentName: 'Emily Davis',
          requestDate: DateTime.now().subtract(const Duration(days: 1)),
        ),
        ClubJoinRequest(
          studentId: '2020103',
          studentName: 'Robert Wilson',
          requestDate: DateTime.now(),
        ),
      ],
    ),
    Club(
      name: 'Computer Club',
      coverImagePath: 'assets/images/computer.svg',
      profileImagePath: 'assets/images/computer.svg',
      description: 'For students interested in programming and technology.',
      members: [
        ClubMember(
          name: 'Mike Johnson',
          position: 'President',
          role: 'executive',
          studentId: '2020005',
        ),
        ClubMember(
          name: 'Emily Davis',
          position: 'Vice President',
          role: 'executive',
          studentId: '2020006',
        ),
        ClubMember(
          name: 'David Brown',
          position: 'Event Coordinator',
          role: 'sub-executive',
          studentId: '2020007',
        ),
        ClubMember(
          name: 'Olivia Martinez',
          position: 'Member',
          role: 'general',
          studentId: '2020008',
        ),
      ],
    ),
    Club(
      name: 'Literary Club',
      coverImagePath: 'assets/images/literary.svg',
      profileImagePath: 'assets/images/literary.svg',
      description: 'A club for literature lovers and aspiring writers.',
      members: [
        ClubMember(
          name: 'Daniel Taylor',
          position: 'President',
          role: 'executive',
          studentId: '2020009',
        ),
        ClubMember(
          name: 'Sophia Anderson',
          position: 'Vice President',
          role: 'executive',
          studentId: '2020010',
        ),
      ],
    ),
    Club(
      name: 'MUN Club',
      coverImagePath: 'assets/images/mun.svg',
      profileImagePath: 'assets/images/mun.svg',
      description: 'Model United Nations club for debate and diplomacy.',
      members: [
        ClubMember(
          name: 'Ethan Thomas',
          position: 'President',
          role: 'executive',
          studentId: '2020011',
        ),
        ClubMember(
          name: 'Emma Wilson',
          position: 'Vice President',
          role: 'executive',
          studentId: '2020012',
        ),
      ],
    ),
    Club(
      name: 'Photography Club',
      coverImagePath: 'assets/images/sunset.svg',
      profileImagePath: 'assets/images/sunset.svg',
      description: 'For photography enthusiasts to share and learn techniques.',
      members: [
        ClubMember(
          name: 'Claire Dangais',
          position: 'President',
          role: 'executive',
          studentId: '2020013',
        ),
        ClubMember(
          name: 'Noah Martin',
          position: 'Vice President',
          role: 'executive',
          studentId: '2020014',
        ),
      ],
    ),
    Club(
      name: 'Research Club',
      coverImagePath: 'assets/images/research.svg',
      profileImagePath: 'assets/images/research.svg',
      description: 'For students interested in academic research.',
      members: [
        ClubMember(
          name: 'Ava Johnson',
          position: 'President',
          role: 'executive',
          studentId: '2020015',
        ),
        ClubMember(
          name: 'Liam Brown',
          position: 'Vice President',
          role: 'executive',
          studentId: '2020016',
        ),
      ],
    ),
    Club(
      name: 'Social Business Club',
      coverImagePath: 'assets/images/social_business.svg',
      profileImagePath: 'assets/images/social_business.svg',
      description: 'For students interested in social entrepreneurship.',
      members: [
        ClubMember(
          name: 'Isabella Garcia',
          position: 'President',
          role: 'executive',
          studentId: '2020017',
        ),
        ClubMember(
          name: 'Mason Davis',
          position: 'Vice President',
          role: 'executive',
          studentId: '2020018',
        ),
      ],
    ),
    Club(
      name: 'Social Service Club',
      coverImagePath: 'assets/images/social_service.svg',
      profileImagePath: 'assets/images/social_service.svg',
      description:
          'A dedicated group of students committed to making a positive impact in our community through volunteer work, fundraising, and awareness campaigns. We organize regular service activities, collaborate with local non-profit organizations, and develop leadership skills while helping those in need.',
      members: [
        ClubMember(
          name: 'Amelia Wilson',
          position: 'President',
          role: 'executive',
          studentId: '2020019',
        ),
        ClubMember(
          name: 'Lucas Martinez',
          position: 'Vice President',
          role: 'executive',
          studentId: '2020020',
        ),
        ClubMember(
          name: 'Harper Thomas',
          position: 'Treasurer',
          role: 'sub-executive',
          studentId: '2020021',
        ),
        ClubMember(
          name: 'Evelyn Anderson',
          position: 'Event Coordinator',
          role: 'sub-executive',
          studentId: '2020022',
        ),
        ClubMember(
          name: 'Logan Taylor',
          position: 'Member',
          role: 'general',
          studentId: '2020023',
        ),
        ClubMember(
          name: 'Mia Johnson',
          position: 'Member',
          role: 'general',
          studentId: '2020024',
        ),
      ],
    ),
    Club(
      name: 'Sports Club',
      coverImagePath: 'assets/images/sports.svg',
      profileImagePath: 'assets/images/sports.svg',
      description: 'For sports enthusiasts and athletes.',
      members: [
        ClubMember(
          name: 'Benjamin Smith',
          position: 'President',
          role: 'executive',
          studentId: '2020025',
        ),
        ClubMember(
          name: 'Charlotte Brown',
          position: 'Vice President',
          role: 'executive',
          studentId: '2020026',
        ),
      ],
    ),
  ];
  clubs.sort((a, b) => a.name.compareTo(b.name));
  return clubs;
}
