import '../entities/article.dart';
import '../repositories/article_repository.dart';

class GetArticlesMockUseCase {
  Future<List<Article>> execute() async {
    // Mock data para demostración/testing
    await Future.delayed(const Duration(seconds: 1)); // Simular delay
    
    return [
      Article(
        id: 'mock_1',
        title: 'Mock Article 1 - Flutter es Increíble',
        content: 'Este es un artículo de prueba para demostrar la arquitectura sin necesidad de Firebase. Flutter permite desarrollar aplicaciones nativas desde un solo código base.',
        authorId: 'mock_user',
        thumbnailURL: 'https://via.placeholder.com/600x400/3B82F6/FFFFFF?text=Mock+Image+1',
        tags: ['flutter', 'mock', 'test'],
        published: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Article(
        id: 'mock_2',
        title: 'Clean Architecture en Flutter',
        content: 'Implementar Clean Architecture con BLoC pattern permite separar responsabilidades y hacer el código más testeable y mantenible.',
        authorId: 'mock_user',
        thumbnailURL: 'https://via.placeholder.com/600x400/10B981/FFFFFF?text=Mock+Image+2',
        tags: ['architecture', 'bloc', 'testing'],
        published: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
      ),
      Article(
        id: 'mock_3',
        title: 'Firebase para Backend as a Service',
        content: 'Firebase ofrece Firestore para base de datos en tiempo real y Storage para archivos, perfecto para prototipos rápidos.',
        authorId: 'mock_user',
        thumbnailURL: 'https://via.placeholder.com/600x400/EF4444/FFFFFF?text=Mock+Image+3',
        tags: ['firebase', 'backend', 'database'],
        published: false, // Draft
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ];
  }
}