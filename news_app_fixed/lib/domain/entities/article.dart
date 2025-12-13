import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Article extends Equatable {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String thumbnailURL;
  final List<String> tags;
  final bool published;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Article({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.thumbnailURL,
    this.tags = const [],
    required this.published,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object> get props => [
    id, title, content, authorId, thumbnailURL, tags, published, createdAt, updatedAt,
  ];

  factory Article.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Article(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      authorId: data['authorId'] ?? '',
      thumbnailURL: data['thumbnailURL'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      published: data['published'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'authorId': authorId,
      'thumbnailURL': thumbnailURL,
      'tags': tags,
      'published': published,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}