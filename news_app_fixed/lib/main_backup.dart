// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase inicializado correctamente');
  } catch (e) {
    print('❌ Error inicializando Firebase: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Symmetry News App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue[800],
          elevation: 4,
        ),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Symmetry News App'),
        backgroundColor: Colors.blue[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Forzar recarga
              // El StreamBuilder se actualiza automáticamente
            },
            tooltip: 'Recargar artículos',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado de bienvenida
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.blue[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bienvenido al News App',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Haz clic en el botón + para crear un nuevo artículo',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          
          // Contador de artículos
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color: Colors.grey[50],
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('articles')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    '📰 ${snapshot.data!.docs.length} artículos disponibles',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.blue[800],
                    ),
                  );
                }
                return const Text('📰 Cargando artículos...');
              },
            ),
          ),
          
          // Lista de artículos desde Firebase
          Expanded(
            child: _buildArticlesList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateArticleScreen(),
            ),
          ).then((_) {
            // Recargar después de crear artículo
            // El StreamBuilder ya lo hace automáticamente
          });
        },
        backgroundColor: Colors.blue[800],
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }

  Widget _buildArticlesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('articles')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        // Estado de carga
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text('Cargando artículos...'),
              ],
            ),
          );
        }

        // Error
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 60, color: Colors.red),
                const SizedBox(height: 20),
                Text(
                  'Error al cargar artículos',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.red[700],
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    // Intentar de nuevo
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        // Sin datos
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.article, size: 80, color: Colors.grey),
                const SizedBox(height: 20),
                const Text(
                  'No hay artículos todavía',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  '¡Sé el primero en crear un artículo!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateArticleScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add),
                      SizedBox(width: 10),
                      Text('Crear primer artículo'),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // Mostrar lista de artículos
        final articles = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: articles.length,
          itemBuilder: (context, index) {
            final doc = articles[index];
            final data = doc.data() as Map<String, dynamic>;
            
            // Depuración: ver qué campos tiene el artículo
            print('📄 Artículo ${index + 1}: ${data['title']}');
            print('   ¿Tiene thumbnailURL?: ${data.containsKey('thumbnailURL')}');
            print('   thumbnailURL: ${data['thumbnailURL']}');
            
            return InkWell(
              onTap: () {
                // Navegar a pantalla de detalle
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ArticleDetailScreen(
                      articleId: doc.id,
                      articleData: data,
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Imagen del artículo si existe - ¡CORREGIDO AQUÍ!
                      if (data['thumbnailURL'] != null && data['thumbnailURL'].toString().isNotEmpty)
                        Container(
                          height: 180,
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[200],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: _convertGsUrlToHttp(data['thumbnailURL'].toString()),
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.broken_image, color: Colors.grey),
                                      SizedBox(height: 8),
                                      Text('Error cargando imagen',
                                        style: TextStyle(fontSize: 10, color: Colors.grey)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      
                      // Título
                      if (data['title'] != null && data['title'].isNotEmpty)
                        Text(
                          data['title'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      
                      const SizedBox(height: 8),
                      
                      // Contenido (resumen)
                      if (data['content'] != null && data['content'].isNotEmpty)
                        Text(
                          data['content'].length > 120
                              ? '${data['content'].substring(0, 120)}...'
                              : data['content'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      
                      const SizedBox(height: 12),
                      
                      // Información adicional
                      Row(
                        children: [
                          // Categoría
                          if (data['category'] != null && data['category'].isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.category, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    data['category'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue[800],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          
                          const Spacer(),
                          
                          // Fecha y botón de ver más
                          Row(
                            children: [
                              if (data['createdAt'] != null)
                                Text(
                                  _formatDate(data['createdAt']),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.arrow_forward,
                                  size: 14,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(dynamic timestamp) {
    try {
      if (timestamp is Timestamp) {
        final date = timestamp.toDate();
        final now = DateTime.now();
        final difference = now.difference(date);
        
        // Si es hoy
        if (difference.inDays == 0) {
          if (difference.inHours == 0) {
            return 'Hace ${difference.inMinutes} min';
          }
          return 'Hoy ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
        }
        // Si es ayer
        else if (difference.inDays == 1) {
          return 'Ayer ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
        }
        // Más de un día
        else {
          return '${date.day}/${date.month}/${date.year}';
        }
      }
    } catch (e) {
      print('Error formateando fecha: $e');
    }
    return 'Fecha no disponible';
  }

  // Función para convertir URLs gs:// a https://
  String _convertGsUrlToHttp(String gsUrl) {
    print('🔧 Convirtiendo URL: $gsUrl');
    
    try {
      if (gsUrl.startsWith('gs://')) {
        // Remover "gs://"
        final withoutGs = gsUrl.substring(5);
        print('   Sin gs://: "$withoutGs"');
        
        // Separar bucket y path
        final firstSlash = withoutGs.indexOf('/');
        if (firstSlash != -1) {
          final bucket = withoutGs.substring(0, firstSlash);
          final path = withoutGs.substring(firstSlash + 1);
          
          print('   📦 Bucket: "$bucket"');
          print('   📁 Path: "$path"');
          
          // Codificar el path para URL
          final encodedPath = Uri.encodeComponent(path);
          print('   🔠 Path codificado: "$encodedPath"');
          
          // Construir URL HTTPS
          final httpsUrl = 'https://firebasestorage.googleapis.com/v0/b/$bucket/o/$encodedPath?alt=media';
          print('   🎉 URL final: $httpsUrl');
          
          return httpsUrl;
        }
      }
      
      // Si ya es una URL HTTP o no necesita conversión
      return gsUrl;
      
    } catch (e) {
      print('❌ Error convirtiendo URL: $e');
      return gsUrl;
    }
  }
}

// Pantalla de detalle del artículo
class ArticleDetailScreen extends StatelessWidget {
  final String articleId;
  final Map<String, dynamic> articleData;

  const ArticleDetailScreen({
    Key? key,
    required this.articleId,
    required this.articleData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Artículo'),
        backgroundColor: Colors.blue[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen si existe - ¡CORREGIDO AQUÍ!
            if (articleData['thumbnailURL'] != null && articleData['thumbnailURL'].toString().isNotEmpty)
              Container(
                height: 250,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: _convertGsUrlToHttp(articleData['thumbnailURL'].toString()),
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image, size: 60, color: Colors.grey),
                            SizedBox(height: 10),
                            Text('Error cargando imagen'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            
            // Título
            if (articleData['title'] != null)
              Text(
                articleData['title'],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Información del artículo
            Row(
              children: [
                if (articleData['category'] != null)
                  Chip(
                    label: Text(articleData['category']),
                    backgroundColor: Colors.blue[100],
                  ),
                
                const Spacer(),
                
                if (articleData['createdAt'] != null)
                  Text(
                    _formatDetailDate(articleData['createdAt']),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Contenido completo
            if (articleData['content'] != null)
              Text(
                articleData['content'],
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                ),
                textAlign: TextAlign.justify,
              ),
            
            const SizedBox(height: 30),
            
            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Volver'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Aquí podrías agregar funcionalidad de compartir
                      _showShareOptions(context);
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Compartir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDetailDate(dynamic timestamp) {
    try {
      if (timestamp is Timestamp) {
        final date = timestamp.toDate();
        return 'Publicado el ${date.day}/${date.month}/${date.year} a las ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      print('Error formateando fecha detalle: $e');
    }
    return 'Fecha no disponible';
  }

  void _showShareOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Compartir artículo'),
        content: const Text('Selecciona cómo quieres compartir este artículo'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Función de compartir en desarrollo'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Compartir'),
          ),
        ],
      ),
    );
  }

  // Función para convertir URLs gs:// a https://
  String _convertGsUrlToHttp(String gsUrl) {
    try {
      if (gsUrl.startsWith('gs://')) {
        // Remover "gs://"
        final withoutGs = gsUrl.substring(5);
        
        // Separar bucket y path
        final firstSlash = withoutGs.indexOf('/');
        if (firstSlash != -1) {
          final bucket = withoutGs.substring(0, firstSlash);
          final path = withoutGs.substring(firstSlash + 1);
          
          // Codificar el path para URL
          final encodedPath = Uri.encodeComponent(path);
          
          // Construir URL HTTPS
          return 'https://firebasestorage.googleapis.com/v0/b/$bucket/o/$encodedPath?alt=media';
        }
      }
      
      // Si ya es una URL HTTP o no necesita conversión
      return gsUrl;
      
    } catch (e) {
      print('❌ Error convirtiendo URL: $e');
      return gsUrl;
    }
  }
}

// Pantalla de creación de artículo (actualizada para soportar imágenes)
class CreateArticleScreen extends StatefulWidget {
  const CreateArticleScreen({Key? key}) : super(key: key);

  @override
  _CreateArticleScreenState createState() => _CreateArticleScreenState();
}

class _CreateArticleScreenState extends State<CreateArticleScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _categoryController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  String? _imageUrl;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nuevo Artículo'),
        backgroundColor: Colors.blue[800],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del artículo
            if (_imageUrl != null)
              Container(
                height: 200,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: _imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),
              ),
            
            // Botón para subir imagen
            Container(
              width: double.infinity,
              height: 50,
              margin: const EdgeInsets.only(bottom: 20),
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _uploadImage,
                icon: _isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.image),
                label: Text(_isUploading ? 'Subiendo imagen...' : 'Subir imagen'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                ),
              ),
            ),
            
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título del artículo *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 20),
            
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Categoría (opcional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
            ),
            const SizedBox(height: 20),
            
            TextField(
              controller: _contentController,
              maxLines: 10,
              decoration: const InputDecoration(
                labelText: 'Contenido *',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 30),
            
            // Nota sobre campos obligatorios
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.orange),
                  const SizedBox(width: 10),
                  const Flexible(
                    child: Text(
                      'Los campos marcados con * son obligatorios',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Botón de publicación
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _saveArticle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isUploading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 10),
                          Text('Publicando...'),
                        ],
                      )
                    : const Text(
                        'PUBLICAR ARTÍCULO',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadImage() async {
    // Por ahora simulamos una URL de imagen
    // En un caso real, aquí subirías la imagen a Firebase Storage
    setState(() => _isUploading = true);
    
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isUploading = false;
      _imageUrl = 'https://via.placeholder.com/600x400/3B82F6/FFFFFF?text=Imagen+del+Art%C3%ADculo';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Imagen subida correctamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _saveArticle() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Por favor, escribe un título'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Por favor, escribe contenido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() => _isUploading = true);
    
    try {
      // Guardar en Firebase - ¡CORREGIDO AQUÍ!
      await _firestore.collection('articles').add({
        'title': _titleController.text,
        'content': _contentController.text,
        'category': _categoryController.text.isNotEmpty 
            ? _categoryController.text 
            : 'General',
        'thumbnailURL': _imageUrl ?? '',  // ¡CAMBIADO DE imageUrl A thumbnailURL!
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      print('✅ Artículo guardado en Firebase');
      
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Artículo creado exitosamente'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
      // Regresar a la pantalla anterior
      Navigator.pop(context);
      
    } catch (e) {
      print('❌ Error guardando artículo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }
}