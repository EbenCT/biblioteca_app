# Sistema de Biblioteca - Frontend Flutter 📱

## Descripción General

Aplicación móvil Flutter para el sistema de gestión de biblioteca que se conecta al backend Spring Boot GraphQL. La app permite a los usuarios registrarse como miembros, marcar entradas/salidas, consultar libros disponibles, ver historial y gestionar préstamos.

## 🚀 Características Principales

### 1. **Registro de Miembros** 
- Crear cuenta de nuevo miembro
- Autenticación JWT
- Perfil de usuario

### 2. **Control de Acceso (Funcionalidad Principal)**
- ✅ **Marcar Entrada** - Registrar ingreso a la biblioteca
- ❌ **Marcar Salida** - Registrar salida de la biblioteca
- 📊 **Historial de Accesos** - Ver registro de entradas y salidas

### 3. **Gestión de Libros (Básico)**
- 📚 **Ver libros disponibles**

### 4. **Sistema de Préstamos (Básico)**
- 📋 **Mis préstamos activos**: Libros que tengo prestados
- 🕒 **Mi historial**: Todos mis préstamos

## 🔌 Integración GraphQL con Backend

### Configuración de Conexión

```dart
// lib/config/graphql_config.dart
import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLConfig {
  static const String _baseUrl = 'http://10.0.2.2:8080'; // Android emulator
  // static const String _baseUrl = 'http://localhost:8080'; // iOS simulator
  // static const String _baseUrl = 'http://YOUR_IP:8080'; // Physical device
  
  static const String _graphqlEndpoint = '$_baseUrl/graphql';

  static ValueNotifier<GraphQLClient> initializeClient(String? token) {
    final HttpLink httpLink = HttpLink(_graphqlEndpoint);
    
    final AuthLink authLink = AuthLink(
      getToken: () async => token != null ? 'Bearer $token' : null,
    );

    final Link link = authLink.concat(httpLink);

    return ValueNotifier(
      GraphQLClient(
        link: link,
        cache: GraphQLCache(store: InMemoryStore()),
      ),
    );
  }
}
```

### 📝 Mutations y Queries GraphQL

#### **1. Autenticación**

```dart
// Registro de Usuario
const String REGISTER_USER = '''
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
const String LOGIN_USER = '''
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
```

#### **2. Gestión de Miembros**

```dart
// Crear Miembro
const String CREATE_MIEMBRO = '''
  mutation CreateMiembro(\$input: MiembroInput!) {
    createMiembro(input: \$input) {
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

// Obtener Miembro por Usuario
const String GET_MIEMBRO_BY_USER = '''
  query GetMiembroByUserId(\$userId: ID!) {
    miembroByUserId(userId: \$userId) {
      id
      nombre
      apellido
      direccion
      telefono
      fechaRegistro
      usuario {
        id
        username
        email
      }
    }
  }
''';
```

#### **3. Control de Acceso (Entrada/Salida)**

```dart
// Marcar Entrada
const String MARCAR_ENTRADA = '''
  mutation MarcarEntrada(\$input: AccesoBibliotecaInput!) {
    createAccesoBiblioteca(input: \$input) {
      id
      fechaEntrada
      fechaSalida
      miembro {
        id
        nombre
        apellido
      }
      createdAt
    }
  }
''';

// Marcar Salida
const String MARCAR_SALIDA = '''
  mutation MarcarSalida(\$id: ID!, \$input: AccesoBibliotecaInput!) {
    updateAccesoBiblioteca(id: \$id, input: \$input) {
      id
      fechaEntrada
      fechaSalida
      miembro {
        id
        nombre
        apellido
      }
      updatedAt
    }
  }
''';

// Historial de Accesos
const String GET_ACCESOS_BY_MIEMBRO = '''
  query GetAccesosByMiembro(\$miembroId: ID!) {
    accesosByMiembro(miembroId: \$miembroId) {
      id
      fechaEntrada
      fechaSalida
      createdAt
      updatedAt
    }
  }
''';
```

#### **4. Gestión de Libros (Básico)**

