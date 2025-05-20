// lib/di/injection_container.dart (modificado)

import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../core/theme/app_theme.dart';
import '../data/repositories/repositories_impl.dart';
import '../domain/repositories/repositories.dart';
import '../presentation/bloc/auth/auth_bloc.dart';
import '../presentation/bloc/book/book_bloc.dart';
import '../presentation/bloc/loan/loan_bloc.dart';
import '../presentation/bloc/reservation/reservation_bloc.dart';
import '../presentation/bloc/notification/notification_bloc.dart';
import '../presentation/bloc/chat/chat_bloc.dart';
import '../core/services/dialogflow_service.dart';
import '../core/services/speech_service.dart';
import '../core/services/tts_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features - Auth
  sl.registerFactory(
    () => AuthBloc(
      authRepository: sl(),
    ),
  );

  // Features - Book
  sl.registerFactory(
    () => BookBloc(
      bookRepository: sl(),
    ),
  );

  // Features - Loan
  sl.registerFactory(
    () => LoanBloc(
      loanRepository: sl(),
    ),
  );

  // Features - Reservation
  sl.registerFactory(
    () => ReservationBloc(
      reservationRepository: sl(),
    ),
  );

  // Features - Notification
  sl.registerFactory(
    () => NotificationBloc(
      notificationRepository: sl(),
    ),
  );

  // Features - Chat
  sl.registerFactory(
    () => ChatBloc(
      chatRepository: sl(),
    ),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(),
  );

  sl.registerLazySingleton<BookRepository>(
    () => BookRepositoryImpl(),
  );

  sl.registerLazySingleton<LoanRepository>(
    () => LoanRepositoryImpl(),
  );

  sl.registerLazySingleton<ReservationRepository>(
    () => ReservationRepositoryImpl(),
  );

  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(),
  );

  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(),
  );

  // Services
  sl.registerLazySingleton(() => DialogflowService());
  sl.registerLazySingleton(() => SpeechService());
  sl.registerLazySingleton(() => TTSService());

  // Core
  sl.registerLazySingleton(() => InternetConnectionChecker.createInstance());
  sl.registerLazySingleton(() => ThemeProvider());
}