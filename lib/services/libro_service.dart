// lib/services/libro_service.dart
import '../models/libro.dart';
import 'graphql_service.dart';

class LibroService {
  
  // Obtener libros del backend
  static Future<List<Libro>> getLibrosFromBackend() async {
    try {
      final librosData = await GraphQLService.getLibros();
      return librosData.map((data) => Libro.fromJson(data)).toList();
    } catch (e) {
      print('Error obteniendo libros del backend: $e');
      return [];
    }
  }

  // Libros estáticos con imágenes de portada de internet
  static List<Libro> getLibrosEstaticos() {
    return [
      Libro(
        id: 'static_1',
        titulo: 'Cien años de soledad',
        autor: 'Gabriel García Márquez',
        categoria: 'Realismo Mágico',
        disponible: true,
        imagenPortada: 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1327881361i/320.jpg',
      ),
      Libro(
        id: 'static_2',
        titulo: 'Don Quijote de la Mancha',
        autor: 'Miguel de Cervantes',
        categoria: 'Clásico',
        disponible: true,
        imagenPortada: 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1546112331i/3836.jpg',
      ),
      Libro(
        id: 'static_3',
        titulo: '1984',
        autor: 'George Orwell',
        categoria: 'Distopía',
        disponible: false,
        imagenPortada: 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1532714506i/40961427.jpg',
      ),
      Libro(
        id: 'static_4',
        titulo: 'El Principito',
        autor: 'Antoine de Saint-Exupéry',
        categoria: 'Fábula',
        disponible: true,
        imagenPortada: 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1367545443i/157993.jpg',
      ),
      Libro(
        id: 'static_5',
        titulo: 'Orgullo y Prejuicio',
        autor: 'Jane Austen',
        categoria: 'Romance',
        disponible: true,
        imagenPortada: 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1320399351i/1885.jpg',
      ),
      Libro(
        id: 'static_6',
        titulo: 'El Hobbit',
        autor: 'J.R.R. Tolkien',
        categoria: 'Fantasía',
        disponible: false,
        imagenPortada: 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1546071216i/5907.jpg',
      ),
      Libro(
        id: 'static_7',
        titulo: 'Crónica de una muerte anunciada',
        autor: 'Gabriel García Márquez',
        categoria: 'Realismo Mágico',
        disponible: true,
        imagenPortada: 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1327878452i/23878.jpg',
      ),
      Libro(
        id: 'static_8',
        titulo: 'El amor en los tiempos del cólera',
        autor: 'Gabriel García Márquez',
        categoria: 'Romance',
        disponible: true,
        imagenPortada: 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1327881335i/9712.jpg',
      ),
      Libro(
        id: 'static_9',
        titulo: 'La Casa de los Espíritus',
        autor: 'Isabel Allende',
        categoria: 'Realismo Mágico',
        disponible: false,
        imagenPortada: 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1371057135i/9328.jpg',
      ),
      Libro(
        id: 'static_10',
        titulo: 'El Alquimista',
        autor: 'Paulo Coelho',
        categoria: 'Filosofía',
        disponible: true,
        imagenPortada: 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1466865542i/865.jpg',
      ),
    ];
  }

  // Obtener todos los libros (backend + estáticos)
  static Future<List<Libro>> getTodosLosLibros() async {
    try {
      final librosBackend = await getLibrosFromBackend();
      final librosEstaticos = getLibrosEstaticos();
      
      // Combinar las dos listas
      final todosLosLibros = <Libro>[];
      todosLosLibros.addAll(librosBackend);
      todosLosLibros.addAll(librosEstaticos);
      
      // Ordenar por título
      todosLosLibros.sort((a, b) => a.titulo.compareTo(b.titulo));
      
      return todosLosLibros;
    } catch (e) {
      print('Error obteniendo todos los libros: $e');
      // En caso de error, devolver solo los estáticos
      return getLibrosEstaticos();
    }
  }

  // Filtrar libros por disponibilidad
  static List<Libro> filtrarPorDisponibilidad(List<Libro> libros, bool disponible) {
    return libros.where((libro) => libro.disponible == disponible).toList();
  }

  // Filtrar libros por categoría
  static List<Libro> filtrarPorCategoria(List<Libro> libros, String categoria) {
    return libros.where((libro) => 
      libro.categoria.toLowerCase().contains(categoria.toLowerCase())
    ).toList();
  }

  // Buscar libros por título o autor
  static List<Libro> buscarLibros(List<Libro> libros, String query) {
    if (query.isEmpty) return libros;
    
    final queryLower = query.toLowerCase();
    return libros.where((libro) => 
      libro.titulo.toLowerCase().contains(queryLower) ||
      libro.autor.toLowerCase().contains(queryLower)
    ).toList();
  }

  // Obtener categorías únicas
  static List<String> getCategorias(List<Libro> libros) {
    final categorias = libros.map((libro) => libro.categoria).toSet().toList();
    categorias.sort();
    return categorias;
  }
}