// lib/models/libro.dart
class Libro {
  final String id;
  final String titulo;
  final String autor;
  final String categoria;
  final bool disponible;
  final String? isbn;
  final String? descripcion;
  final String? editorial;
  final String? fechaPublicacion;
  final String? qrCode;        // ✨ QR único del libro para préstamos
  final int? cantidadTotal;    // Total de copias
  final int? cantidadDisponible; // Copias disponibles

  Libro({
    required this.id,
    required this.titulo,
    required this.autor,
    required this.categoria,
    required this.disponible,
    this.isbn,
    this.descripcion,
    this.editorial,
    this.fechaPublicacion,
    this.qrCode,
    this.cantidadTotal,
    this.cantidadDisponible,
  });

  factory Libro.fromJson(Map<String, dynamic> json) {
    return Libro(
      id: json['id'] ?? '',
      titulo: json['titulo'] ?? '',
      autor: json['autor'] ?? '',
      categoria: json['categoria'] ?? '',
      disponible: json['disponible'] ?? false,
      isbn: json['isbn'],
      descripcion: json['descripcion'],
      editorial: json['editorial'],
      fechaPublicacion: json['fechaPublicacion'],
      qrCode: json['qrCode'],
      cantidadTotal: json['cantidadTotal'],
      cantidadDisponible: json['cantidadDisponible'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'autor': autor,
      'categoria': categoria,
      'disponible': disponible,
      'isbn': isbn,
      'descripcion': descripcion,
      'editorial': editorial,
      'fechaPublicacion': fechaPublicacion,
      'qrCode': qrCode,
      'cantidadTotal': cantidadTotal,
      'cantidadDisponible': cantidadDisponible,
    };
  }

  // Getters de utilidad
  String get tituloCompleto => titulo;
  String get autorCompleto => autor;
  String get estadoDisponibilidad => disponible ? 'Disponible' : 'No Disponible';
  
  // Información de disponibilidad detallada
  String get infoDisponibilidad {
    if (cantidadTotal != null && cantidadDisponible != null) {
      return '$cantidadDisponible de $cantidadTotal disponibles';
    }
    return estadoDisponibilidad;
  }

  // Verificar si se puede prestar
  bool get sePuedePrestar => disponible && (cantidadDisponible == null || cantidadDisponible! > 0);

  @override
  String toString() {
    return 'Libro(id: $id, titulo: $titulo, autor: $autor, disponible: $disponible)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Libro && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}