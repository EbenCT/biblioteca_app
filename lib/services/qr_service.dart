// lib/services/qr_service.dart
import 'package:permission_handler/permission_handler.dart';
import '../config/app_config.dart';

import 'graphql_service.dart';

enum TipoQR {
  entrada,
  salida,
  miembro,
  libro,
  invalido,
}

class QRService {
  // ========== PERMISOS ==========

  // Solicitar permisos de cámara
  static Future<bool> solicitarPermisosCamara() async {
    final status = await Permission.camera.request();
    return status == PermissionStatus.granted;
  }

  // Verificar si tiene permisos
  static Future<bool> tienePermisosCamara() async {
    final status = await Permission.camera.status;
    return status == PermissionStatus.granted;
  }

  // ========== VALIDACIÓN Y PROCESAMIENTO QR ==========

  // Determinar tipo de código QR
  static TipoQR determinarTipoQR(String qrData) {
    if (qrData.isEmpty) return TipoQR.invalido;

    // QR de entrada
    if (qrData.startsWith(AppConfig.qrEntradaPrefix)) {
      return TipoQR.entrada;
    }
    
    // QR de salida
    if (qrData.startsWith(AppConfig.qrSalidaPrefix)) {
      return TipoQR.salida;
    }
    
    // QR de miembro (formato: MIEMBRO_ID)
    if (qrData.startsWith('MIEMBRO_')) {
      return TipoQR.miembro;
    }
    
    // QR de libro (formato: LIBRO_ID)
    if (qrData.startsWith('LIBRO_')) {
      return TipoQR.libro;
    }

    return TipoQR.invalido;
  }

  // Validar QR de entrada
  static bool esQREntradaValido(String qrData) {
    return qrData.startsWith(AppConfig.qrEntradaPrefix) &&
           qrData.contains(AppConfig.qrBibliotecaId);
  }

  // Validar QR de salida
  static bool esQRSalidaValido(String qrData) {
    return qrData.startsWith(AppConfig.qrSalidaPrefix) &&
           qrData.contains(AppConfig.qrBibliotecaId);
  }

  // Extraer ID de QR de miembro
  static String? extraerIdMiembro(String qrData) {
    if (!qrData.startsWith('MIEMBRO_')) return null;
    return qrData.replaceFirst('MIEMBRO_', '');
  }

  // Extraer ID de QR de libro
  static String? extraerIdLibro(String qrData) {
    if (!qrData.startsWith('LIBRO_')) return null;
    return qrData.replaceFirst('LIBRO_', '');
  }

  // ========== PROCESAMIENTO DE ACCESOS ==========

  // Procesar QR escaneado para acceso
  static Future<Map<String, dynamic>> procesarQRAcceso(
    String qrData, 
    String miembroId
  ) async {
    final tipoQR = determinarTipoQR(qrData);
    
    switch (tipoQR) {
      case TipoQR.entrada:
        return await _procesarEntrada(qrData, miembroId);
      
      case TipoQR.salida:
        return await _procesarSalida(qrData, miembroId);
      
      case TipoQR.miembro:
        // Validar que sea el mismo miembro
        final qrMiembroId = extraerIdMiembro(qrData);
        if (qrMiembroId == miembroId) {
          return {
            'success': true,
            'message': 'QR de miembro validado correctamente',
            'tipo': 'miembro_validado',
          };
        } else {
          throw Exception('QR de miembro no coincide con el usuario actual');
        }
      
      case TipoQR.libro:
        return {
          'success': true,
          'message': 'QR de libro escaneado',
          'tipo': 'libro',
          'libroId': extraerIdLibro(qrData),
        };
      
      default:
        throw Exception('Código QR inválido o no reconocido');
    }
  }

  // Procesar entrada
  static Future<Map<String, dynamic>> _procesarEntrada(
    String qrData, 
    String miembroId
  ) async {
    if (!esQREntradaValido(qrData)) {
      throw Exception('Código QR de entrada inválido');
    }

    try {
      final result = await GraphQLService.registrarIngreso(miembroId, qrData);
      
      return {
        'success': result['exitoso'] ?? false,
        'message': result['mensaje'] ?? 'Entrada registrada',
        'tipo': 'entrada',
        'acceso': result,
        'timestamp': DateTime.now(),
      };
    } catch (e) {
      throw Exception('Error al registrar entrada: ${e.toString()}');
    }
  }

