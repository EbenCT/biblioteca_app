// lib/services/prestamo_service.dart
import '../models/prestamo.dart';
import 'graphql_service.dart';

class PrestamoService {
  
  // Obtener préstamos activos del miembro
  static Future<List<Prestamo>> getPrestamosActivos() async {
    try {
      final prestamosData = await GraphQLService.getPrestamosActivos();
      return prestamosData.map((data) => Prestamo.fromJson(data)).toList();
    } catch (e) {
      print('Error obteniendo préstamos activos: $e');
      return _getPrestamosEstaticosActivos();
    }
  }

  // Obtener todos los préstamos (historial completo)
  static Future<List<Prestamo>> getTodosPrestamos() async {
    try {
      final prestamosData = await GraphQLService.getTodosPrestamos();
      final prestamosBackend = prestamosData.map((data) => Prestamo.fromJson(data)).toList();
      
      // Combinar con préstamos estáticos
      final prestamosEstaticos = _getTodosPrestamosEstaticos();
      final todosPrestamos = [...prestamosBackend, ...prestamosEstaticos];
      
      // Ordenar por fecha de préstamo (más reciente primero)
      todosPrestamos.sort((a, b) => b.fechaPrestamo.compareTo(a.fechaPrestamo));
      
      return todosPrestamos;
    } catch (e) {
      print('Error obteniendo todos los préstamos: $e');
      return _getTodosPrestamosEstaticos();
    }
  }

  // Obtener préstamos con multa
  static Future<List<Prestamo>> getPrestamosConMulta() async {
    try {
      final prestamosData = await GraphQLService.getPrestamosConMulta();
      final prestamosBackend = prestamosData.map((data) => Prestamo.fromJson(data)).toList();
      
      // Agregar préstamos estáticos con multa
      final prestamosEstaticos = _getPrestamosEstaticosConMulta();
      final prestamosConMulta = [...prestamosBackend, ...prestamosEstaticos];
      
      return prestamosConMulta;
    } catch (e) {
      print('Error obteniendo préstamos con multa: $e');
      return _getPrestamosEstaticosConMulta();
    }
  }

  // Calcular multa por días de retraso
  static double calcularMulta(DateTime fechaDevolucionEsperada, DateTime? fechaDevolucionReal) {
    final fechaComparacion = fechaDevolucionReal ?? DateTime.now();
    final diasRetraso = fechaComparacion.difference(fechaDevolucionEsperada).inDays;
    
    if (diasRetraso <= 0) return 0.0;
    
    // 5 Bs por día de retraso
    return diasRetraso * 5.0;
  }

  // Filtrar préstamos por estado
  static List<Prestamo> filtrarPorEstado(List<Prestamo> prestamos, bool activo) {
    return prestamos.where((prestamo) => prestamo.estado == activo).toList();
  }

  // Obtener total de multas pendientes
  static double getTotalMultasPendientes(List<Prestamo> prestamos) {
    return prestamos
        .where((prestamo) => prestamo.multa != null && prestamo.multa! > 0)
        .fold(0.0, (total, prestamo) => total + prestamo.multa!);
  }

  // ========== DATOS ESTÁTICOS ==========

  // Préstamos activos estáticos
  static List<Prestamo> _getPrestamosEstaticosActivos() {
    final ahora = DateTime.now();
    
    return [
      Prestamo(
        id: 'static_prestamo_1',
        fechaPrestamo: ahora.subtract(const Duration(days: 5)).toIso8601String(),
        fechaDevolucionEsperada: ahora.add(const Duration(days: 9)).toIso8601String(),
        fechaDevolucionReal: null,
        estado: true, // Activo
        multa: null,
        libroId: 'static_1',
        miembroId: 'current_user',
      ),
    ];
  }

  // Préstamos estáticos con multa
  static List<Prestamo> _getPrestamosEstaticosConMulta() {
    final ahora = DateTime.now();
    
    return [
      Prestamo(
        id: 'static_prestamo_multa_1',
        fechaPrestamo: ahora.subtract(const Duration(days: 25)).toIso8601String(),
        fechaDevolucionEsperada: ahora.subtract(const Duration(days: 5)).toIso8601String(),
        fechaDevolucionReal: null,
        estado: true, // Activo con retraso
        multa: 25.0, // 5 días de retraso × 5 Bs
        libroId: 'static_3',
        miembroId: 'current_user',
      ),
    ];
  }

