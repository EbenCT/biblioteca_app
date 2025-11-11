// lib/models/miembro.dart
import 'user.dart';

class Miembro {
  final String id;
  final String nombre;
  final String apellido;
  final String direccion;
  final String telefono;
  final String fechaRegistro;
  final String? qrPersonal; // ✨ QR personal único del miembro
  final String? usuarioId;  // Relación con User
  final User? usuario;      // Usuario asociado (opcional para poblado)

  Miembro({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.direccion,
    required this.telefono,
    required this.fechaRegistro,
    this.qrPersonal,
    this.usuarioId,
    this.usuario,
  });

  factory Miembro.fromJson(Map<String, dynamic> json) {
    return Miembro(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      direccion: json['direccion'] ?? '',
      telefono: json['telefono'] ?? '',
      fechaRegistro: json['fechaRegistro'] ?? '',
      qrPersonal: json['qrPersonal'],
      usuarioId: json['usuarioId'],
      usuario: json['usuario'] != null ? User.fromJson(json['usuario']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'direccion': direccion,
      'telefono': telefono,
      'fechaRegistro': fechaRegistro,
      'qrPersonal': qrPersonal,
      'usuarioId': usuarioId,
      'usuario': usuario?.toJson(),
    };
  }

  // Getters de utilidad
  String get nombreCompleto => '$nombre $apellido';
  String get iniciales => '${nombre.isNotEmpty ? nombre[0] : ''}${apellido.isNotEmpty ? apellido[0] : ''}';
  
  // Formatear fecha de registro
  DateTime get fechaRegistroDateTime {
    try {
      return DateTime.parse(fechaRegistro);
    } catch (e) {
      return DateTime.now();
    }
  }

  @override
  String toString() {
    return 'Miembro(id: $id, nombreCompleto: $nombreCompleto, telefono: $telefono)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Miembro && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}