// lib/presentation/widgets/qr/access_status_card.dart
import 'package:flutter/material.dart';
import '../../../models/acceso_biblioteca.dart';

class AccessStatusCard extends StatelessWidget {
  final AccesoBiblioteca? ultimoAcceso;
  final bool isInside;
  final VoidCallback? onManualEntry;
  final VoidCallback? onManualExit;
  final VoidCallback? onViewHistory;

  const AccessStatusCard({
    super.key,
    this.ultimoAcceso,
    required this.isInside,
    this.onManualEntry,
    this.onManualExit,
    this.onViewHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título con icono de estado
            Row(
              children: [
                Icon(
                  isInside ? Icons.home : Icons.logout,
                  color: isInside ? Colors.green : Colors.grey,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estado Actual',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isInside ? 'Dentro de la biblioteca' : 'Fuera de la biblioteca',
                        style: TextStyle(
                          color: isInside ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Información del último acceso
            if (ultimoAcceso != null) ...[
              Text(
                'Último Acceso',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _buildAccessInfo(context, ultimoAcceso!),
              const SizedBox(height: 20),
            ],

            // Botones de acción manual
            Row(
              children: [
                if (!isInside)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onManualEntry,
                      icon: const Icon(Icons.login, size: 20),
                      label: const Text('Entrada Manual'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                if (isInside)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onManualExit,
                      icon: const Icon(Icons.logout, size: 20),
                      label: const Text('Salida Manual'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: onViewHistory,
                  icon: const Icon(Icons.history, size: 20),
                  label: const Text('Historial'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessInfo(BuildContext context, AccesoBiblioteca acceso) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Tipo de acceso
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getAccessTypeColor(acceso.metodoAcceso),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_getAccessTypeEmoji(acceso.metodoAcceso)} ${_getAccessTypeDisplayName(acceso.metodoAcceso)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                acceso.fechaEntrada,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          
          if (acceso.fechaSalida != null) ...[
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  'Salida: ${acceso.fechaSalida}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],

          if (acceso.fechaSalida != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.timer,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  'Duración: ${_calculateDuration(acceso.fechaEntrada, acceso.fechaSalida!)}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getAccessTypeColor(String metodo) {
    if (metodo.toLowerCase().contains('entrada') || metodo.toLowerCase().contains('ingreso')) {
      return Colors.green;
    } else if (metodo.toLowerCase().contains('salida') || metodo.toLowerCase().contains('egreso')) {
      return Colors.blue;
    }
    return Colors.grey;
  }

  String _getAccessTypeEmoji(String metodo) {
    if (metodo.toLowerCase().contains('entrada') || metodo.toLowerCase().contains('ingreso')) {
      return '📍';
    } else if (metodo.toLowerCase().contains('salida') || metodo.toLowerCase().contains('egreso')) {
      return '🚪';
    }
    return '🔄';
  }

  String _getAccessTypeDisplayName(String metodo) {
    if (metodo.toLowerCase().contains('entrada') || metodo.toLowerCase().contains('ingreso')) {
      return 'Entrada';
    } else if (metodo.toLowerCase().contains('salida') || metodo.toLowerCase().contains('egreso')) {
      return 'Salida';
    }
    return metodo;
  }

  String _calculateDuration(String fechaEntrada, String fechaSalida) {
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
      return 'N/A';
    }
  }
}