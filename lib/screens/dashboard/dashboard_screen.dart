// lib/screens/dashboard/dashboard_screen.dart - Pantalla Principal con QR Scanner
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/models.dart';
import '../../blocs/access/access_bloc.dart';
import '../../blocs/access/access_event.dart';
import '../../blocs/access/access_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../presentation/widgets/qr/qr_widgets.dart';
import '../history/access_history_screen.dart';

class DashboardScreen extends StatefulWidget {
  final User user;
  final Miembro? miembro;

  const DashboardScreen({
    super.key,
    required this.user,
    this.miembro,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _showQRScanner = false;
  AccesoBiblioteca? _ultimoAcceso;
  bool _isInside = false;

  // Helper para obtener el ID correcto del miembro
  String get _miembroId => widget.miembro?.id ?? widget.user.id;

  @override
  void initState() {
    super.initState();
    // Verificar estado del miembro al cargar
    // Verificar estado del miembro usando el miembro ID o user ID como fallback
    context.read<AccessBloc>().add(VerificarEstadoMiembro(
      miembroId: _miembroId,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccessBloc, AccessState>(
      listener: (context, state) {
        if (state is EntradaRegistrada || state is SalidaRegistrada) {
          setState(() {
            _showQRScanner = false;
            if (state is EntradaRegistrada) {
              _ultimoAcceso = AccesoBiblioteca.fromJson(state.acceso);
              _isInside = true;
            } else if (state is SalidaRegistrada) {
              _ultimoAcceso = AccesoBiblioteca.fromJson(state.acceso);
              _isInside = false;
            }
          });
        } else if (state is EstadoMiembroLoaded) {
          setState(() {
            _isInside = state.estaAdentro;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Biblioteca UAGRM'),
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: _showHistory,
              tooltip: 'Historial de Accesos',
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AuthBloc>().add(LogoutEvent());
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            // Contenido principal
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Tarjeta de bienvenida
                  _buildWelcomeCard(),
                  const SizedBox(height: 16),

                  // Estado de acceso y controles manuales
                  AccessStatusCard(
                    ultimoAcceso: _ultimoAcceso,
                    isInside: _isInside,
                    onManualEntry: () => _handleManualEntry(),
                    onManualExit: () => _handleManualExit(),
                    onViewHistory: () => _showHistory(),
                  ),

                  const SizedBox(height: 16),

                  // Instrucciones de uso
                  _buildInstructionsCard(),
                  const SizedBox(height: 100), // Espacio para FAB
                ],
              ),
            ),

            // Overlay del scanner QR
            if (_showQRScanner)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.9),
                  child: Column(
                    children: [
                      // Header del scanner
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => setState(() => _showQRScanner = false),
                              icon: const Icon(Icons.close, color: Colors.white),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Escanear Código QR',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Widget del scanner
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: QRScannerWidget(
                            miembroId: _miembroId,
                            onClose: () => setState(() => _showQRScanner = false),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        floatingActionButton: QRFloatingButton(
          isActive: _showQRScanner,
          onPressed: () {
            setState(() {
              _showQRScanner = !_showQRScanner;
            });
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    widget.user.username.isNotEmpty 
                        ? widget.user.username[0].toUpperCase()
                        : 'U',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Bienvenido!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.miembro?.nombreCompleto ?? widget.user.email,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (widget.miembro != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.verified, color: Colors.green.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Miembro verificado',
                      style: TextStyle(
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cómo usar el acceso QR',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInstructionStep(
              1,
              'Toca el botón azul para activar la cámara',
              Icons.qr_code_scanner,
            ),
            _buildInstructionStep(
              2,
              'Escanea tu código QR personal',
              Icons.center_focus_strong,
            ),
            _buildInstructionStep(
              3,
              'El sistema registrará tu entrada o salida',
              Icons.check_circle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(int step, String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Icon(icon, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _handleManualEntry() {
    context.read<AccessBloc>().add(MarcarEntradaManual(
      miembroId: _miembroId,
    ));
  }

  void _handleManualExit() {
    context.read<AccessBloc>().add(MarcarSalidaManual(
      miembroId: _miembroId,
    ));
  }

  void _showHistory() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AccessHistoryScreen(
          user: widget.user,
          miembro: widget.miembro,
        ),
      ),
    );
  }
}