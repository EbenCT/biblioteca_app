// lib/data/models/recommendations_models.dart
// Extension para convertir RecommendationBook a Book entity
import '../../domain/entities/entities.dart';

class RecommendationBook {
  final String bookId;
  final String title;
  final double score;

  RecommendationBook({
    required this.bookId,
    required this.title,
    required this.score,
  });

  factory RecommendationBook.fromJson(Map<String, dynamic> json) {
    return RecommendationBook(
      bookId: json['book_id'] as String,
      title: json['title'] as String,
      score: (json['score'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'book_id': bookId,
      'title': title,
      'score': score,
    };
  }

  @override
  String toString() {
    return 'RecommendationBook(bookId: $bookId, title: $title, score: $score)';
  }
}

class RecommendationResponse {
  final String userId;
  final List<RecommendationBook> recommendations;
  final int totalRecommendations;
  final String? message;

  RecommendationResponse({
    required this.userId,
    required this.recommendations,
    required this.totalRecommendations,
    this.message,
  });

  factory RecommendationResponse.fromJson(Map<String, dynamic> json) {
    return RecommendationResponse(
      userId: json['user_id'] as String,
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((item) => RecommendationBook.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalRecommendations: json['total_recommendations'] as int,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'recommendations': recommendations.map((r) => r.toJson()).toList(),
      'total_recommendations': totalRecommendations,
      'message': message,
    };
  }

  @override
  String toString() {
    return 'RecommendationResponse(userId: $userId, total: $totalRecommendations, message: $message)';
  }
}

extension RecommendationBookToBook on RecommendationBook {
  Book toBook({
    String? imageUrl,
    List<String>? authors,
    String? publisher,
    String? publishYear,
    String? category,
    String? type,
    double? rating,
    int? ratingCount,
    bool? isAvailable,
    String? description,
  }) {
    return Book(
      id: bookId,
      title: title,
      authors: authors ?? ['Autor desconocido'],
      publisher: publisher ?? 'Editorial desconocida',
      publishYear: publishYear ?? '2023',
      category: category ?? 'Recomendación',
      type: type ?? 'Físico',
      imageUrl: imageUrl ?? _generateImageUrl(title),
      rating: rating ?? _scoreToRating(score),
      ratingCount: ratingCount ?? 0,
      isAvailable: isAvailable ?? true,
      description: description ?? _generateDescription(title, score),
    );
  }

  // Convertir score de recomendación (0.0-1.0) a rating (1.0-5.0)
  double _scoreToRating(double score) {
    return 1.0 + (score * 4.0); // Mapea 0.0-1.0 a 1.0-5.0
  }

  String _generateImageUrl(String title) {
    // Generar URL de imagen placeholder
    return 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400&h=600&fit=crop&q=80';
  }

  String _generateDescription(String title, double score) {
    final percentage = (score * 100).toInt();
    return 'Libro recomendado especialmente para ti con un ${percentage}% de compatibilidad basado en tus preferencias de lectura. "$title" forma parte de nuestras recomendaciones personalizadas generadas por inteligencia artificial.';
  }
}