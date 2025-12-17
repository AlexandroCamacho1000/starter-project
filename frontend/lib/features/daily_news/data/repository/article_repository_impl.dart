// lib/features/daily_news/data/repository/article_repository_impl.dart
import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/firestore_article.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final FirebaseFirestore firestore;

  ArticleRepositoryImpl({required this.firestore});

  @override
  Future<DataState<List<ArticleEntity>>> getNewsArticles() async {
    print('=' * 50);
    print('🚀 INICIANDO getNewsArticles()');
    print('=' * 50);
    
    try {
      // CONSULTA SIMPLIFICADA
      print('1️⃣ Consultando Firestore...');
      final snapshot = await firestore
          .collection('articles')
          .limit(2)
          .get();

      print('2️⃣ Resultado: ${snapshot.docs.length} documentos');
      
      if (snapshot.docs.isEmpty) {
        print('⚠️  Colección vacía');
        return DataSuccess([]);
      }
      
      // MOSTRAR DATOS
      print('\n📊 PRIMER DOCUMENTO:');
      final firstDoc = snapshot.docs.first;
      print('   ID: ${firstDoc.id}');
      print('   CAMPOS: ${firstDoc.data().keys.toList()}');
      
      // CONVERTIR
      print('\n3️⃣ Convirtiendo a ArticleEntity...');
      final articles = snapshot.docs.map((doc) {
        final data = doc.data();
        return ArticleEntity(
          id: doc.id.hashCode,
          author: data['authorId']?.toString() ?? 'Anónimo',
          title: data['title']?.toString() ?? 'Sin título',
          description: data['excerpt']?.toString() ?? '',
          url: '',
          urlToImage: data['thumbnailURL']?.toString() ?? '',
          publishedAt: data['createdAt'] != null 
              ? (data['createdAt'] as Timestamp).toDate().toIso8601String()
              : DateTime.now().toIso8601String(),
          content: data['content']?.toString() ?? '',
        );
      }).toList();

      print('🎉 ${articles.length} artículos convertidos');
      return DataSuccess(articles);
      
    } catch (e) {
      print('❌ ERROR: $e');
      
      // ✅ CORREGIDO: DataFailed necesita DioException
      return DataFailed(DioException(
        requestOptions: RequestOptions(path: '/articles'),
        error: e.toString(),
        type: DioExceptionType.unknown,
      ));
    }
  }

  @override
  Future<List<ArticleEntity>> getSavedArticles() async => [];

  @override
  Future<void> saveArticle(ArticleEntity article) async {}

  @override
  Future<void> removeArticle(ArticleEntity article) async {}
}