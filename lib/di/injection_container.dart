// lib/di/injection_container.dart

import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../core/services/local_notification_service.dart';
import '../core/controllers/notification_controller.dart';
import '../core/services/dialogflow_service.dart';
import '../core/theme/app_theme.dart';
import '../core/config/graphql_config.dart';
import '../core/config/recommendations_config.dart';
import '../core/services/graphql_service.dart';
import '../core/services/recommendations_service.dart';
import '../core/services/auth_service.dart';
import '../core/services/token_storage_service.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/hybrid_loan_repository.dart';
import '../data/repositories/repositories_impl.dart';
import '../data/repositories/graphql_ejemplar_repository.dart';
import '../data/repositories/graphql_loan_repository.dart';
import '../data/repositories/graphql_reservation_repository.dart';
import '../data/repositories/hybrid_reservation_repository.dart';
import '../data/repositories/recommendations_repository.dart';
import '../domain/repositories/repositories.dart';
import '../presentation/bloc/auth/auth_bloc.dart';
import '../presentation/bloc/book/book_bloc.dart';
import '../presentation/bloc/loan/loan_bloc.dart';
import '../presentation/bloc/reservation/reservation_bloc.dart';
import '../presentation/bloc/notification/notification_bloc.dart';
import '../presentation/bloc/chat/chat_bloc.dart';
import '../core/services/speech_service.dart';
import '../core/services/tts_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  await _initCoreServices();
  await _initGraphQL();
  await _initRecommendationsService();
  
  _registerBlocs();
  _registerRepositories();
  _registerVoiceServices();
  _registerCoreServices();
}

void _registerBlocs() {
  sl.registerFactory(
    () => AuthBloc(
      authRepository: sl(),
    ),
  );

  sl.registerFactory(
    () => BookBloc(
      bookRepository: sl(),
      recommendationsRepository: sl(),
    ),
  );

  sl.registerFactory(
    () => LoanBloc(
      loanRepository: sl(),
    ),
  );

  sl.registerFactory(
    () => ReservationBloc(
      reservationRepository: sl(),
    ),
  );

  sl.registerFactory(
    () => NotificationBloc(
      notificationRepository: sl(),
    ),
  );

  sl.registerFactory(
    () => ChatBloc(
      chatRepository: sl(),
    ),
  );
}

void _registerRepositories() {
  sl.registerLazySingleton<AuthRepository>(
    () => RealAuthRepository(
      sl<AuthService>(),
      sl<TokenStorageService>(),
      sl<GraphQLService>(),
    ),
  );

  sl.registerLazySingleton<BookRepository>(
    () => GraphQLEjemplarRepository(sl<GraphQLService>()),
  );

  sl.registerLazySingleton<RecommendationsRepository>(
    () => HybridRecommendationsRepository(
      RecommendationsRepositoryImpl(sl<RecommendationsService>()),
    ),
  );

  sl.registerLazySingleton<LoanRepository>(
    () => HybridLoanRepository(
      GraphQLLoanRepository(sl<GraphQLService>()),
      LoanRepositoryImpl(),
    ),
  );

  sl.registerLazySingleton<ReservationRepository>(
    () => HybridReservationRepository(
      GraphQLReservationRepository(sl<GraphQLService>()),
      ReservationRepositoryImpl(),
      sl<BookRepository>(),
    ),
  );

  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(),
  );

  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImplWithFallback(
      GraphQLChatRepositoryImpl(sl<GraphQLService>()),
      ChatRepositoryImpl(),
    ),
  );
}

void _registerVoiceServices() {
  sl.registerLazySingleton(() => SimpleDialogflowService());
  sl.registerLazySingleton(() => SpeechService());
  sl.registerLazySingleton(() => TTSService());
}

void _registerCoreServices() {
  sl.registerLazySingleton(() => InternetConnectionChecker.createInstance());
  sl.registerLazySingleton(() => ThemeProvider());
  sl.registerLazySingleton(() => LocalNotificationService.instance);
  sl.registerLazySingleton(() => NotificationController.instance);
}

Future<void> _initCoreServices() async {
  try {
    sl.registerLazySingleton<AuthService>(() => AuthService.instance);
    sl.registerLazySingleton<TokenStorageService>(() => TokenStorageService.instance);
  } catch (e) {
    rethrow;
  }
}

Future<void> _initGraphQL() async {
  final graphQLService = GraphQLService.instance;
  
  try {
    final endpoint = GraphQLEnvironment.endpoint;
    final tokenStorage = TokenStorageService.instance;
    final storedToken = await tokenStorage.getToken();
    
    if (storedToken != null && await tokenStorage.hasValidToken()) {
      graphQLService.initialize(
        endpoint: endpoint,
        authToken: storedToken,
      );
    } else {
      graphQLService.initialize(
        endpoint: endpoint,
        authToken: null,
      );
    }
    
    sl.registerLazySingleton<GraphQLService>(() => graphQLService);
  } catch (e) {
    sl.registerLazySingleton<GraphQLService>(() => graphQLService);
  }
}

Future<void> _initRecommendationsService() async {
  final recommendationsService = RecommendationsService.instance;
  
  try {
    final endpoint = RecommendationsEnvironment.endpoint;
    recommendationsService.initialize(endpoint: endpoint);
    sl.registerLazySingleton<RecommendationsService>(() => recommendationsService);
    
    try {
      await recommendationsService.getHealthCheck();
    } catch (healthError) {
      // Ignore health check errors
    }
  } catch (e) {
    sl.registerLazySingleton<RecommendationsService>(() => recommendationsService);
  }
}