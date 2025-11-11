// lib/presentation/widgets/qr/qr_scanner_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../blocs/access/access_bloc.dart';
import '../../../blocs/access/access_event.dart';
import '../../../blocs/access/access_state.dart';
import '../../../config/app_config.dart';

class QRScannerWidget extends StatefulWidget {
  final String? miembroId;
  final String? userName;
  final VoidCallback? onClose;

  const QRScannerWidget({
    super.key,
    this.miembroId,
    this.userName,
    this.onClose,
  });

  @override
  State<QRScannerWidget> createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget> {
  MobileScannerController controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Iniciar scanner cuando se carga el widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccessBloc>().add(StartQRScanner());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccessBloc, AccessState>(
      listener: (context, state) {
        if (state is QRScannerError) {
          _showErrorMessage(context, state.message);
        } else if (state is PermissionDenied) {
          _showPermissionDialog(context);
        } else if (state is EntradaRegistrada) {
          _showSuccessMessage(context, 'Entrada registrada correctamente');
          _resetScanner();
        } else if (state is SalidaRegistrada) {
          _showSuccessMessage(context, 'Salida registrada correctamente');
          _resetScanner();
        } else if (state is AccessError) {
          _showErrorMessage(context, state.message);
          _resetScanner();
        }
      },
      child: BlocBuilder<AccessBloc, AccessState>(
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                // Scanner de QR
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: MobileScanner(
                    controller: controller,
                    onDetect: (BarcodeCapture barcodeCapture) {
                      final List<Barcode> barcodes = barcodeCapture.barcodes;
                      for (final barcode in barcodes) {
                        if (barcode.rawValue != null) {
                          _processQRCode(barcode.rawValue!);
                          break;
                        }
                      }
                    },
                  ),
                ),

                // Overlay de escaneado
                _buildScanOverlay(context),

                // Overlay de estado
                if (state is AccessLoading || _isProcessing)
                  _buildLoadingOverlay(),

                // Overlay de instrucciones
                if (state is QRScannerActive)
                  _buildInstructionsOverlay(),

                // Botón de cierre
                Positioned(
                  top: 16,
                  right: 16,
                  child: _buildCloseButton(),
                ),

                // Botón de flash
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: _buildFlashButton(),
                ),

                // Información del usuario
                if (widget.miembroId != null)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: _buildUserInfo(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildScanOverlay(BuildContext context) {
    final scanArea = MediaQuery.of(context).size.width * AppConfig.qrScanArea;
    
    return Positioned.fill(
      child: Container(
        decoration: ShapeDecoration(
          shape: QrScannerOverlayShape(
            borderColor: Theme.of(context).primaryColor,
            borderRadius: 10,
            borderLength: 30,
            borderWidth: 10,
            cutOutSize: scanArea,
          ),
        ),
      ),
    );
  }

  void _processQRCode(String qrData) {
    if (qrData.isEmpty || _isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    // Procesar código QR
    context.read<AccessBloc>().add(ProcessQRCode(
      qrData: qrData,
      miembroId: widget.miembroId ?? '',
      userName: widget.userName,
    ));
  }

  void _resetScanner() {
    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Widget _buildLoadingOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Procesando código QR...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsOverlay() {
    return Positioned(
      top: 60,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.qr_code_scanner,
              color: Colors.white,
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              'Escanea tu código QR',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              'Coloca el código dentro del marco',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return Material(
      color: Colors.black.withOpacity(0.7),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          context.read<AccessBloc>().add(StopQRScanner());
          widget.onClose?.call();
        },
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(
            Icons.close,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildFlashButton() {
    return Material(
      color: Colors.black.withOpacity(0.7),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          await controller.toggleTorch();
        },
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(
            Icons.flash_on,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.person,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            'ID: ${widget.miembroId}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permisos de Cámara'),
        content: const Text(
          'La aplicación necesita acceso a la cámara para escanear códigos QR. '
          'Por favor, otorga los permisos en la configuración de la aplicación.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

// Clase helper para crear el overlay de escaneo
class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QrScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path path = Path();
    Rect cutOutRect = Rect.fromCenter(
      center: rect.center,
      width: cutOutSize,
      height: cutOutSize,
    );

    path.addRRect(
      RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)),
    );
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final borderWidthSize = width / 2;
    final height = rect.height;
    final borderOffset = borderWidth / 2;
    final mBorderLength = borderLength > cutOutSize / 2 + borderOffset
        ? borderWidthSize / 2
        : borderLength;
    final mCutOutSize = cutOutSize < width ? cutOutSize : width - borderOffset;

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;



    final cutOutRect = Rect.fromLTWH(
      rect.left + width / 2 - mCutOutSize / 2 + borderOffset,
      rect.top + height / 2 - mCutOutSize / 2 + borderOffset,
      mCutOutSize - borderOffset * 2,
      mCutOutSize - borderOffset * 2,
    );

    // Draw overlay:
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(rect),
        Path()
          ..addRRect(
            RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)),
          ),
      ),
      backgroundPaint,
    );

    // Draw corners
    final path = Path()
      ..moveTo(cutOutRect.left, cutOutRect.top + mBorderLength)
      ..quadraticBezierTo(cutOutRect.left, cutOutRect.top, 
          cutOutRect.left + borderRadius, cutOutRect.top)
      ..lineTo(cutOutRect.left + mBorderLength, cutOutRect.top)
      ..moveTo(cutOutRect.right - mBorderLength, cutOutRect.top)
      ..lineTo(cutOutRect.right - borderRadius, cutOutRect.top)
      ..quadraticBezierTo(cutOutRect.right, cutOutRect.top,
          cutOutRect.right, cutOutRect.top + borderRadius)
      ..lineTo(cutOutRect.right, cutOutRect.top + mBorderLength)
      ..moveTo(cutOutRect.right, cutOutRect.bottom - mBorderLength)
      ..lineTo(cutOutRect.right, cutOutRect.bottom - borderRadius)
      ..quadraticBezierTo(cutOutRect.right, cutOutRect.bottom,
          cutOutRect.right - borderRadius, cutOutRect.bottom)
      ..lineTo(cutOutRect.right - mBorderLength, cutOutRect.bottom)
      ..moveTo(cutOutRect.left + mBorderLength, cutOutRect.bottom)
      ..lineTo(cutOutRect.left + borderRadius, cutOutRect.bottom)
      ..quadraticBezierTo(cutOutRect.left, cutOutRect.bottom,
          cutOutRect.left, cutOutRect.bottom - borderRadius)
      ..lineTo(cutOutRect.left, cutOutRect.bottom - mBorderLength);

    canvas.drawPath(path, borderPaint);
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}