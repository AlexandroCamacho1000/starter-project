// lib/data/repositories/article_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/article.dart';
import '../../domain/repositories/article_repository.dart';
import '../datasources/firebase_article_datasource.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final FirebaseArticleDataSource _dataSource;

  ArticleRepositoryImpl({required FirebaseArticleDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<List<Article>> getArticles() async {
    return await _dataSource.getArticles();
  }

  @override
  Future<String> createArticle(Article article) async {
    return await _dataSource.createArticle(article);
  }

  @override
  Future<void> updateArticle(Article article) async {
    // Get existing article to preserve createdAt
    final existingArticle = await getArticleById(article.id);
    
    // Create updated article with preserved createdAt
    final updatedArticle = Article(
      id: article.id,
      title: article.title,
      content: article.content,
      authorId: article.authorId,
      thumbnailURL: article.thumbnailURL,
      tags: article.tags,
      published: article.published,
      createdAt: existingArticle.createdAt,
      updatedAt: DateTime.now(),
    );
    
    await _dataSource.updateArticle(updatedArticle);
  }

  @override
  Future<void> deleteArticle(String articleId) async {
    await _dataSource.deleteArticle(articleId);
  }

  @override
  Future<String> uploadImage(String filePath, String fileName) async {
    return await _dataSource.uploadImage(filePath, fileName);
  }

  @override
  Future<Article> getArticleById(String articleId) async {
    return await _dataSource.getArticleById(articleId);
  }

  @override
  Future<List<Article>> getArticlesByAuthor(String authorId) async {
    return await _dataSource.getArticlesByAuthor(authorId);
  }

  @override
  Future<void> togglePublishStatus(String articleId, bool published) async {
    await _dataSource.togglePublishStatus(articleId, published);
  }
}