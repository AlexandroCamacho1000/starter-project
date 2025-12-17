// lib/features/daily_news/data/repository/article_repository_impl.dart
import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Función auxiliar para obtener campos sin problemas de espacios
dynamic _getField(Map<String, dynamic> data, List<String> possibleNames) {
  for (final name in possibleNames) {
    if (data.containsKey(name)) {
      return data[name];
    }
  }
  return null;
}

// Función auxiliar para limpiar valores de Firestore
String _cleanFirestoreValue(String? value) {
  if (value == null || value.isEmpty) return value ?? '';
  
  // Quitar comillas extras y espacios
  value = value.trim();
  if (value.endsWith('"') || value.startsWith('"')) {
    value = value.replaceAll('"', '');
  }
  
  return value;
}

class ArticleRepositoryImpl implements ArticleRepository {
  final FirebaseFirestore firestore;

  ArticleRepositoryImpl({required this.firestore});

  @override
  Future<DataState<List<ArticleEntity>>> getNewsArticles() async {
    print('=' * 50);
    print('🚀 INICIANDO getNewsArticles() - VERSIÓN CORREGIDA');
    print('=' * 50);
    
    try {
      // CONSULTA TODOS
      print('1️⃣ Consultando TODOS los artículos...');
      final snapshot = await firestore
          .collection('articles')
          .get();

      print('2️⃣ Resultado: ${snapshot.docs.length} documentos\n');
      
      if (snapshot.docs.isEmpty) {
        print('⚠️  Colección vacía');
        return DataSuccess([]);
      }
      
      // VERIFICAR CAMPOS REALES
      print('🔍 VERIFICANDO CAMPOS REALES:');
      for (int i = 0; i < snapshot.docs.length; i++) {
        final doc = snapshot.docs[i];
        final data = doc.data();
        
        print('\n📄 ARTÍCULO ${i+1}: ${doc.id}');
        
        // Verificar contenido
        final contenidoCrudo = _getField(data, ['content', ' content'])?.toString();
        final contenidoLimpio = _cleanFirestoreValue(contenidoCrudo);
        print('├─ Content (crudo): $contenidoCrudo');
        print('├─ Content (limpio): $contenidoLimpio');
        print('├─ ¿Tiene content?: ${contenidoCrudo != null ? "SÍ" : "NO"}');
        
        // Verificar excerpt
        final excerptCrudo = _getField(data, ['excerpt', ' excerpt'])?.toString();
        final excerptLimpio = _cleanFirestoreValue(excerptCrudo);
        print('├─ Excerpt (crudo): $excerptCrudo');
        print('└─ Excerpt (limpio): $excerptLimpio');
        
        // Mostrar todos los campos para debug
        print('   Campos disponibles: ${data.keys.toList()}');
      }
      
      // CONVERTIR CON LAS FUNCIONES CORRECTAS
      print('\n3️⃣ CONVIRTIENDO CON MÉTODOS CORREGIDOS...');
      final List<ArticleEntity> articles = [];
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        
        print('\n🔄 Convirtiendo: ${doc.id}');
        
        try {
          // Obtener valores usando las funciones corregidas
          final title = _cleanFirestoreValue(
            _getField(data, ['title', ' title'])?.toString()
          ) ?? 'Sin título';
          
          final content = _cleanFirestoreValue(
            _getField(data, ['content', ' content'])?.toString()
          ) ?? 'Contenido no disponible';
          
          final excerpt = _cleanFirestoreValue(
            _getField(data, ['excerpt', ' excerpt'])?.toString()
          ) ?? '';
          
          final author = _getField(data, ['authorId', ' authorId'])?.toString() ?? 'Anónimo';
          final thumbnail = _cleanFirestoreValue(
            _getField(data, ['thumbnailURL', ' thumbnailURL'])?.toString()
          ) ?? '';
          
          final createdAt = _getField(data, ['createdAt', ' createdAt']);
          String publishedAt;
          
          if (createdAt != null && createdAt is Timestamp) {
            publishedAt = createdAt.toDate().toIso8601String();
          } else {
            publishedAt = DateTime.now().toIso8601String();
            print('   ⚠️  Sin fecha válida, usando actual');
          }
          
          // MOSTRAR SIN ERRORES DE substring
          print('   Título: $title');
          
          // Manejar excerpt seguro
          if (excerpt.isNotEmpty && excerpt.length > 30) {
            print('   Excerpt: ${excerpt.substring(0, 30)}...');
          } else {
            print('   Excerpt: $excerpt');
          }
          
          // Manejar content seguro
          if (content.isNotEmpty && content.length > 50) {
            print('   Content: ${content.substring(0, 50)}...');
          } else {
            print('   Content: $content');
          }
          
          final article = ArticleEntity(
            id: doc.id.hashCode,
            author: author,
            title: title,
            description: excerpt,
            url: '',
            urlToImage: thumbnail,
            publishedAt: publishedAt,
            content: content,
          );
          
          articles.add(article);
          print('   ✅ Convertido correctamente');
          
        } catch (e) {
          print('   ❌ ERROR convirtiendo: $e');
          print('   Datos del documento: $data');
          // Continuar con el siguiente artículo en lugar de fallar todo
          continue;
        }
      }
      
      print('\n🎉 ${articles.length} artículos convertidos');
      
      // RESUMEN FINAL
      print('\n📋 RESUMEN FINAL:');
      for (int i = 0; i < articles.length; i++) {
        final article = articles[i];
        print('${i+1}. ${article.title}');
        
        // Mostrar contenido de forma segura
        if (article.description != null && article.description!.isNotEmpty) {
          final desc = article.description!;
          print('   Excerpt: ${desc.length > 50 ? '${desc.substring(0, 50)}...' : desc}');
        }
        
        if (article.content != null && article.content!.isNotEmpty) {
          final cont = article.content!;
          print('   Content: ${cont.length > 50 ? '${cont.substring(0, 50)}...' : cont}');
        }
      }
      
      if (articles.isEmpty) {
        print('⚠️  No se pudo convertir ningún artículo');
        return DataFailed(DioException(
          requestOptions: RequestOptions(path: '/articles'),
          error: 'No se pudieron convertir los artículos',
          type: DioExceptionType.unknown,
        ));
      }
      
      return DataSuccess(articles);
      
    } catch (e) {
      print('❌ ERROR: $e');
      
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