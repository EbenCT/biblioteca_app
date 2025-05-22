// lib/presentation/routes/app_routes.dart

import 'package:flutter/material.dart';
import '../pages/splash_page.dart';
import '../pages/auth/login_page.dart';
import '../pages/auth/register_page.dart';
import '../pages/auth/forgot_password_page.dart';
import '../pages/home/home_page.dart';
import '../pages/home/search_page.dart';
import '../pages/home/loans_page.dart';
import '../pages/home/reservations_page.dart';
import '../pages/home/chat_page.dart';
import '../pages/home/profile_page.dart';
import '../pages/home/book_detail_page.dart';
import '../pages/home/loan_detail_page.dart';

// Rutas de la aplicación
final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const SplashPage(),
  '/login': (context) => const LoginPage(),
  '/register': (context) => const RegisterPage(),
  '/forgot-password': (context) => const ForgotPasswordPage(),
  '/home': (context) => const HomePage(),
  '/search': (context) => const SearchPage(),
  '/loans': (context) => const LoansPage(),  // Agregada
  '/reservations': (context) => const ReservationsPage(),  // Agregada
  '/chat': (context) => const ChatPage(),  // Agregada
  '/profile': (context) => const ProfilePage(),  // Agregada
};

// Para rutas que necesitan parámetros
Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/book-detail':
      final String bookId = (settings.arguments as Map<String, dynamic>)['bookId'];
      return MaterialPageRoute(
        builder: (context) => BookDetailPage(bookId: bookId),
      );
    
    case '/loan-detail':
      final String loanId = (settings.arguments as Map<String, dynamic>)['loanId'];
      return MaterialPageRoute(
        builder: (context) => LoanDetailPage(loanId: loanId),
      );
    
    default:
      return null;
  }
}