import 'package:dartz/dartz.dart';
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

      if (isActive == true) {
        return Right(MockData.loans.where((loan) => !loan.isReturned).toList());
      } else if (isActive == false) {
        return Right(MockData.loanHistory);
      } else {
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

      final loan = [...MockData.loans, ...MockData.loanHistory].firstWhere(
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

      final loan = [...MockData.loans, ...MockData.loanHistory].firstWhere(
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
