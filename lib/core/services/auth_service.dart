import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/graphql_config.dart';

class AuthService {
  static AuthService? _instance;
  AuthService._internal();
  
  static AuthService get instance {
    _instance ??= AuthService._internal();
    return _instance!;
  }

  // Endpoints de autenticación REST
  String get _baseUrl => 'http://${GraphQLConfig.laptopIp}:${GraphQLConfig.port}';
  String get _signInEndpoint => '$_baseUrl/auth/signin';
  String get _signUpEndpoint => '$_baseUrl/auth/signup';

  Future<AuthResponse> signIn(String email, String password) async {
    try {
      print('🔐 Attempting login to: $_signInEndpoint');
      print('📧 Email: $email');
      
      final response = await http.post(
        Uri.parse(_signInEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      print('📡 Login response status: ${response.statusCode}');
      print('📄 Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        print('✅ Login successful');
        return AuthResponse.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMessage = errorData['message'] ?? 'Error en el login';
        print('❌ Login failed: $errorMessage');
        throw AuthException(errorMessage);
      }
    } catch (e) {
      print('❌ Login exception: $e');
      if (e is AuthException) rethrow;
      throw AuthException('Error de conexión. Verifica tu conexión a internet.');
    }
  }

  Future<AuthResponse> signUp(String name, String email, String password) async {
    try {
      print('📝 Attempting signup to: $_signUpEndpoint');
      
      final response = await http.post(
        Uri.parse(_signUpEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      print('📡 Signup response status: ${response.statusCode}');
      print('📄 Signup response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        print('✅ Signup successful');
        return AuthResponse.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMessage = errorData['message'] ?? 'Error en el registro';
        print('❌ Signup failed: $errorMessage');
        throw AuthException(errorMessage);
      }
    } catch (e) {
      print('❌ Signup exception: $e');
      if (e is AuthException) rethrow;
      throw AuthException('Error de conexión. Verifica tu conexión a internet.');
    }
  }

  Future<bool> validateToken(String token) async {
    try {
      // Podríamos hacer una llamada a un endpoint de validación
      // Por ahora, verificamos que el token no esté vacío y tenga formato JWT
      if (token.isEmpty) return false;
      
      final parts = token.split('.');
      if (parts.length != 3) return false;
      
      // Verificar que no haya expirado (opcional)
      // final payload = jsonDecode(utf8.decode(base64Decode(parts[1])));
      // final exp = payload['exp'];
      // return DateTime.fromMillisecondsSinceEpoch(exp * 1000).isAfter(DateTime.now());
      
      return true;
    } catch (e) {
      print('❌ Token validation error: $e');
      return false;
    }
  }
}

class AuthResponse {
  final String token;
  final UserData user;

  AuthResponse({
    required this.token,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 Parsing AuthResponse from JSON: $json');
      
      // Extraer token
      final token = json['token'] as String;
      
      // El usuario puede estar en diferentes ubicaciones
      Map<String, dynamic> userJson;
      if (json['user'] != null) {
        userJson = json['user'] as Map<String, dynamic>;
      } else {
        // Si no hay campo 'user', usar el json completo como user data
        userJson = Map<String, dynamic>.from(json);
        // Remover campos que no son del usuario
        userJson.remove('token');
        userJson.remove('type');
      }
      
      print('🔍 User JSON for parsing: $userJson');
      
      final user = UserData.fromJson(userJson);
      
      print('✅ AuthResponse parsed successfully');
      return AuthResponse(
        token: token,
        user: user,
      );
    } catch (e) {
      print('❌ Error parsing AuthResponse: $e');
      print('📄 Raw JSON: $json');
      rethrow;
    }
  }
}

class UserData {
  final String id;
  final String name;
  final String email;
  final String? role;

  UserData({
    required this.id,
    required this.name,
    required this.email,
    this.role,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    // Extraer role de diferentes formatos posibles
    String? role;
    
    if (json['role'] != null) {
      role = json['role'].toString();
    } else if (json['roles'] != null) {
      final roles = json['roles'];
      if (roles is List && roles.isNotEmpty) {
        // Si roles es una lista de objetos con 'authority'
        final firstRole = roles.first;
        if (firstRole is Map<String, dynamic> && firstRole['authority'] != null) {
          role = firstRole['authority'].toString();
        } else {
          // Si roles es una lista de strings
          role = firstRole.toString();
        }
      }
    }
    
    return UserData(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['username'] ?? '',
      email: json['email'] ?? '',
      role: role,
    );
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  
  @override
  String toString() => message;
}