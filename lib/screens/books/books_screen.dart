// lib/screens/books/books_screen.dart
import 'package:flutter/material.dart';
import '../../models/libro.dart';
import '../../services/libro_service.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  List<Libro> _todosLosLibros = [];
  List<Libro> _librosFiltrados = [];
  List<String> _categorias = [];
  String _categoriaSeleccionada = 'Todas';
  String _busqueda = '';
  bool _soloDisponibles = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarLibros();
  }

  Future<void> _cargarLibros() async {
    setState(() => _isLoading = true);

    try {
      final libros = await LibroService.getTodosLosLibros();
      final categorias = LibroService.getCategorias(libros);

      setState(() {
        _todosLosLibros = libros;
        _librosFiltrados = libros;
        _categorias = ['Todas', ...categorias];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar libros: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _aplicarFiltros() {
    var librosTemp = _todosLosLibros;

    // Filtrar por búsqueda
    if (_busqueda.isNotEmpty) {
      librosTemp = LibroService.buscarLibros(librosTemp, _busqueda);
    }

    // Filtrar por categoría
    if (_categoriaSeleccionada != 'Todas') {
      librosTemp = LibroService.filtrarPorCategoria(librosTemp, _categoriaSeleccionada);
    }

    // Filtrar por disponibilidad
    if (_soloDisponibles) {
      librosTemp = LibroService.filtrarPorDisponibilidad(librosTemp, true);
    }

    setState(() {
      _librosFiltrados = librosTemp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 Biblioteca'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filtros y búsqueda
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade800,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Barra de búsqueda
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar por título o autor...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  onChanged: (value) {
                    setState(() => _busqueda = value);
                    _aplicarFiltros();
                  },
                ),
                const SizedBox(height: 16),

                // Filtros
                Row(
                  children: [
                    // Filtro de categoría
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: DropdownButton<String>(
                          value: _categoriaSeleccionada,
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: _categorias.map((categoria) {
                            return DropdownMenuItem(
                              value: categoria,
                              child: Text(categoria),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _categoriaSeleccionada = value!);
                            _aplicarFiltros();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Filtro de disponibilidad
                    Expanded(
                      flex: 1,
                      child: FilterChip(
                        label: const Text('Solo disponibles'),
                        selected: _soloDisponibles,
                        onSelected: (selected) {
                          setState(() => _soloDisponibles = selected);
                          _aplicarFiltros();
                        },
                        backgroundColor: Colors.white,
                        selectedColor: Colors.green.shade100,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Lista de libros
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _librosFiltrados.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.library_books_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No se encontraron libros',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Intenta ajustar los filtros de búsqueda',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _cargarLibros,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _librosFiltrados.length,
                          itemBuilder: (context, index) {
                            final libro = _librosFiltrados[index];
                            return _LibroCard(libro: libro);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _LibroCard extends StatelessWidget {
  final Libro libro;

  const _LibroCard({required this.libro});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _mostrarDetallesLibro(context, libro),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen de portada
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 120,
                  color: Colors.grey.shade200,
                  child: libro.imagenPortada != null
                      ? Image.network(
                          libro.imagenPortada!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade300,
                              child: const Icon(
                                Icons.book,
                                size: 40,
                                color: Colors.grey,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey.shade200,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                        )
                      : const Icon(
                          Icons.book,
                          size: 40,
                          color: Colors.grey,
                        ),
                ),
              ),
              const SizedBox(width: 16),

              // Información del libro
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      libro.titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'por ${libro.autor}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Text(
                        libro.categoria,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          libro.disponible 
                              ? Icons.check_circle 
                              : Icons.cancel,
                          size: 16,
                          color: libro.disponible 
                              ? Colors.green 
                              : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          libro.disponible 
                              ? 'Disponible' 
                              : 'No disponible',
                          style: TextStyle(
                            fontSize: 12,
                            color: libro.disponible 
                                ? Colors.green.shade700 
                                : Colors.red.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDetallesLibro(BuildContext context, Libro libro) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DetallesLibroModal(libro: libro),
    );
  }
}

class _DetallesLibroModal extends StatelessWidget {
  final Libro libro;

  const _DetallesLibroModal({required this.libro});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle del modal
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Contenido scrolleable
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Imagen y título
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Imagen más grande
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 120,
                              height: 180,
                              color: Colors.grey.shade200,
                              child: libro.imagenPortada != null
                                  ? Image.network(
                                      libro.imagenPortada!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey.shade300,
                                          child: const Icon(
                                            Icons.book,
                                            size: 60,
                                            color: Colors.grey,
                                          ),
                                        );
                                      },
                                    )
                                  : const Icon(
                                      Icons.book,
                                      size: 60,
                                      color: Colors.grey,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 20),

                          // Información principal
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  libro.titulo,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'por ${libro.autor}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Categoría
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.blue.shade200),
                                  ),
                                  child: Text(
                                    libro.categoria,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Estado
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: libro.disponible 
                                        ? Colors.green.shade50 
                                        : Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: libro.disponible 
                                          ? Colors.green.shade200 
                                          : Colors.red.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        libro.disponible 
                                            ? Icons.check_circle 
                                            : Icons.cancel,
                                        size: 20,
                                        color: libro.disponible 
                                            ? Colors.green.shade600 
                                            : Colors.red.shade600,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        libro.disponible 
                                            ? 'Disponible' 
                                            : 'No disponible',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: libro.disponible 
                                              ? Colors.green.shade700 
                                              : Colors.red.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Información adicional
                      if (!libro.disponible) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.orange.shade600,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Este libro no está disponible actualmente. Consulta con el personal de la biblioteca para más información.',
                                  style: TextStyle(
                                    color: Colors.orange.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Nota sobre préstamos
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.library_books,
                              color: Colors.blue.shade600,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Para solicitar un préstamo de este libro, acércate al mostrador de la biblioteca con tu carnet de miembro.',
                                style: TextStyle(
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Botón de cerrar
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cerrar',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}