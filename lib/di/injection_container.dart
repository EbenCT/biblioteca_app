// lib/di/injection_container.dart (final with real authentication)

import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../core/services/local_notification_service.dart';
import '../core/controllers/notification_controller.dart';
import '../core/services/dialogflow_service.dart';
import '../core/theme/app_theme.dart';
import '../core/config/graphql_config.dart';
import '../core/services/graphql_service.dart';
import '../core/services/auth_service.dart';
import '../core/services/token_storage_service.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/hybrid_loan_repository.dart';
import '../data/repositories/repositories_impl.dart';
import '../data/repositories/graphql_ejemplar_repository.dart';
import '../data/repositories/graphql_loan_repository.dart';
import '../data/repositories/graphql_reservation_repository.dart';
import '../data/repositories/hybrid_reservation_repository.dart';
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
  // Initialize Core Services first
  await _initCoreServices();
  
  // Initialize GraphQL Service
  await _initGraphQL();
  
  // Features - Auth (with real authentication)
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

  // Repositories - Real authentication
  sl.registerLazySingleton<AuthRepository>(
    () => RealAuthRepository(
      sl<AuthService>(),
      sl<TokenStorageService>(),
      sl<GraphQLService>(),
    ),
  );

  // Repositories - GraphQL implementations
  sl.registerLazySingleton<BookRepository>(
    () => GraphQLEjemplarRepository(sl<GraphQLService>()),
  );

sl.registerLazySingleton<LoanRepository>(
  () => HybridLoanRepository(
    GraphQLLoanRepository(sl<GraphQLService>()),
    LoanRepositoryImpl(),
  ),
);

// Hybrid repository for reservations (GraphQL + Cache + Mock fallback)
sl.registerLazySingleton<ReservationRepository>(
  () => HybridReservationRepository(
    GraphQLReservationRepository(sl<GraphQLService>()),
    ReservationRepositoryImpl(),
    sl<BookRepository>(), // Necesita acceso al repositorio de libros
  ),
);

  // Repositories - Mock implementations for features not fully implemented
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(),
  );

sl.registerLazySingleton<ChatRepository>(
  () => ChatRepositoryImplWithFallback(
    GraphQLChatRepositoryImpl(sl<GraphQLService>()),
    ChatRepositoryImpl(),
  ),
);

  // Voice Services
  sl.registerLazySingleton(() => SimpleDialogflowService());
  sl.registerLazySingleton(() => SpeechService());
  sl.registerLazySingleton(() => TTSService());

  // Core
  sl.registerLazySingleton(() => InternetConnectionChecker.createInstance());
  sl.registerLazySingleton(() => ThemeProvider());

  sl.registerLazySingleton(() => LocalNotificationService.instance);
  sl.registerLazySingleton(() => NotificationController.instance);

  print('✅ Dependency injection completed successfully');
  
  print('✅ Dependency injection completed successfully');
}

Future<void> _initCoreServices() async {
  try {
    // Auth Service
    sl.registerLazySingleton<AuthService>(() => AuthService.instance);
    
    // Token Storage Service
    sl.registerLazySingleton<TokenStorageService>(() => TokenStorageService.instance);
    
    print('✅ Core services initialized');
  } catch (e) {
    print('❌ Error initializing core services: $e');
    rethrow;
  }
}

Future<void> _initGraphQL() async {
  // Initialize GraphQL service
  final graphQLService = GraphQLService.instance;
  
  // Print connection information for debugging
  GraphQLConfig.printConnectionInfo();
  
  try {
    // Use the automatically detected endpoint
    final endpoint = GraphQLEnvironment.endpoint;
    
    print('🔄 Attempting to connect to GraphQL endpoint: $endpoint');
    
    // Check if we have a stored token
    final tokenStorage = TokenStorageService.instance;
    final storedToken = await tokenStorage.getToken();
    
    if (storedToken != null && await tokenStorage.hasValidToken()) {
      print('🔑 Found stored auth token, initializing with authentication');
      graphQLService.initialize(
        endpoint: endpoint,
        authToken: storedToken,
      );
    } else {
      print('🔓 No valid stored token, initializing without authentication');
      graphQLService.initialize(
        endpoint: endpoint,
        authToken: null,
      );
    }
    
    sl.registerLazySingleton<GraphQLService>(() => graphQLService);
    print('✅ GraphQL Service initialized successfully');
    print('📡 Ready to make GraphQL queries to: $endpoint');
    
  } catch (e) {
    print('❌ Error initializing GraphQL Service: $e');
    print('🔧 Troubleshooting steps:');
    print('   1. Verify your backend is running on ${GraphQLConfig.laptopIp}:${GraphQLConfig.port}');
    print('   2. Check if port ${GraphQLConfig.port} is accessible from your device');
    print('   3. Ensure both devices are on the same WiFi network');
    print('   4. Try accessing http://${GraphQLConfig.laptopIp}:${GraphQLConfig.port}/graphql from your phone browser');
    
    // Still register the service even if initialization fails
    // This prevents dependency injection errors
    sl.registerLazySingleton<GraphQLService>(() => graphQLService);
    
    // Don't rethrow the error, let the app continue with fallback repositories
    print('🔄 App will continue with fallback repositories when GraphQL fails');
  }
}