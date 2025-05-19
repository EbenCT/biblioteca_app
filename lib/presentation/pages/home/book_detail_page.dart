import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/book/book_bloc.dart';
import '../../bloc/reservation/reservation_bloc.dart';
import '../../../domain/entities/entities.dart';
import '../../widgets/review_card.dart';

class BookDetailPage extends StatefulWidget {
  final String bookId;

  const BookDetailPage({
    super.key,
    required this.bookId,
  });

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<BookBloc>().add(GetBookByIdEvent(widget.bookId));
    context.read<BookBloc>().add(GetBookReviewsEvent(widget.bookId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<BookBloc, BookState>(
        builder: (context, state) {
          if (state is BookDetailsLoaded) {
            final book = state.book;
            return CustomScrollView(
              slivers: [
                // App Bar with book cover
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          book.imageUrl,
                          fit: BoxFit.cover,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Book details
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and availability
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                book.title,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: book.isAvailable ? Colors.green : Colors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                book.isAvailable ? 'Disponible' : 'No disponible',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Authors
                        Text(
                          'Por ${book.authors.join(', ')}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Rating
                        Row(
                          children: [
                            ...List.generate(
                              5,
                              (index) => Icon(
                                index < book.rating.floor()
                                    ? Icons.star
                                    : (index < book.rating
                                        ? Icons.star_half
                                        : Icons.star_border),
                                color: Colors.amber.shade700,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${book.rating} (${book.ratingCount} reseñas)',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Book details
                        _buildDetailItem(
                          context,
                          'Editorial',
                          book.publisher,
                        ),
                        _buildDetailItem(
                          context,
                          'Año de publicación',
                          book.publishYear,
                        ),
                        _buildDetailItem(
                          context,
                          'Categoría',
                          book.category,
                        ),
                        _buildDetailItem(
                          context,
                          'Tipo',
                          book.type,
                        ),
                        const SizedBox(height: 16),

                        // Description
                        Text(
                          'Descripción',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          book.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),

                        // Reviews
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Reseñas',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                // Show dialog to add review
                                _showAddReviewDialog(context, book.id);
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Añadir reseña'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Reviews
                BlocBuilder<BookBloc, BookState>(
                  builder: (context, state) {
                    if (state is BookReviewsLoaded) {
                      if (state.reviews.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: Text('No hay reseñas para este libro aún.'),
                            ),
                          ),
                        );
                      }

                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final review = state.reviews[index];
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: ReviewCard(review: review),
                            );
                          },
                          childCount: state.reviews.length,
                        ),
                      );
                    } else if (state is BookLoading) {
                      return const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      );
                    }
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  },
                ),
                
                // Add some bottom padding
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            );
          } else if (state is BookLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is BookError) {
            return Center(
              child: Text(
                'Error al cargar el libro: ${state.message}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: BlocBuilder<BookBloc, BookState>(
        builder: (context, state) {
          if (state is BookDetailsLoaded) {
            final book = state.book;
            return book.isAvailable
                ? FloatingActionButton.extended(
                    onPressed: () {
                      _showReservationDialog(context, book);
                    },
                    icon: const Icon(Icons.bookmark_add),
                    label: const Text('Reservar'),
                  )
                : const SizedBox.shrink();
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showAddReviewDialog(BuildContext context, String bookId) {
    final _ratingController = TextEditingController();
    final _commentController = TextEditingController();
    double _rating = 3.0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Añadir Reseña'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('¿Cómo calificarías este libro?'),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (context, setState) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (index) => IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber.shade700,
                        ),
                        onPressed: () {
                          setState(() {
                            _rating = index + 1.0;
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  labelText: 'Comentario',
                  hintText: 'Escribe tu opinión sobre el libro',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (_commentController.text.isNotEmpty) {
                context.read<BookBloc>().add(
                      AddBookReviewEvent(
                        bookId: bookId,
                        rating: _rating,
                        comment: _commentController.text,
                      ),
                    );
                Navigator.of(context).pop();
                
                // Refresh reviews after adding
                Future.delayed(const Duration(milliseconds: 500), () {
                  context.read<BookBloc>().add(GetBookReviewsEvent(bookId));
                });
              }
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  void _showReservationDialog(BuildContext context, Book book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reservar Libro'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Deseas reservar "${book.title}"?'),
            const SizedBox(height: 8),
            const Text(
              'Al reservar este libro, tendrás 3 días para recogerlo en la biblioteca. Si no lo haces, la reserva se cancelará automáticamente.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
          BlocConsumer<ReservationBloc, ReservationState>(
            listener: (context, state) {
              if (state is ReservationCreated) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reserva creada con éxito'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is ReservationError) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${state.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              return TextButton(
                onPressed: state is ReservationLoading
                    ? null
                    : () {
                        context.read<ReservationBloc>().add(
                              CreateReservationEvent(book.id),
                            );
                      },
                child: state is ReservationLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Confirmar'),
              );
            },
          ),
        ],
      ),
    );
  }
}
