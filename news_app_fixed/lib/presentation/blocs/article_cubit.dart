import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/article.dart';

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

class ArticleCubit extends Cubit<ArticleState> {
  ArticleCubit() : super(ArticleInitial());

  // MOCK DATA según README sección 2.1
  Future<void> loadArticles() async {
    emit(ArticleLoading());
    
    // Simular delay de red
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock data según tu esquema DB_SCHEMA.md
    final mockArticles = [
      Article(
        id: 'art_001',
        title: 'Cómo Flutter revoluciona el desarrollo móvil',
        content: 'Flutter permite desarrollar apps nativas desde un solo código base...',
        authorId: 'journalist_123',
        thumbnailURL: 'media/articles/art_001/thumbnail.jpg',
        tags: ['flutter', 'mobile', 'development'],
        published: true,
        createdAt: DateTime(2024, 3, 15),
        updatedAt: DateTime(2024, 3, 15),
      ),
      Article(
        id: 'art_002',
        title: 'Firebase Firestore para apps en tiempo real',
        content: 'Firestore ofrece sincronización automática y escalabilidad...',
        authorId: 'journalist_456',
        thumbnailURL: 'media/articles/art_002/thumbnail.jpg',
        tags: ['firebase', 'backend', 'database'],
        published: true,
        createdAt: DateTime(2024, 3, 14),
        updatedAt: DateTime(2024, 3, 14),
      ),
      Article(
        id: 'art_003',
        title: 'Clean Architecture en proyectos Flutter',
        content: 'Separación de responsabilidades para código mantenible...',
        authorId: 'journalist_789',
        thumbnailURL: 'media/articles/art_003/thumbnail.jpg',
        tags: ['architecture', 'best-practices', 'flutter'],
        published: false, // Borrador
        createdAt: DateTime(2024, 3, 13),
        updatedAt: DateTime(2024, 3, 13),
      ),
    ];
    
    emit(ArticleLoaded(mockArticles));
  }

  // Para subir nuevo artículo (mock por ahora)
  Future<void> createArticle(Article article) async {
    emit(ArticleLoading());
    await Future.delayed(const Duration(seconds: 1));
    // TODO: Conectar con Firebase
    emit(const ArticleError('Funcionalidad no implementada aún'));
  }
}