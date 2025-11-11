// lib/models/acceso_biblioteca.dart
class AccesoBiblioteca {
  final String id;
  final String fechaEntrada;
  final String? fechaSalida;
  final String metodoAcceso;
  final String codigoQr;
  final bool estado;
  final String? miembroId;
  final String? miembroNombre;
  final String? miembroApellido;
  final String? createdAt;
  final String? updatedAt;

  AccesoBiblioteca({
    required this.id,
    required this.fechaEntrada,
    this.fechaSalida,
    required this.metodoAcceso,
    required this.codigoQr,
    required this.estado,
    this.miembroId,
    this.miembroNombre,
    this.miembroApellido,
    this.createdAt,
    this.updatedAt,
  });

  factory AccesoBiblioteca.fromJson(Map<String, dynamic> json) {
    return AccesoBiblioteca(
      id: json['id']?.toString() ?? '',
      fechaEntrada: json['fechaEntrada'] ?? '',
      fechaSalida: json['fechaSalida'],
      metodoAcceso: json['metodoAcceso'] ?? '',
      codigoQr: json['codigoQr'] ?? '',
      estado: json['estado'] ?? false,
      miembroId: json['miembroId']?.toString(),
      miembroNombre: json['miembroNombre'],
      miembroApellido: json['miembroApellido'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fechaEntrada': fechaEntrada,
      'fechaSalida': fechaSalida,
      'metodoAcceso': metodoAcceso,
      'codigoQr': codigoQr,
      'estado': estado,
      'miembroId': miembroId,
      'miembroNombre': miembroNombre,
      'miembroApellido': miembroApellido,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  @override
  String toString() {
    return 'AccesoBiblioteca(id: $id, miembro: $miembroNombre $miembroApellido, entrada: $fechaEntrada)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AccesoBiblioteca && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}