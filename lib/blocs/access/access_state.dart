// lib/blocs/access/access_state.dart
import '../../models/models.dart';

abstract class AccessState {
  const AccessState();
}

// Estado inicial
class AccessInitial extends AccessState {}

// Estados de carga
class AccessLoading extends AccessState {}

// Estados del QR Scanner
class QRScannerActive extends AccessState {}

class QRScannerInactive extends AccessState {}

// Estados de éxito
class QRProcessSuccess extends AccessState {
  final Map<String, dynamic> resultado;
  final Map<String, dynamic>? acceso;

  const QRProcessSuccess({
    required this.resultado,
    this.acceso,
  });
}

class EntradaRegistrada extends AccessState {
  final Map<String, dynamic> acceso;
  final DateTime timestamp;

  const EntradaRegistrada({
    required this.acceso,
    required this.timestamp,
  });
}

class SalidaRegistrada extends AccessState {
  final Map<String, dynamic> acceso;
  final String duracion;
  final DateTime timestamp;

  const SalidaRegistrada({
    required this.acceso,
    required this.duracion,
    required this.timestamp,
  });
}

// Estados de datos cargados
class HistorialAccesosLoaded extends AccessState {
  final List<AccesoBiblioteca> historialAccesos;

  const HistorialAccesosLoaded({required this.historialAccesos});
}

class EstadoMiembroLoaded extends AccessState {
  final bool estaAdentro;

  const EstadoMiembroLoaded({required this.estaAdentro});
}

// Estados de error
class AccessError extends AccessState {
  final String message;
  final String? errorCode;

  const AccessError({
    required this.message,
    this.errorCode,
  });
}

class QRScannerError extends AccessState {
  final String message;

  const QRScannerError({required this.message});
}

class PermissionDenied extends AccessState {
  final String message;

  const PermissionDenied({
    this.message = 'Permisos de cámara requeridos para escanear códigos QR',
  });
}