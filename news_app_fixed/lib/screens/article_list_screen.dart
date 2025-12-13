import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/article.dart';

class ArticleListScreen extends StatelessWidget {
  const ArticleListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TEST: Verificar conversión
    final testUrls = [
      'gs://app-articles-339e5.firebasestorage.app/media/articles/cat.jpg',
      'gs://app-articles-339e5.appspot.com/media/articles/nav2.jpg',
      'media/articles/test.jpg',
    ];
    
    for (final url in testUrls) {
      final result = _getImageUrl(url);
      print('🧪 TEST CONVERSIÓN: $url -> $result');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('News Articles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Crear artículo en desarrollo')),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('articles')
            .where('published', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final articles = snapshot.data!.docs
              .map((doc) => Article.fromFirestore(doc))
              .toList();

          if (articles.isEmpty) {
            return const Center(child: Text('No articles yet'));
          }

          return ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              final imageUrl = _getImageUrl(article.thumbnailURL);
              print('📱 Widget - Artículo ${index + 1}: ${article.title}');
              print('📱 Widget - URL imagen: $imageUrl');
              print('📱 Widget - Es URL válida?: ${imageUrl.startsWith("https://")}');

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: article.thumbnailURL.isNotEmpty
                      ? SizedBox(
                          width: 50,
                          height: 50,
                          child: imageUrl.isNotEmpty && imageUrl.startsWith('https://')
                              ? CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) {
                                    print('❌ Error cargando thumbnail: $url');
                                    print('❌ Error: $error');
                                    return Container(
                                      color: Colors.red[100],
                                      child: const Icon(
                                        Icons.broken_image,
                                        color: Colors.red,
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.article,
                                    color: Colors.grey,
                                  ),
                                ),
                        )
                      : Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey[300],
                          child: const Icon(Icons.article),
                        ),
                  title: Text(article.title),
                  subtitle: Text(
                    article.content.length > 100
                        ? '${article.content.substring(0, 100)}...'
                        : article.content,
                  ),
                  trailing: Text(
                    '${article.createdAt.day}/${article.createdAt.month}/${article.createdAt.year}',
                  ),
                  onTap: () {
                    _showArticleDetails(context, article);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showArticleDetails(BuildContext context, Article article) {
    final imageUrl = _getImageUrl(article.thumbnailURL);
    print('🔍 Dialog - URL imagen: $imageUrl');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(article.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (article.thumbnailURL.isNotEmpty && imageUrl.isNotEmpty && imageUrl.startsWith('https://'))
                Container(
                  height: 150,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) {
                      print('❌ Error cargando imagen grande: $url');
                      return Container(
                        color: Colors.red[100],
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.red,
                          ),
                        ),
                      );
                    },
                  ),
                )
              else if (article.thumbnailURL.isNotEmpty)
                Container(
                  height: 150,
                  color: Colors.orange[100],
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.warning, color: Colors.orange),
                        SizedBox(height: 8),
                        Text('URL de imagen no válida'),
                      ],
                    ),
                  ),
                ),
              
              const SizedBox(height: 16),
              Text(
                article.content,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                'Publicado: ${article.createdAt.day}/${article.createdAt.month}/${article.createdAt.year}',
                style: const TextStyle(color: Colors.grey),
              ),
              if (article.authorId.isNotEmpty)
                Text(
                  'Autor ID: ${article.authorId}',
                  style: const TextStyle(color: Colors.grey),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  String _getImageUrl(String thumbnailURL) {
    print('🔍 _getImageUrl LLAMADA con: "$thumbnailURL"');
    
    // Caso 1: URL vacía
    if (thumbnailURL.isEmpty) {
      print('⚠️ URL vacía, retornando vacío');
      return '';
    }
    
    // Caso 2: Ya es URL HTTP/HTTPS
    if (thumbnailURL.startsWith('http')) {
      print('✅ Ya es URL HTTP, usando directamente');
      return thumbnailURL;
    }
    
    // Caso 3: Es URL gs://
    if (thumbnailURL.startsWith('gs://')) {
      print('🔧 Procesando URL gs://');
      
      try {
        // 1. Quitar 'gs://'
        String withoutGS = thumbnailURL.substring(5);
        print('   Sin gs://: "$withoutGS"');
        
        // 2. Encontrar el primer '/' (separador bucket/path)
        int slashIndex = withoutGS.indexOf('/');
        if (slashIndex == -1) {
          print('❌ ERROR: No se encuentra / en la URL');
          return '';
        }
        
        // 3. Extraer bucket (TODO lo antes del primer /)
        String bucket = withoutGS.substring(0, slashIndex);
        print('   📦 Bucket: "$bucket"');
        
        // 4. Extraer path (TODO lo después del primer /)
        String path = withoutGS.substring(slashIndex + 1);
        print('   📁 Path: "$path"');
        
        // 5. Validar que path no esté vacío
        if (path.isEmpty) {
          print('❌ ERROR: Path está vacío');
          return '';
        }
        
        // 6. Codificar el path para URL (IMPORTANTE: esto convierte / en %2F)
        String encodedPath = Uri.encodeComponent(path);
        print('   🔠 Path codificado: "$encodedPath"');
        
        // 7. Construir URL final de Firebase Storage
        // ¡IMPORTANTE! NO cambiar .firebasestorage.app a .appspot.com
        String finalUrl = 'https://firebasestorage.googleapis.com/v0/b/$bucket/o/$encodedPath?alt=media';
        
        print('🎉🎉🎉 URL FINAL GENERADA:');
        print('   $finalUrl');
        print('   Longitud: ${finalUrl.length} caracteres');
        
        return finalUrl;
      } catch (e) {
        print('💥 ERROR CRÍTICO en conversión: $e');
        return '';
      }
    }
    
    // Caso 4: Para emuladores (localhost) - si usas emulador
    if (thumbnailURL.startsWith('media/')) {
      print('🏠 Usando URL para emulador');
      return 'http://localhost:9199/v0/b/app-articles-339e5.appspot.com/o/${Uri.encodeComponent(thumbnailURL)}?alt=media';
    }
    
    // Caso 5: URL no reconocida
    print('⚠️ URL no reconocida (no es http:// ni gs://)');
    return '';
  }
}