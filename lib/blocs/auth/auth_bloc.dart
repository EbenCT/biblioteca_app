// lib/blocs/auth/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/graphql_service.dart';
import '../../models/user.dart';
import '../../models/miembro.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<CheckAuthEvent>(_onCheckAuth);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<ClearAuthErrorEvent>(_onClearAuthError);
  }

  void _onCheckAuth(CheckAuthEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        emit(AuthInitial());
        return;
      }

      // Para verificar token, intentamos hacer una query simple
      // Si falla, el token es inválido
      await GraphQLService.query('{ __typename }');
      
      // Token válido - emitir estado autenticado básico
      emit(Authenticated(user: User(id: '1', username: 'user', email: 'user@email.com', role: 'USER')));
    } catch (e) {
      // Token inválido o error de conexión
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      emit(AuthInitial());
    }
  }

  void _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final result = await GraphQLService.login(event.email, event.password);
      
      final user = result['user'] as User;
      
      // Intentar obtener miembro asociado
      Miembro? miembro;
      try {
        miembro = await GraphQLService.getMiembroByUser(user.id);
      } catch (e) {
        // No hay miembro aún, ok continuar
      }

      emit(Authenticated(user: user, miembro: miembro));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  void _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      // Registro de usuario (username = email para simplicidad)
      final userResult = await GraphQLService.register(
        event.nombre, // username
        event.email,
        event.password,
      );
      
      final user = userResult['user'] as User;

      // Crear miembro automáticamente después del registro
      final miembroData = {
        'nombre': event.nombre,
        'apellido': event.apellido,
        'telefono': event.telefono,
        'direccion': 'Sin especificar',
        'usuarioId': user.id,
      };

      final miembro = await GraphQLService.createMiembro(miembroData);

      emit(MiembroCreated(
        miembro: miembro,
        message: 'Cuenta creada exitosamente. Ya puedes usar el código QR.',
      ));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  void _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    try {
      await GraphQLService.logout();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthError(message: 'Error al cerrar sesión'));
    }
  }

  void _onClearAuthError(ClearAuthErrorEvent event, Emitter<AuthState> emit) {
    emit(AuthInitial());
  }
}