import 'package:flutter/material.dart';
import '../models/post.dart';
import '../data/club_data.dart';
import 'dart:io';

class PostsPage extends StatefulWidget {
  final String studentId;
  final List<Club> clubs;

  const PostsPage({super.key, required this.studentId, required this.clubs});

  @override
  _PostsPageState createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  final List<Post> _posts = [
    // Sample posts
    Post(
      id: '1',
      clubName: 'Computer Club',
      clubProfilePictureUrl: 'assets/images/computer.svg',
      caption: 'Join us for our annual hackathon on October 26th! Great prizes and learning opportunities.',
      title: 'Hackathon Announcement',
      content: 'Join us for our annual hackathon on October 26th! Great prizes and learning opportunities.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      imageUrl: 'assets/images/flutter_01.png',
    ),
    Post(
      id: '2',
      clubName: 'Art Club',
      clubProfilePictureUrl: 'assets/images/art.svg',
      caption: 'Our annual art exhibition is happening next week. Come and see amazing artworks by our talented members.',
      title: 'Art Exhibition!',
      content: 'Our annual art exhibition is happening next week. Come and see amazing artworks by our talented members.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      imageUrl: 'assets/images/flutter_02.png',
    ),
    Post(
      id: '3',
      clubName: 'Literary Club',
      clubProfilePictureUrl: 'assets/images/literary.svg',
      caption: 'Express yourself at our open mic poetry slam night. All are welcome!',
      title: 'Poetry Slam Night',
      content: 'Express yourself at our open mic poetry slam night. All are welcome!',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      imageUrl: 'assets/images/flutter_03.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Posts',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF6a0e33),
        foregroundColor: Colors.white,
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
      body: _posts.isEmpty
          ? const Center(
              child: Text('No posts yet.'),
            )
          : ListView.builder(
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                return _buildPostCard(post);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create_post');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 1.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(post.clubProfilePictureUrl),
                  radius: 20,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.clubName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      '${post.timestamp.day}/${post.timestamp.month}/${post.timestamp.year} ${post.timestamp.hour}:${post.timestamp.minute}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              post.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              post.content,
              style: const TextStyle(fontSize: 14),
            ),
            if (post.imageUrl != null)
              Column(
                children: [
                  const SizedBox(height: 10),
                  Image.file(
                    File(post.imageUrl!),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                  ),
                ],
              ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionItem(Icons.thumb_up, '${post.likesCount} Likes', () {
                  // Handle like action
                  print('Liked post ${post.id}');
                }),
                _buildActionItem(Icons.comment, '${post.commentsCount} Comments', () {
                  // Handle comment action
                  print('Commented on post ${post.id}');
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 5),
          Text(text, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}

