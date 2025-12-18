// VERSIÓN DEFINITIVA CON FIREBASE STORAGE SDK
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  ArticleRepositoryImpl({
    required this.firestore,
    FirebaseStorage? storage,
  }) : storage = storage ?? FirebaseStorage.instance;

  @override
  Future<DataState<List<ArticleEntity>>> getNewsArticles() async {
    print('🚀 OBTENIENDO ARTÍCULOS CON FIREBASE STORAGE SDK');
    
    try {
      // 1. Obtener artículos de Firestore
      final snapshot = await firestore.collection('articles').get();
      print('📚 ${snapshot.docs.length} artículos encontrados');
      
      // 2. Procesar cada artículo CON IMÁGENES REALES
      final articles = <ArticleEntity>[];
      
      for (final doc in snapshot.docs) {
        try {
          final article = await _createArticleWithRealImage(doc);
          articles.add(article);
        } catch (e) {
          print('⚠️ Error procesando artículo ${doc.id}: $e');
        }
      }
      
      print('\n🎉 ${articles.length} artículos procesados exitosamente');
      return DataSuccess(articles);
      
    } catch (e) {
      print('💥 ERROR CRÍTICO: $e');
      return DataFailed(DioException(
        requestOptions: RequestOptions(path: '/articles'),
        error: 'Error: $e',
        type: DioExceptionType.connectionError,
      ));
    }
  }

  Future<ArticleEntity> _createArticleWithRealImage(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    final title = data['title']?.toString()?.trim() ?? 'Sin título';
    
    print('\n📰 Procesando: "$title"');
    
    // Obtener URL gs:// de la base de datos
    final gsUrl = data['thumbnailURL']?.toString()?.trim() ?? 
                  data[' thumbnailURL']?.toString()?.trim() ?? '';
    
    print('   🔗 URL en DB: $gsUrl');
    
    // Obtener URL REAL de Firebase Storage
    String imageUrl = await _getRealImageUrlFromGsUrl(gsUrl, title);
    
    print('   🖼️ Imagen final: $imageUrl');
    
    return ArticleEntity(
      id: doc.id.hashCode,
      author: data['authorId']?.toString() ?? 'Anónimo',
      title: title,
      description: data['excerpt']?.toString()?.trim() ?? '',
      url: '',
      urlToImage: imageUrl,
      publishedAt: data['createdAt'] != null && data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate().toIso8601String()
          : DateTime.now().toIso8601String(),
      content: data['content']?.toString()?.trim() ?? '',
    );
  }

  Future<String> _getRealImageUrlFromGsUrl(String gsUrl, String title) async {
    if (gsUrl.isEmpty) {
      print('   ⚠️ No hay imagen en DB, usando por defecto');
      return _getFallbackImage(title);
    }
    
    try {
      print('   🔄 Obteniendo URL REAL con Firebase Storage SDK...');
      
      // MÉTODO CORRECTO: Usar refFromURL del SDK
      // Convierte gs:// directamente a referencia
      final storageRef = storage.refFromURL(gsUrl);
      
      // Obtener URL de descarga REAL (con token de acceso)
      final downloadUrl = await storageRef.getDownloadURL();
      
      print('   ✅ ¡URL REAL OBTENIDA!');
      print('      $downloadUrl');
      
      return downloadUrl;
      
    } catch (e) {
      print('   ❌ Error obteniendo imagen real: $e');
      
      // Intentar método alternativo si refFromURL falla
      return await _tryAlternativeMethod(gsUrl, title);
    }
  }

  Future<String> _tryAlternativeMethod(String gsUrl, String title) async {
    print('   🔄 Intentando método alternativo...');
    
    try {
      // Extraer path del archivo de la URL gs://
      // Formato: gs://bucket/path/to/file.jpg
      final withoutGs = gsUrl.substring(5); // Quitar "gs://"
      final slashIndex = withoutGs.indexOf('/');
      
      if (slashIndex != -1) {
        final filePath = withoutGs.substring(slashIndex + 1);
        print('   📁 Path extraído: $filePath');
        
        // Crear referencia usando el path
        final ref = storage.ref(filePath);
        final downloadUrl = await ref.getDownloadURL();
        
        print('   ✅ ¡URL obtenida con método alternativo!');
        return downloadUrl;
      }
    } catch (e) {
      print('   ❌ Método alternativo también falló: $e');
    }
    
    // Si todo falla, usar imagen por defecto
    print('   ⚠️ Usando imagen por defecto');
    return _getFallbackImage(title);
  }

  String _getFallbackImage(String title) {
    // Imágenes reales de alta calidad de Unsplash
    final lowerTitle = title.toLowerCase();
    
    if (lowerTitle.contains('christmas') || lowerTitle.contains('navidad')) {
      return 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=800&h=600&fit=crop';
    } 
    else if (lowerTitle.contains('cat') || lowerTitle.contains('gato')) {
      return 'https://images.unsplash.com/photo-1514888286974-6d03bde4ba42?w=800&h=600&fit=crop';
    }
    else {
      return 'https://images.unsplash.com/photo-1504711434969-e33886168f5c?w=800&h=600&fit=crop';
    }
  }

  @override
  Future<List<ArticleEntity>> getSavedArticles() async => [];

  @override
  Future<void> saveArticle(ArticleEntity article) async {}

  @override
  Future<void> removeArticle(ArticleEntity article) async {}
}