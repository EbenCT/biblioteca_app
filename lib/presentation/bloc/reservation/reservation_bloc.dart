// lib/presentation/bloc/reservation/reservation_bloc.dart (ACTUALIZACIÓN)

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/entities.dart';
import '../../../domain/repositories/repositories.dart';
import '../../../core/services/reservation_cache_service.dart';

// Events (se mantienen iguales)
abstract class ReservationEvent extends Equatable {
  const ReservationEvent();

  @override
  List<Object?> get props => [];
}

class GetReservationsEvent extends ReservationEvent {
  final bool? isActive;

  const GetReservationsEvent({this.isActive});

  @override
  List<Object?> get props => [isActive];
}

class GetReservationByIdEvent extends ReservationEvent {
  final String id;

  const GetReservationByIdEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class CreateReservationEvent extends ReservationEvent {
  final String bookId;

  const CreateReservationEvent(this.bookId);

  @override
  List<Object?> get props => [bookId];
}

class CancelReservationEvent extends ReservationEvent {
  final String id;

  const CancelReservationEvent(this.id);

  @override
  List<Object?> get props => [id];
}

// NUEVO EVENT: Para refrescar solo desde cache
class RefreshFromCacheEvent extends ReservationEvent {}

// NUEVO EVENT: Para limpiar cache
class ClearCacheEvent extends ReservationEvent {}

// States (se mantienen iguales + algunos nuevos)
abstract class ReservationState extends Equatable {
  const ReservationState();

  @override
  List<Object?> get props => [];
}

class ReservationInitial extends ReservationState {}

class ReservationLoading extends ReservationState {}

class ReservationsLoaded extends ReservationState {
  final List<Reservation> reservations;
  final bool isFromCache; // NUEVO: indicar si viene del cache

  const ReservationsLoaded(this.reservations, {this.isFromCache = false});

  @override
  List<Object?> get props => [reservations, isFromCache];
}

class ReservationDetailsLoaded extends ReservationState {
  final Reservation reservation;

  const ReservationDetailsLoaded(this.reservation);

  @override
  List<Object?> get props => [reservation];
}

class ReservationCreated extends ReservationState {
  final Reservation reservation;
  final bool isLocalOnly; // NUEVO: indicar si se creó solo localmente

  const ReservationCreated(this.reservation, {this.isLocalOnly = false});

  @override
  List<Object?> get props => [reservation, isLocalOnly];
}

class ReservationCancelled extends ReservationState {}

class ReservationError extends ReservationState {
  final String message;

  const ReservationError(this.message);

  @override
  List<Object?> get props => [message];
}

// NUEVO STATE: Para indicar operaciones de cache
class CacheCleared extends ReservationState {}

// Bloc (ACTUALIZADO)
class ReservationBloc extends Bloc<ReservationEvent, ReservationState> {
  final ReservationRepository reservationRepository;
  final ReservationCacheService _cacheService = ReservationCacheService.instance;

  ReservationBloc({required this.reservationRepository}) : super(ReservationInitial()) {
    on<GetReservationsEvent>(_onGetReservations);
    on<GetReservationByIdEvent>(_onGetReservationById);
    on<CreateReservationEvent>(_onCreateReservation);
    on<CancelReservationEvent>(_onCancelReservation);
    on<RefreshFromCacheEvent>(_onRefreshFromCache);
    on<ClearCacheEvent>(_onClearCache);
  }

  Future<void> _onGetReservations(GetReservationsEvent event, Emitter<ReservationState> emit) async {
    emit(ReservationLoading());
    
    try {
      final result = await reservationRepository.getReservations(isActive: event.isActive);
      result.fold(
        (failure) => emit(ReservationError(failure.toString())),
        (reservations) {
          // Verificar si alguna reserva viene del cache local
          final hasLocalReservations = reservations.any((r) => r.id.startsWith('local_'));
          
          emit(ReservationsLoaded(
            reservations, 
            isFromCache: hasLocalReservations,
          ));
          
          if (hasLocalReservations) {
            print('📱 Algunas reservas provienen del cache local');
          }
        },
      );
    } catch (e) {
      print('❌ Error obteniendo reservas: $e');
      emit(ReservationError('Error al cargar las reservas'));
    }
  }

  Future<void> _onGetReservationById(GetReservationByIdEvent event, Emitter<ReservationState> emit) async {
    emit(ReservationLoading());
    final result = await reservationRepository.getReservationById(event.id);
    result.fold(
      (failure) => emit(ReservationError(failure.toString())),
      (reservation) => emit(ReservationDetailsLoaded(reservation)),
    );
  }

  Future<void> _onCreateReservation(CreateReservationEvent event, Emitter<ReservationState> emit) async {
    emit(ReservationLoading());
    
    try {
      final result = await reservationRepository.createReservation(event.bookId);
      result.fold(
        (failure) => emit(ReservationError(failure.toString())),
        (reservation) {
          // Verificar si la reserva se creó solo localmente
          final isLocalOnly = reservation.id.startsWith('local_');
          
          emit(ReservationCreated(
            reservation,
            isLocalOnly: isLocalOnly,
          ));
          
          if (isLocalOnly) {
            print('📱 Reserva creada solo en cache local');
          } else {
            print('✅ Reserva creada en servidor y cache');
          }
        },
      );
    } catch (e) {
      print('❌ Error creando reserva: $e');
      emit(ReservationError('Error al crear la reserva'));
    }
  }

  Future<void> _onCancelReservation(CancelReservationEvent event, Emitter<ReservationState> emit) async {
    emit(ReservationLoading());
    final result = await reservationRepository.cancelReservation(event.id);
    result.fold(
      (failure) => emit(ReservationError(failure.toString())),
      (_) => emit(ReservationCancelled()),
    );
  }

  // NUEVO: Refrescar solo desde cache
  Future<void> _onRefreshFromCache(RefreshFromCacheEvent event, Emitter<ReservationState> emit) async {
    try {
      final cacheReservations = _cacheService.getAllReservations();
      emit(ReservationsLoaded(cacheReservations, isFromCache: true));
      print('🔄 Reservas refrescadas desde cache local');
    } catch (e) {
      emit(ReservationError('Error al refrescar desde cache'));
    }
  }

  // NUEVO: Limpiar cache
  Future<void> _onClearCache(ClearCacheEvent event, Emitter<ReservationState> emit) async {
    try {
      _cacheService.clearCache();
      emit(CacheCleared());
      print('🗑️ Cache de reservas limpiado');
    } catch (e) {
      emit(ReservationError('Error al limpiar cache'));
    }
  }

  // Método auxiliar para obtener estadísticas del cache
  Map<String, dynamic> getCacheStats() {
    return _cacheService.getCacheStats();
  }

  // Método auxiliar para debugging
  void debugCache() {
    _cacheService.debugPrintReservations();
  }
}