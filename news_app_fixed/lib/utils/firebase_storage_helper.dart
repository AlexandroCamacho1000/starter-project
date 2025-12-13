// lib/utils/firebase_storage_helper.dart

/// Helper para manejar URLs de Firebase Storage
class FirebaseStorageHelper {
  /// Convierte una URL gs:// de Firebase Storage a URL HTTPS pública
  static String convertGsToHttps(String gsUrl) {
    if (gsUrl.isEmpty || !gsUrl.startsWith('gs://')) {
      return gsUrl;
    }
    
    // Debug
    print('🟡 FirebaseStorageHelper - URL original: $gsUrl');
    
    // Convertir formato nuevo (.firebasestorage.app) a antiguo (.appspot.com)
    String convertedUrl = gsUrl;
    if (convertedUrl.contains('.firebasestorage.app')) {
      convertedUrl = convertedUrl.replaceFirst(
        '.firebasestorage.app', 
        '.appspot.com'
      );
      print('🔄 Convertido a formato antiguo: $convertedUrl');
    }
    
    // Extraer bucket name y file path
    final parts = convertedUrl.replaceFirst('gs://', '').split('/');
    if (parts.length < 2) return gsUrl;
    
    final bucket = parts[0];
    final filePath = parts.sublist(1).join('/');
    
    // Codificar el path para URL
    final encodedPath = Uri.encodeComponent(filePath);
    
    // Crear URL pública de Firebase Storage
    final httpsUrl = 
      'https://firebasestorage.googleapis.com/v0/b/$bucket/o/$encodedPath?alt=media';
    
    print('✅ URL final: $httpsUrl');
    return httpsUrl;
  }
  
  /// Versión simplificada para usar en widgets
  static String getPublicUrl(String gsUrl) {
    return convertGsToHttps(gsUrl);
  }
}