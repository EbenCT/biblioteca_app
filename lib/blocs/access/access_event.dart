// lib/blocs/access/access_event.dart
abstract class AccessEvent {
  const AccessEvent();
}

// Eventos de QR Scanner
class StartQRScanner extends AccessEvent {}

class StopQRScanner extends AccessEvent {}

class ProcessQRCode extends AccessEvent {
  final String qrData;
  final String miembroId;

  const ProcessQRCode({
    required this.qrData,
    required this.miembroId,
  });
}

// Eventos de acceso manual
class MarcarEntradaManual extends AccessEvent {
  final String miembroId;

  const MarcarEntradaManual({required this.miembroId});
}

class MarcarSalidaManual extends AccessEvent {
  final String miembroId;

  const MarcarSalidaManual({required this.miembroId});
}

// Eventos de historial
class LoadHistorialAccesos extends AccessEvent {
  final String miembroId;

  const LoadHistorialAccesos({required this.miembroId});
}

// Evento para verificar estado del miembro
class VerificarEstadoMiembro extends AccessEvent {
  final String miembroId;

  const VerificarEstadoMiembro({required this.miembroId});
}

// Evento para limpiar resultados
class ClearAccessResult extends AccessEvent {}

// Evento para reiniciar scanner
class ResetQRScanner extends AccessEvent {}