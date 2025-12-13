import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/article_bloc.dart';
import '../blocs/article_event.dart';
import '../blocs/article_state.dart';
import 'article_detail_page.dart';
import 'create_article_page.dart';
import '../../models/article.dart';
import '../../theme/app_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Map<String, String> _authorNamesCache = {};
  TextEditingController _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;
  final List<String> _categories = [
    'All',
    'Technology',
    'Business',
    'Sports',
    'Health',
    'Science'
  ];
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ArticleBloc>().add(LoadArticlesEvent());
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<String> _getAuthorName(String authorId) async {
    try {
      if (authorId.isEmpty) return 'Anonymous';
      
      if (_authorNamesCache.containsKey(authorId)) {
        return _authorNamesCache[authorId]!;
      }
      
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && authorId == currentUser.uid) {
        final userName = _getCurrentUserName();
        _authorNamesCache[authorId] = userName;
        return userName;
      }
      
      if (authorId == 'demo_user' || authorId == 'default_author') {
        return 'Demo User';
      }
      
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(authorId)
          .get();
      
      String authorName;
      
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        authorName = userData['displayName'] ?? 
                    userData['name'] ?? 
                    userData['username'] ?? 
                    userData['email']?.toString().split('@').first ?? 
                    'User${authorId.substring(0, 4)}';
        
        authorName = authorName[0].toUpperCase() + 
                    (authorName.length > 1 ? authorName.substring(1) : '');
      } else {
        authorName = 'User${authorId.substring(0, 4)}';
      }
      
      _authorNamesCache[authorId] = authorName;
      return authorName;
      
    } catch (e) {
      print('Error getting author name: $e');
      return 'User';
    }
  }
  
  String _getCurrentUserName() {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (user.displayName != null && user.displayName!.isNotEmpty) {
          return user.displayName!;
        }
        if (user.email != null) {
          final email = user.email!;
          final username = email.split('@').first;
          return username[0].toUpperCase() + 
                (username.length > 1 ? username.substring(1) : '');
        }
        return 'User${user.uid.substring(0, 4)}';
      }
    } catch (e) {
      print('Error getting current user name: $e');
    }
    return 'User';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemes.backgroundWhite,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      title: Container(
        height: 40,
        decoration: BoxDecoration(
          color: AppThemes.cardGray,
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search articles...',
            hintStyle: GoogleFonts.inter(
              fontSize: 16,
              color: AppThemes.textGray,
            ),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: AppThemes.textGray),
            contentPadding: EdgeInsets.only(bottom: 10),
          ),
          style: GoogleFonts.inter(
            fontSize: 16,
            color: AppThemes.textBlack,
          ),
        ),
      ),
      centerTitle: false,
      automaticallyImplyLeading: false,
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // Category Chips (horizontal scroll like Figma)
        _buildCategoryChips(),
        
        // Featured Articles Header (like Figma)
        Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Featured Articles',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppThemes.textBlack,
                  letterSpacing: -0.3,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'View all',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppThemes.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Articles List
        Expanded(
          child: _buildArticlesList(),
        ),
      ],
    );
  }

  Widget _buildCategoryChips() {
    return Container(
      height: 56,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(
              left: index == 0 ? 16 : 8,
              right: index == _categories.length - 1 ? 16 : 0,
              top: 16,
            ),
            child: ChoiceChip(
              label: Text(
                _categories[index],
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: _selectedCategoryIndex == index 
                      ? FontWeight.w600 
                      : FontWeight.w400,
                  color: _selectedCategoryIndex == index 
                      ? Colors.white 
                      : AppThemes.textGray,
                ),
              ),
              selected: _selectedCategoryIndex == index,
              selectedColor: AppThemes.primaryBlue,
              backgroundColor: Colors.white,
              shape: StadiumBorder(
                side: BorderSide(
                  color: _selectedCategoryIndex == index 
                      ? AppThemes.primaryBlue 
                      : AppThemes.borderLight,
                  width: 1.5,
                ),
              ),
              onSelected: (selected) {
                setState(() {
                  _selectedCategoryIndex = index;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildArticlesList() {
    return BlocBuilder<ArticleBloc, ArticleState>(
      builder: (context, state) {
        if (state is ArticleLoading || state is ArticleInitial) {
          return Center(
            child: CircularProgressIndicator(
              color: AppThemes.primaryBlue,
              strokeWidth: 3,
            ),
          );
        }
        
        if (state is ArticleError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 60,
                  color: AppThemes.primaryBlue,
                ),
                SizedBox(height: 16),
                Text(
                  'Something went wrong',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppThemes.textBlack,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: AppThemes.textGray,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    context.read<ArticleBloc>().add(LoadArticlesEvent());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppThemes.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Try Again',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        
        if (state is ArticleLoaded) {
          if (state.articles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.article_outlined,
                    size: 80,
                    color: AppThemes.textGray.withOpacity(0.3),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'No articles yet',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppThemes.textBlack,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Be the first to create an article!',
                    style: GoogleFonts.inter(
                      color: AppThemes.textGray,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateArticlePage(),
                        ),
                      ).then((_) {
                        context.read<ArticleBloc>().add(LoadArticlesEvent());
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppThemes.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Create Article',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _enrichArticlesWithAuthorNames(state.articles),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              
              final enrichedArticles = snapshot.data ?? [];
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: enrichedArticles.length,
                itemBuilder: (context, index) {
                  return _buildArticleCard(enrichedArticles[index]);
                },
              );
            },
          );
        }
        
        return Container();
      },
    );
  }

  Widget _buildArticleCard(Map<String, dynamic> article) {
    final title = article['title'] ?? 'Untitled Article';
    final category = article['category']?.toString() ?? 'General';
    final content = article['content'] ?? 'No content available';
    final imageUrl = article['thumbnailURL'] ?? '';
    final authorName = article['authorName'] ?? 'User';
    final createdAt = article['createdAt'] as Timestamp?;
    
    String timeText = _formatArticleDate(createdAt?.toDate());
    String displayImageUrl = imageUrl;
    if (imageUrl.startsWith('gs://')) {
      displayImageUrl = _convertGsUrlToHttp(imageUrl);
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppThemes.borderLight.withOpacity(0.3),
            width: 1,
          ),
        ),
        elevation: 0,
        color: AppThemes.cardGray,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ArticleDetailPage(
                  article: Article(
                    id: article['id'] ?? '',
                    title: title,
                    content: content,
                    authorId: article['authorId'] ?? '',
                    authorName: authorName,
                    thumbnailURL: displayImageUrl,
                    published: article['published'] ?? true,
                    createdAt: createdAt?.toDate() ?? DateTime.now(),
                    updatedAt: (article['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
                  ),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  color: AppThemes.textGray.withOpacity(0.1),
                  child: displayImageUrl.isNotEmpty
                      ? Image.network(
                          displayImageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppThemes.primaryBlue,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.image,
                                size: 50,
                                color: AppThemes.textGray.withOpacity(0.3),
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Icon(
                            Icons.article,
                            size: 50,
                            color: AppThemes.textGray.withOpacity(0.3),
                          ),
                        ),
                ),
              ),
              
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppThemes.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        category.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppThemes.primaryBlue,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 8),
                    
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppThemes.textBlack,
                        height: 1.3,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: 8),
                    
                    Text(
                      content.length > 100 
                          ? '${content.substring(0, 100)}...' 
                          : content,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: AppThemes.textGray,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 16,
                          color: AppThemes.textGray,
                        ),
                        SizedBox(width: 6),
                        Text(
                          authorName,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: AppThemes.textGray,
                          ),
                        ),
                        Spacer(),
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: AppThemes.textGray,
                        ),
                        SizedBox(width: 4),
                        Text(
                          timeText,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: AppThemes.textGray,
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

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: AppThemes.primaryBlue,
      unselectedItemColor: AppThemes.textGray,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      elevation: 2,
      backgroundColor: Colors.white,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home_filled),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          activeIcon: Icon(Icons.add_circle),
          label: 'Create',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outlined),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      onTap: (index) {
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateArticlePage(),
            ),
          ).then((_) {
            context.read<ArticleBloc>().add(LoadArticlesEvent());
          });
        }
      },
    );
  }

  Future<List<Map<String, dynamic>>> _enrichArticlesWithAuthorNames(
    List<Map<String, dynamic>> articles,
  ) async {
    final enrichedArticles = <Map<String, dynamic>>[];
    
    for (final article in articles) {
      final authorId = article['authorId']?.toString() ?? '';
      final authorName = await _getAuthorName(authorId);
      
      enrichedArticles.add({
        ...article,
        'authorName': authorName,
      });
    }
    
    return enrichedArticles;
  }

  String _formatArticleDate(DateTime? date) {
    if (date == null) return 'Now';
    
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) {
      return 'Now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(date);
    }
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
      return gsUrl;
    }
  }
}