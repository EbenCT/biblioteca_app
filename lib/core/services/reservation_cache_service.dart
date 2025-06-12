// lib/core/services/reservation_cache_service.dart

import '../../domain/entities/entities.dart';
import '../../data/mock_data.dart';

class ReservationCacheService {
  static ReservationCacheService? _instance;
  ReservationCacheService._internal();
  
  static ReservationCacheService get instance {
    _instance ??= ReservationCacheService._internal();
    return _instance!;
  }

  // Lista en memoria para las reservas
  List<Reservation> _cachedReservations = [];
  
  // Flag para indicar si ya se cargaron los datos iniciales
  bool _isInitialized = false;

  // Inicializar con datos mock
  void _initializeIfNeeded() {
    if (!_isInitialized) {
      print('📚 Inicializando cache de reservas con datos mock');
      _cachedReservations = List.from(MockData.reservations);
      _isInitialized = true;
      print('✅ Cache inicializado con ${_cachedReservations.length} reservas');
    }
  }

  // Obtener todas las reservas
  List<Reservation> getAllReservations({bool? isActive}) {
    _initializeIfNeeded();
    
    if (isActive == null) {
      return List.from(_cachedReservations);
    }
    
    if (isActive) {
      return _cachedReservations
          .where((reservation) => reservation.status == 'active')
          .toList();
    } else {
      return _cachedReservations
          .where((reservation) => reservation.status != 'active')
          .toList();
    }
  }

  // Obtener reserva por ID
  Reservation? getReservationById(String id) {
    _initializeIfNeeded();
    
    try {
      return _cachedReservations.firstWhere((reservation) => reservation.id == id);
    } catch (e) {
      print('❌ Reserva con ID $id no encontrada en cache');
      return null;
    }
  }

  // Crear nueva reserva
  Reservation createReservation(String bookId, String bookTitle, String bookImageUrl) {
    _initializeIfNeeded();
    
    final newReservation = Reservation(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      bookId: bookId,
      bookTitle: bookTitle,
      bookImageUrl: bookImageUrl,
      reservationDate: DateTime.now(),
      expirationDate: DateTime.now().add(const Duration(days: 3)),
      status: 'active',
    );
    
    _cachedReservations.add(newReservation);
    
    print('✅ Nueva reserva creada en cache:');
    print('   ID: ${newReservation.id}');
    print('   Libro: ${newReservation.bookTitle}');
    print('   Expira: ${newReservation.expirationDate}');
    
    return newReservation;
  }

  // Cancelar reserva
  bool cancelReservation(String id) {
    _initializeIfNeeded();
    
    final index = _cachedReservations.indexWhere((reservation) => reservation.id == id);
    
    if (index != -1) {
      // Cambiar el estado en lugar de eliminar para mantener historial
      final reservation = _cachedReservations[index];
      final updatedReservation = Reservation(
        id: reservation.id,
        bookId: reservation.bookId,
        bookTitle: reservation.bookTitle,
        bookImageUrl: reservation.bookImageUrl,
        reservationDate: reservation.reservationDate,
        expirationDate: reservation.expirationDate,
        status: 'cancelled',
      );
      
      _cachedReservations[index] = updatedReservation;
      
      print('✅ Reserva ${id} cancelada en cache');
      return true;
    }
    
    print('❌ No se pudo cancelar reserva ${id} - no encontrada en cache');
    return false;
  }

  // Limpiar cache (útil para testing o logout)
  void clearCache() {
    _cachedReservations.clear();
    _isInitialized = false;
    print('🗑️ Cache de reservas limpiado');
  }

  // Obtener estadísticas del cache (para debugging)
  Map<String, dynamic> getCacheStats() {
    _initializeIfNeeded();
    
    final activeCount = _cachedReservations
        .where((r) => r.status == 'active')
        .length;
    
    final cancelledCount = _cachedReservations
        .where((r) => r.status == 'cancelled')
        .length;
    
    final expiredCount = _cachedReservations
        .where((r) => r.status == 'expired')
        .length;
    
    return {
      'total': _cachedReservations.length,
      'active': activeCount,
      'cancelled': cancelledCount,
      'expired': expiredCount,
      'initialized': _isInitialized,
    };
  }

  // Debug: imprimir todas las reservas
  void debugPrintReservations() {
    _initializeIfNeeded();
    
    print('🔍 RESERVAS EN CACHE (${_cachedReservations.length}):');
    for (var reservation in _cachedReservations) {
      print('   ${reservation.id}: ${reservation.bookTitle} (${reservation.status})');
    }
  }
}