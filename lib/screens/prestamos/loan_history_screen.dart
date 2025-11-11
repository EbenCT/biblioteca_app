// lib/screens/prestamos/loan_history_screen.dart
import 'package:flutter/material.dart';
import '../../models/prestamo.dart';
import '../../services/prestamo_service.dart';

class LoanHistoryScreen extends StatefulWidget {
  const LoanHistoryScreen({Key? key}) : super(key: key);

  @override
  State<LoanHistoryScreen> createState() => _LoanHistoryScreenState();
}

class _LoanHistoryScreenState extends State<LoanHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Prestamo> _todosPrestamos = [];
  List<Prestamo> _prestamosConMulta = [];
  double _totalMultas = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _cargarDatos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    
    try {
      final todosPrestamos = await PrestamoService.getTodosPrestamos();
      final prestamosConMulta = await PrestamoService.getPrestamosConMulta();
      final totalMultas = PrestamoService.getTotalMultasPendientes(prestamosConMulta);
      
      setState(() {
        _todosPrestamos = todosPrestamos;
        _prestamosConMulta = prestamosConMulta;
        _totalMultas = totalMultas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando préstamos: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Préstamos'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            _todosPrestamos.isNotEmpty 
                ? Badge(
                    label: Text('${_todosPrestamos.length}'),
                    child: const Tab(icon: Icon(Icons.history), text: 'Historial'),
                  )
                : const Tab(icon: Icon(Icons.history), text: 'Historial'),
            PrestamoService.filtrarPorEstado(_todosPrestamos, true).isNotEmpty
                ? Badge(
                    label: Text('${PrestamoService.filtrarPorEstado(_todosPrestamos, true).length}'),
                    child: const Tab(icon: Icon(Icons.book), text: 'Activos'),
                  )
                : const Tab(icon: Icon(Icons.book), text: 'Activos'),
            _prestamosConMulta.isNotEmpty
                ? Badge(
                    backgroundColor: Colors.red,
                    label: Text('${_prestamosConMulta.length}'),
                    child: const Tab(icon: Icon(Icons.warning), text: 'Multas'),
                  )
                : const Tab(icon: Icon(Icons.warning), text: 'Multas'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando historial...'),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _cargarDatos,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildHistorialTab(),
                  _buildActivosTab(),
                  _buildMultasTab(),
                ],
              ),
            ),
    );
  }

  Widget _buildHistorialTab() {
    if (_todosPrestamos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay préstamos registrados',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _todosPrestamos.length,
      itemBuilder: (context, index) {
        final prestamo = _todosPrestamos[index];
        return _buildPrestamoCard(prestamo);
      },
    );
  }

  Widget _buildActivosTab() {
    final prestamosActivos = PrestamoService.filtrarPorEstado(_todosPrestamos, true);
    
    if (prestamosActivos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No tienes préstamos activos',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: prestamosActivos.length,
      itemBuilder: (context, index) {
        final prestamo = prestamosActivos[index];
        return _buildPrestamoCard(prestamo, isActive: true);
      },
    );
  }

  Widget _buildMultasTab() {
    return Column(
      children: [
        // Resumen de multas
        if (_totalMultas > 0)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              border: Border.all(color: Colors.red.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(Icons.warning_amber, size: 48, color: Colors.red.shade600),
                const SizedBox(height: 12),
                Text(
                  'Total Multas Pendientes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.red.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_totalMultas.toStringAsFixed(2)} Bs',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${_prestamosConMulta.length} préstamo${_prestamosConMulta.length != 1 ? 's' : ''} con multa',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red.shade600,
                  ),
                ),
              ],
            ),
          ),
        
        // Lista de préstamos con multa
        Expanded(
          child: _prestamosConMulta.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.thumb_up, size: 64, color: Colors.green),
                      SizedBox(height: 16),
                      Text(
                        '¡No tienes multas pendientes!',
                        style: TextStyle(fontSize: 18, color: Colors.green),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _prestamosConMulta.length,
                  itemBuilder: (context, index) {
                    final prestamo = _prestamosConMulta[index];
                    return _buildPrestamoCard(prestamo, showFine: true);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPrestamoCard(Prestamo prestamo, {bool isActive = false, bool showFine = false}) {
    final libroInfo = PrestamoService.getLibroInfo(prestamo.libroId ?? 'unknown');
    final estadoDevolucion = PrestamoService.getEstadoDevolucion(
      prestamo.fechaDevolucionEsperada,
      prestamo.fechaDevolucionReal,
    );
    
    Color cardColor = Colors.white;
    Color borderColor = Colors.grey.shade300;
    
    if (showFine && prestamo.multa != null && prestamo.multa! > 0) {
      cardColor = Colors.red.shade50;
      borderColor = Colors.red.shade300;
    } else if (isActive) {
      if (estadoDevolucion['tipo'] == 'vencido') {
        cardColor = Colors.red.shade50;
        borderColor = Colors.red.shade300;
      } else if (estadoDevolucion['tipo'] == 'vence_hoy') {
        cardColor = Colors.orange.shade50;
        borderColor = Colors.orange.shade300;
      } else {
        cardColor = Colors.blue.shade50;
        borderColor = Colors.blue.shade300;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título y autor del libro
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.book, color: Colors.blue.shade700, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        libroInfo['titulo']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        libroInfo['autor']!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Estado del préstamo
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: prestamo.estado ? Colors.green.shade100 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    prestamo.estado ? 'Activo' : 'Devuelto',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: prestamo.estado ? Colors.green.shade700 : Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Fechas
            Row(
              children: [
                Expanded(
                  child: _buildFechaInfo(
                    'Préstamo',
                    PrestamoService.formatearFecha(prestamo.fechaPrestamo),
                    Icons.calendar_today,
                  ),
                ),
                Expanded(
                  child: _buildFechaInfo(
                    'Vencimiento',
                    PrestamoService.formatearFecha(prestamo.fechaDevolucionEsperada),
                    Icons.event,
                  ),
                ),
                if (prestamo.fechaDevolucionReal != null)
                  Expanded(
                    child: _buildFechaInfo(
                      'Devuelto',
                      PrestamoService.formatearFecha(prestamo.fechaDevolucionReal!),
                      Icons.check_circle,
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Estado de devolución y multa
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getEstadoColor(estadoDevolucion['tipo']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getEstadoColor(estadoDevolucion['tipo']).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getEstadoIcon(estadoDevolucion['tipo']),
                          size: 16,
                          color: _getEstadoColor(estadoDevolucion['tipo']),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            estadoDevolucion['texto'],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: _getEstadoColor(estadoDevolucion['tipo']),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Multa
                if (prestamo.multa != null && prestamo.multa! > 0) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.monetization_on, size: 16, color: Colors.red.shade700),
                        Text(
                          '${prestamo.multa!.toStringAsFixed(2)} Bs',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFechaInfo(String label, String fecha, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          fecha,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getEstadoColor(String tipo) {
    switch (tipo) {
      case 'pendiente':
        return Colors.blue;
      case 'vence_hoy':
        return Colors.orange;
      case 'vencido':
        return Colors.red;
      case 'devuelto_a_tiempo':
        return Colors.green;
      case 'devuelto_tarde':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getEstadoIcon(String tipo) {
    switch (tipo) {
      case 'pendiente':
        return Icons.schedule;
      case 'vence_hoy':
        return Icons.warning;
      case 'vencido':
        return Icons.error;
      case 'devuelto_a_tiempo':
        return Icons.check_circle;
      case 'devuelto_tarde':
        return Icons.check_circle_outline;
      default:
        return Icons.help;
    }
  }
}