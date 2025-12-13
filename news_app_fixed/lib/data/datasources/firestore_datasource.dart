import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/article.dart';

// CAMBIO: Renombrar clase de FirebaseArticleDataSource a FirestoreDataSource
class FirestoreDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Main articles collection reference
  CollectionReference get _articlesCollection => _firestore.collection('articles');

  // Get all published articles with pagination support
  Future<List<Article>> getArticles({int limit = 20, DocumentSnapshot? lastDocument}) async {
    try {
      Query query = _articlesCollection
          .where('published', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      // For pagination: start after last document
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final querySnapshot = await query.get();
      
      return querySnapshot.docs
          .map((doc) => Article.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch articles: $e');
    }
  }

  // Create a new article document in Firestore
  Future<String> createArticle(Article article) async {
    try {
      final docRef = await _articlesCollection.add(article.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create article: $e');
    }
  }

  // Upload thumbnail image to Firebase Storage
  Future<String> uploadThumbnail(File imageFile, String articleId) async {
    try {
      final fileName = 'thumbnail_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref('media/articles/$articleId/$fileName');
      await ref.putFile(imageFile);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      throw Exception('Failed to upload thumbnail: $e');
    }
  }

  // Upload any image file to Firebase Storage (generic method)
  Future<String> uploadImage(String filePath, String fileName) async {
    try {
      // Organize images by user ID for better storage management
      final userId = _auth.currentUser?.uid ?? 'anonymous';
      final storagePath = 'media/articles/$userId/$fileName';
      
      final ref = _storage.ref(storagePath);
      await ref.putFile(File(filePath));
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Retrieve single article by ID
  Future<Article> getArticleById(String id) async {
    try {
      final doc = await _articlesCollection.doc(id).get();
      if (!doc.exists) {
        throw Exception('Article with ID $id not found');
      }
      return Article.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to fetch article: $e');
    }
  }

  // Update existing article document
  Future<void> updateArticle(Article article) async {
    try {
      await _articlesCollection.doc(article.id).update(article.toFirestore());
    } catch (e) {
      throw Exception('Failed to update article: $e');
    }
  }

  // Delete article from Firestore
  Future<void> deleteArticle(String id) async {
    try {
      await _articlesCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete article: $e');
    }
  }

  // Get articles by specific author
  Future<List<Article>> getArticlesByAuthor(String authorId) async {
    try {
      final querySnapshot = await _articlesCollection
          .where('authorId', isEqualTo: authorId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => Article.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch author articles: $e');
    }
  }

  // Toggle article publish status
  Future<void> togglePublishStatus(String articleId, bool published) async {
    try {
      await _articlesCollection.doc(articleId).update({
        'published': published,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update publish status: $e');
    }
  }

  // Search articles by title or content
  Future<List<Article>> searchArticles(String query) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // This is a basic implementation - consider using Algolia or ElasticSearch for production
      final snapshot = await _articlesCollection
          .where('published', isEqualTo: true)
          .get();
      
      return snapshot.docs
          .map((doc) => Article.fromFirestore(doc))
          .where((article) => 
              article.title.toLowerCase().contains(query.toLowerCase()) ||
              article.content.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      throw Exception('Failed to search articles: $e');
    }
  }

  // Get articles by category/tag
  Future<List<Article>> getArticlesByTag(String tag) async {
    try {
      final snapshot = await _articlesCollection
          .where('published', isEqualTo: true)
          .where('tags', arrayContains: tag)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => Article.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch articles by tag: $e');
    }
  }

  // Increment article view count
  Future<void> incrementViewCount(String articleId) async {
    try {
      await _articlesCollection.doc(articleId).update({
        'views': FieldValue.increment(1),
      });
    } catch (e) {
      // Log error but don't throw - view counting shouldn't break the app
    }
  }

  // Test Firestore connection (for debugging)
  Future<void> testConnection() async {
    try {
      await _articlesCollection.limit(1).get();
    } catch (e) {
      throw Exception('Firestore connection failed: $e');
    }
  }

  // Convert gs:// URL to HTTPS download URL
  String convertGsUrlToDownloadUrl(String gsUrl) {
    if (!gsUrl.startsWith('gs://')) {
      return gsUrl;
    }
    
    // Remove gs:// prefix
    final withoutGs = gsUrl.substring(5);
    final parts = withoutGs.split('/');
    
    if (parts.length < 2) {
      return gsUrl;
    }
    
    final bucket = parts[0];
    final path = parts.sublist(1).join('/');
    final encodedPath = Uri.encodeComponent(path).replaceAll('%2F', '/');
    
    return 'https://firebasestorage.googleapis.com/v0/b/$bucket/o/$encodedPath?alt=media';
  }

  // Get featured articles (could be based on views, likes, or manual selection)
  Future<List<Article>> getFeaturedArticles({int limit = 5}) async {
    try {
      // This is a simple implementation - you might want to add a 'featured' field
      // or use a different algorithm in production
      final snapshot = await _articlesCollection
          .where('published', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs
          .map((doc) => Article.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch featured articles: $e');
    }
  }

  // Get article statistics (total articles, published articles, etc.)
  Future<Map<String, int>> getArticleStats() async {
    try {
      final totalSnapshot = await _articlesCollection.get();
      final publishedSnapshot = await _articlesCollection
          .where('published', isEqualTo: true)
          .get();
      
      return {
        'total': totalSnapshot.docs.length,
        'published': publishedSnapshot.docs.length,
        'drafts': totalSnapshot.docs.length - publishedSnapshot.docs.length,
      };
    } catch (e) {
      throw Exception('Failed to fetch article statistics: $e');
    }
  }
}