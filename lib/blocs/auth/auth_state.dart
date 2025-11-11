// lib/blocs/auth/auth_state.dart
import '../../models/user.dart';
import '../../models/miembro.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final User user;
  final Miembro? miembro;

  Authenticated({required this.user, this.miembro});
}

class MiembroCreated extends AuthState {
  final Miembro miembro;
  final String message;

  MiembroCreated({required this.miembro, required this.message});
}

class AuthError extends AuthState {
  final String message;

  AuthError({required this.message});
}