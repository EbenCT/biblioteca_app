import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/entities.dart';
import '../../../domain/repositories/repositories.dart';

// Events
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

// States
abstract class ReservationState extends Equatable {
  const ReservationState();

  @override
  List<Object?> get props => [];
}

class ReservationInitial extends ReservationState {}

class ReservationLoading extends ReservationState {}

class ReservationsLoaded extends ReservationState {
  final List<Reservation> reservations;

  const ReservationsLoaded(this.reservations);

  @override
  List<Object?> get props => [reservations];
}

class ReservationDetailsLoaded extends ReservationState {
  final Reservation reservation;

  const ReservationDetailsLoaded(this.reservation);

  @override
  List<Object?> get props => [reservation];
}

class ReservationCreated extends ReservationState {
  final Reservation reservation;

  const ReservationCreated(this.reservation);

  @override
  List<Object?> get props => [reservation];
}

class ReservationCancelled extends ReservationState {}

class ReservationError extends ReservationState {
  final String message;

  const ReservationError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class ReservationBloc extends Bloc<ReservationEvent, ReservationState> {
  final ReservationRepository reservationRepository;

  ReservationBloc({required this.reservationRepository}) : super(ReservationInitial()) {
    on<GetReservationsEvent>(_onGetReservations);
    on<GetReservationByIdEvent>(_onGetReservationById);
    on<CreateReservationEvent>(_onCreateReservation);
    on<CancelReservationEvent>(_onCancelReservation);
  }

  Future<void> _onGetReservations(GetReservationsEvent event, Emitter<ReservationState> emit) async {
    emit(ReservationLoading());
    final result = await reservationRepository.getReservations(isActive: event.isActive);
    result.fold(
      (failure) => emit(ReservationError(failure.toString())),
      (reservations) => emit(ReservationsLoaded(reservations)),
    );
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
    final result = await reservationRepository.createReservation(event.bookId);
    result.fold(
      (failure) => emit(ReservationError(failure.toString())),
      (reservation) => emit(ReservationCreated(reservation)),
    );
  }

  Future<void> _onCancelReservation(CancelReservationEvent event, Emitter<ReservationState> emit) async {
    emit(ReservationLoading());
    final result = await reservationRepository.cancelReservation(event.id);
    result.fold(
      (failure) => emit(ReservationError(failure.toString())),
      (_) => emit(ReservationCancelled()),
    );
  }
}
