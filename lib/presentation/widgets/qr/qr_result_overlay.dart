// lib/presentation/widgets/qr/qr_result_overlay.dart
import 'package:flutter/material.dart';
import '../../../models/acceso_biblioteca.dart';

class QRResultOverlay extends StatelessWidget {
  final AccesoBiblioteca acceso;
  final String resultType; // 'entrada', 'salida', 'error'
  final String message;
  final VoidCallback onClose;

  const QRResultOverlay({
    super.key,
    required this.acceso,
    required this.resultType,
    required this.message,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono de resultado
              _buildResultIcon(),
              const SizedBox(height: 16),

              // Título
              Text(
                _getTitle(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: _getColor(),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Mensaje
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Información del acceso
              _buildAccessInfo(context),
              const SizedBox(height: 24),

              // Botón de cerrar
              ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getColor(),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultIcon() {
    IconData iconData;
    Color color = _getColor();

    switch (resultType) {
      case 'entrada':
        iconData = Icons.login;
        break;
      case 'salida':
        iconData = Icons.logout;
        break;
      case 'error':
        iconData = Icons.error;
        break;
      default:
        iconData = Icons.check_circle;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        size: 48,
        color: color,
      ),
    );
  }

  Widget _buildAccessInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildInfoRow('Fecha', acceso.fechaEntrada),
          if (acceso.fechaSalida != null)
            _buildInfoRow('Salida', acceso.fechaSalida!),
          if (acceso.duracionFormateada.isNotEmpty)
            _buildInfoRow('Duración', acceso.duracionFormateada),
          _buildInfoRow('Tipo', acceso.tipoAcceso.value),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (resultType) {
      case 'entrada':
        return '¡Bienvenido a la Biblioteca!';
      case 'salida':
        return '¡Hasta luego!';
      case 'error':
        return 'Error en el acceso';
      default:
        return 'Acceso procesado';
    }
  }

  Color _getColor() {
    switch (resultType) {
      case 'entrada':
        return Colors.green;
      case 'salida':
        return Colors.blue;
      case 'error':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }


}