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
    await _loadToken();
    _initializeClient();
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
      throw Exception('GraphQL client no inicializado');
    }

    final result = await _client!.query(
      QueryOptions(
        document: gql(queryString),
        variables: variables ?? {},
      ),
    );

    if (result.hasException) {
      throw Exception('GraphQL Error: ${result.exception.toString()}');
    }

    return result;
  }

  // Ejecutar mutation
  static Future<QueryResult> mutate(String mutationString, {Map<String, dynamic>? variables}) async {
    if (_client == null) {
      throw Exception('GraphQL client no inicializado');
    }

    final result = await _client!.mutate(
      MutationOptions(
        document: gql(mutationString),
        variables: variables ?? {},
      ),
    );

    if (result.hasException) {
      throw Exception('GraphQL Error: ${result.exception.toString()}');
    }

    return result;
  }

  // ========== AUTENTICACIÓN ==========

  static const String _loginMutation = '''
    mutation LoginUser(\$input: LoginRequestDTO!) {
      loginUser(input: \$input) {
        token
        user {
          id
          username
          email
          role
        }
      }
    }
  ''';

  static const String _registerMutation = '''
    mutation RegisterUser(\$input: RegisterRequestDTO!) {
      registerUser(input: \$input) {
        token
        user {
          id
          username
          email
          role
        }
      }
    }
  ''';

  // Login
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final result = await mutate(_loginMutation, variables: {
      'input': {
        'username': username,
        'password': password,
      }
    });

    final data = result.data!['loginUser'];
    final token = data['token'];
    
    // Guardar token
    await _saveToken(token);
    
    return {
      'token': token,
      'user': User.fromJson(data['user']),
    };
  }

  // Register
  static Future<Map<String, dynamic>> register(String username, String email, String password) async {
    final result = await mutate(_registerMutation, variables: {
      'input': {
        'username': username,
        'email': email,
        'password': password,
        'role': 'USER',
      }
    });

    final data = result.data!['registerUser'];
    final token = data['token'];
    
    // Guardar token
    await _saveToken(token);
    
    return {
      'token': token,
      'user': User.fromJson(data['user']),
    };
  }

  // Logout
  static Future<void> logout() async {
    await _clearToken();
  }

  // ========== MIEMBROS ==========

  static const String _createMiembroMutation = '''
    mutation CreateMiembro(\$input: MiembroInput!) {
      createMiembro(input: \$input) {
        id
        nombre
        apellido
        direccion
        telefono
        fechaRegistro
        qrPersonal
        usuario {
          id
          username
          email
        }
      }
    }
  ''';

  static const String _getMiembroByUserQuery = '''
    query GetMiembroByUserId(\$userId: ID!) {
      miembroByUserId(userId: \$userId) {
        id
        nombre
        apellido
        direccion
        telefono
        fechaRegistro
        qrPersonal
        usuario {
          id
          username
          email
        }
      }
    }
  ''';

  // Crear miembro
  static Future<Miembro> createMiembro(Map<String, dynamic> miembroData) async {
    final result = await mutate(_createMiembroMutation, variables: {
      'input': miembroData,
    });

    return Miembro.fromJson(result.data!['createMiembro']);
  }

  // Obtener miembro por usuario
  static Future<Miembro?> getMiembroByUser(String userId) async {
    final result = await query(_getMiembroByUserQuery, variables: {
      'userId': userId,
    });

    final data = result.data!['miembroByUserId'];
    return data != null ? Miembro.fromJson(data) : null;
  }

  // ========== ACCESOS BIBLIOTECA (QR) ==========

  static const String _marcarEntradaMutation = '''
    mutation MarcarEntrada(\$input: AccesoBibliotecaInput!) {
      createAccesoBiblioteca(input: \$input) {
        id
        fechaEntrada
        fechaSalida
        miembroId
        qrCode
        tipoAcceso
        miembro {
          id
          nombre
          apellido
        }
      }
    }
  ''';

  static const String _marcarSalidaMutation = '''
    mutation MarcarSalida(\$id: ID!, \$input: AccesoBibliotecaInput!) {
      updateAccesoBiblioteca(id: \$id, input: \$input) {
        id
        fechaEntrada
        fechaSalida
        miembroId
        qrCode
        tipoAcceso
        miembro {
          id
          nombre
          apellido
        }
      }
    }
  ''';

  static const String _getHistorialAccesosQuery = '''
    query GetHistorialAccesos(\$miembroId: ID!) {
      accesosByMiembro(miembroId: \$miembroId) {
        id
        fechaEntrada
        fechaSalida
        miembroId
        qrCode
        tipoAcceso
      }
    }
  ''';

  // Marcar entrada
  static Future<AccesoBiblioteca> marcarEntrada(String miembroId, String? qrCode) async {
    final result = await mutate(_marcarEntradaMutation, variables: {
      'input': {
        'fechaEntrada': DateTime.now().toIso8601String(),
        'miembroId': miembroId,
        'qrCode': qrCode,
        'tipoAcceso': 'ENTRADA',
      }
    });

    return AccesoBiblioteca.fromJson(result.data!['createAccesoBiblioteca']);
  }

  // Marcar salida
  static Future<AccesoBiblioteca> marcarSalida(String accesoId, String? qrCode) async {
    final result = await mutate(_marcarSalidaMutation, variables: {
      'id': accesoId,
      'input': {
        'fechaSalida': DateTime.now().toIso8601String(),
        'qrCode': qrCode,
        'tipoAcceso': 'SALIDA',
      }
    });

    return AccesoBiblioteca.fromJson(result.data!['updateAccesoBiblioteca']);
  }

  // Obtener historial de accesos
  static Future<List<AccesoBiblioteca>> getHistorialAccesos(String miembroId) async {
    final result = await query(_getHistorialAccesosQuery, variables: {
      'miembroId': miembroId,
    });

    final List<dynamic> accesos = result.data!['accesosByMiembro'] ?? [];
    return accesos.map((acceso) => AccesoBiblioteca.fromJson(acceso)).toList();
  }

  // ========== LIBROS ==========

  static const String _getLibrosDisponiblesQuery = '''
    query GetLibrosDisponibles {
      librosDisponibles {
        id
        titulo
        autor
        categoria
        disponible
        isbn
        descripcion
        editorial
        qrCode
      }
    }
  ''';

  // Obtener libros disponibles
  static Future<List<Libro>> getLibrosDisponibles() async {
    final result = await query(_getLibrosDisponiblesQuery);

    final List<dynamic> libros = result.data!['librosDisponibles'] ?? [];
    return libros.map((libro) => Libro.fromJson(libro)).toList();
  }

  // ========== PRÉSTAMOS ==========

  static const String _getMisPrestamosActivosQuery = '''
    query GetMisPrestamosActivos(\$miembroId: ID!) {
      prestamosActivos(miembroId: \$miembroId) {
        id
        fechaPrestamo
        fechaDevolucionEsperada
        fechaDevolucionReal
        estado
        multa
        libroId
        miembroId
        libro {
          id
          titulo
          autor
          categoria
        }
      }
    }
  ''';

  static const String _getMiHistorialQuery = '''
    query GetMiHistorial(\$miembroId: ID!) {
      prestamos(miembroId: \$miembroId) {
        id
        fechaPrestamo
        fechaDevolucionEsperada
        fechaDevolucionReal
        estado
        multa
        libroId
        miembroId
        libro {
          id
          titulo
          autor
          categoria
        }
      }
    }
  ''';

  // Obtener préstamos activos
  static Future<List<Prestamo>> getMisPrestamosActivos(String miembroId) async {
    final result = await query(_getMisPrestamosActivosQuery, variables: {
      'miembroId': miembroId,
    });

    final List<dynamic> prestamos = result.data!['prestamosActivos'] ?? [];
    return prestamos.map((prestamo) => Prestamo.fromJson(prestamo)).toList();
  }

  // Obtener historial de préstamos
  static Future<List<Prestamo>> getMiHistorial(String miembroId) async {
    final result = await query(_getMiHistorialQuery, variables: {
      'miembroId': miembroId,
    });

    final List<dynamic> prestamos = result.data!['prestamos'] ?? [];
    return prestamos.map((prestamo) => Prestamo.fromJson(prestamo)).toList();
  }

  // ========== UTILIDADES ==========

  // Verificar si hay token
  static bool get hasToken => _token != null && _token!.isNotEmpty;

  // Obtener token actual
  static String? get currentToken => _token;
}