// lib/models/libro.dart
class Libro {
  final String id;
  final String titulo;
  final String autor;
  final String categoria;
  final bool disponible;
  final String? createdAt;
  final String? updatedAt;

  Libro({
    required this.id,
    required this.titulo,
    required this.autor,
    required this.categoria,
    required this.disponible,
    this.createdAt,
    this.updatedAt,
  });

  factory Libro.fromJson(Map<String, dynamic> json) {
    return Libro(
      id: json['id']?.toString() ?? '',
      titulo: json['titulo'] ?? '',
      autor: json['autor'] ?? '',
      categoria: json['categoria'] ?? '',
      disponible: json['disponible'] ?? false,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'autor': autor,
      'categoria': categoria,
      'disponible': disponible,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Getters de utilidad
  String get tituloCompleto => titulo;
  String get autorCompleto => autor;
  String get estadoDisponibilidad => disponible ? 'Disponible' : 'No Disponible';

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