  // Procesar salida
  static Future<Map<String, dynamic>> _procesarSalida(
    String qrData, 
    String miembroId
  ) async {
    if (!esQRSalidaValido(qrData)) {
      throw Exception('Código QR de salida inválido');
    }

    try {
      final result = await GraphQLService.registrarEgreso(miembroId, qrData);
      
      return {
        'success': result['exitoso'] ?? false,
        'message': result['mensaje'] ?? 'Salida registrada',
        'tipo': 'salida',
        'acceso': result,
        'timestamp': DateTime.now(),
      };
    } catch (e) {
      throw Exception('Error al registrar salida: ${e.toString()}');
    }
  }

  // ========== ACCESOS MANUALES (SIN QR) ==========

  // Marcar entrada manual (sin QR)
  static Future<Map<String, dynamic>> marcarEntradaManual(String miembroId) async {
    try {
      return await GraphQLService.registrarIngreso(miembroId, 'MANUAL_ENTRY');
    } catch (e) {
      throw Exception('Error al marcar entrada manual: ${e.toString()}');
    }
  }

  // Marcar salida manual (sin QR)
  static Future<Map<String, dynamic>> marcarSalidaManual(String miembroId) async {
    try {
      return await GraphQLService.registrarEgreso(miembroId, 'MANUAL_EXIT');
    } catch (e) {
      throw Exception('Error al marcar salida manual: ${e.toString()}');
    }
  }

  // ========== GENERACIÓN DE QR (OPCIONAL) ==========

  // Generar QR para miembro
  static String generarQRMiembro(String miembroId) {
    return 'MIEMBRO_$miembroId';
  }

  // Generar QR para libro
  static String generarQRLibro(String libroId) {
    return 'LIBRO_$libroId';
  }

  // Generar QR de entrada para biblioteca
  static String generarQREntrada() {
    return '${AppConfig.qrEntradaPrefix}${AppConfig.qrBibliotecaId}_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Generar QR de salida para biblioteca
  static String generarQRSalida() {
    return '${AppConfig.qrSalidaPrefix}${AppConfig.qrBibliotecaId}_${DateTime.now().millisecondsSinceEpoch}';
  }

  // ========== UTILIDADES ==========

  // Verificar estado actual del miembro
  static Future<Map<String, dynamic>> verificarEstadoMiembro(String miembroId) async {
    try {
      final historialAccesos = await GraphQLService.getHistorialMiembro(miembroId);
      
      // Verificar si tiene acceso activo (sin fechaSalida)
      final accesoActivo = historialAccesos.where((acceso) => 
        acceso['fechaSalida'] == null && acceso['estado'] == true
      ).toList();
      
      return {
        'tieneAccesoActivo': accesoActivo.isNotEmpty,
        'ultimoAcceso': historialAccesos.isNotEmpty ? historialAccesos.first : null,
        'accesoActivo': accesoActivo.isNotEmpty ? accesoActivo.first : null,
        'totalAccesos': historialAccesos.length,
      };
    } catch (e) {
      throw Exception('Error al verificar estado del miembro: ${e.toString()}');
    }
  }

  // Formatear resultado para mostrar en UI
  static Map<String, dynamic> formatearResultadoParaUI(Map<String, dynamic> resultado) {
    final tipo = resultado['tipo'];
    String titulo = '';
    String subtitulo = '';
    String icono = '';
    String color = '';

    switch (tipo) {
      case 'entrada':
        titulo = '¡Entrada Registrada!';
        subtitulo = 'Bienvenido a la biblioteca';
        icono = '📍';
        color = 'green';
        break;
      
      case 'salida':
        titulo = '¡Salida Registrada!';
        subtitulo = 'Duración: ${resultado['duracion']}';
        icono = '🚪';
        color = 'blue';
        break;
      
      case 'miembro_validado':
        titulo = 'Miembro Validado';
        subtitulo = 'QR personal verificado';
        icono = '✅';
        color = 'green';
        break;
      
      case 'libro':
        titulo = 'Libro Escaneado';
        subtitulo = 'ID: ${resultado['libroId']}';
        icono = '📚';
        color = 'orange';
        break;
      
      default:
        titulo = 'Operación Completada';
        subtitulo = resultado['message'] ?? '';
        icono = 'ℹ️';
        color = 'gray';
    }

    return {
      ...resultado,
      'ui': {
        'titulo': titulo,
        'subtitulo': subtitulo,
        'icono': icono,
        'color': color,
      }
    };
  }
}