import 'package:flutter/material.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/constants.dart';
import '../data/club_data.dart';
import 'event_detail_page.dart'; // Added import for EventDetailPage
import 'create_event_page.dart'; // Use CreateEventPage for adding events

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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    setState(() => _isLoading = true);
    try {
      final supabase = Supabase.instance.client;
      final List<dynamic> rows = await supabase
          .from(kActivitiesTable)
          .select('id, club_id, title, description, location, starting_date, ending_date')
          .order('starting_date', ascending: true);

      final now = DateTime.now();
      final events = rows.map((row) {
        final String id = row['id']?.toString() ?? '';
        final String clubId = row['club_id']?.toString() ?? '';
        final Club? club = (() {
          try {
            return widget.clubs.firstWhere((c) => c.id == clubId);
          } catch (_) {
            return null;
          }
        })();
        final String clubName = club?.name ?? 'Unknown Club';
        final String coverImage = club?.coverImagePath ?? kDefaultCoverImagePath;

        DateTime? start;
        DateTime? end;
        if (row['starting_date'] != null && (row['starting_date'] as String).isNotEmpty) {
          start = DateTime.tryParse(row['starting_date']);
        }
        if (row['ending_date'] != null && (row['ending_date'] as String).isNotEmpty) {
          end = DateTime.tryParse(row['ending_date']);
        }

        final DateTime date = start ?? end ?? now;
        final bool isUpcoming = end != null ? !end.isBefore(DateTime(now.year, now.month, now.day)) : (start != null ? !start.isBefore(DateTime(now.year, now.month, now.day)) : false);

        return Event(
          id: id,
          clubId: clubId,
          clubName: clubName,
          title: (row['title'] ?? '').toString(),
          description: (row['description'] ?? '').toString(),
          date: date,
          location: (row['location'] ?? '').toString(),
          imagePath: coverImage,
          isUpcoming: isUpcoming,
          interestedCount: 0,
          goingCount: 0,
        );
      }).toList();

      setState(() {
        _events = events;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load events: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Event> get _upcomingEvents =>
      _events.where((event) => event.isUpcoming).toList();

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
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Event',
            onPressed: () async {
              final created = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateEventPage(
                    clubs: widget.clubs,
                  ),
                ),
              );
              if (created != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Event created.')),
                );
                await _fetchEvents();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _upcomingEvents.isEmpty
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
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
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
                            .firstWhere(
                              (club) => club.name == event.clubName,
                              orElse: () => widget.clubs.first,
                            )
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
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Colors.grey,
                    ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${date.day}/${date.month}/${date.year}',
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}
