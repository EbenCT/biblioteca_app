import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/loan/loan_bloc.dart';
import 'book_detail_page.dart';
import 'package:intl/intl.dart';

class LoanDetailPage extends StatefulWidget {
  final String loanId;

  const LoanDetailPage({
    super.key,
    required this.loanId,
  });

  @override
  State<LoanDetailPage> createState() => _LoanDetailPageState();
}

class _LoanDetailPageState extends State<LoanDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<LoanBloc>().add(GetLoanByIdEvent(widget.loanId));
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'es');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de préstamo'),
      ),
      body: BlocBuilder<LoanBloc, LoanState>(
        builder: (context, state) {
          if (state is LoanDetailsLoaded) {
            final loan = state.loan;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Book card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Book cover
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => BookDetailPage(bookId: loan.bookId),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                loan.bookImageUrl,
                                width: 100,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          // Book details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loan.bookTitle,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                // Loan status
                                _buildStatusChip(
                                  context,
                                  loan.isReturned
                                      ? 'Devuelto'
                                      : loan.isLate
                                          ? 'Atrasado'
                                          : 'Activo',
                                  loan.isReturned
                                      ? Colors.green
                                      : loan.isLate
                                          ? Colors.red
                                          : Colors.blue,
                                ),
                                
                                if (loan.isLate && loan.penalty != null) ...[
                                  const SizedBox(height: 8),
                                  _buildStatusChip(
                                    context,
                                    'Multa: Bs. ${loan.penalty!.toStringAsFixed(2)}',
                                    Colors.red,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Loan details
                  Text(
                    'Detalles del préstamo',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Loan ID
                  _buildDetailRow(
                    context,
                    'ID del préstamo:',
                    loan.id,
                  ),
                  const Divider(),
                  
                  // Loan date
                  _buildDetailRow(
                    context,
                    'Fecha de préstamo:',
                    dateFormat.format(loan.loanDate),
                  ),
                  const Divider(),
                  
                  // Due date
                  _buildDetailRow(
                    context,
                    'Fecha de devolución:',
                    dateFormat.format(loan.dueDate),
                    textColor: loan.isLate ? Colors.red : null,
                    fontWeight: loan.isLate ? FontWeight.bold : null,
                  ),
                  const Divider(),
                  
                  // Return date (if applicable)
                  if (loan.isReturned) ...[
                    _buildDetailRow(
                      context,
                      'Fecha de entrega:',
                      dateFormat.format(loan.returnDate!),
                      textColor: loan.isLate ? Colors.red : Colors.green,
                    ),
                    const Divider(),
                  ],
                  
                  // Penalties (if applicable)
                  if (loan.isLate && loan.penalty != null) ...[
                    _buildDetailRow(
                      context,
                      'Multa:',
                      'Bs. ${loan.penalty!.toStringAsFixed(2)}',
                      textColor: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                    const Divider(),
                    
                    // Penalty explanation
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Información sobre la multa',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Esta multa se ha generado debido a que el libro no fue devuelto a tiempo. Puedes realizar el pago en la biblioteca.',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Si tienes alguna pregunta, puedes comunicarte con el personal de la biblioteca.',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  // Note for active loans
                  if (!loan.isReturned) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recuerda',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Para devolver este libro, dirígete a la biblioteca con tu carnet de identidad y el libro en buenas condiciones.',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                            ),
                          ),
                          if (!loan.isLate) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Te quedan ${loan.dueDate.difference(DateTime.now()).inDays} días para devolver este libro.',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          } else if (state is LoanLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is LoanError) {
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
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    Color? textColor,
    FontWeight? fontWeight,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: textColor,
                fontWeight: fontWeight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
