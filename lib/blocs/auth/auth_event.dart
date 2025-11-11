// lib/blocs/auth/auth_event.dart
abstract class AuthEvent {}

class CheckAuthEvent extends AuthEvent {}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent({required this.email, required this.password});
}

class RegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String nombre;
  final String apellido;
  final String telefono;

  RegisterEvent({
    required this.email,
    required this.password,
    required this.nombre,
    required this.apellido,
    required this.telefono,
  });
}

class LogoutEvent extends AuthEvent {}

class ClearAuthErrorEvent extends AuthEvent {}