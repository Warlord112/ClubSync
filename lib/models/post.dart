class Post {
  final String id;
  final String clubName;
  final String title;
  final String content;
  final String clubProfilePictureUrl;
  final String caption;
  final String? imageUrl;
  final int likesCount;
  final int commentsCount;
  final DateTime timestamp;
  bool isLiked; // Added for like functionality

  Post({
    required this.id,
    required this.clubName,
    required this.title,
    required this.content,
    required this.clubProfilePictureUrl,
    required this.caption,
    this.imageUrl,
    this.likesCount = 0,
    this.commentsCount = 0,
    required this.timestamp,
    this.isLiked = false, // Initialize isLiked to false
  });

  // Factory constructor to create a Post from a map (e.g., from JSON)
  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'],
      clubName: map['clubName'],
      title: map['title'],
      content: map['content'],
      clubProfilePictureUrl: map['clubProfilePictureUrl'],
      caption: map['caption'],
      imageUrl: map['imageUrl'],
      likesCount: map['likesCount'] ?? 0,
      commentsCount: map['commentsCount'] ?? 0,
      timestamp: DateTime.parse(map['timestamp']),
      isLiked: map['isLiked'] ?? false, // Deserialize isLiked
    );
  }

  // Method to convert a Post to a map (e.g., for JSON serialization)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clubName': clubName,
      'title': title,
      'content': content,
      'clubProfilePictureUrl': clubProfilePictureUrl,
      'caption': caption,
      'imageUrl': imageUrl,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'timestamp': timestamp.toIso8601String(),
      'isLiked': isLiked, // Serialize isLiked
    };
  }

  // Method to create a copy of the Post with updated values
  Post copyWith({
    String? id,
    String? clubName,
    String? title,
    String? content,
    String? clubProfilePictureUrl,
    String? caption,
    String? imageUrl,
    int? likesCount,
    int? commentsCount,
    DateTime? timestamp,
    bool? isLiked,
  }) {
    return Post(
      id: id ?? this.id,
      clubName: clubName ?? this.clubName,
      title: title ?? this.title,
      content: content ?? this.content,
      clubProfilePictureUrl: clubProfilePictureUrl ?? this.clubProfilePictureUrl,
      caption: caption ?? this.caption,
      imageUrl: imageUrl ?? this.imageUrl,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      timestamp: timestamp ?? this.timestamp,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}

