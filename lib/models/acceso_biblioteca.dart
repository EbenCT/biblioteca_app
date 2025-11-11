// lib/models/acceso_biblioteca.dart
import 'miembro.dart';

enum TipoAcceso {
  entrada,
  salida,
}

extension TipoAccesoExtension on TipoAcceso {
  String get value {
    switch (this) {
      case TipoAcceso.entrada:
        return 'ENTRADA';
      case TipoAcceso.salida:
        return 'SALIDA';
    }
  }

  String get displayName {
    switch (this) {
      case TipoAcceso.entrada:
        return 'Entrada';
      case TipoAcceso.salida:
        return 'Salida';
    }
  }

  String get emoji {
    switch (this) {
      case TipoAcceso.entrada:
        return '📍';
      case TipoAcceso.salida:
        return '🚪';
    }
  }
}

class AccesoBiblioteca {
  final String id;
  final String fechaEntrada;
  final String? fechaSalida;
  final String miembroId;
  final String? qrCode;           // ✨ Código QR escaneado
  final TipoAcceso tipoAcceso;    // ENTRADA | SALIDA
  final Miembro? miembro;         // Información del miembro (opcional)
  final String? createdAt;
  final String? updatedAt;

  AccesoBiblioteca({
    required this.id,
    required this.fechaEntrada,
    this.fechaSalida,
    required this.miembroId,
    this.qrCode,
    required this.tipoAcceso,
    this.miembro,
    this.createdAt,
    this.updatedAt,
  });

  factory AccesoBiblioteca.fromJson(Map<String, dynamic> json) {
    return AccesoBiblioteca(
      id: json['id'] ?? '',
      fechaEntrada: json['fechaEntrada'] ?? '',
      fechaSalida: json['fechaSalida'],
      miembroId: json['miembroId'] ?? '',
      qrCode: json['qrCode'],
      tipoAcceso: _parseTipoAcceso(json['tipoAcceso']),
      miembro: json['miembro'] != null ? Miembro.fromJson(json['miembro']) : null,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fechaEntrada': fechaEntrada,
      'fechaSalida': fechaSalida,
      'miembroId': miembroId,
      'qrCode': qrCode,
      'tipoAcceso': tipoAcceso.value,
      'miembro': miembro?.toJson(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Helper para parsear tipo de acceso
  static TipoAcceso _parseTipoAcceso(dynamic value) {
    if (value == null) return TipoAcceso.entrada;
    
    final stringValue = value.toString().toUpperCase();
    switch (stringValue) {
      case 'ENTRADA':
        return TipoAcceso.entrada;
      case 'SALIDA':
        return TipoAcceso.salida;
      default:
        return TipoAcceso.entrada;
    }
  }

  // Getters de utilidad
  DateTime get fechaEntradaDateTime {
    try {
      return DateTime.parse(fechaEntrada);
    } catch (e) {
      return DateTime.now();
    }
  }

  DateTime? get fechaSalidaDateTime {
    if (fechaSalida == null) return null;
    try {
      return DateTime.parse(fechaSalida!);
    } catch (e) {
      return null;
    }
  }

  // Verificar si el acceso está activo (entrada sin salida)
  bool get esAccesoActivo => fechaSalida == null && tipoAcceso == TipoAcceso.entrada;

  // Calcular duración de la visita
  Duration? get duracionVisita {
    final salida = fechaSalidaDateTime;
    if (salida == null) return null;
    
    return salida.difference(fechaEntradaDateTime);
  }

  // Formatear duración para mostrar
  String get duracionFormateada {
    final duracion = duracionVisita;
    if (duracion == null) return 'En progreso';
    
    final horas = duracion.inHours;
    final minutos = duracion.inMinutes % 60;
    
    if (horas > 0) {
      return '${horas}h ${minutos}m';
    } else {
      return '${minutos}m';
    }
  }

  // Información completa del acceso
  String get resumenAcceso {
    final tipo = tipoAcceso.emoji;
    final nombre = miembro?.nombreCompleto ?? 'Usuario';
    final fecha = fechaEntradaDateTime;
    
    return '$tipo $nombre - ${fecha.day}/${fecha.month} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'AccesoBiblioteca(id: $id, tipo: ${tipoAcceso.value}, miembro: ${miembro?.nombreCompleto}, entrada: $fechaEntrada)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AccesoBiblioteca && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}