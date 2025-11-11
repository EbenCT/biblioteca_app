// lib/blocs/access/access_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/qr_service.dart';
import '../../services/graphql_service.dart';
import 'access_event.dart';
import 'access_state.dart';

class AccessBloc extends Bloc<AccessEvent, AccessState> {
  AccessBloc() : super(AccessInitial()) {
    // Eventos de QR Scanner
    on<StartQRScanner>(_onStartQRScanner);
    on<StopQRScanner>(_onStopQRScanner);
    on<ProcessQRCode>(_onProcessQRCode);
    on<ResetQRScanner>(_onResetQRScanner);

    // Eventos de acceso manual
    on<MarcarEntradaManual>(_onMarcarEntradaManual);
    on<MarcarSalidaManual>(_onMarcarSalidaManual);

    // Eventos de datos
    on<LoadHistorialAccesos>(_onLoadHistorialAccesos);
    on<VerificarEstadoMiembro>(_onVerificarEstadoMiembro);

    // Eventos de limpieza
    on<ClearAccessResult>(_onClearAccessResult);
  }

  // ========== QR SCANNER ==========

  void _onStartQRScanner(StartQRScanner event, Emitter<AccessState> emit) async {
    try {
      // Verificar permisos de cámara
      final hasPermission = await QRService.tienePermisosCamara();
      
      if (!hasPermission) {
        final granted = await QRService.solicitarPermisosCamara();
        if (!granted) {
          emit(const PermissionDenied());
          return;
        }
      }

      emit(QRScannerActive());
    } catch (e) {
      emit(QRScannerError(message: 'Error al inicializar escáner: ${e.toString()}'));
    }
  }

  void _onStopQRScanner(StopQRScanner event, Emitter<AccessState> emit) async {
    try {
      emit(QRScannerInactive());
    } catch (e) {
      emit(QRScannerError(message: 'Error al detener escáner: ${e.toString()}'));
    }
  }

  void _onResetQRScanner(ResetQRScanner event, Emitter<AccessState> emit) {
    emit(QRScannerInactive());
  }

  void _onProcessQRCode(ProcessQRCode event, Emitter<AccessState> emit) async {
    emit(AccessLoading());

    try {
      // Procesando QR (el widget maneja la pausa del scanner)

      // Procesar código QR
      final resultado = await QRService.procesarQRAcceso(
        event.qrData, 
        event.miembroId
      );

      // Formatear resultado para UI
      final resultadoFormateado = QRService.formatearResultadoParaUI(resultado);

      // Emitir estado específico según el tipo de resultado
      final tipo = resultado['tipo'];
      
      if (tipo == 'entrada') {
        emit(EntradaRegistrada(
          acceso: resultado['acceso'],
          timestamp: resultado['timestamp'],
        ));
      } else if (tipo == 'salida') {
        emit(SalidaRegistrada(
          acceso: resultado['acceso'],
          duracion: resultado['duracion'],
          timestamp: resultado['timestamp'],
        ));
      } else {
        emit(QRProcessSuccess(
          resultado: resultadoFormateado,
          acceso: resultado['acceso'],
        ));
      }

      // Notificar éxito (el widget manejará la reanudación del scanner)
      await Future.delayed(const Duration(seconds: 2));
      emit(QRScannerActive());

    } catch (e) {
      emit(AccessError(message: e.toString()));
      
      // El widget manejará la reanudación del escáner
      emit(QRScannerActive());
    }
  }

  // ========== ACCESO MANUAL ==========

  void _onMarcarEntradaManual(MarcarEntradaManual event, Emitter<AccessState> emit) async {
    emit(AccessLoading());

    try {
      final acceso = await QRService.marcarEntradaManual(event.miembroId);
      
      emit(EntradaRegistrada(
        acceso: acceso,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      emit(AccessError(message: e.toString()));
    }
  }

  void _onMarcarSalidaManual(MarcarSalidaManual event, Emitter<AccessState> emit) async {
    emit(AccessLoading());

    try {
      final acceso = await QRService.marcarSalidaManual(event.miembroId);
      
      emit(SalidaRegistrada(
        acceso: acceso,
        duracion: acceso.duracionFormateada,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      emit(AccessError(message: e.toString()));
    }
  }

  // ========== DATOS Y HISTORIAL ==========

  void _onLoadHistorialAccesos(LoadHistorialAccesos event, Emitter<AccessState> emit) async {
    emit(AccessLoading());

    try {
      final historial = await GraphQLService.getHistorialAccesos(event.miembroId);
      emit(HistorialAccesosLoaded(historialAccesos: historial));
    } catch (e) {
      emit(AccessError(message: 'Error al cargar historial: ${e.toString()}'));
    }
  }

  void _onVerificarEstadoMiembro(VerificarEstadoMiembro event, Emitter<AccessState> emit) async {
    emit(AccessLoading());

    try {
      final estado = await QRService.verificarEstadoMiembro(event.miembroId);
      emit(EstadoMiembroLoaded(estadoMiembro: estado));
    } catch (e) {
      emit(AccessError(message: 'Error al verificar estado: ${e.toString()}'));
    }
  }

  // ========== LIMPIEZA ==========

  void _onClearAccessResult(ClearAccessResult event, Emitter<AccessState> emit) {
    emit(AccessInitial());
  }

  @override
  Future<void> close() {
    // El widget manejará la limpieza de recursos del scanner
    return super.close();
  }
}