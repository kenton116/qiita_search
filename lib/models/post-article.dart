import 'package:cloud_firestore/cloud_firestore.dart';
import 'user.dart';
import 'article.dart';

class PostArticle {
  PostArticle({
    required this.title,
    required this.userId,
    required this.userImage,
    required this.comment,
    required this.postUserEmail,
    this.likesCount = 0,
    this.tags = const [],
    required this.createdAt,
    required this.url,
  });

  final String title;
  final String userId;
  final String userImage;
  final String comment;
  final String postUserEmail;
  final int likesCount;
  final List<String> tags;
  final DateTime createdAt;
  final String url;

  factory PostArticle.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception("Document data was null!");
    }

    return PostArticle(
      title: data['title'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      url: data['url'] as String? ?? '',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likesCount: data['likes_count'] as int? ?? 0,
      tags: List<String>.from(data['tags'] ?? []),
      userImage: data['userImage'] as String? ?? '',
      comment: data['comment'] as String? ?? '',
      postUserEmail: data['postUserEmail'] as String? ?? '',
    );
  }

  Article toArticle() {
    return Article(
      title: title,
      user: User(id: userId, profileImageUrl: userImage),
      likesCount: likesCount,
      tags: tags,
      createdAt: createdAt,
      url: url,
    );
  }
}
