import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorageService {
  static TokenStorageService? _instance;
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _refreshTokenKey = 'refresh_token';

  TokenStorageService._internal();

  static TokenStorageService get instance {
    _instance ??= TokenStorageService._internal();
    return _instance!;
  }

  Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      print('💾 Token saved successfully');
    } catch (e) {
      print('❌ Error saving token: $e');
      throw Exception('Failed to save token');
    }
  }

  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      print('🔑 Token retrieved: ${token != null ? 'Found' : 'Not found'}');
      return token;
    } catch (e) {
      print('❌ Error getting token: $e');
      return null;
    }
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(userData));
      print('💾 User data saved successfully');
    } catch (e) {
      print('❌ Error saving user data: $e');
      throw Exception('Failed to save user data');
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(_userKey);
      if (userDataString != null) {
        final userData = jsonDecode(userDataString) as Map<String, dynamic>;
        print('👤 User data retrieved successfully');
        return userData;
      }
      print('👤 No user data found');
      return null;
    } catch (e) {
      print('❌ Error getting user data: $e');
      return null;
    }
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_refreshTokenKey, refreshToken);
      print('💾 Refresh token saved successfully');
    } catch (e) {
      print('❌ Error saving refresh token: $e');
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_refreshTokenKey);
    } catch (e) {
      print('❌ Error getting refresh token: $e');
      return null;
    }
  }

  Future<void> clearAllTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      await prefs.remove(_refreshTokenKey);
      print('🗑️ All tokens cleared successfully');
    } catch (e) {
      print('❌ Error clearing tokens: $e');
      throw Exception('Failed to clear tokens');
    }
  }

  Future<bool> hasValidToken() async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return false;
      }

      // Verificar formato JWT básico
      final parts = token.split('.');
      if (parts.length != 3) {
        print('⚠️ Invalid token format');
        return false;
      }

      // Opcional: verificar expiración
      try {
        final payload = jsonDecode(
          utf8.decode(base64Decode(_addPadding(parts[1]))),
        ) as Map<String, dynamic>;
        
        final exp = payload['exp'];
        if (exp != null) {
          final expirationDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
          final isExpired = expirationDate.isBefore(DateTime.now());
          
          if (isExpired) {
            print('⚠️ Token is expired');
            await clearAllTokens();
            return false;
          }
        }
      } catch (e) {
        print('⚠️ Error verifying token expiration: $e');
        // Si no podemos verificar la expiración, asumimos que es válido
      }

      return true;
    } catch (e) {
      print('❌ Error checking token validity: $e');
      return false;
    }
  }

  String _addPadding(String base64String) {
    // Agregar padding si es necesario para decodificación base64
    final padding = 4 - (base64String.length % 4);
    if (padding != 4) {
      base64String += '=' * padding;
    }
    return base64String;
  }

  Future<void> debugTokenInfo() async {
    try {
      final token = await getToken();
      final userData = await getUserData();
      
      print('🔍 TOKEN DEBUG INFO:');
      print('Has token: ${token != null}');
      print('Token length: ${token?.length ?? 0}');
      print('Has user data: ${userData != null}');
      print('User email: ${userData?['email'] ?? 'N/A'}');
      
      if (token != null) {
        final isValid = await hasValidToken();
        print('Token is valid: $isValid');
      }
    } catch (e) {
      print('❌ Error in debug token info: $e');
    }
  }
}