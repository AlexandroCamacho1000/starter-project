import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/article.dart';

class ArticleModel extends Equatable {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String thumbnailURL;
  final List<String> tags;
  final bool published;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ArticleModel({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.thumbnailURL,
    required this.tags,
    required this.published,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object> get props => [
    id, title, content, authorId, thumbnailURL, tags, published, createdAt, updatedAt,
  ];

  // Entity → Model
  factory ArticleModel.fromEntity(Article article) {
    return ArticleModel(
      id: article.id,
      title: article.title,
      content: article.content,
      authorId: article.authorId,
      thumbnailURL: article.thumbnailURL,
      tags: article.tags,
      published: article.published,
      createdAt: article.createdAt,
      updatedAt: article.updatedAt,
    );
  }

  // Model → Entity
  Article toEntity() {
    return Article(
      id: id,
      title: title,
      content: content,
      authorId: authorId,
      thumbnailURL: thumbnailURL,
      tags: tags,
      published: published,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Firestore → Model
  factory ArticleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ArticleModel(
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

  // Model → Map (para Firestore)
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

  // Para debug
  @override
  String toString() {
    return 'ArticleModel{id: $id, title: $title, tags: $tags}';
  }
}