// lib/domain/usecases/create_article_usecase.dart
import '../repositories/article_repository.dart';
import '../entities/article.dart';

class CreateArticleUseCase {
  final ArticleRepository repository;
  
  CreateArticleUseCase(this.repository);
  
  Future<String> execute({
    required String title,
    required String content,
    required String authorId,
    required String thumbnailURL,
    List<String> tags = const [],
    bool published = false,
  }) async {
    final now = DateTime.now();
    
    final article = Article(
      id: '', // Firestore generará el ID
      title: title,
      content: content,
      authorId: authorId,
      thumbnailURL: thumbnailURL,
      tags: tags,
      published: published,
      createdAt: now,
      updatedAt: now,
    );
    
    return await repository.createArticle(article);
  }
}