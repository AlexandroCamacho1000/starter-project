import 'package:equatable/equatable.dart';

abstract class ArticleEvent extends Equatable {
  const ArticleEvent();

  @override
  List<Object> get props => [];
}

class LoadArticlesEvent extends ArticleEvent {}

class CreateArticleEvent extends ArticleEvent {
  final String title;
  final String content;
  final String? category;
  final String? imageUrl;

  const CreateArticleEvent({
    required this.title,
    required this.content,
    this.category,
    this.imageUrl,
  });

  @override
  List<Object> get props => [title, content];
}