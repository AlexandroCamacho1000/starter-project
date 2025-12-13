import '../repositories/article_repository.dart';
import '../entities/article.dart';

class GetArticlesUseCase {
  final ArticleRepository repository;
  
  GetArticlesUseCase(this.repository);
  
  Future<List<Article>> execute() async {
    return await repository.getArticles();
  }
}