// lib/presentation/widgets/article_card.dart - VERSIÓN MEJORADA
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ArticleCard extends StatelessWidget {
  final String articleId;
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  const ArticleCard({
    Key? key,
    required this.articleId,
    required this.data,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen (izquierda) - estilo Figma
              if (data['thumbnailURL'] != null && data['thumbnailURL'].toString().isNotEmpty)
                Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.only(right: 16),
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
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.image,
                        color: Colors.grey[400],
                        size: 40,
                      ),
                    ),
                  ),
                ),
              
              // Contenido (derecha)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Categoría (arriba)
                    if (data['category'] != null && data['category'].isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(data['category']),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          data['category'].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    
                    // Título
                    Text(
                      data['title'] ?? 'Sin título',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Extracto/resumen
                    Text(
                      _getExcerpt(data['content']),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Información inferior (autor/fecha)
                    Row(
                      children: [
                        // Icono de autor
                        Icon(Icons.person_outline, size: 12, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          data['authorId']?.split('_').first ?? 'Anónimo',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // Fecha
                        Text(
                          _formatDate(data['createdAt']),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getExcerpt(String? content) {
    if (content == null || content.isEmpty) return 'Sin contenido';
    if (content.length > 100) {
      return '${content.substring(0, 100)}...';
    }
    return content;
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'tecnología': Colors.blue,
      'deportes': Colors.green,
      'entretenimiento': Colors.purple,
      'política': Colors.red,
      'salud': Colors.teal,
      'educación': Colors.orange,
      'general': Colors.grey,
    };
    
    return colors[category.toLowerCase()] ?? Colors.blue;
  }

  String _formatDate(dynamic timestamp) {
    try {
      if (timestamp is Timestamp) {
        final date = timestamp.toDate();
        final now = DateTime.now();
        final difference = now.difference(date);
        
        if (difference.inDays == 0) {
          if (difference.inHours == 0) {
            return 'Hace ${difference.inMinutes} min';
          }
          return 'Hoy ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
        } else if (difference.inDays == 1) {
          return 'Ayer';
        } else if (difference.inDays < 7) {
          return 'Hace ${difference.inDays} días';
        } else {
          return '${date.day}/${date.month}/${date.year}';
        }
      }
    } catch (e) {
      print('Error formateando fecha: $e');
    }
    return '';
  }

  String _convertGsUrlToHttp(String gsUrl) {
    try {
      if (gsUrl.startsWith('gs://')) {
        final withoutGs = gsUrl.substring(5);
        final firstSlash = withoutGs.indexOf('/');
        if (firstSlash != -1) {
          final bucket = withoutGs.substring(0, firstSlash);
          final path = withoutGs.substring(firstSlash + 1);
          final encodedPath = Uri.encodeComponent(path);
          return 'https://firebasestorage.googleapis.com/v0/b/$bucket/o/$encodedPath?alt=media';
        }
      }
      return gsUrl;
    } catch (e) {
      print('Error convirtiendo URL: $e');
      return gsUrl;
    }
  }
}