// lib/models/article.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Article {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;  // NUEVO CAMPO
  final String thumbnailURL;
  final bool published;
  final DateTime createdAt;
  final DateTime updatedAt;

  Article({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,  // NUEVO PARÁMETRO REQUERIDO
    required this.thumbnailURL,
    required this.published,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Article.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Article(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'User',  // NUEVO
      thumbnailURL: data['thumbnailURL'] ?? '',
      published: data['published'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Constructor para cuando tienes el nombre aparte
  factory Article.fromFirestoreWithAuthorName(
    DocumentSnapshot doc, 
    String authorName
  ) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Article(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: authorName,  // Usamos el nombre pasado
      thumbnailURL: data['thumbnailURL'] ?? '',
      published: data['published'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,  // NUEVO
      'thumbnailURL': thumbnailURL,
      'published': published,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}