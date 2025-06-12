// ignore_for_file: unused_field

import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/config/graphql_config.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/token_storage_service.dart';
import '../../core/services/graphql_service.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';

class RealAuthRepository implements AuthRepository {
  final AuthService _authService;
  final TokenStorageService _tokenStorage;
  final GraphQLService _graphQLService;

  RealAuthRepository(
    this._authService,
    this._tokenStorage,
    this._graphQLService,
  );

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      print('🔐 Attempting login with: $email');
      
      // Llamar al endpoint REST de autenticación
      final authResponse = await _authService.signIn(email, password);
      
      print('🔍 AuthResponse details:');
      print('   Token length: ${authResponse.token.length}');
      print('   User ID: ${authResponse.user.id}');
      print('   User name: ${authResponse.user.name}');
      print('   User email: ${authResponse.user.email}');
      print('   User role: ${authResponse.user.role}');
      
      // Guardar el token y datos del usuario
      await _tokenStorage.saveToken(authResponse.token);
      await _tokenStorage.saveUserData({
        'id': authResponse.user.id,
        'name': authResponse.user.name,
        'email': authResponse.user.email,
        'role': authResponse.user.role,
      });
      
      print('💾 Token and user data saved successfully');
      
      // Actualizar el cliente GraphQL con el token
      _updateGraphQLClientWithToken(authResponse.token);
      
      // Convertir a entidad del dominio
      final user = User(
        id: authResponse.user.id,
        name: authResponse.user.name,
        email: authResponse.user.email,
        phoneNumber: '', // No disponible en la respuesta de auth
        address: '', // No disponible en la respuesta de auth
        profileImage: _generateProfileImageUrl(authResponse.user.name),
      );
      
      print('✅ Login successful for user: ${user.name}');
      return Right(user);
      
    } on AuthException catch (e) {
      print('❌ Auth error: ${e.message}');
      return Left(AuthFailure(e.message));
    } catch (e) {
      print('❌ Login error: $e');
      print('❌ Error type: ${e.runtimeType}');
      print('❌ Stack trace: ${StackTrace.current}');
      return Left(ServerFailure('Error de conexión con el servidor: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> register(
    String name,
    String email,
    String password,
    String phone,
    String address,
  ) async {
    try {
      print('📝 Attempting registration with: $email');
      
      // Llamar al endpoint REST de registro
      final authResponse = await _authService.signUp(name, email, password);
      
      // Guardar el token y datos del usuario
      await _tokenStorage.saveToken(authResponse.token);
      await _tokenStorage.saveUserData({
        'id': authResponse.user.id,
        'name': authResponse.user.name,
        'email': authResponse.user.email,
        'role': authResponse.user.role,
      });
      
      // Actualizar el cliente GraphQL con el token
      _updateGraphQLClientWithToken(authResponse.token);
      
      // Convertir a entidad del dominio
      final user = User(
        id: authResponse.user.id,
        name: authResponse.user.name,
        email: authResponse.user.email,
        phoneNumber: phone,
        address: address,
        profileImage: _generateProfileImageUrl(authResponse.user.name),
      );
      
      print('✅ Registration successful for user: ${user.name}');
      return Right(user);
      
    } on AuthException catch (e) {
      print('❌ Registration error: ${e.message}');
      return Left(AuthFailure(e.message));
    } catch (e) {
      print('❌ Registration error: $e');
      return Left(ServerFailure('Error de conexión con el servidor'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      print('🚪 Logging out user');
      
      // Limpiar tokens almacenados
      await _tokenStorage.clearAllTokens();
      
      // Reinicializar el cliente GraphQL sin token
      _updateGraphQLClientWithToken(null);
      
      print('✅ Logout successful');
      return const Right(null);
      
    } catch (e) {
      print('❌ Logout error: $e');
      return Left(ServerFailure('Error durante el logout'));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      print('👤 Getting current user');
      
      // Verificar si tenemos un token válido
      final hasValidToken = await _tokenStorage.hasValidToken();
      if (!hasValidToken) {
        print('❌ No valid token found');
        return Left(AuthFailure('No hay sesión activa'));
      }
      
      // Obtener datos del usuario almacenados
      final userData = await _tokenStorage.getUserData();
      if (userData == null) {
        print('❌ No user data found');
        await _tokenStorage.clearAllTokens();
        return Left(AuthFailure('Datos de usuario no encontrados'));
      }
      
      // Obtener el token para el cliente GraphQL
      final token = await _tokenStorage.getToken();
      if (token != null) {
        _updateGraphQLClientWithToken(token);
      }
      
      // Convertir a entidad del dominio
      final user = User(
        id: userData['id']?.toString() ?? '',
        name: userData['name'] ?? '',
        email: userData['email'] ?? '',
        phoneNumber: userData['phone'] ?? '',
        address: userData['address'] ?? '',
        profileImage: _generateProfileImageUrl(userData['name'] ?? ''),
      );
      
      print('✅ Current user retrieved: ${user.name}');
      return Right(user);
      
    } catch (e) {
      print('❌ Get current user error: $e');
      return Left(ServerFailure('Error obteniendo usuario actual'));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile(User user, {String? password}) async {
    try {
      print('📝 Updating profile for user: ${user.name}');
      
      // Por ahora, solo actualizar datos localmente
      // En el futuro, podrías implementar un endpoint REST para actualizar perfil
      await _tokenStorage.saveUserData({
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'phone': user.phoneNumber,
        'address': user.address,
      });
      
      print('✅ Profile updated successfully');
      return Right(user);
      
    } catch (e) {
      print('❌ Update profile error: $e');
      return Left(ServerFailure('Error actualizando perfil'));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    try {
      print('🔑 Forgot password for: $email');
      
      // Por ahora, simular envío exitoso
      // En el futuro, implementar endpoint REST para recuperación de contraseña
      await Future.delayed(const Duration(seconds: 2));
      
      print('✅ Password reset email sent (simulated)');
      return const Right(null);
      
    } catch (e) {
      print('❌ Forgot password error: $e');
      return Left(ServerFailure('Error enviando email de recuperación'));
    }
  }

  void _updateGraphQLClientWithToken(String? token) {
    try {
      // Usar el endpoint correcto de la configuración
      final endpoint = GraphQLEnvironment.endpoint;
      
      print('🔄 Updating GraphQL client with endpoint: $endpoint');
      
      final graphQLService = GraphQLService.instance;
      graphQLService.initialize(
        endpoint: endpoint,
        authToken: token,
      );
      
      print('🔄 GraphQL client updated with auth token');
    } catch (e) {
      print('❌ Error updating GraphQL client: $e');
    }
  }

  String _generateProfileImageUrl(String name) {
    if (name.isEmpty) return '';
    
    // Generar una URL de imagen de perfil usando un servicio de avatares
    final encodedName = Uri.encodeComponent(name);
    return 'https://ui-avatars.com/api/?name=$encodedName&background=0d47a1&color=fff&size=200';
  }

  Future<void> debugAuthState() async {
    print('🔍 AUTH DEBUG STATE:');
    await _tokenStorage.debugTokenInfo();
    
    final currentUserResult = await getCurrentUser();
    currentUserResult.fold(
      (failure) => print('Current user error: ${failure.toString()}'),
      (user) => print('Current user: ${user.name} (${user.email})'),
    );
  }
}