```dart
// Ver libros disponibles
const String GET_LIBROS_DISPONIBLES = '''
  query GetLibrosDisponibles {
    librosDisponibles {
      id
      titulo
      autor
      categoria
      disponible
    }
  }
''';
```

#### **5. Sistema de Préstamos (Solo Consulta)**

```dart
// Mis préstamos activos (estado = true)
const String GET_MIS_PRESTAMOS_ACTIVOS = '''
  query GetMisPrestamosActivos {
    prestamosActivos {
      id
      fechaPrestamo
      fechaDevolucionEsperada
      estado
      libroId
      miembroId
    }
  }
''';

// Mi historial completo
const String GET_MI_HISTORIAL = '''
  query GetMiHistorial {
    prestamos {
      id
      fechaPrestamo
      fechaDevolucionEsperada
      fechaDevolucionReal
      estado
      libroId
      miembroId
    }
  }
''';
```

## 📱 Estructura de Pantallas Propuesta

### 1. **Autenticación**
- `login_screen.dart` - Pantalla de login
- `register_screen.dart` - Registro de usuario y miembro

### 2. **Dashboard Principal**
- `home_screen.dart` - Dashboard con acceso rápido a funciones principales
- `profile_screen.dart` - Perfil del usuario/miembro

### 3. **Control de Acceso**
- `access_control_screen.dart` - Marcar entrada/salida (FUNCIONALIDAD PRINCIPAL)
- `access_history_screen.dart` - Historial de entradas y salidas

### 4. **Gestión de Libros**
- `books_screen.dart` - Lista de libros disponibles

### 5. **Sistema de Préstamos (Solo Consulta)**
- `my_loans_screen.dart` - Mis préstamos activos
- `loan_history_screen.dart` - Mi historial de préstamos

## 🔧 Modelos de Datos Flutter

```dart
// lib/models/user.dart
class User {
  final String id;
  final String username;
  final String email;
  final String role;

  User({required this.id, required this.username, required this.email, required this.role});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      role: json['role'],
    );
  }
}

// lib/models/miembro.dart
class Miembro {
  final String id;
  final String nombre;
  final String apellido;
  final String direccion;
  final String telefono;
  final String fechaRegistro;
  final User? usuario;

  Miembro({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.direccion,
    required this.telefono,
    required this.fechaRegistro,
    this.usuario,
  });

  factory Miembro.fromJson(Map<String, dynamic> json) {
    return Miembro(
      id: json['id'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      direccion: json['direccion'],
      telefono: json['telefono'],
      fechaRegistro: json['fechaRegistro'],
      usuario: json['usuario'] != null ? User.fromJson(json['usuario']) : null,
    );
  }
}

// lib/models/libro.dart
class Libro {
  final String id;
  final String titulo;
  final String autor;
  final String categoria;
  final bool disponible;

  Libro({
    required this.id,
    required this.titulo,
    required this.autor,
    required this.categoria,
    required this.disponible,
  });

  factory Libro.fromJson(Map<String, dynamic> json) {
    return Libro(
      id: json['id'],
      titulo: json['titulo'],
      autor: json['autor'],
      categoria: json['categoria'],
      disponible: json['disponible'],
    );
  }
}

// lib/models/acceso_biblioteca.dart
class AccesoBiblioteca {
  final String id;
  final String fechaEntrada;
  final String? fechaSalida;
  final Miembro? miembro;

  AccesoBiblioteca({
    required this.id,
    required this.fechaEntrada,
    this.fechaSalida,
    this.miembro,
  });

  factory AccesoBiblioteca.fromJson(Map<String, dynamic> json) {
    return AccesoBiblioteca(
      id: json['id'],
      fechaEntrada: json['fechaEntrada'],
      fechaSalida: json['fechaSalida'],
      miembro: json['miembro'] != null ? Miembro.fromJson(json['miembro']) : null,
    );
  }
}

// lib/models/prestamo.dart
class Prestamo {
  final String id;
  final String fechaPrestamo;
  final String fechaDevolucionEsperada;
  final String? fechaDevolucionReal;
  final bool estado;
  final double? multa;
  final Libro? libro;
  final Miembro? miembro;

  Prestamo({
    required this.id,
    required this.fechaPrestamo,
    required this.fechaDevolucionEsperada,
    this.fechaDevolucionReal,
    required this.estado,
    this.multa,
    this.libro,
    this.miembro,
  });

  factory Prestamo.fromJson(Map<String, dynamic> json) {
    return Prestamo(
      id: json['id'],
      fechaPrestamo: json['fechaPrestamo'],
      fechaDevolucionEsperada: json['fechaDevolucionEsperada'],
      fechaDevolucionReal: json['fechaDevolucionReal'],
      estado: json['estado'],
      multa: json['multa']?.toDouble(),
      libro: json['libro'] != null ? Libro.fromJson(json['libro']) : null,
      miembro: json['miembro'] != null ? Miembro.fromJson(json['miembro']) : null,
    );
  }
}
```

