import 'package:dartz/dartz.dart';
import '../../core/services/graphql_service.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';
import '../mock_data.dart';
import '../../core/errors/failures.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      // Check if credentials match the mock user
      if (email == 'michel.cardenas@uagrm.edu.bo' && password == '123456') {
        return Right(MockData.currentUser);
      } else {
        return Left(AuthFailure('Credenciales incorrectas'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> register(
    String name,
    String email,
    String password,
    String phone,
    String address,
  ) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      // Assume registration is successful and return the user
      final user = User(
        id: 'new_user_id',
        name: name,
        email: email,
        phoneNumber: phone,
        address: address,
      );
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      return Right(MockData.currentUser);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile(User user, {String? password}) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      // Return the updated user
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

class BookRepositoryImpl implements BookRepository {
  @override
  Future<Either<Failure, List<Book>>> getBooks({
    String? query,
    String? category,
    String? author,
    String? type,
  }) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      var filteredBooks = MockData.books;

      // Apply filters
      if (query != null && query.isNotEmpty) {
        final lowerCaseQuery = query.toLowerCase();
        filteredBooks = filteredBooks.where((book) {
          return book.title.toLowerCase().contains(lowerCaseQuery) ||
              book.authors.any((author) => author.toLowerCase().contains(lowerCaseQuery));
        }).toList();
      }

      if (category != null && category.isNotEmpty) {
        filteredBooks = filteredBooks.where((book) => book.category == category).toList();
      }

      if (author != null && author.isNotEmpty) {
        filteredBooks = filteredBooks.where((book) {
          return book.authors.any((a) => a.toLowerCase().contains(author.toLowerCase()));
        }).toList();
      }

      if (type != null && type.isNotEmpty) {
        filteredBooks = filteredBooks.where((book) => book.type == type).toList();
      }

      return Right(filteredBooks);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Book>> getBookById(String id) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final book = MockData.books.firstWhere(
        (book) => book.id == id,
        orElse: () => throw Exception('Libro no encontrado'),
      );

      return Right(book);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Book>>> getRecommendedBooks() async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      return Right(MockData.recommendedBooks);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Review>>> getBookReviews(String bookId) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final reviews = MockData.reviews.where((review) => review.bookId == bookId).toList();
      return Right(reviews);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Review>> addBookReview(
    String bookId,
    double rating,
    String comment,
  ) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final newReview = Review(
        id: 'new_review_id',
        userId: MockData.currentUser.id,
        userName: MockData.currentUser.name,
        bookId: bookId,
        rating: rating,
        comment: comment,
        date: DateTime.now(),
        helpfulVotes: 0,
        isSystemGenerated: false,
      );

      return Right(newReview);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateBookReview(
    String reviewId,
    double rating,
    String comment,
  ) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBookReview(String reviewId) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> voteReviewHelpful(String reviewId, bool isHelpful) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

class LoanRepositoryImpl implements LoanRepository {
  @override
  Future<Either<Failure, List<Loan>>> getLoans({bool? isActive}) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // USAR LOS NUEVOS DATOS MOCK que incluyen el préstamo por vencer
      if (isActive == true) {
        // Solo préstamos activos (no devueltos)
        return Right(MockData.loans.where((loan) => !loan.isReturned).toList());
      } else if (isActive == false) {
        // Solo historial (devueltos)
        return Right(MockData.loanHistory);
      } else {
        // Todos los préstamos
        return Right([...MockData.loans, ...MockData.loanHistory]);
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Loan>> getLoanById(String id) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Buscar en todos los préstamos (activos + historial)
      final allLoans = [...MockData.loans, ...MockData.loanHistory];
      final loan = allLoans.firstWhere(
        (loan) => loan.id == id,
        orElse: () => throw Exception('Préstamo no encontrado'),
      );

      return Right(loan);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Loan>>> getLoanHistory() async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      return Right(MockData.loanHistory);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getPenalty(String loanId) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final allLoans = [...MockData.loans, ...MockData.loanHistory];
      final loan = allLoans.firstWhere(
        (loan) => loan.id == loanId,
        orElse: () => throw Exception('Préstamo no encontrado'),
      );

      return Right(loan.penalty ?? 0.0);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
class ReservationRepositoryImpl implements ReservationRepository {
  @override
  Future<Either<Failure, List<Reservation>>> getReservations({bool? isActive}) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      if (isActive == true) {
        return Right(
          MockData.reservations.where((res) => res.status == 'active').toList(),
        );
      } else {
        return Right(MockData.reservations);
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Reservation>> getReservationById(String id) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final reservation = MockData.reservations.firstWhere(
        (res) => res.id == id,
        orElse: () => throw Exception('Reserva no encontrada'),
      );

      return Right(reservation);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Reservation>> createReservation(String bookId) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final book = MockData.books.firstWhere(
        (book) => book.id == bookId,
        orElse: () => throw Exception('Libro no encontrado'),
      );

      final newReservation = Reservation(
        id: 'new_reservation_id',
        bookId: bookId,
        bookTitle: book.title,
        bookImageUrl: book.imageUrl,
        reservationDate: DateTime.now(),
        expirationDate: DateTime.now().add(const Duration(days: 5)),
        status: 'active',
      );

      return Right(newReservation);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelReservation(String id) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

class NotificationRepositoryImpl implements NotificationRepository {
  @override
  Future<Either<Failure, List<AppNotification>>> getNotifications() async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      return Right(MockData.notifications);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markNotificationAsRead(String id) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAllNotificationsAsRead() async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

class ChatRepositoryImpl implements ChatRepository {
  int messageIndex = 0;

  @override
  Future<Either<Failure, String>> sendMessage(String message) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // For demo purposes, cycle through predefined responses
      messageIndex = (messageIndex + 2) % MockData.chatMessages.length;
      final response = MockData.chatMessages[messageIndex];

      return Right(response);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}


class GraphQLChatRepositoryImpl implements ChatRepository {
  final GraphQLService _graphQLService;

  GraphQLChatRepositoryImpl(this._graphQLService);

  @override
  Future<Either<Failure, String>> sendMessage(String message) async {
    try {
      print('🤖 Enviando mensaje a Dialogflow via GraphQL: $message');
      
      const String sendChatMessageMutation = '''
        mutation SendChatMessage(\$input: ChatInput!) {
          sendChatMessage(input: \$input) {
            message
            intent
            action
            confidence
            parameters
            success
          }
        }
      ''';
      
      final result = await _graphQLService.mutate(
        sendChatMessageMutation,
        variables: {
          'input': {
            'message': message,
            'userId': 'mobile_user_${DateTime.now().millisecondsSinceEpoch}',
          },
        },
      );

      if (result.hasException) {
        print('❌ Error en GraphQL Chat: ${result.exception}');
        return Left(ServerFailure(result.exception.toString()));
      }

      final data = result.data;
      if (data == null || data['sendChatMessage'] == null) {
        return Left(ServerFailure('No se recibió respuesta del chat'));
      }

      final chatResponse = data['sendChatMessage'];
      
      // Log de la respuesta completa para debugging
      print('📥 Respuesta de Dialogflow:');
      print('   Mensaje: ${chatResponse['message']}');
      print('   Intent: ${chatResponse['intent']}');
      print('   Acción: ${chatResponse['action']}');
      print('   Confianza: ${chatResponse['confidence']}');
      print('   Éxito: ${chatResponse['success']}');
      
      final responseMessage = chatResponse['message'] as String? ?? 
          'Lo siento, no pude procesar tu solicitud.';
      
      return Right(responseMessage);
      
    } catch (e) {
      print('❌ Error en GraphQL Chat Repository: $e');
      return Left(ServerFailure('Error de conexión con el servidor de chat'));
    }
  }
}

// MODIFICAR la clase ChatRepositoryImpl existente para agregar fallback
class ChatRepositoryImplWithFallback implements ChatRepository {
  final GraphQLChatRepositoryImpl _graphqlRepo;
  final ChatRepositoryImpl _localRepo;
  
  // Control de estado para fallback
  bool _graphqlAvailable = true;
  DateTime? _lastFailureTime;
  static const Duration _retryDelay = Duration(minutes: 2);

  ChatRepositoryImplWithFallback(this._graphqlRepo, this._localRepo);

  @override
  Future<Either<Failure, String>> sendMessage(String message) async {
    // Verificar si debemos intentar GraphQL
    if (!_shouldTryGraphQL()) {
      print('🔄 Usando servicio local (GraphQL no disponible)');
      return _localRepo.sendMessage(message);
    }

    // Intentar GraphQL primero
    final graphqlResult = await _graphqlRepo.sendMessage(message);
    
    return graphqlResult.fold(
      (failure) {
        print('⚠️ GraphQL falló, usando servicio local como fallback');
        _markGraphQLFailure();
        return _localRepo.sendMessage(message);
      },
      (response) {
        print('✅ GraphQL exitoso, respuesta de Dialogflow recibida');
        _markGraphQLSuccess();
        return Right(response);
      },
    );
  }

  bool _shouldTryGraphQL() {
    if (_graphqlAvailable) return true;
    
    if (_lastFailureTime != null) {
      final timeSinceFailure = DateTime.now().difference(_lastFailureTime!);
      if (timeSinceFailure > _retryDelay) {
        print('🔄 Reintentando GraphQL después de ${timeSinceFailure.inMinutes} minutos');
        _graphqlAvailable = true;
        return true;
      }
    }
    
    return false;
  }

  void _markGraphQLFailure() {
    _graphqlAvailable = false;
    _lastFailureTime = DateTime.now();
  }

  void _markGraphQLSuccess() {
    _graphqlAvailable = true;
    _lastFailureTime = null;
  }
}