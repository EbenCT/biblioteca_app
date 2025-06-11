import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/services/graphql_service.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';
import '../datasources/graphql_queries.dart';
import '../models/graphql_models.dart' as gql_models;

class GraphQLEjemplarRepository implements BookRepository {
  final GraphQLService _graphQLService;

  GraphQLEjemplarRepository(this._graphQLService);

  @override
  Future<Either<Failure, List<Book>>> getBooks({
    String? query,
    String? category,
    String? author,
    String? type,
    int page = 0,
    int size = 10,
  }) async {
    try {
      String graphQLQuery;
      Map<String, dynamic> variables = {'page': page, 'size': size};

      if (query != null && query.isNotEmpty) {
        graphQLQuery = GraphQLQueries.buscarEjemplares;
        variables['nombre'] = query;
      } else {
        graphQLQuery = GraphQLQueries.getEjemplares;
      }

      final result = await _graphQLService.query(graphQLQuery, variables: variables);

      if (result.hasException) {
        return Left(ServerFailure(result.exception.toString()));
      }

      final data = result.data;
      if (data == null) {
        return Left(ServerFailure('No data received'));
      }

      final String queryKey = query != null && query.isNotEmpty ? 'buscarEjemplares' : 'ejemplares';
      final paginatedResult = gql_models.PaginatedResult<gql_models.Ejemplar>.fromJson(
        data[queryKey],
        (json) => gql_models.Ejemplar.fromJson(json),
      );

      // Convertir a entidades del dominio
      final books = paginatedResult.content.map((ejemplar) => _mapEjemplarToBook(ejemplar)).toList();

      // Aplicar filtros adicionales si es necesario
      List<Book> filteredBooks = books;

      if (category != null && category.isNotEmpty) {
        filteredBooks = filteredBooks.where((book) => 
          book.category.toLowerCase().contains(category.toLowerCase())
        ).toList();
      }

      if (author != null && author.isNotEmpty) {
        filteredBooks = filteredBooks.where((book) => 
          book.authors.any((bookAuthor) => 
            bookAuthor.toLowerCase().contains(author.toLowerCase())
          )
        ).toList();
      }

      if (type != null && type.isNotEmpty) {
        filteredBooks = filteredBooks.where((book) => 
          book.type.toLowerCase().contains(type.toLowerCase())
        ).toList();
      }

      return Right(filteredBooks);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Book>> getBookById(String id) async {
    try {
      final result = await _graphQLService.query(
        GraphQLQueries.getEjemplar,
        variables: {'id': id},
      );

      if (result.hasException) {
        return Left(ServerFailure(result.exception.toString()));
      }

      final data = result.data;
      if (data == null || data['ejemplar'] == null) {
        return Left(ServerFailure('Ejemplar not found'));
      }

      final ejemplar = gql_models.Ejemplar.fromJson(data['ejemplar']);
      final book = _mapEjemplarToBook(ejemplar);

      return Right(book);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Book>>> getRecommendedBooks() async {
    try {
      final result = await _graphQLService.query(GraphQLQueries.getEjemplaresDisponibles);

      if (result.hasException) {
        return Left(ServerFailure(result.exception.toString()));
      }

      final data = result.data;
      if (data == null) {
        return Left(ServerFailure('No data received'));
      }

      final ejemplares = (data['ejemplaresDisponibles'] as List)
          .map((json) => gql_models.Ejemplar.fromJson(json))
          .toList();

      // Tomar solo los primeros 5 como recomendados
      final recommendedEjemplares = ejemplares.take(5).toList();
      final books = recommendedEjemplares.map((ejemplar) => _mapEjemplarToBook(ejemplar)).toList();

      return Right(books);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Review>>> getBookReviews(String bookId) async {
    // Por ahora retornamos una lista vacía ya que el schema GraphQL no incluye reviews
    // En el futuro se puede agregar al schema
    return const Right([]);
  }

  @override
  Future<Either<Failure, Review>> addBookReview(
    String bookId,
    double rating,
    String comment,
  ) async {
    // Funcionalidad no disponible en el schema actual
    return Left(ServerFailure('Review functionality not implemented in GraphQL schema'));
  }

  @override
  Future<Either<Failure, void>> updateBookReview(
    String reviewId,
    double rating,
    String comment,
  ) async {
    return Left(ServerFailure('Review functionality not implemented in GraphQL schema'));
  }

  @override
  Future<Either<Failure, void>> deleteBookReview(String reviewId) async {
    return Left(ServerFailure('Review functionality not implemented in GraphQL schema'));
  }

  @override
  Future<Either<Failure, void>> voteReviewHelpful(String reviewId, bool isHelpful) async {
    return Left(ServerFailure('Review functionality not implemented in GraphQL schema'));
  }

  Book _mapEjemplarToBook(gql_models.Ejemplar ejemplar) {
    return Book(
      id: ejemplar.id,
      title: ejemplar.nombre,
      authors: ejemplar.autor != null ? [ejemplar.autor!.nombre] : ['Autor desconocido'],
      publisher: ejemplar.editorial ?? 'Editorial desconocida',
      publishYear: '2023', // No disponible en el schema, usar valor por defecto
      category: ejemplar.tipo?.nombre ?? 'Sin categoría',
      type: ejemplar.tipo?.nombre ?? 'Físico',
      imageUrl: _generateBookImageUrl(ejemplar.nombre), // Generar URL de imagen
      rating: 4.0, // Valor por defecto ya que no hay reviews en el schema
      ratingCount: 0, // Valor por defecto
      isAvailable: ejemplar.stock > 0,
      description: _generateBookDescription(ejemplar.nombre, ejemplar.autor?.nombre), // Generar descripción
    );
  }

  String _generateBookImageUrl(String bookTitle) {
    // Generar una URL de imagen usando un servicio de placeholders
    final encodedTitle = Uri.encodeComponent(bookTitle);
    return 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400&h=600&fit=crop&q=80';
  }

  String _generateBookDescription(String bookTitle, String? authorName) {
    final author = authorName ?? 'un destacado autor';
    return 'Una fascinante obra titulada "$bookTitle" escrita por $author. '
           'Este libro forma parte de nuestra colección y está disponible para préstamo en la biblioteca. '
           'Descubre nuevos conocimientos y disfruta de una experiencia de lectura enriquecedora.';
  }
}