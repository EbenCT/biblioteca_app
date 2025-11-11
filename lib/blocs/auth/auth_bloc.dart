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
      
      final userData = result['user'];
      final user = User(
        id: userData['id'] ?? '',
        username: userData['email'] ?? '',
        email: userData['email'] ?? '',
        role: 'USER',
      );
      
      // Obtener datos del miembro usando el userId
      Miembro? miembro;
      try {
        miembro = await GraphQLService.getMiembroPorUserId(user.id);
        print('✅ Miembro obtenido: ${miembro?.id} - ${miembro?.nombre}');
      } catch (e) {
        print('❌ Error obteniendo miembro: $e');
      }
      
      emit(Authenticated(user: user, miembro: miembro));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  void _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      // Crear miembro (esto crea automáticamente el usuario y devuelve token)
      final miembroData = {
        'nombre': event.nombre,
        'apellido': event.apellido,
        'direccion': 'Sin especificar',
        'telefono': event.telefono,
        'fechaRegistro': DateTime.now().toIso8601String(),
        'email': event.email,
        'password': event.password,
      };

      final result = await GraphQLService.createMiembro(miembroData);
      
      // Crear objeto User con la respuesta
      final userData = result['user'];
      final user = User(
        id: userData['id'] ?? '',
        username: userData['email'] ?? '',
        email: userData['email'] ?? '',
        role: 'USER',
      );

      // Obtener el miembro real del backend usando el userId
      Miembro? miembro;
      try {
        miembro = await GraphQLService.getMiembroPorUserId(user.id);
        print('✅ Miembro registrado y obtenido: ${miembro?.id} - ${miembro?.nombre}');
      } catch (e) {
        print('❌ Error obteniendo miembro después del registro: $e');
        // Fallback: crear miembro temporal con los datos locales
        miembro = Miembro(
          id: user.id,
          nombre: event.nombre,
          apellido: event.apellido,
          direccion: miembroData['direccion'] ?? '',
          telefono: event.telefono,
          fechaRegistro: DateTime.now().toIso8601String(),
        );
      }

      // Emitir estado autenticado (login automático)
      emit(Authenticated(user: user, miembro: miembro));
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