## 🎯 Funcionalidad Principal: Control de Acceso

### Ejemplo de Implementación de Marcar Entrada/Salida

```dart
// lib/services/access_service.dart
class AccessService {
  static Future<AccesoBiblioteca?> marcarEntrada(String miembroId) async {
    final result = await GraphQLConfig.client.value.mutate(
      MutationOptions(
        document: gql(MARCAR_ENTRADA),
        variables: {
          'input': {
            'fechaEntrada': DateTime.now().toIso8601String(),
            'miembroId': miembroId,
          }
        },
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return AccesoBiblioteca.fromJson(result.data!['createAccesoBiblioteca']);
  }

  static Future<AccesoBiblioteca?> marcarSalida(String accesoId) async {
    final result = await GraphQLConfig.client.value.mutate(
      MutationOptions(
        document: gql(MARCAR_SALIDA),
        variables: {
          'id': accesoId,
          'input': {
            'fechaSalida': DateTime.now().toIso8601String(),
          }
        },
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return AccesoBiblioteca.fromJson(result.data!['updateAccesoBiblioteca']);
  }
}
```

## 📚 **Sistema de Préstamos (Solo Consulta desde Móvil)**

### **Flujo Real del Sistema:**

#### **1. �️ En la Biblioteca (Presencial)**
- **Miembro va físicamente** a la biblioteca
- **Admin/Bibliotecario** registra el préstamo en el sistema
- Se crea préstamo con `estado: true` (activo)

#### **2. 📱 En la App Móvil (Solo Consulta)**
- **Ver préstamos activos**: Libros que tiene prestados actualmente
- **Ver historial**: Todos sus préstamos (activos + devueltos)
- **Ver multas**: Si tiene multas pendientes por retraso

#### **3. 📋 Estados del Préstamo**
- **`estado: true`** = Préstamo **ACTIVO** (tiene el libro)
- **`estado: false`** = Préstamo **FINALIZADO** (ya devolvió el libro)

### **Servicios Flutter Súper Simples:**

```dart
// lib/services/prestamo_service.dart
class PrestamoService {
  // Ver mis préstamos activos
  static Future<List<Prestamo>> getMisPrestamosActivos() async {
    // Consultar prestamosActivos
  }
  
  // Ver mi historial completo
  static Future<List<Prestamo>> getMiHistorial() async {
    // Consultar prestamos
  }
}

// lib/services/libro_service.dart
class LibroService {
  // Ver libros disponibles
  static Future<List<Libro>> getLibrosDisponibles() async {
    // Consultar librosDisponibles
  }
}

## 📦 Dependencias Requeridas

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  
  # GraphQL
  graphql_flutter: ^5.1.2
  
  # Estado
  provider: ^6.1.1
  
  # HTTP y Networking
  http: ^1.1.0
  
  # Almacenamiento local
  shared_preferences: ^2.2.2
  
  # UI Components
  cupertino_icons: ^1.0.6
  
  # Fechas
  intl: ^0.18.1
  
  # Navegación
  go_router: ^12.1.3
```

## ⚡ **VERSIÓN MINIMA PARA 2 HORAS**

