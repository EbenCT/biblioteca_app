// lib/models/ingreso_egreso_response.dart
class IngresoEgresoResponse {
  final String? accesoId;
  final String? miembroId;
  final String? miembroNombre;
  final String? miembroApellido;
  final String? fechaEntrada;
  final String? fechaSalida;
  final String tipoAccion;
  final String mensaje;
  final bool exitoso;

  IngresoEgresoResponse({
    this.accesoId,
    this.miembroId,
    this.miembroNombre,
    this.miembroApellido,
    this.fechaEntrada,
    this.fechaSalida,
    required this.tipoAccion,
    required this.mensaje,
    required this.exitoso,
  });

  factory IngresoEgresoResponse.fromJson(Map<String, dynamic> json) {
    return IngresoEgresoResponse(
      accesoId: json['accesoId']?.toString(),
      miembroId: json['miembroId']?.toString(),
      miembroNombre: json['miembroNombre'],
      miembroApellido: json['miembroApellido'],
      fechaEntrada: json['fechaEntrada'],
      fechaSalida: json['fechaSalida'],
      tipoAccion: json['tipoAccion'] ?? '',
      mensaje: json['mensaje'] ?? '',
      exitoso: json['exitoso'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accesoId': accesoId,
      'miembroId': miembroId,
      'miembroNombre': miembroNombre,
      'miembroApellido': miembroApellido,
      'fechaEntrada': fechaEntrada,
      'fechaSalida': fechaSalida,
      'tipoAccion': tipoAccion,
      'mensaje': mensaje,
      'exitoso': exitoso,
    };
  }
}