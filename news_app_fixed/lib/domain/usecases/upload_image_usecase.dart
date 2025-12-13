// lib/domain/usecases/upload_image_usecase.dart
import '../repositories/article_repository.dart';

class UploadImageUseCase {
  final ArticleRepository repository;
  
  UploadImageUseCase(this.repository);
  
  Future<String> execute({
    required String filePath,
    required String fileName,
  }) async {
    return await repository.uploadImage(filePath, fileName);
  }
}