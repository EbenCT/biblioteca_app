import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/reservation/reservation_bloc.dart';
import '../../../domain/entities/entities.dart';
import 'book_detail_page.dart';
import 'package:intl/intl.dart';

class ReservationsPage extends StatefulWidget {
  const ReservationsPage({super.key});

  @override
  State<ReservationsPage> createState() => _ReservationsPageState();
}

class _ReservationsPageState extends State<ReservationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ReservationBloc>().add(const GetReservationsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis reservas'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<ReservationBloc>().add(const GetReservationsEvent());
        },
        child: BlocBuilder<ReservationBloc, ReservationState>(
          builder: (context, state) {
            if (state is ReservationsLoaded) {
              if (state.reservations.isEmpty) {
                return const Center(
                  child: Text('No tienes reservas activas'),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.reservations.length,
                itemBuilder: (context, index) {
                  final reservation = state.reservations[index];
                  return ReservationCard(
                    reservation: reservation,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BookDetailPage(bookId: reservation.bookId),
                        ),
                      );
                    },
                    onCancel: () {
                      _showCancelDialog(context, reservation);
                    },
                  );
                },
              );
            } else if (state is ReservationLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is ReservationError) {
              return Center(
                child: Text(
                  'Error: ${state.message}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, Reservation reservation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Reserva'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Estás seguro de cancelar la reserva para "${reservation.bookTitle}"?'),
            const SizedBox(height: 8),
            const Text(
              'Al cancelar la reserva, perderás tu lugar y el libro podrá ser reservado por otro usuario.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('No, mantener'),
          ),
          BlocConsumer<ReservationBloc, ReservationState>(
            listener: (context, state) {
              if (state is ReservationCancelled) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reserva cancelada con éxito'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Refresh reservations
                context.read<ReservationBloc>().add(const GetReservationsEvent());
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
                              CancelReservationEvent(reservation.id),
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
                    : const Text('Sí, cancelar'),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ReservationCard extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback onTap;
  final VoidCallback onCancel;

  const ReservationCard({
    super.key,
    required this.reservation,
    required this.onTap,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final daysLeft = reservation.expirationDate.difference(DateTime.now()).inDays;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Book cover
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      reservation.bookImageUrl,
                      width: 80,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Reservation details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reservation.bookTitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        
                        // Reservation dates
                        _buildInfoRow(
                          context,
                          Icons.date_range,
                          'Reservado: ${dateFormat.format(reservation.reservationDate)}',
                        ),
                        const SizedBox(height: 4),
                        _buildInfoRow(
                          context,
                          Icons.event,
                          'Expira: ${dateFormat.format(reservation.expirationDate)}',
                          color: daysLeft <= 1 ? Colors.red : null,
                          fontWeight: daysLeft <= 1 ? FontWeight.bold : null,
                        ),
                        
                        // Reservation status
                        const SizedBox(height: 8),
                        _buildStatusChip(
                          context,
                          reservation.status == 'active'
                              ? 'Activa'
                              : reservation.status == 'expired'
                                  ? 'Expirada'
                                  : reservation.status == 'completed'
                                      ? 'Completada'
                                      : 'Cancelada',
                          reservation.status == 'active'
                              ? Colors.green
                              : reservation.status == 'expired'
                                  ? Colors.red
                                  : reservation.status == 'completed'
                                      ? Colors.blue
                                      : Colors.grey,
                        ),
                        
                        // Expiration notice
                        if (reservation.status == 'active' && daysLeft <= 1) ...[
                          const SizedBox(height: 8),
                          Text(
                            daysLeft == 0
                                ? '¡Expira hoy!'
                                : daysLeft == 1
                                    ? '¡Expira mañana!'
                                    : '',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              
              // Cancel button (only for active reservations)
              if (reservation.status == 'active') ...[
                const SizedBox(height: 12),
                const Divider(),
                Center(
                  child: TextButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.close),
                    label: const Text('Cancelar reserva'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String text, {
    Color? color,
    FontWeight? fontWeight,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color ?? Colors.grey.shade600,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: color ?? Colors.grey.shade600,
            fontWeight: fontWeight,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