  // Todos los préstamos estáticos (historial completo)
  static List<Prestamo> _getTodosPrestamosEstaticos() {
    final ahora = DateTime.now();
    
    return [
      // Préstamos activos
      ..._getPrestamosEstaticosActivos(),
      ..._getPrestamosEstaticosConMulta(),
      
      // Préstamos completados (historial) - solo uno
      Prestamo(
        id: 'static_prestamo_3',
        fechaPrestamo: ahora.subtract(const Duration(days: 35)).toIso8601String(),
        fechaDevolucionEsperada: ahora.subtract(const Duration(days: 21)).toIso8601String(),
        fechaDevolucionReal: ahora.subtract(const Duration(days: 20)).toIso8601String(),
        estado: false, // Completado
        multa: null,
        libroId: 'static_2',
        miembroId: 'current_user',
      ),
    ];
  }

  // Obtener información del libro por ID (simplificado)
  static Map<String, String> getLibroInfo(String libroId) {
    final librosInfo = {
      'static_1': {'titulo': 'Cien años de soledad', 'autor': 'Gabriel García Márquez'},
      'static_2': {'titulo': 'Don Quijote de la Mancha', 'autor': 'Miguel de Cervantes'},
      'static_3': {'titulo': '1984', 'autor': 'George Orwell'},
      'static_4': {'titulo': 'El Principito', 'autor': 'Antoine de Saint-Exupéry'},
      'static_5': {'titulo': 'Orgullo y Prejuicio', 'autor': 'Jane Austen'},
      'static_6': {'titulo': 'El Hobbit', 'autor': 'J.R.R. Tolkien'},
      'static_7': {'titulo': 'Crónica de una muerte anunciada', 'autor': 'Gabriel García Márquez'},
      'unknown': {'titulo': 'Libro Desconocido', 'autor': 'Autor Desconocido'},
    };
    
    return librosInfo[libroId] ?? {'titulo': 'Libro Desconocido', 'autor': 'Autor Desconocido'};
  }

  // Formatear fecha para mostrar
  static String formatearFecha(String fechaISO) {
    try {
      final fecha = DateTime.parse(fechaISO);
      final meses = [
        'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
        'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
      ];
      
      return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
    } catch (e) {
      return 'Fecha inválida';
    }
  }

  // Obtener días restantes o días de retraso
  static Map<String, dynamic> getEstadoDevolucion(String fechaDevolucionEsperada, String? fechaDevolucionReal) {
    try {
      final fechaEsperada = DateTime.parse(fechaDevolucionEsperada);
      final fechaComparacion = fechaDevolucionReal != null 
          ? DateTime.parse(fechaDevolucionReal) 
          : DateTime.now();
      
      final diferencia = fechaEsperada.difference(fechaComparacion).inDays;
      
      if (fechaDevolucionReal != null) {
        // Ya fue devuelto
        if (diferencia >= 0) {
          return {'tipo': 'devuelto_a_tiempo', 'dias': diferencia, 'texto': 'Devuelto a tiempo'};
        } else {
          return {'tipo': 'devuelto_tarde', 'dias': diferencia.abs(), 'texto': 'Devuelto con ${diferencia.abs()} días de retraso'};
        }
      } else {
        // Aún no devuelto
        if (diferencia > 0) {
          return {'tipo': 'pendiente', 'dias': diferencia, 'texto': 'Quedan $diferencia días'};
        } else if (diferencia == 0) {
          return {'tipo': 'vence_hoy', 'dias': 0, 'texto': 'Vence hoy'};
        } else {
          return {'tipo': 'vencido', 'dias': diferencia.abs(), 'texto': '${diferencia.abs()} días de retraso'};
        }
      }
    } catch (e) {
      return {'tipo': 'error', 'dias': 0, 'texto': 'Error en fecha'};
    }
  }
}