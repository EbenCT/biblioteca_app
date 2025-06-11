class GraphQLQueries {
  // Usuario Queries
  static const String getUsuarios = '''
    query GetUsuarios(\$page: Int, \$size: Int) {
      usuarios(page: \$page, size: \$size) {
        content {
          id
          name
          email
          rol {
            id
            name
          }
        }
        totalElements
        totalPages
        size
        number
        first
        last
      }
    }
  ''';

  static const String getUsuario = '''
    query GetUsuario(\$id: ID!) {
      usuario(id: \$id) {
        id
        name
        email
        rol {
          id
          name
        }
      }
    }
  ''';

  static const String getUsuarioByEmail = '''
    query GetUsuarioByEmail(\$email: String!) {
      usuarioByEmail(email: \$email) {
        id
        name
        email
        rol {
          id
          name
        }
      }
    }
  ''';

  // Miembro Queries
  static const String getMiembros = '''
    query GetMiembros(\$page: Int, \$size: Int) {
      miembros(page: \$page, size: \$size) {
        content {
          id
          ci
          nombre
          direccion
          celular
          sexo
          edad
          usuario {
            id
            name
            email
          }
        }
        totalElements
        totalPages
        size
        number
        first
        last
      }
    }
  ''';

  static const String getMiembro = '''
    query GetMiembro(\$id: ID!) {
      miembro(id: \$id) {
        id
        ci
        nombre
        direccion
        celular
        sexo
        edad
        usuario {
          id
          name
          email
        }
      }
    }
  ''';

  static const String buscarMiembros = '''
    query BuscarMiembros(\$nombre: String!, \$page: Int, \$size: Int) {
      buscarMiembros(nombre: \$nombre, page: \$page, size: \$size) {
        content {
          id
          ci
          nombre
          direccion
          celular
          sexo
          edad
        }
        totalElements
        totalPages
        size
        number
        first
        last
      }
    }
  ''';

  // Ejemplar Queries
  static const String getEjemplares = '''
    query GetEjemplares(\$page: Int, \$size: Int) {
      ejemplares(page: \$page, size: \$size) {
        content {
          id
          nombre
          stock
          editorial
          tipo {
            id
            nombre
            descripcion
          }
          autor {
            id
            nombre
            nacionalidad
          }
        }
        totalElements
        totalPages
        size
        number
        first
        last
      }
    }
  ''';

  static const String getEjemplar = '''
    query GetEjemplar(\$id: ID!) {
      ejemplar(id: \$id) {
        id
        nombre
        stock
        editorial
        tipo {
          id
          nombre
          descripcion
        }
        autor {
          id
          nombre
          nacionalidad
        }
      }
    }
  ''';

  static const String buscarEjemplares = '''
    query BuscarEjemplares(\$nombre: String!, \$page: Int, \$size: Int) {
      buscarEjemplares(nombre: \$nombre, page: \$page, size: \$size) {
        content {
          id
          nombre
          stock
          editorial
          tipo {
            id
            nombre
            descripcion
          }
          autor {
            id
            nombre
            nacionalidad
          }
        }
        totalElements
        totalPages
        size
        number
        first
        last
      }
    }
  ''';

  static const String getEjemplaresDisponibles = '''
    query GetEjemplaresDisponibles {
      ejemplaresDisponibles {
        id
        nombre
        stock
        editorial
        tipo {
          id
          nombre
          descripcion
        }
        autor {
          id
          nombre
          nacionalidad
        }
      }
    }
  ''';

  // Prestamo Queries
  static const String getPrestamos = '''
    query GetPrestamos(\$page: Int, \$size: Int) {
      prestamos(page: \$page, size: \$size) {
        content {
          id
          fechaInicio
          fechaDevolucion
          miembro {
            id
            ci
            nombre
          }
          detalles {
            id
            cantidad
            ejemplar {
              id
              nombre
              editorial
              autor {
                id
                nombre
              }
            }
          }
        }
        totalElements
        totalPages
        size
        number
        first
        last
      }
    }
  ''';

  static const String getPrestamosPorMiembro = '''
    query GetPrestamosPorMiembro(\$miembroId: ID!) {
      prestamosPorMiembro(miembroId: \$miembroId) {
        id
        fechaInicio
        fechaDevolucion
        detalles {
          id
          cantidad
          ejemplar {
            id
            nombre
            editorial
            autor {
              id
              nombre
            }
          }
        }
      }
    }
  ''';

  static const String getPrestamosVencidos = '''
    query GetPrestamosVencidos {
      prestamosVencidos {
        id
        fechaInicio
        fechaDevolucion
        miembro {
          id
          ci
          nombre
        }
        detalles {
          id
          cantidad
          ejemplar {
            id
            nombre
            editorial
          }
        }
      }
    }
  ''';

  // Reserva Queries
  static const String getReservas = '''
    query GetReservas(\$page: Int, \$size: Int) {
      reservas(page: \$page, size: \$size) {
        content {
          id
          fechaRegistro
          fechaRecojo
          miembro {
            id
            ci
            nombre
          }
          detalles {
            id
            cantidad
            ejemplar {
              id
              nombre
              editorial
              autor {
                id
                nombre
              }
            }
          }
        }
        totalElements
        totalPages
        size
        number
        first
        last
      }
    }
  ''';

  static const String getReservasPorMiembro = '''
    query GetReservasPorMiembro(\$miembroId: ID!) {
      reservasPorMiembro(miembroId: \$miembroId) {
        id
        fechaRegistro
        fechaRecojo
        detalles {
          id
          cantidad
          ejemplar {
            id
            nombre
            editorial
            autor {
              id
              nombre
            }
          }
        }
      }
    }
  ''';

  // Autor Queries
  static const String getAutores = '''
    query GetAutores(\$page: Int, \$size: Int) {
      autores(page: \$page, size: \$size) {
        content {
          id
          nombre
          nacionalidad
        }
        totalElements
        totalPages
        size
        number
        first
        last
      }
    }
  ''';

  static const String buscarAutores = '''
    query BuscarAutores(\$nombre: String!, \$page: Int, \$size: Int) {
      buscarAutores(nombre: \$nombre, page: \$page, size: \$size) {
        content {
          id
          nombre
          nacionalidad
        }
        totalElements
        totalPages
        size
        number
        first
        last
      }
    }
  ''';

  static const String getTodosLosAutores = '''
    query GetTodosLosAutores {
      todosLosAutores {
        id
        nombre
        nacionalidad
      }
    }
  ''';

  // Tipo Queries
  static const String getTipos = '''
    query GetTipos {
      tipos {
        id
        nombre
        descripcion
      }
    }
  ''';

  // Rol Queries
  static const String getRoles = '''
    query GetRoles {
      roles {
        id
        name
      }
    }
  ''';
}

