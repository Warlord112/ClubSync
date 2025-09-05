import 'package:flutter/material.dart';
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
  
  // Sample student ID for testing
  final String _currentStudentId = '2020001'; // Reverted to original student ID
  
  // Initialize clubs list
  final List<Club> _clubs = getClubs();

  // Get the current screen based on selected index
  Widget _getScreenForIndex(int index) {
    switch (index) {
      case 0: // Home (Posts)
        return PostsPage(studentId: _currentStudentId, clubs: _clubs,);
      case 1: // All Clubs
        return ClubsPage(studentId: _currentStudentId, clubs: _clubs,);
      case 2: // Create Post
        return CreatePostPage(studentId: _currentStudentId, clubs: _clubs,);
      case 3: // Events
        return EventsPage(clubs: _clubs, studentId: _currentStudentId);
      case 4: // Profile
        return ProfilePage(studentId: _currentStudentId, clubs: _clubs);
      default:
        return PostsPage(studentId: _currentStudentId, clubs: _clubs,);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _getScreenForIndex(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF6a0e33),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
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
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}