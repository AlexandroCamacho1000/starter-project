import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'article_event.dart';
import 'article_state.dart';

class ArticleBloc extends Bloc<ArticleEvent, ArticleState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ArticleBloc() : super(ArticleInitial()) {
    on<LoadArticlesEvent>(_onLoadArticles);
    on<CreateArticleEvent>(_onCreateArticle);
  }

  Future<void> _onLoadArticles(
    LoadArticlesEvent event,
    Emitter<ArticleState> emit,
  ) async {
    emit(ArticleLoading());
    try {
      final snapshot = await _firestore
          .collection('articles')
          .orderBy('createdAt', descending: true)
          .get();

      final articles = <Map<String, dynamic>>[];
      
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          
          // Asegurarse de que authorId no sea nulo
          if (data['authorId'] == null || data['authorId'].toString().isEmpty) {
            data['authorId'] = 'default_author';
          }
          
          // Asegurarse de que haya al menos un campo de imagen
          if (data['thumbnailURL'] == null && 
              data['imageUrl'] == null && 
              data['image'] == null) {
            data['thumbnailURL'] = '';
          }
          
          articles.add({
            'id': doc.id,
            ...data,
          });
        } catch (e) {
          print('Error processing article ${doc.id}: $e');
        }
      }

      emit(ArticleLoaded(articles: articles));
    } catch (e) {
      print('Error loading articles: $e');
      emit(ArticleError(message: 'Error loading articles: $e'));
    }
  }

  Future<void> _onCreateArticle(
    CreateArticleEvent event,
    Emitter<ArticleState> emit,
  ) async {
    try {
      await _firestore.collection('articles').add({
        'title': event.title,
        'content': event.content,
        'category': event.category ?? 'General',
        'thumbnailURL': event.imageUrl ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'published': true,
        'authorId': 'demo_user',
        'authorName': 'Demo User',
      });

      add(LoadArticlesEvent());
    } catch (e) {
      emit(ArticleError(message: 'Error creating article: $e'));
    }
  }
}