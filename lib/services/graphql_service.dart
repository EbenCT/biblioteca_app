// lib/services/graphql_service.dart
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/models.dart';

class GraphQLService {
  static GraphQLClient? _client;
  static String? _token;

  // Inicializar el cliente GraphQL
  static Future<void> initialize() async {
    try {
      await _loadToken();
      _initializeClient();
      print('✅ GraphQL Service inicializado correctamente');
      print('🌐 Endpoint: ${AppConfig.graphqlEndpoint}');
    } catch (e) {
      print('❌ Error inicializando GraphQL Service: $e');
      // Inicializar con configuración básica
      _initializeClient();
    }
  }

  // Cargar token guardado
  static Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  // Guardar token
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    _token = token;
    _initializeClient(); // Reinicializar cliente con nuevo token
  }

  // Limpiar token
  static Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _token = null;
    _initializeClient(); // Reinicializar cliente sin token
  }

  // Inicializar cliente GraphQL
  static void _initializeClient() {
    final httpLink = HttpLink(AppConfig.graphqlEndpoint);
    
    final authLink = AuthLink(
      getToken: () async => _token != null ? 'Bearer $_token' : null,
    );

    final link = authLink.concat(httpLink);

    _client = GraphQLClient(
      link: link,
      cache: GraphQLCache(store: InMemoryStore()),
    );
  }

  // Ejecutar query
  static Future<QueryResult> query(String queryString, {Map<String, dynamic>? variables}) async {
    if (_client == null) {
      print('❌ GraphQL client no inicializado, reinicializando...');
      await initialize();
      if (_client == null) {
        throw Exception('GraphQL client no inicializado. Verifica la conexión.');
      }
    }

    try {
      final result = await _client!.query(
        QueryOptions(
          document: gql(queryString),
          variables: variables ?? {},
          fetchPolicy: FetchPolicy.noCache,
        ),
      );

      if (result.hasException) {
        print('❌ GraphQL Query Error: ${result.exception.toString()}');
        throw Exception('GraphQL Error: ${result.exception.toString()}');
      }

      return result;
    } catch (e) {
      print('❌ Error ejecutando query: $e');
      rethrow;
    }
  }

  // Ejecutar mutation
  static Future<QueryResult> mutate(String mutationString, {Map<String, dynamic>? variables}) async {
    if (_client == null) {
      print('❌ GraphQL client no inicializado, reinicializando...');
      await initialize();
      if (_client == null) {
        throw Exception('GraphQL client no inicializado. Verifica la conexión.');
      }
    }

    try {
      print('🔄 Ejecutando mutation GraphQL...');
      final result = await _client!.mutate(
        MutationOptions(
          document: gql(mutationString),
          variables: variables ?? {},
          fetchPolicy: FetchPolicy.noCache,
        ),
      );

      if (result.hasException) {
        print('❌ GraphQL Mutation Error: ${result.exception.toString()}');
        throw Exception('GraphQL Error: ${result.exception.toString()}');
      }

      print('✅ Mutation ejecutada exitosamente');
      return result;
    } catch (e) {
      print('❌ Error ejecutando mutation: $e');
      rethrow;
    }
  }

  // ========== AUTENTICACIÓN ==========

  static const String _loginMutation = '''
    mutation Login(\$loginRequest: LoginRequest!) {
      login(loginRequest: \$loginRequest) {
        token
        user {
          id
          email
        }
      }
    }
  ''';

  // Login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final result = await mutate(_loginMutation, variables: {
      'loginRequest': {
        'email': email,
        'password': password,
      }
    });

    final data = result.data!['login'];
    final token = data['token'];
    
    // Guardar token
    await _saveToken(token);
    
    return {
      'token': token,
      'user': data['user'],
    };
  }

  // Logout
  static Future<void> logout() async {
    await _clearToken();
  }

  // ========== MIEMBROS ==========

  static const String _createMiembroMutation = '''
    mutation CrearMiembro(\$input: MiembroInput!) {
      crearMiembro(input: \$input) {
        token
        user {
          id
          email
        }
      }
    }
  ''';

  static const String _getMiembroPorUserIdQuery = '''
    query ObtenerMiembroPorUserId(\$userId: ID!) {
      miembroPorUserId(userId: \$userId) {
        id
        nombre
        apellido
        direccion
        telefono
        fechaRegistro
        createdAt
        updatedAt
      }
    }
  ''';

  // Crear miembro
  static Future<Map<String, dynamic>> createMiembro(Map<String, dynamic> miembroData) async {
    final result = await mutate(_createMiembroMutation, variables: {
      'input': miembroData,
    });

    final data = result.data!['crearMiembro'];
    final token = data['token'];
    
    // Guardar token automáticamente
    await _saveToken(token);
    
    return {
      'token': token,
      'user': data['user'],
    };
  }

  // Obtener miembro por user ID
  static Future<Miembro?> getMiembroPorUserId(String userId) async {
    final result = await query(_getMiembroPorUserIdQuery, variables: {
      'userId': userId,
    });

    final data = result.data!['miembroPorUserId'];
    return data != null ? Miembro.fromJson(data) : null;
  }

  // ========== ACCESOS BIBLIOTECA (QR) ==========

  static const String _generarQRMutation = '''
    mutation GenerarQR {
      generarCodigoQR
    }
  ''';

  static const String _registrarIngresoMutation = '''
    mutation RegistrarIngreso(\$miembroId: ID!, \$codigoQr: String!) {
      registrarIngreso(miembroId: \$miembroId, codigoQr: \$codigoQr) {
        accesoId
        miembroId
        miembroNombre
        miembroApellido
        fechaEntrada
        fechaSalida
        tipoAccion
        mensaje
        exitoso
      }
    }
  ''';

  static const String _registrarEgresoMutation = '''
    mutation RegistrarEgreso(\$miembroId: ID!, \$codigoQr: String!) {
      registrarEgreso(miembroId: \$miembroId, codigoQr: \$codigoQr) {
        accesoId
        miembroId
        miembroNombre
        miembroApellido
        fechaEntrada
        fechaSalida
        tipoAccion
        mensaje
        exitoso
      }
    }
  ''';

  static const String _historialMiembroQuery = '''
    query HistorialMiembro(\$miembroId: ID!) {
      historialMiembro(miembroId: \$miembroId) {
        id
        fechaEntrada
        fechaSalida
        metodoAcceso
        codigoQr
        estado
        miembroId
        miembroNombre
        miembroApellido
        createdAt
        updatedAt
      }
    }
  ''';

  static const String _miembroEstaAdentroQuery = '''
    query MiembroEstaAdentro(\$miembroId: ID!) {
      miembroEstaAdentro(miembroId: \$miembroId)
    }
  ''';

  // Generar código QR
  static Future<String> generarCodigoQR() async {
    final result = await mutate(_generarQRMutation);
    return result.data!['generarCodigoQR'];
  }

  // Registrar ingreso
  static Future<Map<String, dynamic>> registrarIngreso(String miembroId, String codigoQr) async {
    print('📝 registrarIngreso - miembroId: $miembroId, codigoQr: $codigoQr');
    
    final variables = {
      'miembroId': miembroId,
      'codigoQr': codigoQr,
    };
    print('📤 Variables enviadas: $variables');
    
    final result = await mutate(_registrarIngresoMutation, variables: variables);
    
    final data = result.data!['registrarIngreso'];
    print('📥 Respuesta recibida: $data');
    
    return data;
  }

  // Registrar egreso
  static Future<Map<String, dynamic>> registrarEgreso(String miembroId, String codigoQr) async {
    final result = await mutate(_registrarEgresoMutation, variables: {
      'miembroId': miembroId,
      'codigoQr': codigoQr,
    });

    return result.data!['registrarEgreso'];
  }

  // Obtener historial de accesos
  static Future<List<Map<String, dynamic>>> getHistorialMiembro(String miembroId) async {
    final result = await query(_historialMiembroQuery, variables: {
      'miembroId': miembroId,
    });

    final List<dynamic> accesos = result.data!['historialMiembro'] ?? [];
    return accesos.cast<Map<String, dynamic>>();
  }

  // Verificar si miembro está adentro
  static Future<bool> miembroEstaAdentro(String miembroId) async {
    final result = await query(_miembroEstaAdentroQuery, variables: {
      'miembroId': miembroId,
    });

    return result.data!['miembroEstaAdentro'] ?? false;
  }

  // ========== LIBROS ==========

  static const String _getLibrosDisponiblesQuery = '''
    query LibrosDisponibles {
      librosDisponibles {
        id
        titulo
        autor
        categoria
        disponible
        createdAt
        updatedAt
      }
    }
  ''';

  static const String _getTodosLosLibrosQuery = '''
    query TodosLosLibros {
      libros {
        id
        titulo
        autor
        categoria
        disponible
        createdAt
        updatedAt
      }
    }
  ''';

  // Obtener libros disponibles
  static Future<List<Map<String, dynamic>>> getLibrosDisponibles() async {
    final result = await query(_getLibrosDisponiblesQuery);

    final List<dynamic> libros = result.data!['librosDisponibles'] ?? [];
    return libros.cast<Map<String, dynamic>>();
  }

  // Obtener todos los libros
  static Future<List<Map<String, dynamic>>> getTodosLosLibros() async {
    final result = await query(_getTodosLosLibrosQuery);

    final List<dynamic> libros = result.data!['libros'] ?? [];
    return libros.cast<Map<String, dynamic>>();
  }

  // ========== PRÉSTAMOS ==========

  static const String _getPrestamosActivosQuery = '''
    query PrestamosActivos {
      prestamosActivos {
        id
        fechaPrestamo
        fechaDevolucionEsperada
        fechaDevolucionReal
        estado
        multa
        libroId
        miembroId
        createdAt
        updatedAt
      }
    }
  ''';

  static const String _getTodosPrestamosQuery = '''
    query TodosPrestamos {
      prestamos {
        id
        fechaPrestamo
        fechaDevolucionEsperada
        fechaDevolucionReal
        estado
        multa
        libroId
        miembroId
        createdAt
        updatedAt
      }
    }
  ''';

  static const String _getPrestamosConMultaQuery = '''
    query PrestamosConMulta {
      prestamosConMulta {
        id
        fechaPrestamo
        fechaDevolucionEsperada
        fechaDevolucionReal
        estado
        multa
        libroId
        miembroId
        createdAt
        updatedAt
      }
    }
  ''';

  // Obtener préstamos activos
  static Future<List<Map<String, dynamic>>> getPrestamosActivos() async {
    final result = await query(_getPrestamosActivosQuery);

    final List<dynamic> prestamos = result.data!['prestamosActivos'] ?? [];
    return prestamos.cast<Map<String, dynamic>>();
  }

  // Obtener todos los préstamos
  static Future<List<Map<String, dynamic>>> getTodosPrestamos() async {
    final result = await query(_getTodosPrestamosQuery);

    final List<dynamic> prestamos = result.data!['prestamos'] ?? [];
    return prestamos.cast<Map<String, dynamic>>();
  }

  // Obtener préstamos con multa
  static Future<List<Map<String, dynamic>>> getPrestamosConMulta() async {
    final result = await query(_getPrestamosConMultaQuery);

    final List<dynamic> prestamos = result.data!['prestamosConMulta'] ?? [];
    return prestamos.cast<Map<String, dynamic>>();
  }

  // ========== UTILIDADES ==========

  // Verificar si hay token
  static bool get hasToken => _token != null && _token!.isNotEmpty;

  // Obtener token actual
  static String? get currentToken => _token;

  // ========== GESTIÓN DE LIBROS ==========

  static const String _getLibrosQuery = '''
    query GetLibros {
      libros {
        id
        titulo
        autor
        categoria
        disponible
        createdAt
        updatedAt
      }
    }
  ''';

  // Obtener todos los libros
  static Future<List<Map<String, dynamic>>> getLibros() async {
    try {
      final result = await query(_getLibrosQuery);
      final List<dynamic> libros = result.data!['libros'] ?? [];
      return libros.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error obteniendo libros: $e');
      return [];
    }
  }
}