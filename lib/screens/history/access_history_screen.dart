// lib/screens/history/access_history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/access/access_bloc.dart';
import '../../blocs/access/access_event.dart';
import '../../blocs/access/access_state.dart';
import '../../models/acceso_biblioteca.dart';
import '../../models/user.dart';
import '../../models/miembro.dart';

class AccessHistoryScreen extends StatefulWidget {
  final User user;
  final Miembro? miembro;

  const AccessHistoryScreen({
    super.key,
    required this.user,
    this.miembro,
  });

  @override
  State<AccessHistoryScreen> createState() => _AccessHistoryScreenState();
}

class _AccessHistoryScreenState extends State<AccessHistoryScreen> {
  List<AccesoBiblioteca> _historial = [];
  bool _isLoading = true;

  // Helper para obtener el ID correcto del miembro
  String get _miembroId => widget.miembro?.id ?? widget.user.id;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    context.read<AccessBloc>().add(LoadHistorialAccesos(
      miembroId: _miembroId,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Accesos'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadHistory,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: BlocListener<AccessBloc, AccessState>(
        listener: (context, state) {
          if (state is HistorialAccesosLoaded) {
            setState(() {
              _historial = state.historialAccesos;
              _isLoading = false;
            });
          } else if (state is AccessError) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AccessLoading) {
            setState(() {
              _isLoading = true;
            });
          }
        },
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _historial.isEmpty
                ? _buildEmptyState()
                : _buildHistoryList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay registros de acceso',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tus entradas y salidas aparecerán aquí',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadHistory,
            icon: const Icon(Icons.refresh),
            label: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return RefreshIndicator(
      onRefresh: () async {
        _loadHistory();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _historial.length,
        itemBuilder: (context, index) {
          final acceso = _historial[index];
          return _buildAccessCard(acceso, index);
        },
      ),
    );
  }

  Widget _buildAccessCard(AccesoBiblioteca acceso, int index) {
    final isEntry = acceso.fechaSalida == null || acceso.fechaSalida!.isEmpty;
    final fecha = acceso.fechaEntrada;
    final duracion = _calculateDuration(acceso.fechaEntrada, acceso.fechaSalida);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con tipo de acceso y fecha
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isEntry ? Colors.green : Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isEntry ? Icons.login : Icons.logout,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isEntry ? 'Entrada' : 'Salida',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  '#${_historial.length - index}',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Información de fechas
            _buildInfoRow(
              icon: Icons.access_time,
              label: 'Entrada',
              value: _formatDateTime(fecha),
            ),

            if (!isEntry && acceso.fechaSalida != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                icon: Icons.exit_to_app,
                label: 'Salida',
                value: _formatDateTime(acceso.fechaSalida!),
              ),
            ],

            if (duracion.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                icon: Icons.timer,
                label: 'Duración',
                value: duracion,
                valueColor: Colors.orange.shade700,
              ),
            ],

            // Método de acceso
            if (acceso.metodoAcceso.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                icon: Icons.qr_code,
                label: 'Método',
                value: _formatAccessMethod(acceso.metodoAcceso),
              ),
            ],

            // Estado
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: acceso.estado ? Icons.check_circle : Icons.cancel,
              label: 'Estado',
              value: acceso.estado ? 'Completado' : 'Pendiente',
              valueColor: acceso.estado ? Colors.green : Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: valueColor ?? Colors.grey.shade800,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays == 0) {
        return 'Hoy ${_formatTime(dateTime)}';
      } else if (difference.inDays == 1) {
        return 'Ayer ${_formatTime(dateTime)}';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} días ${_formatTime(dateTime)}';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${_formatTime(dateTime)}';
      }
    } catch (e) {
      return dateTimeStr;
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _calculateDuration(String? fechaEntrada, String? fechaSalida) {
    if (fechaEntrada == null || fechaSalida == null || fechaSalida.isEmpty) {
      return '';
    }
    
    try {
      final entrada = DateTime.parse(fechaEntrada);
      final salida = DateTime.parse(fechaSalida);
      final duracion = salida.difference(entrada);
      
      final horas = duracion.inHours;
      final minutos = duracion.inMinutes % 60;
      
      if (horas > 0) {
        return '${horas}h ${minutos}m';
      } else {
        return '${minutos}m';
      }
    } catch (e) {
      return '';
    }
  }

  String _formatAccessMethod(String metodo) {
    if (metodo.toLowerCase().contains('qr')) {
      return '📱 Código QR';
    } else if (metodo.toLowerCase().contains('manual')) {
      return '✋ Manual';
    } else {
      return metodo;
    }
  }
}