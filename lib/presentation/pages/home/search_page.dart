import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/book/book_bloc.dart';
import 'book_detail_page.dart';
import '../../widgets/book_card.dart';
import '../../../data/mock_data.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  String _selectedCategory = '';
  String _selectedType = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Debounce search
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchController.text == _searchController.text) {
        _performSearch();
      }
    });
  }

  void _performSearch() {
    context.read<BookBloc>().add(
          GetBooksEvent(
            query: _searchController.text,
            category: _selectedCategory.isEmpty ? null : _selectedCategory,
            type: _selectedType.isEmpty ? null : _selectedType,
          ),
        );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _selectedCategory = '';
      _selectedType = '';
    });
    _performSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search TextField
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar libros, autores...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _clearSearch,
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Filter options
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Category filter
                      PopupMenuButton<String>(
                        initialValue: _selectedCategory,
                        child: Chip(
                          label: Text(
                            _selectedCategory.isEmpty
                                ? 'Categoría'
                                : _selectedCategory,
                          ),
                          deleteIcon: _selectedCategory.isNotEmpty
                              ? const Icon(Icons.clear, size: 16)
                              : null,
                          onDeleted: _selectedCategory.isNotEmpty
                              ? () {
                                  setState(() {
                                    _selectedCategory = '';
                                  });
                                  _performSearch();
                                }
                              : null,
                        ),
                        itemBuilder: (context) {
                          return [
                            const PopupMenuItem(
                              value: '',
                              child: Text('Todas'),
                            ),
                            ...MockData.categories.map(
                              (category) => PopupMenuItem(
                                value: category,
                                child: Text(category),
                              ),
                            ),
                          ];
                        },
                        onSelected: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                          _performSearch();
                        },
                      ),
                      const SizedBox(width: 8),

                      // Type filter
                      PopupMenuButton<String>(
                        initialValue: _selectedType,
                        child: Chip(
                          label: Text(
                            _selectedType.isEmpty ? 'Tipo' : _selectedType,
                          ),
                          deleteIcon: _selectedType.isNotEmpty
                              ? const Icon(Icons.clear, size: 16)
                              : null,
                          onDeleted: _selectedType.isNotEmpty
                              ? () {
                                  setState(() {
                                    _selectedType = '';
                                  });
                                  _performSearch();
                                }
                              : null,
                        ),
                        itemBuilder: (context) {
                          return [
                            const PopupMenuItem(
                              value: '',
                              child: Text('Todos'),
                            ),
                            const PopupMenuItem(
                              value: 'Físico',
                              child: Text('Físico'),
                            ),
                            const PopupMenuItem(
                              value: 'Digital',
                              child: Text('Digital'),
                            ),
                          ];
                        },
                        onSelected: (value) {
                          setState(() {
                            _selectedType = value;
                          });
                          _performSearch();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Search results
          Expanded(
            child: BlocBuilder<BookBloc, BookState>(
              builder: (context, state) {
                if (state is BooksLoaded) {
                  if (state.books.isEmpty) {
                    return const Center(
                      child: Text('No se encontraron resultados'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: state.books.length,
                    itemBuilder: (context, index) {
                      final book = state.books[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: BookCard(
                          book: book,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => BookDetailPage(bookId: book.id),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                } else if (state is BookLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is BookError) {
                  return Center(
                    child: Text(
                      'Error al buscar: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                return Center(
                  child: Text(
                    'Busca libros por título, autor o categoría',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
