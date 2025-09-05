import 'package:flutter/material.dart';
import '../data/club_data.dart';

class ClubJoinRequestsPage extends StatefulWidget {
  final Club club;

  const ClubJoinRequestsPage({Key? key, required this.club}) : super(key: key);

  @override
  State<ClubJoinRequestsPage> createState() => _ClubJoinRequestsPageState();
}

class _ClubJoinRequestsPageState extends State<ClubJoinRequestsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Requests'),
        backgroundColor: const Color(0xFF6a0e33),
        foregroundColor: Colors.white,
      ),
      body: widget.club.joinRequests.isEmpty
          ? _buildEmptyState()
          : _buildRequestsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No pending join requests',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: widget.club.joinRequests.length,
      itemBuilder: (context, index) {
        final request = widget.club.joinRequests[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      child: Text(
                        request.studentName[0],
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.studentName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Student ID: ${request.studentId}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Requested on: ${_formatDate(request.requestDate)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => _handleDeclineRequest(request),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text('Decline'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => _handleApproveRequest(request),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6a0e33),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Approve'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleApproveRequest(ClubJoinRequest request) {
    setState(() {
      widget.club.approveJoinRequest(request.studentId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${request.studentName} has been approved to join the club',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handleDeclineRequest(ClubJoinRequest request) {
    setState(() {
      widget.club.declineJoinRequest(request.studentId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${request.studentName}\'s request has been declined'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
