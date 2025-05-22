import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/loan/loan_bloc.dart';
import '../../../domain/entities/entities.dart';
import '../../widgets/network_image_widget.dart';
import 'loan_detail_page.dart';
import 'package:intl/intl.dart';

class LoansPage extends StatefulWidget {
  const LoansPage({super.key});

  @override
  State<LoansPage> createState() => _LoansPageState();
}

class _LoansPageState extends State<LoansPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<LoanBloc>().add(const GetLoansEvent(isActive: true));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis préstamos'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Activos'),
            Tab(text: 'Historial'),
          ],
          onTap: (index) {
            if (index == 0) {
              context.read<LoanBloc>().add(const GetLoansEvent(isActive: true));
            } else {
              context.read<LoanBloc>().add(const GetLoansEvent(isActive: false));
            }
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Active loans tab
          RefreshIndicator(
            onRefresh: () async {
              context.read<LoanBloc>().add(const GetLoansEvent(isActive: true));
            },
            child: BlocBuilder<LoanBloc, LoanState>(
              builder: (context, state) {
                if (state is LoansLoaded) {
                  if (state.loans.isEmpty) {
                    return const Center(
                      child: Text('No tienes préstamos activos'),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.loans.length,
                    itemBuilder: (context, index) {
                      final loan = state.loans[index];
                      return LoanCard(
                        loan: loan,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => LoanDetailPage(loanId: loan.id),
                            ),
                          );
                        },
                      );
                    },
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
          ),

          // Loan history tab
          RefreshIndicator(
            onRefresh: () async {
              context.read<LoanBloc>().add(const GetLoansEvent(isActive: false));
            },
            child: BlocBuilder<LoanBloc, LoanState>(
              builder: (context, state) {
                if (state is LoansLoaded) {
                  if (state.loans.isEmpty) {
                    return const Center(
                      child: Text('No tienes historial de préstamos'),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.loans.length,
                    itemBuilder: (context, index) {
                      final loan = state.loans[index];
                      return LoanCard(
                        loan: loan,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => LoanDetailPage(loanId: loan.id),
                            ),
                          );
                        },
                      );
                    },
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
          ),
        ],
      ),
    );
  }
}

class LoanCard extends StatelessWidget {
  final Loan loan;
  final VoidCallback onTap;

  const LoanCard({
    super.key,
    required this.loan,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book cover con manejo de errores
              NetworkImageWidget(
                imageUrl: loan.bookImageUrl,
                width: 80,
                height: 120,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(width: 12),
              
              // Loan details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loan.bookTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    
                    // Loan dates
                    _buildInfoRow(
                      context,
                      Icons.date_range,
                      'Préstamo: ${dateFormat.format(loan.loanDate)}',
                    ),
                    const SizedBox(height: 4),
                    _buildInfoRow(
                      context,
                      Icons.event_repeat,
                      'Devolución: ${dateFormat.format(loan.dueDate)}',
                      color: loan.isLate ? Colors.red : null,
                      fontWeight: loan.isLate ? FontWeight.bold : null,
                    ),
                    
                    // Loan status and penalties
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (loan.isReturned) ...[
                          _buildStatusChip(context, 'Devuelto', Colors.green),
                          if (loan.isLate && loan.penalty != null)
                            _buildStatusChip(
                              context,
                              'Multa: Bs. ${loan.penalty!.toStringAsFixed(2)}',
                              Colors.red,
                            ),
                        ] else if (loan.isLate) ...[
                          _buildStatusChip(context, 'Atrasado', Colors.red),
                          if (loan.penalty != null)
                            _buildStatusChip(
                              context,
                              'Multa: Bs. ${loan.penalty!.toStringAsFixed(2)}',
                              Colors.red,
                            ),
                        ] else ...[
                          _buildStatusChip(context, 'Activo', Colors.blue),
                        ],
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
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: color ?? Colors.grey.shade600,
              fontWeight: fontWeight,
            ),
            overflow: TextOverflow.ellipsis,
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
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}