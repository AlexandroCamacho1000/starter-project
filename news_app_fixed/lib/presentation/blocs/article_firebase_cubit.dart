import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/article.dart';
import '../../domain/repositories/article_repository.dart';

// Los mismos estados (podrías reusarlos de tu cubit original)
abstract class ArticleState extends Equatable {
  const ArticleState();
}

class ArticleInitial extends ArticleState {
  @override
  List<Object> get props => [];
}

class ArticleLoading extends ArticleState {
  @override
  List<Object> get props => [];
}

class ArticleLoaded extends ArticleState {
  final List<Article> articles;
  const ArticleLoaded(this.articles);
  
  @override
  List<Object> get props => [articles];
}

class ArticleError extends ArticleState {
  final String message;
  const ArticleError(this.message);
  
  @override
  List<Object> get props => [message];
}

// NUEVO: Cubit que usa Repository REAL (Firebase)
class ArticleFirebaseCubit extends Cubit<ArticleState> {
  final ArticleRepository _repository;

  ArticleFirebaseCubit(this._repository) : super(ArticleInitial());

  // Cargar artículos DESDE FIREBASE REAL
  Future<void> loadArticles() async {
    emit(ArticleLoading());
    try {
      final articles = await _repository.getArticles();
      emit(ArticleLoaded(articles));
    } catch (e) {
      emit(ArticleError('Error loading from Firebase: $e'));
    }
  }

  // Crear artículo EN FIREBASE REAL
  Future<void> createArticle(Article article) async {
    emit(ArticleLoading());
    try {
      final articleId = await _repository.createArticle(article);
      print('✅ Artículo creado en Firebase con ID: $articleId');
      await loadArticles(); // Recargar lista después de crear
    } catch (e) {
      emit(ArticleError('Error creating article: $e'));
    }
  }
}