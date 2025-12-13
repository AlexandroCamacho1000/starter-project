import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CreateArticlePage extends StatefulWidget {
  const CreateArticlePage({Key? key}) : super(key: key);

  @override
  _CreateArticlePageState createState() => _CreateArticlePageState();
}

class _CreateArticlePageState extends State<CreateArticlePage> {
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