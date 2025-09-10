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
  final DateTime? startDate; // new: full range support
  final DateTime? endDate;   // new: full range support
  final String location;
  final String imagePath;
  final bool isUpcoming;
  final int interestedCount; // Reverted to non-nullable
  final int goingCount; // Reverted to non-nullable
  final String? status; // new: status from activities

  Event({
    required this.id,
    required this.clubId,
    required this.clubName,
    required this.title,
    required this.description,
    required this.date,
    this.startDate, // new
    this.endDate, // new
    required this.location,
    required this.imagePath,
    required this.isUpcoming,
    this.interestedCount = 0, // Reverted to default value
    this.goingCount = 0, // Reverted to default value
    this.status,
  });
}

class EventsPage extends StatefulWidget {
  final List<Club> clubs;
  final String studentId;

  const EventsPage({super.key, required this.clubs, required this.studentId});

  @override
  _EventsPageState createState() => _EventsPageState();
}

enum EventFilter { upcoming, ongoing, past, all }

class _EventsPageState extends State<EventsPage> {
  List<Event> _events = [];
  bool _isLoading = false;
  bool _isCurrentUserInstructor = false;
  bool _showMyClubsOnly = false;
  EventFilter _selectedFilter = EventFilter.upcoming; // new

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
    _fetchEvents();
  }

  Future<void> _fetchUserRole() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) {
        if (mounted) setState(() => _isCurrentUserInstructor = false);
        return;
      }
      final resp = await supabase
          .from('users')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();
      final String? role = resp != null ? resp['role'] as String? : null;
      if (mounted) {
        setState(() {
          _isCurrentUserInstructor =
              role == kRoleInstructor || role == 'Instructor';
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isCurrentUserInstructor = false);
    }
  }

  Future<void> _fetchEvents() async {
    setState(() => _isLoading = true);
    try {
      final supabase = Supabase.instance.client;
      final List<dynamic> rows = await supabase
          .from(kActivitiesTable)
          .select(
            'id, club_id, title, description, location, starting_date, ending_date, status',
          )
          .order('starting_date', ascending: true);

      final now = DateTime.now();
      final events = rows.map((row) {
        final String id = row["id"]?.toString() ?? '';
        final String clubId = row["club_id"]?.toString() ?? '';
        final Club? club = (() {
          try {
            return widget.clubs.firstWhere((c) => c.id == clubId);
          } catch (_) {
            return null;
          }
        })();
        final String clubName = club?.name ?? 'Unknown Club';
        final String coverImage =
            club?.coverImagePath ?? kDefaultCoverImagePath;

        DateTime? start;
        DateTime? end;
        if (row['starting_date'] != null &&
            (row['starting_date'] as String).isNotEmpty) {
          start = DateTime.tryParse(row['starting_date']);
        }
        if (row['ending_date'] != null &&
            (row['ending_date'] as String).isNotEmpty) {
          end = DateTime.tryParse(row['ending_date']);
        }

        final DateTime date = start ?? end ?? now;
        final bool isUpcoming = end != null
            ? !end.isBefore(DateTime(now.year, now.month, now.day))
            : (start != null
                  ? !start.isBefore(DateTime(now.year, now.month, now.day))
                  : false);

        // Determine display status from DB value or fallback to date logic
        String? rawStatus = (row['status'] as String?)?.trim();
        String? displayStatus = rawStatus;
        if (displayStatus == null || displayStatus.isEmpty) {
          final today = DateTime(now.year, now.month, now.day);
          final s = start != null ? DateTime(start.year, start.month, start.day) : null;
          final en = end != null ? DateTime(end.year, end.month, end.day) : null;
          if (en != null && en.isBefore(today)) {
            displayStatus = 'Expired';
          } else if (s != null && s.isAfter(today)) {
            displayStatus = 'Upcoming Events';
          } else {
            displayStatus = 'On going';
          }
        }

        return Event(
          id: id,
          clubId: clubId,
          clubName: clubName,
          title: (row['title'] ?? '').toString(),
          description: (row['description'] ?? '').toString(),
          date: date,
          startDate: start, // new
          endDate: end, // new
          location: (row['location'] ?? '').toString(),
          imagePath: coverImage,
          isUpcoming: isUpcoming,
          interestedCount: 0,
          goingCount: 0,
          status: displayStatus,
        );
      }).toList();

      setState(() {
        _events = events;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load events: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Event> get _filteredEvents {
    final Set<String> myClubIds = widget.clubs
        .where((c) => c.members.any((m) => m.studentId == widget.studentId))
        .map((c) => c.id)
        .toSet();

    DateTime now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    bool isOngoing(Event e) {
      final s = e.startDate != null
          ? DateTime(e.startDate!.year, e.startDate!.month, e.startDate!.day)
          : null;
      final en = e.endDate != null
          ? DateTime(e.endDate!.year, e.endDate!.month, e.endDate!.day)
          : null;
      if (s != null && en != null) return s.compareTo(today) <= 0 && en.compareTo(today) >= 0;
      if (s != null && en == null) return s.compareTo(today) == 0; // single-day event
      if (s == null && en != null) return en.compareTo(today) == 0; // fallback
      return false;
    }

    bool isPast(Event e) {
      final s = e.startDate != null
          ? DateTime(e.startDate!.year, e.startDate!.month, e.startDate!.day)
          : null;
      final en = e.endDate != null
          ? DateTime(e.endDate!.year, e.endDate!.month, e.endDate!.day)
          : null;
      if (en != null) return en.isBefore(today);
      if (s != null) return s.isBefore(today);
      return false;
    }

    bool isUpcoming(Event e) {
      final s = e.startDate != null
          ? DateTime(e.startDate!.year, e.startDate!.month, e.startDate!.day)
          : null;
      final en = e.endDate != null
          ? DateTime(e.endDate!.year, e.endDate!.month, e.endDate!.day)
          : null;
      if (s != null) return s.isAfter(today);
      if (en != null) return en.isAfter(today);
      return false;
    }

    return _events.where((event) {
      if (_showMyClubsOnly && !myClubIds.contains(event.clubId)) return false;
      switch (_selectedFilter) {
        case EventFilter.upcoming:
          return isUpcoming(event);
        case EventFilter.ongoing:
          return isOngoing(event);
        case EventFilter.past:
          return isPast(event);
        case EventFilter.all:
          return true;
      }
    }).toList();
  }

  String get _emptyTextForCurrentFilter {
    switch (_selectedFilter) {
      case EventFilter.upcoming:
        return kNoUpcomingEventsText;
      case EventFilter.ongoing:
        return kNoOngoingEventsText;
      case EventFilter.past:
        return kNoPastEventsText;
      case EventFilter.all:
        return 'No events';
    }
  }

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
          if (_isCurrentUserInstructor)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add Event',
              onPressed: () async {
                final created = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateEventPage(clubs: widget.clubs),
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
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Row(
                    children: [
                      // Filter dropdown
                      Expanded(
                        child: DropdownButtonFormField<EventFilter>(
                          value: _selectedFilter,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: EventFilter.upcoming,
                              child: Text(kUpcomingEventsTitle),
                            ),
                            DropdownMenuItem(
                              value: EventFilter.ongoing,
                              child: Text(kOngoingEventsTitle),
                            ),
                            DropdownMenuItem(
                              value: EventFilter.past,
                              child: Text(kPastEventsTitle),
                            ),
                            DropdownMenuItem(
                              value: EventFilter.all,
                              child: Text('All'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val == null) return;
                            setState(() {
                              _selectedFilter = val;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // My clubs only toggle button
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _showMyClubsOnly = !_showMyClubsOnly;
                          });
                        },
                        icon: Icon(
                          _showMyClubsOnly
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: Colors.white,
                        ),
                        label: const Text(
                          kShowMyClubsOnlyText,
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: _filteredEvents.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                _emptyTextForCurrentFilter,
                                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredEvents.length,
                          itemBuilder: (context, index) {
                            final event = _filteredEvents[index];
                            return _buildEventCard(event);
                          },
                        ),
                ),
              ],
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
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _dateRangeText(event),
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusChip(event.status),
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

  String _dateRangeText(Event e) {
    String fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';
    final s = e.startDate;
    final en = e.endDate;
    if (s != null && en != null) {
      if (s.year == en.year && s.month == en.month && s.day == en.day) {
        return fmt(s);
      }
      return '${fmt(s)} - ${fmt(en)}';
    } else if (s != null) {
      return fmt(s);
    } else if (en != null) {
      return fmt(en);
    }
    return fmt(e.date);
  }

  Widget _buildStatusChip(String? status) {
    if (status == null || status.isEmpty) return const SizedBox.shrink();
    final lower = status.toLowerCase();
    Color bg;
    Color fg;
    if (lower.contains('upcoming')) {
      bg = Colors.blue.shade50;
      fg = Colors.blue.shade700;
    } else if (lower.contains('on going') || lower.contains('ongoing')) {
      bg = Colors.green.shade50;
      fg = Colors.green.shade700;
    } else if (lower.contains('expired') || lower.contains('past')) {
      bg = Colors.red.shade50;
      fg = Colors.red.shade700;
    } else {
      bg = Colors.grey.shade200;
      fg = Colors.grey.shade800;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withOpacity(0.2)),
      ),
      child: Text(
        status,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