class GraphQLMutations {
  // Usuario Mutations
  static const String crearUsuario = '''
    mutation CrearUsuario(\$input: CreateUsuarioInput!) {
      crearUsuario(input: \$input) {
        id
        name
        email
        rol {
          id
          name
        }
      }
    }
  ''';

  static const String actualizarUsuario = '''
    mutation ActualizarUsuario(\$id: ID!, \$input: CreateUsuarioInput!) {
      actualizarUsuario(id: \$id, input: \$input) {
        id
        name
        email
        rol {
          id
          name
        }
      }
    }
  ''';

  // Miembro Mutations
  static const String crearMiembro = '''
    mutation CrearMiembro(\$input: CreateMiembroInput!) {
      crearMiembro(input: \$input) {
        id
        ci
        nombre
        direccion
        celular
        sexo
        edad
        usuario {
          id
          name
          email
        }
      }
    }
  ''';

  // Prestamo Mutations
  static const String crearPrestamo = '''
    mutation CrearPrestamo(\$input: CreatePrestamoInput!) {
      crearPrestamo(input: \$input) {
        id
        fechaInicio
        fechaDevolucion
        miembro {
          id
          nombre
        }
        detalles {
          id
          cantidad
          ejemplar {
            id
            nombre
          }
        }
      }
    }
  ''';

  // Ejemplar Mutations
  static const String crearEjemplar = '''
    mutation CrearEjemplar(\$input: CreateEjemplarInput!) {
      crearEjemplar(input: \$input) {
        id
        nombre
        stock
        editorial
        tipo {
          id
          nombre
        }
        autor {
          id
          nombre
        }
      }
    }
  ''';
}