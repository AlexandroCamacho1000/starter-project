// lib/screens/article_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/article.dart';

class ArticleDetailScreen extends StatefulWidget {
  final Article article;
  
  const ArticleDetailScreen({
    required this.article,
    Key? key,
  }) : super(key: key);

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  bool _isFavorite = false;
  bool _isAuthor = false;
  bool _isLoading = false;
  String? _authorName; // Para almacenar el nombre del autor

  @override
  void initState() {
    super.initState();
    _checkIfAuthor();
    _checkIfFavorite();
    _fetchAuthorName();
  }

  void _checkIfAuthor() {
    final currentUser = FirebaseAuth.instance.currentUser;
    setState(() {
      _isAuthor = currentUser?.uid == widget.article.authorId;
    });
  }

  void _fetchAuthorName() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.article.authorId)
          .get();
      
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _authorName = userData['displayName'] ?? 
                       userData['email']?.split('@')[0] ?? 
                       'Usuario';
        });
      }
    } catch (e) {
      print('Error fetching author name: $e');
      _authorName = 'Autor';
    }
  }

  void _checkIfFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(widget.article.id)
          .get();
      
      setState(() {
        _isFavorite = doc.exists;
      });
    }
  }

  void _toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesión para guardar favoritos')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final favoritesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites');

    try {
      if (_isFavorite) {
        await favoritesRef.doc(widget.article.id).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removido de favoritos')),
        );
      } else {
        await favoritesRef.doc(widget.article.id).set({
          'articleId': widget.article.id,
          'timestamp': FieldValue.serverTimestamp(),
          'title': widget.article.title,
          'thumbnailURL': widget.article.thumbnailURL,
          'authorName': _authorName ?? 'Autor',
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Agregado a favoritos')),
        );
      }

      setState(() {
        _isFavorite = !_isFavorite;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _shareArticle() {
    Share.share(
      '📰 ${widget.article.title}\n\n'
      '${widget.article.content.length > 200 ? widget.article.content.substring(0, 200) + '...' : widget.article.content}\n\n'
      'Autor: ${_authorName ?? "Autor desconocido"}\n'
      'Lee el artículo completo en Symmetry News App!',
      subject: widget.article.title,
    );
  }

  void _deleteArticle() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar artículo'),
        content: const Text('¿Estás seguro de eliminar este artículo? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseFirestore.instance
            .collection('articles')
            .doc(widget.article.id)
            .delete();
        
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Artículo eliminado exitosamente')),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'Hace ${difference.inMinutes} min';
      }
      return 'Hoy ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Ayer ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Artículo'),
        actions: [
          _isLoading
              ? Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : null,
                  ),
                  onPressed: _toggleFavorite,
                  tooltip: _isFavorite ? 'Quitar de favoritos' : 'Agregar a favoritos',
                ),
          
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareArticle,
            tooltip: 'Compartir artículo',
          ),
        ],
      ),
      
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildArticleContent(),
      
      floatingActionButton: _isAuthor ? FloatingActionButton(
        onPressed: _deleteArticle,
        backgroundColor: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
        tooltip: 'Eliminar artículo',
      ) : null,
    );
  }

  Widget _buildArticleContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. IMAGEN DEL ARTÍCULO
          if (widget.article.thumbnailURL.isNotEmpty)
            Container(
              width: double.infinity,
              height: 250,
              child: CachedNetworkImage(
                imageUrl: widget.article.thumbnailURL,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 80, color: Colors.grey),
                  ),
                ),
              ),
            ),
          
          // 2. CONTENIDO PRINCIPAL
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Estado de publicación
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: widget.article.published ? Colors.green[100] : Colors.orange[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.article.published ? 'Publicado' : 'Borrador',
                    style: TextStyle(
                      color: widget.article.published ? Colors.green[800] : Colors.orange[800],
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                
                // Título
                Text(
                  widget.article.title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 3. INFORMACIÓN DEL AUTOR Y FECHA
                Row(
                  children: [
                    // Avatar del autor
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.blue[100],
                      child: Icon(
                        Icons.person,
                        color: Colors.blue[800],
                        size: 20,
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Información del autor
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _authorName ?? 'Cargando autor...',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(
                                _formatDate(widget.article.createdAt),
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(width: 10),
                              const Icon(Icons.update, size: 14, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(
                                _formatDate(widget.article.updatedAt),
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Indicador si eres el autor
                    if (_isAuthor)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green),
                        ),
                        child: const Text(
                          'Tú',
                          style: TextStyle(
                            color: Colors.green[800],
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // 4. CONTENIDO DEL ARTÍCULO
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey[300]!),
                      bottom: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Text(
                    widget.article.content,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // 5. METADATOS ADICIONALES
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Información del artículo',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildMetadataItem('ID:', widget.article.id),
                      _buildMetadataItem('Creado:', _formatDate(widget.article.createdAt)),
                      _buildMetadataItem('Actualizado:', _formatDate(widget.article.updatedAt)),
                      _buildMetadataItem('Estado:', widget.article.published ? 'Publicado' : 'Borrador'),
                      _buildMetadataItem('Autor ID:', widget.article.authorId),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // 6. BOTÓN PARA EDITAR (solo autor)
                if (_isAuthor)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Navegar a pantalla de edición
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Funcionalidad de edición en desarrollo')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: const Icon(Icons.edit, color: Colors.white),
                      label: const Text(
                        'Editar Artículo',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}