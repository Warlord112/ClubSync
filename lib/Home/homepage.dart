import '../utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import '../data/club_data.dart';
import '../clubs/clubs_page.dart';
import '../events/events_page.dart';
import '../profile/profile_page.dart';
import '../posts/posts_page.dart'; // Added this import
import '../posts/create_post_page.dart'; // Added this import

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _isLoading = true; // Add loading state

  // Sample student ID for testing
  String? _currentStudentId; // Make nullable
  final SupabaseClient supabase =
      Supabase.instance.client; // Initialize Supabase client

  // Initialize clubs list
  List<Club> _clubs = []; // Initialize as empty list
  bool _isCurrentUserInstructor = false;

  @override
  void initState() {
    super.initState();
    _fetchInitialData(); // Call a new async function to fetch all initial data
  }

  Future<void> _fetchInitialData() async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        try {
          final resp = await supabase
              .from('users')
              .select('student_id, role')
              .eq('id', user.id)
              .maybeSingle();
          final meta = user.userMetadata;
          final String? metaStudentId = meta != null
              ? meta['student_id'] as String?
              : null;
          final String? dbStudentId = resp != null
              ? resp['student_id'] as String?
              : null;

          _currentStudentId = (dbStudentId != null && dbStudentId.isNotEmpty)
              ? dbStudentId
              : (metaStudentId != null && metaStudentId.isNotEmpty
                    ? metaStudentId
                    : user.id);

          final String? role = resp != null ? resp['role'] as String? : null;
          _isCurrentUserInstructor =
              role == 'Instructor' || role == kRoleInstructor;
        } catch (e) {
          print('Error fetching student_id for current user: $e');
          _currentStudentId = user.id;
          _isCurrentUserInstructor = false;
        }
      } else {
        print('User not logged in on Homepage.');
        // Potentially navigate to login screen if no user is found
      }

      final fetchedClubs = await getClubs();
      setState(() {
        _clubs = fetchedClubs;
        _isLoading = false; // Set loading to false after clubs are fetched
      });
    } catch (e) {
      print('Error fetching initial data in homepage: $e');
      setState(() {
        _isLoading = false; // Also set to false on error
      });
    }
  }

  // Get the current screen based on selected index
  Widget _getScreenForIndex(int index) {
    if (_currentStudentId == null) {
      return const Center(child: Text('Please log in to view this content.'));
    }
    switch (index) {
      case 0: // Home (Posts)
        return PostsPage(studentId: _currentStudentId!, clubs: _clubs);
      case 1: // All Clubs
        return ClubsPage(studentId: _currentStudentId!, clubs: _clubs);
      case 2: // Create Post (only for instructors)
        return _isCurrentUserInstructor
            ? CreatePostPage(studentId: _currentStudentId!, clubs: _clubs)
            : PostsPage(studentId: _currentStudentId!, clubs: _clubs);
      case 3: // Events
        return EventsPage(clubs: _clubs, studentId: _currentStudentId!);
      case 4: // Profile
        return ProfilePage(studentId: _currentStudentId!, clubs: _clubs);
      default:
        return PostsPage(studentId: _currentStudentId!, clubs: _clubs);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _getScreenForIndex(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF6a0e33),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 2 && !_isCurrentUserInstructor) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Only Instructors can make a post.'),
              ),
            );
            return; // Prevent navigating to Create Post tab for students
          }
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'All Clubs'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Create Post',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
