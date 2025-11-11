// lib/models/prestamo.dart
import 'libro.dart';
import 'miembro.dart';

class Prestamo {
  final String id;
  final String fechaPrestamo;
  final String fechaDevolucionEsperada;
  final String? fechaDevolucionReal;
  final bool estado; // true = activo, false = devuelto
  final double? multa;
  final String libroId;
  final String miembroId;
  final Libro? libro;     // Información del libro (opcional)
  final Miembro? miembro; // Información del miembro (opcional)

  Prestamo({
    required this.id,
    required this.fechaPrestamo,
    required this.fechaDevolucionEsperada,
    this.fechaDevolucionReal,
    required this.estado,
    this.multa,
    required this.libroId,
    required this.miembroId,
    this.libro,
    this.miembro,
  });

  factory Prestamo.fromJson(Map<String, dynamic> json) {
    return Prestamo(
      id: json['id'] ?? '',
      fechaPrestamo: json['fechaPrestamo'] ?? '',
      fechaDevolucionEsperada: json['fechaDevolucionEsperada'] ?? '',
      fechaDevolucionReal: json['fechaDevolucionReal'],
      estado: json['estado'] ?? false,
      multa: json['multa']?.toDouble(),
      libroId: json['libroId'] ?? '',
      miembroId: json['miembroId'] ?? '',
      libro: json['libro'] != null ? Libro.fromJson(json['libro']) : null,
      miembro: json['miembro'] != null ? Miembro.fromJson(json['miembro']) : null,
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
      'libro': libro?.toJson(),
      'miembro': miembro?.toJson(),
    };
  }

  // Getters de utilidad
  DateTime get fechaPrestamoDateTime {
    try {
      return DateTime.parse(fechaPrestamo);
    } catch (e) {
      return DateTime.now();
    }
  }

  DateTime get fechaDevolucionEsperadaDateTime {
    try {
      return DateTime.parse(fechaDevolucionEsperada);
    } catch (e) {
      return DateTime.now().add(const Duration(days: 7));
    }
  }

  DateTime? get fechaDevolucionRealDateTime {
    if (fechaDevolucionReal == null) return null;
    try {
      return DateTime.parse(fechaDevolucionReal!);
    } catch (e) {
      return null;
    }
  }

  // Estados del préstamo
  bool get esActivo => estado;
  bool get esDevuelto => !estado;
  bool get estaAtrasado {
    if (!esActivo) return false;
    return DateTime.now().isAfter(fechaDevolucionEsperadaDateTime);
  }

  // Días restantes para devolución
  int get diasRestantes {
    if (!esActivo) return 0;
    final diferencia = fechaDevolucionEsperadaDateTime.difference(DateTime.now()).inDays;
    return diferencia < 0 ? 0 : diferencia;
  }

  // Días de atraso
  int get diasAtraso {
    if (!estaAtrasado) return 0;
    return DateTime.now().difference(fechaDevolucionEsperadaDateTime).inDays;
  }

  // Estado formateado para UI
  String get estadoFormateado {
    if (esDevuelto) return 'Devuelto';
    if (estaAtrasado) return 'Atrasado ($diasAtraso días)';
    if (diasRestantes == 0) return 'Vence hoy';
    if (diasRestantes == 1) return 'Vence mañana';
    return 'Vence en $diasRestantes días';
  }

  // Color del estado para UI
  String get estadoColor {
    if (esDevuelto) return 'green';
    if (estaAtrasado) return 'red';
    if (diasRestantes <= 2) return 'orange';
    return 'blue';
  }

  @override
  String toString() {
    return 'Prestamo(id: $id, libro: ${libro?.titulo}, estado: ${estadoFormateado})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Prestamo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}