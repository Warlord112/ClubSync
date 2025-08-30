import 'package:flutter/material.dart';
import 'dart:io';
import '../data/club_data.dart';
import 'event_detail_page.dart'; // Added import for EventDetailPage

class Event {
  final String id;
  final String clubId;
  final String clubName;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final String imagePath;
  final bool isUpcoming;
  final int interestedCount; // Reverted to non-nullable
  final int goingCount; // Reverted to non-nullable

  Event({
    required this.id,
    required this.clubId,
    required this.clubName,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.imagePath,
    required this.isUpcoming,
    this.interestedCount = 0, // Reverted to default value
    this.goingCount = 0, // Reverted to default value
  });
}

class EventsPage extends StatefulWidget {
  final List<Club> clubs;
  final String studentId;

  const EventsPage({super.key, required this.clubs, required this.studentId});

  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  List<Event> _events = [];

  @override
  void initState() {
    super.initState();
    _initializeEvents();
  }

  void _initializeEvents() {
    // Sample events for demonstration
    _events = [
      Event(
        id: '1',
        clubId: 'Photography Club',
        clubName: 'Photography Club',
        title: 'Photography Workshop',
        description: 'Learn the basics of photography and camera settings.',
        date: DateTime.now().add(const Duration(days: 5)),
        location: 'Room 101, Arts Building',
        imagePath: 'assets/images/sunset.svg',
        isUpcoming: true,
        interestedCount: 150,
        goingCount: 80,
      ),
      Event(
        id: '2',
        clubId: 'Art Club',
        clubName: 'Art Club',
        title: 'Watercolor Painting Session',
        description: 'Join us for a relaxing watercolor painting session.',
        date: DateTime.now().add(const Duration(days: 10)),
        location: 'Art Studio, Main Campus',
        imagePath: 'assets/images/art.svg',
        isUpcoming: true,
        interestedCount: 200,
        goingCount: 120,
      ),
      Event(
        id: '3',
        clubId: 'Social Service Club',
        clubName: 'Social Service Club',
        title: 'Community Cleanup',
        description: 'Help us clean up the local park and make our community better.',
        date: DateTime.now().add(const Duration(days: 3)),
        location: 'Central Park',
        imagePath: 'assets/images/social_service.svg',
        isUpcoming: true,
        interestedCount: 300,
        goingCount: 180,
      ),
      Event(
        id: '4',
        clubId: 'Photography Club',
        clubName: 'Photography Club',
        title: 'Photo Exhibition',
        description: 'View the best photos taken by our club members.',
        date: DateTime.now().subtract(const Duration(days: 15)),
        location: 'Gallery Hall',
        imagePath: 'assets/images/sunset.svg',
        isUpcoming: false,
        interestedCount: 50,
        goingCount: 25,
      ),
    ];
  }

  List<Event> get _upcomingEvents => _events.where((event) => event.isUpcoming).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Upcoming Events',
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
                backgroundImage: AssetImage('assets/images/sunset.svg'), // Placeholder image
                radius: 20,
              ),
            ),
          ),
        ],
      ),
      body: _upcomingEvents.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No upcoming events',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _upcomingEvents.length,
              itemBuilder: (context, index) {
                final event = _upcomingEvents[index];
                return _buildEventCard(event);
              },
            ),
    );
  }

  Widget _buildEventCard(Event event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event image
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              image: DecorationImage(
                image: event.imagePath.startsWith('/')
                    ? FileImage(File(event.imagePath)) as ImageProvider
                    : AssetImage(event.imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Event details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage(
                        widget.clubs
                            .firstWhere((club) => club.name == event.clubName,
                                orElse: () => widget.clubs.first)
                            .profileImagePath,
                      ),
                      radius: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      event.clubName,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const Spacer(),
                    _buildDateChip(event.date),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(event.description),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      event.location,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailPage(event: event),
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
                  child: const Text('View Details'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateChip(DateTime date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF6a0e33).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${date.day}/${date.month}/${date.year}',
        style: const TextStyle(
          color: Color(0xFF6a0e33),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}