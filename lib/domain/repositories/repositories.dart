import 'package:dartz/dartz.dart';
import '../entities/entities.dart';
import '../../core/errors/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, User>> register(String name, String email, String password, String phone, String address);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User>> getCurrentUser();
  Future<Either<Failure, User>> updateProfile(User user, {String? password});
  Future<Either<Failure, void>> forgotPassword(String email);
}

abstract class BookRepository {
  Future<Either<Failure, List<Book>>> getBooks({
    String? query,
    String? category,
    String? author,
    String? type,
  });
  Future<Either<Failure, Book>> getBookById(String id);
  Future<Either<Failure, List<Book>>> getRecommendedBooks();
  Future<Either<Failure, List<Review>>> getBookReviews(String bookId);
  Future<Either<Failure, Review>> addBookReview(String bookId, double rating, String comment);
  Future<Either<Failure, void>> updateBookReview(String reviewId, double rating, String comment);
  Future<Either<Failure, void>> deleteBookReview(String reviewId);
  Future<Either<Failure, void>> voteReviewHelpful(String reviewId, bool isHelpful);
}

abstract class LoanRepository {
  Future<Either<Failure, List<Loan>>> getLoans({bool? isActive});
  Future<Either<Failure, Loan>> getLoanById(String id);
  Future<Either<Failure, List<Loan>>> getLoanHistory();
  Future<Either<Failure, double>> getPenalty(String loanId);
}

abstract class ReservationRepository {
  Future<Either<Failure, List<Reservation>>> getReservations({bool? isActive});
  Future<Either<Failure, Reservation>> getReservationById(String id);
  Future<Either<Failure, Reservation>> createReservation(String bookId);
  Future<Either<Failure, void>> cancelReservation(String id);
}

abstract class NotificationRepository {
  Future<Either<Failure, List<AppNotification>>> getNotifications();
  Future<Either<Failure, void>> markNotificationAsRead(String id);
  Future<Either<Failure, void>> markAllNotificationsAsRead();
}

abstract class ChatRepository {
  Future<Either<Failure, String>> sendMessage(String message);
}
