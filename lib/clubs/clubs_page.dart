import 'package:flutter/material.dart';
import '../data/club_data.dart';
import 'club_profile_page.dart';
import 'create_club_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClubsPage extends StatefulWidget {
  final String studentId;
  final List<Club> clubs;

  const ClubsPage({super.key, required this.studentId, required this.clubs});

  @override
  _ClubsPageState createState() => _ClubsPageState();
}

class _ClubsPageState extends State<ClubsPage> {
  late List<Club> clubs;
  late List<Club> filteredClubs;
  final TextEditingController _searchController = TextEditingController();
  bool _showMyClubsOnly = false;
  bool _isCurrentUserInstructor = false;
  bool _isLoading = true; // Added loading state
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _initializePage();
    // Add listener to search controller
    _searchController.addListener(_filterClubs);
  }

  Future<void> _initializePage() async {
    debugPrint('ClubsPage: _initializePage started');
    await _fetchUserRole();
    // Initialize clubs list with members
    clubs = getClubs();

    // Sort clubs alphabetically
    debugPrint('ClubsPage: Clubs initialized and sorted');
    clubs.sort((a, b) => a.name.compareTo(b.name));
    filteredClubs = List.from(clubs);

    setState(() {
      _isLoading = false; // Set loading to false after role is fetched and clubs initialized
      debugPrint('ClubsPage: _isLoading set to false, _isCurrentUserInstructor: $_isCurrentUserInstructor');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterClubs() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      // First filter by search query
      List<Club> tempFilteredClubs;
      if (query.isEmpty) {
        tempFilteredClubs = List.from(clubs);
      } else {
        tempFilteredClubs = clubs
            .where(
              (club) =>
                  club.name.toLowerCase().contains(query) ||
                  club.description.toLowerCase().contains(query),
            )
            .toList();
      }

      // Then filter by user association if needed
      if (_showMyClubsOnly) {
        filteredClubs = tempFilteredClubs
            .where(
              (club) => club.members.any(
                (member) => member.studentId == widget.studentId,
              ),
            )
            .toList();
      } else {
        filteredClubs = tempFilteredClubs;
      }
    });
  }

  Future<void> _fetchUserRole() async {
    debugPrint('ClubsPage: _fetchUserRole started');
    final user = supabase.auth.currentUser;
    if (user != null) {
      debugPrint('ClubsPage: User is logged in: ${user.id}');
      try {
        final response = await supabase
            .from('users')
            .select('role')
            .eq('id', user.id)
            .single();
        if (response.isNotEmpty) {
          final userRole = response['role'];
          debugPrint('ClubsPage: Fetched user role: $userRole');
          setState(() {
            _isCurrentUserInstructor = userRole == 'Instructor'; // Corrected to 'Instructor'
            debugPrint('ClubsPage: _isCurrentUserInstructor set to: $_isCurrentUserInstructor');
          });
        } else {
          debugPrint('ClubsPage: User role not found in database for user: ${user.id}');
          setState(() {
            _isCurrentUserInstructor = false;
          });
        }
      } catch (e) {
        debugPrint('ClubsPage: Error fetching user role: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error fetching user role: $e')),
          );
        }
        setState(() {
          _isCurrentUserInstructor = false;
        });
      }
    } else {
      debugPrint('ClubsPage: User is not logged in.');
      setState(() {
        _isCurrentUserInstructor = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('ClubsPage: build method called, _isLoading: $_isLoading, _isCurrentUserInstructor: $_isCurrentUserInstructor');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'All Clubs',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF6a0e33),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/profile',
                  arguments: {
                    'studentId': widget.studentId,
                    'clubs': widget.clubs,
                  },
                );
              },
              child: CircleAvatar(
                backgroundImage: AssetImage(
                  'assets/images/sunset.svg',
                ), // Placeholder image
                radius: 20,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search clubs...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
                const SizedBox(height: 10),
                // Show my clubs only button
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _showMyClubsOnly = !_showMyClubsOnly;
                        _filterClubs(); // Apply the filter
                      });
                    },
                    icon: Icon(
                      _showMyClubsOnly
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Show my clubs only',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6a0e33),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Club list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredClubs.isEmpty
                    ? const Center(
                        child: Text(
                          'No clubs found',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredClubs.length,
                        itemBuilder: (context, index) {
                          return _buildClubCard(filteredClubs[index]);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: _isCurrentUserInstructor
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateClubPage(),
                  ),
                );
              },
              backgroundColor: const Color(0xFF6a0e33),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildClubCard(Club club) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover image with profile picture
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Cover image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                child: Image.asset(
                  club.coverImagePath,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 120,
                      width: double.infinity,
                      color: const Color(0xFF6a0e33).withOpacity(0.7),
                      child: const Center(
                        child: Icon(Icons.image, color: Colors.white, size: 40),
                      ),
                    );
                  },
                ),
              ),
              // Profile picture
              Positioned(
                bottom: -30,
                left: 20,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage(club.profileImagePath),
                    onBackgroundImageError: (exception, stackTrace) {},
                    backgroundColor: Colors.grey[300],
                  ),
                ),
              ),
            ],
          ),
          // Club name and description
          Container(
            padding: const EdgeInsets.fromLTRB(20, 35, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  club.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  club.description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to club detail page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClubProfilePage(
                          club: club,
                          currentStudentId: widget.studentId,
                        ), // Pass actual studentId
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6a0e33),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('View Club'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
