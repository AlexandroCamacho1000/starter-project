// lib/widgets/news_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class NewsCard extends StatelessWidget {
  final String title;
  final String category;
  final String content;
  final String author;
  final DateTime date;
  final String? imageUrl;
  final int likes;
  final bool isBookmarked;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onBookmark;
  final VoidCallback? onShare;
  
  const NewsCard({
    Key? key,
    required this.title,
    required this.category,
    required this.content,
    required this.author,
    required this.date,
    this.imageUrl,
    this.likes = 0,
    this.isBookmarked = false,
    this.onTap,
    this.onLike,
    this.onBookmark,
    this.onShare,
  }) : super(key: key);
  
  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    
    return DateFormat('MMM d').format(date);
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen o placeholder
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                color: Color(0xFFF3F4F6),
              ),
              child: imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Color(0xFFF3F4F6),
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF4F46E5),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Icon(
                        Icons.article,
                        size: 60,
                        color: Color(0xFFD1D5DB),
                      ),
                    ),
            ),
            
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categoría
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4F46E5),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Spacer(),
                      Text(
                        _formatTimeAgo(date),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 12),
                  
                  // Título
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: 8),
                  
                  // Contenido preview
                  Text(
                    content,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6B7280),
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Footer: Autor y acciones
                  Row(
                    children: [
                      // Info autor
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFE5E7EB),
                              ),
                              child: Center(
                                child: Text(
                                  author.isNotEmpty ? author[0].toUpperCase() : 'A',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    author,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF111827),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Author',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Acciones
                      Row(
                        children: [
                          // Like
                          _ActionButton(
                            icon: Icons.favorite_border,
                            activeIcon: Icons.favorite,
                            count: likes,
                            isActive: false,
                            onTap: onLike,
                            activeColor: Color(0xFFEF4444),
                          ),
                          SizedBox(width: 16),
                          
                          // Bookmark
                          _ActionButton(
                            icon: Icons.bookmark_border,
                            activeIcon: Icons.bookmark,
                            isActive: isBookmarked,
                            onTap: onBookmark,
                            activeColor: Color(0xFF10B981),
                          ),
                          SizedBox(width: 16),
                          
                          // Share
                          IconButton(
                            onPressed: onShare,
                            icon: Icon(Icons.share, size: 22),
                            color: Color(0xFF6B7280),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final int? count;
  final bool isActive;
  final VoidCallback? onTap;
  final Color activeColor;
  
  const _ActionButton({
    Key? key,
    required this.icon,
    required this.activeIcon,
    this.count,
    required this.isActive,
    this.onTap,
    this.activeColor = Colors.blue,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            isActive ? activeIcon : icon,
            size: 22,
            color: isActive ? activeColor : Color(0xFF6B7280),
          ),
          if (count != null) SizedBox(width: 6),
          if (count != null)
            Text(
              count.toString(),
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
        ],
      ),
    );
  }
}