// lib/data/repositories/recommendations_repository.dart

import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/services/recommendations_service.dart';
import '../../domain/entities/entities.dart';
import '../models/recommendations_models.dart';
import '../mock_data.dart';

abstract class RecommendationsRepository {
  Future<Either<Failure, List<Book>>> getRecommendations(String userId, {int limit = 10});
  Future<Either<Failure, String>> getHealthStatus();
}

class RecommendationsRepositoryImpl implements RecommendationsRepository {
  final RecommendationsService _recommendationsService;

  RecommendationsRepositoryImpl(this._recommendationsService);

  @override
  Future<Either<Failure, List<Book>>> getRecommendations(String userId, {int limit = 10}) async {
    try {
      print('🤖 Getting ML recommendations for user: $userId');
      
      final result = await _recommendationsService.getRecommendations(userId, limit: limit);

      if (result.hasException) {
        print('❌ Recommendations GraphQL Exception: ${result.exception}');
        return _getFallbackRecommendations();
      }

      final data = result.data;
      if (data == null || data['get_recommendations'] == null) {
        print('❌ No recommendations data received');
        return _getFallbackRecommendations();
      }

      try {
        final recommendationResponse = RecommendationResponse.fromJson(
          data['get_recommendations'] as Map<String, dynamic>
        );

        print('✅ Received ${recommendationResponse.totalRecommendations} recommendations');
        print('📝 Message: ${recommendationResponse.message}');

        // Convertir las recomendaciones a entidades Book
        final recommendedBooks = recommendationResponse.recommendations.map((recBook) {
          return recBook.toBook(
            // Aquí puedes agregar información adicional si la tienes
            imageUrl: _getBookImageUrl(recBook.bookId),
            authors: _getBookAuthors(recBook.bookId),
            category: 'Recomendación ML',
            description: _getEnhancedDescription(recBook.title, recBook.score),
          );
        }).toList();

        // Ordenar por score descendente
        recommendedBooks.sort((a, b) => b.rating.compareTo(a.rating));

        return Right(recommendedBooks);

      } catch (e) {
        print('❌ Error parsing recommendations response: $e');
        return _getFallbackRecommendations();
      }

    } catch (e) {
      print('❌ Error getting recommendations: $e');
      return _getFallbackRecommendations();
    }
  }

  @override
  Future<Either<Failure, String>> getHealthStatus() async {
    try {
      final result = await _recommendationsService.getHealthCheck();

      if (result.hasException) {
        return Left(ServerFailure('Recommendations service unavailable'));
      }

      final healthStatus = result.data?['health_check'] as String?;
      return Right(healthStatus ?? 'Unknown status');

    } catch (e) {
      return Left(ServerFailure('Error checking recommendations service: $e'));
    }
  }

  // Fallback cuando el servicio de ML no está disponible
  Either<Failure, List<Book>> _getFallbackRecommendations() {
    print('🔄 Using fallback recommendations (mock data)');
    
    // Usar las recomendaciones mock existentes
    final fallbackBooks = MockData.recommendedBooks.take(5).toList();
    
    // Marcar como fallback en la descripción
    final modifiedBooks = fallbackBooks.map((book) {
      return Book(
        id: book.id,
        title: book.title,
        authors: book.authors,
        publisher: book.publisher,
        publishYear: book.publishYear,
        category: book.category,
        type: book.type,
        imageUrl: book.imageUrl,
        rating: book.rating,
        ratingCount: book.ratingCount,
        isAvailable: book.isAvailable,
        description: 'Recomendación basada en popularidad general. ${book.description}',
      );
    }).toList();

    return Right(modifiedBooks);
  }

  String _getBookImageUrl(String bookId) {
    // Puedes mapear IDs específicos a imágenes o usar un placeholder
    return 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400&h=600&fit=crop&q=80';
  }

  List<String> _getBookAuthors(String bookId) {
    // Puedes mapear IDs específicos a autores o usar valores por defecto
    return ['Autor Recomendado'];
  }

  String _getEnhancedDescription(String title, double score) {
    final percentage = (score * 100).toInt();
    final confidenceLevel = score > 0.8 ? 'altamente' : score > 0.6 ? 'moderadamente' : 'ligeramente';
    
    return 'Este libro "$title" es $confidenceLevel recomendado para ti con un ${percentage}% de compatibilidad. '
           'Nuestra IA ha analizado tus preferencias de lectura para sugerir este título. '
           'Las recomendaciones se basan en patrones de lectura similares y géneros de tu interés.';
  }
}

// Implementación híbrida que combina ML con fallback
class HybridRecommendationsRepository implements RecommendationsRepository {
  final RecommendationsRepositoryImpl _mlRepository;
  
  // Control de estado para fallback
  bool _mlServiceAvailable = true;
  DateTime? _lastFailureTime;
  static const Duration _retryDelay = Duration(minutes: 5);

  HybridRecommendationsRepository(this._mlRepository);

  @override
  Future<Either<Failure, List<Book>>> getRecommendations(String userId, {int limit = 10}) async {
    // Verificar si debemos intentar ML
    if (!_shouldTryML()) {
      print('🔄 Using fallback recommendations (ML service unavailable)');
      return _mlRepository._getFallbackRecommendations();
    }

    // Intentar ML primero
    final mlResult = await _mlRepository.getRecommendations(userId, limit: limit);
    
    return mlResult.fold(
      (failure) {
        print('⚠️ ML recommendations failed, using fallback');
        _markMLFailure();
        return _mlRepository._getFallbackRecommendations();
      },
      (recommendations) {
        print('✅ ML recommendations successful');
        _markMLSuccess();
        return Right(recommendations);
      },
    );
  }

  @override
  Future<Either<Failure, String>> getHealthStatus() async {
    return _mlRepository.getHealthStatus();
  }

  bool _shouldTryML() {
    if (_mlServiceAvailable) return true;
    
    if (_lastFailureTime != null) {
      final timeSinceFailure = DateTime.now().difference(_lastFailureTime!);
      if (timeSinceFailure > _retryDelay) {
        print('🔄 Retrying ML service after ${timeSinceFailure.inMinutes} minutes');
        _mlServiceAvailable = true;
        return true;
      }
    }
    
    return false;
  }

  void _markMLFailure() {
    _mlServiceAvailable = false;
    _lastFailureTime = DateTime.now();
  }

  void _markMLSuccess() {
    _mlServiceAvailable = true;
    _lastFailureTime = null;
  }
}