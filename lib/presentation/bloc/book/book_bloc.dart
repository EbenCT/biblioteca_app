// lib/presentation/bloc/book/book_bloc.dart (ACTUALIZADO)

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/entities.dart';
import '../../../domain/repositories/repositories.dart';
import '../../../data/repositories/recommendations_repository.dart';

// Events
abstract class BookEvent extends Equatable {
  const BookEvent();

  @override
  List<Object?> get props => [];
}

class GetBooksEvent extends BookEvent {
  final String? query;
  final String? category;
  final String? author;
  final String? type;

  const GetBooksEvent({
    this.query,
    this.category,
    this.author,
    this.type,
  });

  @override
  List<Object?> get props => [query, category, author, type];
}

class GetBookByIdEvent extends BookEvent {
  final String id;

  const GetBookByIdEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class GetRecommendedBooksEvent extends BookEvent {}

// NUEVO: Event para recomendaciones ML
class GetMLRecommendationsEvent extends BookEvent {
  final String userId;
  final int limit;

  const GetMLRecommendationsEvent({
    required this.userId,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [userId, limit];
}

class GetBookReviewsEvent extends BookEvent {
  final String bookId;

  const GetBookReviewsEvent(this.bookId);

  @override
  List<Object?> get props => [bookId];
}

class AddBookReviewEvent extends BookEvent {
  final String bookId;
  final double rating;
  final String comment;

  const AddBookReviewEvent({
    required this.bookId,
    required this.rating,
    required this.comment,
  });

  @override
  List<Object?> get props => [bookId, rating, comment];
}

class UpdateBookReviewEvent extends BookEvent {
  final String reviewId;
  final double rating;
  final String comment;

  const UpdateBookReviewEvent({
    required this.reviewId,
    required this.rating,
    required this.comment,
  });

  @override
  List<Object?> get props => [reviewId, rating, comment];
}

class DeleteBookReviewEvent extends BookEvent {
  final String reviewId;

  const DeleteBookReviewEvent(this.reviewId);

  @override
  List<Object?> get props => [reviewId];
}

class VoteReviewHelpfulEvent extends BookEvent {
  final String reviewId;
  final bool isHelpful;

  const VoteReviewHelpfulEvent({
    required this.reviewId,
    required this.isHelpful,
  });

  @override
  List<Object?> get props => [reviewId, isHelpful];
}

// States
abstract class BookState extends Equatable {
  const BookState();

  @override
  List<Object?> get props => [];
}

class BookInitial extends BookState {}

class BookLoading extends BookState {}

class BooksLoaded extends BookState {
  final List<Book> books;

  const BooksLoaded(this.books);

  @override
  List<Object?> get props => [books];
}

class BookDetailsLoaded extends BookState {
  final Book book;

  const BookDetailsLoaded(this.book);

  @override
  List<Object?> get props => [book];
}

class RecommendedBooksLoaded extends BookState {
  final List<Book> books;

  const RecommendedBooksLoaded(this.books);

  @override
  List<Object?> get props => [books];
}

// NUEVO: State para recomendaciones ML
class MLRecommendationsLoaded extends BookState {
  final List<Book> books;
  final bool isFromML;
  final String? message;

  const MLRecommendationsLoaded(
    this.books, {
    this.isFromML = true,
    this.message,
  });

  @override
  List<Object?> get props => [books, isFromML, message];
}

class BookReviewsLoaded extends BookState {
  final List<Review> reviews;

  const BookReviewsLoaded(this.reviews);

  @override
  List<Object?> get props => [reviews];
}

class ReviewAdded extends BookState {
  final Review review;

  const ReviewAdded(this.review);

  @override
  List<Object?> get props => [review];
}

class ReviewUpdated extends BookState {}

class ReviewDeleted extends BookState {}

class ReviewVoted extends BookState {}

class BookError extends BookState {
  final String message;

  const BookError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class BookBloc extends Bloc<BookEvent, BookState> {
  final BookRepository bookRepository;
  final RecommendationsRepository recommendationsRepository; // NUEVO

  BookBloc({
    required this.bookRepository,
    required this.recommendationsRepository, // NUEVO
  }) : super(BookInitial()) {
    on<GetBooksEvent>(_onGetBooks);
    on<GetBookByIdEvent>(_onGetBookById);
    on<GetRecommendedBooksEvent>(_onGetRecommendedBooks);
    on<GetMLRecommendationsEvent>(_onGetMLRecommendations); // NUEVO
    on<GetBookReviewsEvent>(_onGetBookReviews);
    on<AddBookReviewEvent>(_onAddBookReview);
    on<UpdateBookReviewEvent>(_onUpdateBookReview);
    on<DeleteBookReviewEvent>(_onDeleteBookReview);
    on<VoteReviewHelpfulEvent>(_onVoteReviewHelpful);
  }

  Future<void> _onGetBooks(GetBooksEvent event, Emitter<BookState> emit) async {
    emit(BookLoading());
    final result = await bookRepository.getBooks(
      query: event.query,
      category: event.category,
      author: event.author,
      type: event.type,
    );
    result.fold(
      (failure) => emit(BookError(failure.toString())),
      (books) => emit(BooksLoaded(books)),
    );
  }

  Future<void> _onGetBookById(GetBookByIdEvent event, Emitter<BookState> emit) async {
    emit(BookLoading());
    final result = await bookRepository.getBookById(event.id);
    result.fold(
      (failure) => emit(BookError(failure.toString())),
      (book) => emit(BookDetailsLoaded(book)),
    );
  }

  Future<void> _onGetRecommendedBooks(GetRecommendedBooksEvent event, Emitter<BookState> emit) async {
    emit(BookLoading());
    final result = await bookRepository.getRecommendedBooks();
    result.fold(
      (failure) => emit(BookError(failure.toString())),
      (books) => emit(RecommendedBooksLoaded(books)),
    );
  }

  // NUEVO: Manejar recomendaciones ML
  Future<void> _onGetMLRecommendations(GetMLRecommendationsEvent event, Emitter<BookState> emit) async {
    emit(BookLoading());
    
    try {
      print('🤖 Requesting ML recommendations for user: ${event.userId}');
      
      final result = await recommendationsRepository.getRecommendations(
        event.userId,
        limit: event.limit,
      );
      
      result.fold(
        (failure) {
          print('❌ ML recommendations failed: ${failure.message}');
          emit(BookError('No se pudieron cargar las recomendaciones: ${failure.message}'));
        },
        (books) {
          print('✅ ML recommendations loaded: ${books.length} books');
          
          // Determinar si son recomendaciones reales de ML o fallback
          final isFromML = books.isNotEmpty && 
                          books.first.description.contains('inteligencia artificial');
          
          final message = isFromML 
              ? 'Recomendaciones personalizadas generadas por IA'
              : 'Recomendaciones basadas en popularidad general';
          
          emit(MLRecommendationsLoaded(
            books,
            isFromML: isFromML,
            message: message,
          ));
        },
      );
    } catch (e) {
      print('❌ Error in ML recommendations: $e');
      emit(BookError('Error al obtener recomendaciones: $e'));
    }
  }

  Future<void> _onGetBookReviews(GetBookReviewsEvent event, Emitter<BookState> emit) async {
    emit(BookLoading());
    final result = await bookRepository.getBookReviews(event.bookId);
    result.fold(
      (failure) => emit(BookError(failure.toString())),
      (reviews) => emit(BookReviewsLoaded(reviews)),
    );
  }

  Future<void> _onAddBookReview(AddBookReviewEvent event, Emitter<BookState> emit) async {
    emit(BookLoading());
    final result = await bookRepository.addBookReview(
      event.bookId,
      event.rating,
      event.comment,
    );
    result.fold(
      (failure) => emit(BookError(failure.toString())),
      (review) => emit(ReviewAdded(review)),
    );
  }

  Future<void> _onUpdateBookReview(UpdateBookReviewEvent event, Emitter<BookState> emit) async {
    emit(BookLoading());
    final result = await bookRepository.updateBookReview(
      event.reviewId,
      event.rating,
      event.comment,
    );
    result.fold(
      (failure) => emit(BookError(failure.toString())),
      (_) => emit(ReviewUpdated()),
    );
  }

  Future<void> _onDeleteBookReview(DeleteBookReviewEvent event, Emitter<BookState> emit) async {
    emit(BookLoading());
    final result = await bookRepository.deleteBookReview(event.reviewId);
    result.fold(
      (failure) => emit(BookError(failure.toString())),
      (_) => emit(ReviewDeleted()),
    );
  }

  Future<void> _onVoteReviewHelpful(VoteReviewHelpfulEvent event, Emitter<BookState> emit) async {
    emit(BookLoading());
    final result = await bookRepository.voteReviewHelpful(
      event.reviewId,
      event.isHelpful,
    );
    result.fold(
      (failure) => emit(BookError(failure.toString())),
      (_) => emit(ReviewVoted()),
    );
  }

  // NUEVO: Método auxiliar para verificar estado del servicio ML
  Future<String> getMLServiceStatus() async {
    final result = await recommendationsRepository.getHealthStatus();
    return result.fold(
      (failure) => 'No disponible: ${failure.message}',
      (status) => status,
    );
  }
}