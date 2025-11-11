// lib/models/prestamo.dart
class Prestamo {
  final String id;
  final String fechaPrestamo;
  final String fechaDevolucionEsperada;
  final String? fechaDevolucionReal;
  final bool estado;
  final double? multa;
  final String? libroId;
  final String? miembroId;
  final String? createdAt;
  final String? updatedAt;

  Prestamo({
    required this.id,
    required this.fechaPrestamo,
    required this.fechaDevolucionEsperada,
    this.fechaDevolucionReal,
    required this.estado,
    this.multa,
    this.libroId,
    this.miembroId,
    this.createdAt,
    this.updatedAt,
  });

  factory Prestamo.fromJson(Map<String, dynamic> json) {
    return Prestamo(
      id: json['id']?.toString() ?? '',
      fechaPrestamo: json['fechaPrestamo'] ?? '',
      fechaDevolucionEsperada: json['fechaDevolucionEsperada'] ?? '',
      fechaDevolucionReal: json['fechaDevolucionReal'],
      estado: json['estado'] ?? false,
      multa: json['multa']?.toDouble(),
      libroId: json['libroId']?.toString(),
      miembroId: json['miembroId']?.toString(),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fechaPrestamo': fechaPrestamo,
      'fechaDevolucionEsperada': fechaDevolucionEsperada,
      'fechaDevolucionReal': fechaDevolucionReal,
      'estado': estado,
      'multa': multa,
      'libroId': libroId,
      'miembroId': miembroId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  @override
  String toString() {
    return 'Prestamo(id: $id, libroId: $libroId, estado: $estado)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Prestamo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}