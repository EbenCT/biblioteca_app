// lib/blocs/access/access_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/qr_service.dart';
import '../../services/graphql_service.dart';
import '../../models/models.dart';
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
      print('🔍 Procesando QR - miembroId: ${event.miembroId}, qrData: ${event.qrData}');
      
      // Validar que los datos no estén vacíos
      if (event.miembroId.isEmpty) {
        throw Exception('miembroId está vacío');
      }
      if (event.qrData.isEmpty) {
        throw Exception('qrData está vacío');
      }
      
      // Verificar el estado actual del miembro
      final estaAdentro = await GraphQLService.miembroEstaAdentro(event.miembroId);
      print('📊 Estado del miembro: ${estaAdentro ? "ADENTRO" : "AFUERA"}');

      Map<String, dynamic> resultado;
      
      if (!estaAdentro) {
        // Registrar entrada
        print('🚪 Registrando ENTRADA...');
        
        // Temporal: probar con un código QR fijo para diagnosticar
        final qrCode = event.qrData.isNotEmpty ? event.qrData : 'QR_BIBLIOTECA_ENTRADA_${DateTime.now().millisecondsSinceEpoch}';
        print('🎯 Usando código QR: $qrCode');
        
        resultado = await GraphQLService.registrarIngreso(event.miembroId, qrCode);
        
        emit(EntradaRegistrada(
          acceso: resultado,
          timestamp: DateTime.now(),
        ));
      } else {
        // Registrar salida
        print('🚪 Registrando SALIDA...');
        resultado = await GraphQLService.registrarEgreso(event.miembroId, event.qrData);
        
        final accesoData = resultado;
        final fechaEntrada = accesoData['fechaEntrada'] ?? '';
        final fechaSalida = accesoData['fechaSalida'] ?? '';
        
        emit(SalidaRegistrada(
          acceso: resultado,
          duracion: _calcularDuracion(fechaEntrada, fechaSalida),
          timestamp: DateTime.now(),
        ));
      }

      // Breve pausa para mostrar el resultado
      await Future.delayed(const Duration(seconds: 2));
      emit(QRScannerActive());

    } catch (e) {
      emit(AccessError(message: 'Error al procesar QR: ${e.toString()}'));
      
      // Reactivar scanner después del error
      await Future.delayed(const Duration(seconds: 2));
      emit(QRScannerActive());
    }
  }

  String _calcularDuracion(String? fechaEntrada, String? fechaSalida) {
    if (fechaEntrada == null || fechaSalida == null || fechaEntrada.isEmpty || fechaSalida.isEmpty) {
      return '';
    }
    
    try {
      final ingreso = DateTime.parse(fechaEntrada);
      final egreso = DateTime.parse(fechaSalida);
      final duracion = egreso.difference(ingreso);
      final horas = duracion.inHours;
      final minutos = duracion.inMinutes % 60;
      
      return '${horas}h ${minutos}m';
    } catch (e) {
      return '';
    }
  }

  // ========== ACCESO MANUAL ==========

  void _onMarcarEntradaManual(MarcarEntradaManual event, Emitter<AccessState> emit) async {
    emit(AccessLoading());

    try {
      final result = await QRService.marcarEntradaManual(event.miembroId);
      
      emit(EntradaRegistrada(
        acceso: result,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      emit(AccessError(message: e.toString()));
    }
  }

  void _onMarcarSalidaManual(MarcarSalidaManual event, Emitter<AccessState> emit) async {
    emit(AccessLoading());

    try {
      final result = await QRService.marcarSalidaManual(event.miembroId);
      
      emit(SalidaRegistrada(
        acceso: result,
        duracion: 'Manual',
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
      final historial = await GraphQLService.getHistorialMiembro(event.miembroId);
      // Convertir a AccesoBiblioteca objects
      final accesos = historial.map((h) => AccesoBiblioteca.fromJson(h)).toList();
      emit(HistorialAccesosLoaded(historialAccesos: accesos));
    } catch (e) {
      emit(AccessError(message: 'Error al cargar historial: ${e.toString()}'));
    }
  }

  void _onVerificarEstadoMiembro(VerificarEstadoMiembro event, Emitter<AccessState> emit) async {
    emit(AccessLoading());

    try {
      final estaAdentro = await GraphQLService.miembroEstaAdentro(event.miembroId);
      emit(EstadoMiembroLoaded(estaAdentro: estaAdentro));
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