// lib/domain/repositories/article_repository.dart
import '../entities/article.dart';

abstract class ArticleRepository {
  /// Obtiene todos los artículos publicados
  Future<List<Article>> getArticles();
  
  /// Crea un nuevo artículo
  Future<String> createArticle(Article article);
  
  /// Actualiza un artículo existente
  Future<void> updateArticle(Article article);
  
  /// Elimina un artículo por su ID
  Future<void> deleteArticle(String articleId);
  
  /// Obtiene un artículo por su ID
  Future<Article> getArticleById(String articleId);
  
  /// Sube una imagen y devuelve la URL
  Future<String> uploadImage(String filePath, String fileName);
  
  /// Obtiene artículos por autor
  Future<List<Article>> getArticlesByAuthor(String authorId);
  
  /// Cambia el estado de publicación
  Future<void> togglePublishStatus(String articleId, bool published);
}