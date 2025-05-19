// User entity
class User {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String address;
  final String profileImage;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.address,
    this.profileImage = '',
  });
}

// Book entity
class Book {
  final String id;
  final String title;
  final List<String> authors;
  final String publisher;
  final String publishYear;
  final String category;
  final String type;
  final String imageUrl;
  final double rating;
  final int ratingCount;
  final bool isAvailable;
  final String description;

  Book({
    required this.id,
    required this.title,
    required this.authors,
    required this.publisher,
    required this.publishYear,
    required this.category,
    required this.type,
    required this.imageUrl,
    required this.rating,
    required this.ratingCount,
    required this.isAvailable,
    required this.description,
  });
}

// Loan entity
class Loan {
  final String id;
  final String bookId;
  final String bookTitle;
  final String bookImageUrl;
  final DateTime loanDate;
  final DateTime dueDate;
  final bool isReturned;
  final DateTime? returnDate;
  final bool isLate;
  final double? penalty;

  Loan({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.bookImageUrl,
    required this.loanDate,
    required this.dueDate,
    required this.isReturned,
    this.returnDate,
    required this.isLate,
    this.penalty,
  });
}

// Reservation entity
class Reservation {
  final String id;
  final String bookId;
  final String bookTitle;
  final String bookImageUrl;
  final DateTime reservationDate;
  final DateTime expirationDate;
  final String status; // active, expired, completed, cancelled

  Reservation({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.bookImageUrl,
    required this.reservationDate,
    required this.expirationDate,
    required this.status,
  });
}

// Review entity
class Review {
  final String id;
  final String userId;
  final String userName;
  final String bookId;
  final double rating;
  final String comment;
  final DateTime date;
  final int helpfulVotes;
  final bool isSystemGenerated;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.bookId,
    required this.rating,
    required this.comment,
    required this.date,
    required this.helpfulVotes,
    required this.isSystemGenerated,
  });
}

// Notification entity
class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime date;
  final bool isRead;
  final String type; // loan, return, reservation, penalty, etc.

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    required this.isRead,
    required this.type,
  });
}
