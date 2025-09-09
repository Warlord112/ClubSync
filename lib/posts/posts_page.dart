import 'package:flutter/material.dart';
import '../models/post.dart';
import '../data/club_data.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'create_post_page.dart';

class PostsPage extends StatefulWidget {
  final String studentId;
  final List<Club> clubs;

  const PostsPage({super.key, required this.studentId, required this.clubs});

  @override
  _PostsPageState createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final List<Post> _posts = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Compute the set of club IDs that the current user has joined
    final Set<String> joinedClubIds = widget.clubs
        .where((c) => c.members.any((m) => m.studentId == widget.studentId))
        .map((c) => c.id)
        .toSet();

    try {
      final response = await supabase
          .from('posts')
          .select()
          .order('created_at', ascending: false);

      final List<Post> posts = [];

      for (final row in response as List) {
        final String? clubId = row['club_id']?.toString();
        // Skip posts that are not from clubs the user has joined
        if (clubId == null || !joinedClubIds.contains(clubId)) {
          continue;
        }

        Club? club;
        try {
          club = widget.clubs.firstWhere((c) => c.id == clubId);
        } catch (_) {
          club = null;
        }

        final String? createdAtRaw = row['created_at']?.toString();
        DateTime ts;
        try {
          ts = createdAtRaw != null
              ? DateTime.parse(createdAtRaw)
              : DateTime.now();
        } catch (_) {
          ts = DateTime.now();
        }

        posts.add(
          Post(
            id: row['id'].toString(),
            clubName: club?.name ?? 'Unknown Club',
            title: (row['title'] ?? '').toString(),
            content: (row['caption'] ?? '').toString(),
            clubProfilePictureUrl:
                club?.profileImagePath ?? 'assets/images/computer.svg',
            caption: (row['caption'] ?? '').toString(),
            imageUrl: row['image_url'] as String?,
            likesCount: row['likes_count'] is int
                ? row['likes_count'] as int
                : (int.tryParse((row['likes_count'] ?? '0').toString()) ?? 0),
            commentsCount: row['comments_count'] is int
                ? row['comments_count'] as int
                : (int.tryParse((row['comments_count'] ?? '0').toString()) ??
                    0),
            timestamp: ts,
          ),
        );
      }

      setState(() {
        _posts
          ..clear()
          ..addAll(posts);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

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
                backgroundImage: AssetImage(
                  'assets/images/sunset.svg',
                ), // Placeholder image
                radius: 20,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_error != null
              ? Center(child: Text('Error fetching posts: \n\n$_error'))
              : (_posts.isEmpty
                  ? const Center(child: Text('No posts yet.'))
                  : ListView.builder(
                      itemCount: _posts.length,
                      itemBuilder: (context, index) {
                        final post = _posts[index];
                        return _buildPostCard(post);
                      },
                    ))),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreatePostPage(
                studentId: widget.studentId,
                clubs: widget.clubs,
              ),
            ),
          );
          if (result == true) {
            _fetchPosts();
          }
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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
            Text(post.content, style: const TextStyle(fontSize: 14)),
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
                _buildActionItem(
                  Icons.thumb_up,
                  '${post.likesCount} Likes',
                  () {
                    // Handle like action
                    print('Liked post ${post.id}');
                  },
                ),
                _buildActionItem(
                  Icons.comment,
                  '${post.commentsCount} Comments',
                  () {
                    // Handle comment action
                    print('Commented on post ${post.id}');
                  },
                ),
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
