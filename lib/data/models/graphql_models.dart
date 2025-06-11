// GraphQL Models based on the schema

class Usuario {
  final String id;
  final String name;
  final String email;
  final Rol? rol;

  Usuario({
    required this.id,
    required this.name,
    required this.email,
    this.rol,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      rol: json['rol'] != null ? Rol.fromJson(json['rol']) : null,
    );
  }
}

class Rol {
  final String id;
  final String name;

  Rol({
    required this.id,
    required this.name,
  });

  factory Rol.fromJson(Map<String, dynamic> json) {
    return Rol(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}

class Miembro {
  final String id;
  final String ci;
  final String nombre;
  final String? direccion;
  final int? celular;
  final String? sexo;
  final int? edad;
  final Usuario? usuario;

  Miembro({
    required this.id,
    required this.ci,
    required this.nombre,
    this.direccion,
    this.celular,
    this.sexo,
    this.edad,
    this.usuario,
  });

  factory Miembro.fromJson(Map<String, dynamic> json) {
    return Miembro(
      id: json['id'] as String,
      ci: json['ci'] as String,
      nombre: json['nombre'] as String,
      direccion: json['direccion'] as String?,
      celular: json['celular'] as int?,
      sexo: json['sexo'] as String?,
      edad: json['edad'] as int?,
      usuario: json['usuario'] != null ? Usuario.fromJson(json['usuario']) : null,
    );
  }
}

class Ejemplar {
  final String id;
  final String nombre;
  final int stock;
  final String? editorial;
  final Tipo? tipo;
  final Autor? autor;

  Ejemplar({
    required this.id,
    required this.nombre,
    required this.stock,
    this.editorial,
    this.tipo,
    this.autor,
  });

  factory Ejemplar.fromJson(Map<String, dynamic> json) {
    return Ejemplar(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      stock: json['stock'] as int,
      editorial: json['editorial'] as String?,
      tipo: json['tipo'] != null ? Tipo.fromJson(json['tipo']) : null,
      autor: json['autor'] != null ? Autor.fromJson(json['autor']) : null,
    );
  }
}

class Tipo {
  final String id;
  final String nombre;
  final String? descripcion;

  Tipo({
    required this.id,
    required this.nombre,
    this.descripcion,
  });

  factory Tipo.fromJson(Map<String, dynamic> json) {
    return Tipo(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
    );
  }
}

class Autor {
  final String id;
  final String nombre;
  final String? nacionalidad;

  Autor({
    required this.id,
    required this.nombre,
    this.nacionalidad,
  });

  factory Autor.fromJson(Map<String, dynamic> json) {
    return Autor(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      nacionalidad: json['nacionalidad'] as String?,
    );
  }
}

class Prestamo {
  final String id;
  final DateTime fechaInicio;
  final DateTime fechaDevolucion;
  final Miembro miembro;
  final List<DetallePrestamo> detalles;

  Prestamo({
    required this.id,
    required this.fechaInicio,
    required this.fechaDevolucion,
    required this.miembro,
    required this.detalles,
  });

  factory Prestamo.fromJson(Map<String, dynamic> json) {
    return Prestamo(
      id: json['id'] as String,
      fechaInicio: DateTime.parse(json['fechaInicio'] as String),
      fechaDevolucion: DateTime.parse(json['fechaDevolucion'] as String),
      miembro: Miembro.fromJson(json['miembro']),
      detalles: (json['detalles'] as List)
          .map((detail) => DetallePrestamo.fromJson(detail))
          .toList(),
    );
  }
}

class DetallePrestamo {
  final String id;
  final int cantidad;
  final Ejemplar ejemplar;

  DetallePrestamo({
    required this.id,
    required this.cantidad,
    required this.ejemplar,
  });

  factory DetallePrestamo.fromJson(Map<String, dynamic> json) {
    return DetallePrestamo(
      id: json['id'] as String,
      cantidad: json['cantidad'] as int,
      ejemplar: Ejemplar.fromJson(json['ejemplar']),
    );
  }
}

class Reserva {
  final String id;
  final DateTime fechaRegistro;
  final DateTime fechaRecojo;
  final Miembro miembro;
  final List<DetalleReserva> detalles;

  Reserva({
    required this.id,
    required this.fechaRegistro,
    required this.fechaRecojo,
    required this.miembro,
    required this.detalles,
  });

  factory Reserva.fromJson(Map<String, dynamic> json) {
    return Reserva(
      id: json['id'] as String,
      fechaRegistro: DateTime.parse(json['fechaRegistro'] as String),
      fechaRecojo: DateTime.parse(json['fechaRecojo'] as String),
      miembro: Miembro.fromJson(json['miembro']),
      detalles: (json['detalles'] as List)
          .map((detail) => DetalleReserva.fromJson(detail))
          .toList(),
    );
  }
}

class DetalleReserva {
  final String id;
  final int cantidad;
  final Ejemplar ejemplar;

  DetalleReserva({
    required this.id,
    required this.cantidad,
    required this.ejemplar,
  });

  factory DetalleReserva.fromJson(Map<String, dynamic> json) {
    return DetalleReserva(
      id: json['id'] as String,
      cantidad: json['cantidad'] as int,
      ejemplar: Ejemplar.fromJson(json['ejemplar']),
    );
  }
}

// Pagination models
class PaginatedResult<T> {
  final List<T> content;
  final int totalElements;
  final int totalPages;
  final int size;
  final int number;
  final bool first;
  final bool last;

  PaginatedResult({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.size,
    required this.number,
    required this.first,
    required this.last,
  });

  factory PaginatedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResult<T>(
      content: (json['content'] as List)
          .map((item) => fromJsonT(item))
          .toList(),
      totalElements: json['totalElements'] as int,
      totalPages: json['totalPages'] as int,
      size: json['size'] as int,
      number: json['number'] as int,
      first: json['first'] as bool,
      last: json['last'] as bool,
    );
  }
}