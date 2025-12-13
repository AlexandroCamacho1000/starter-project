import '../../domain/entities/article.dart';
import '../../domain/repositories/article_repository.dart';

class ArticleRepositoryMockImpl implements ArticleRepository {
  final List<Article> _mockArticles = [];
  
  ArticleRepositoryMockImpl() {
    // Inicializar con datos mock
    _mockArticles.addAll([
      Article(
        id: '1',
        title: 'Artículo Mock Inicial',
        content: 'Contenido del artículo mock para testing.',
        authorId: 'mock_user_1',
        thumbnailURL: 'https://via.placeholder.com/300x200',
        tags: ['test'],
        published: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ]);
  }

  @override
  Future<List<Article>> getArticles() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockArticles.where((article) => article.published).toList();
  }

  @override
  Future<String> createArticle(Article article) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newId = 'mock_${DateTime.now().millisecondsSinceEpoch}';
    final newArticle = Article(
      id: newId,
      title: article.title,
      content: article.content,
      authorId: article.authorId,
      thumbnailURL: article.thumbnailURL,
      tags: article.tags,
      published: article.published,
      createdAt: article.createdAt,
      updatedAt: article.updatedAt,
    );
    _mockArticles.add(newArticle);
    return newId;
  }

  @override
  Future<void> updateArticle(Article article) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _mockArticles.indexWhere((a) => a.id == article.id);
    if (index != -1) {
      _mockArticles[index] = article;
    }
  }

  @override
  Future<void> deleteArticle(String articleId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockArticles.removeWhere((article) => article.id == articleId);
  }

  @override
  Future<Article> getArticleById(String articleId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final article = _mockArticles.firstWhere(
      (article) => article.id == articleId,
      orElse: () => throw Exception('Article not found'),
    );
    return article;
  }

  @override
  Future<String> uploadImage(String filePath, String fileName) async {
    await Future.delayed(const Duration(seconds: 1));
    return 'https://via.placeholder.com/600x400/8B5CF6/FFFFFF?text=Mock+Upload+${DateTime.now().millisecond}';
  }

  @override
  Future<List<Article>> getArticlesByAuthor(String authorId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockArticles
        .where((article) => article.authorId == authorId)
        .toList();
  }

  @override
  Future<void> togglePublishStatus(String articleId, bool published) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _mockArticles.indexWhere((a) => a.id == articleId);
    if (index != -1) {
      final article = _mockArticles[index];
      _mockArticles[index] = Article(
        id: article.id,
        title: article.title,
        content: article.content,
        authorId: article.authorId,
        thumbnailURL: article.thumbnailURL,
        tags: article.tags,
        published: published,
        createdAt: article.createdAt,
        updatedAt: DateTime.now(),
      );
    }
  }
}