### **Solo 4 Pantallas Esenciales:**
1. **Login** - Autenticación básica
2. **Dashboard** - Marcar entrada/salida (FUNCIÓN PRINCIPAL)
3. **Mis Préstamos** - Ver préstamos activos
4. **Libros** - Ver libros disponibles

### **3 Queries GraphQL Básicas:**
```dart
// 1. Login
const String LOGIN = '''
  mutation Login(\$input: LoginRequestDTO!) {
    loginUser(input: \$input) {
      token
      user { id username email }
    }
  }
''';

// 2. Marcar entrada/salida 
const String MARCAR_ENTRADA = '''
  mutation MarcarEntrada(\$input: AccesoBibliotecaInput!) {
    createAccesoBiblioteca(input: \$input) {
      id fechaEntrada miembroId
    }
  }
''';

// 3. Ver mis préstamos activos
const String MIS_PRESTAMOS = '''
  query MisPrestamos {
    prestamosActivos {
      id fechaPrestamo fechaDevolucionEsperada libroId
    }
  }
''';
```

### **Estructura Mínima:**
```
lib/
  main.dart
  screens/
    login_screen.dart
    dashboard_screen.dart     # ← PRINCIPAL: Entrada/Salida
    my_loans_screen.dart
    books_screen.dart
  services/
    graphql_service.dart      # Solo estas 3 queries
  models/
    user.dart
    prestamo.dart
```

## 🚀 Configuración de Desarrollo

### 1. **Variables de Entorno**

Crear archivo `lib/config/app_config.dart`:

```dart
class AppConfig {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://10.0.2.2:8080', // Android Emulator
  );
  
  static const String graphqlEndpoint = '$baseUrl/graphql';
}
```

### 2. **Manejo de Estado con Provider**

```dart
// lib/providers/auth_provider.dart
class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  Miembro? _miembro;

  User? get user => _user;
  String? get token => _token;
  Miembro? get miembro => _miembro;
  bool get isAuthenticated => _token != null;

  Future<void> login(String username, String password) async {
    // Implementar lógica de login
  }

  Future<void> register(RegisterData data) async {
    // Implementar lógica de registro
  }

  Future<void> logout() async {
    // Implementar lógica de logout
  }
}
```

## 📋 Flujo de Usuario Principal

### 1. **Registro/Login**
1. Usuario abre la app
2. Se registra creando cuenta de usuario
3. Completa información como miembro
4. Recibe token JWT

### 2. **Control de Acceso (Función Principal)**
1. Usuario en dashboard principal
2. Toca botón "Marcar Entrada" 
3. Se registra entrada con timestamp
4. Al salir, toca "Marcar Salida"
5. Se registra salida y se calcula tiempo de permanencia

### 3. **Consulta Simple**
1. Ve libros disponibles (solo lista básica)
2. Va físicamente a la biblioteca si quiere un libro
3. Admin registra el préstamo presencialmente  
4. En la app móvil:
   - Ve "Mis Préstamos Activos" 
   - Ve "Mi Historial"

## 🔐 Consideraciones de Seguridad

- Almacenar JWT token de forma segura (shared_preferences)
- Validar tokens expirados
- Manejar refresh tokens si es necesario
- Validar permisos antes de operaciones

## 📱 Testing

### Datos de Prueba Sugeridos

Para probar la app, usar estos datos con Postman primero:

```json
// Usuario de prueba
{
  "username": "testuser",
  "email": "test@test.com",
  "password": "password123",
  "role": "USER"
}

// Miembro de prueba
{
  "nombre": "Juan",
  "apellido": "Pérez",
  "direccion": "Calle 123",
  "telefono": "+1234567890",
  "fechaRegistro": "2025-11-10T12:00:00"
}

// Libro de prueba
{
  "titulo": "El Quijote",
  "autor": "Miguel de Cervantes",
  "categoria": "Novela",
  "disponible": true
}
```

¡Con esta documentación tendrás todo lo necesario para integrar tu app Flutter con el backend GraphQL del sistema de biblioteca! 🚀📚