import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/article.dart';

class ArticleDetailPage extends StatefulWidget {
  final Article article;
  
  const ArticleDetailPage({
    required this.article,
    Key? key,
  }) : super(key: key);
  
  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  String _authorName = '';
  bool _isLoadingAuthor = true;

  @override
  void initState() {
    super.initState();
    _fetchAuthorData();
  }

  Future<void> _fetchAuthorData() async {
    try {
      if (widget.article.authorId.isEmpty) {
        setState(() {
          _authorName = 'Autor no disponible';
          _isLoadingAuthor = false;
        });
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.article.authorId)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        final userData = userDoc.data()!;
        setState(() {
          _authorName = userData['name'] ?? 'Nombre no disponible';
          _isLoadingAuthor = false;
        });
      } else {
        setState(() {
          _authorName = 'Usuario no encontrado';
          _isLoadingAuthor = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching author: $e');
      setState(() {
        _authorName = 'Error al cargar autor';
        _isLoadingAuthor = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.article.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen destacada
            if (widget.article.thumbnailURL.isNotEmpty)
              Hero(
                tag: 'article-image-${widget.article.id}',
                child: CachedNetworkImage(
                  imageUrl: widget.article.thumbnailURL,
                  height: 280,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 280,
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 280,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                  ),
                ),
              ),

            // Contenido del artículo
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    widget.article.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Metadata del autor
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 20,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Autor',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Colors.grey[600],
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (_isLoadingAuthor)
                                SizedBox(
                                  height: 20,
                                  child: LinearProgressIndicator(
                                    backgroundColor: Colors.grey[200],
                                    color: Theme.of(context).primaryColor,
                                    minHeight: 2,
                                  ),
                                )
                              else
                                Text(
                                  _authorName,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Separador
                  Divider(
                    height: 1,
                    color: Colors.grey[300],
                  ),

                  const SizedBox(height: 32),

                  // Contenido del artículo
                  Text(
                    widget.article.content,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.8,
                      color: Colors.grey[800],
                    ),
                    textAlign: TextAlign.justify,
                  ),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}