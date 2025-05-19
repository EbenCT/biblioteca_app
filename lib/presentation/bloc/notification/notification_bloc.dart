import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/entities.dart';
import '../../../domain/repositories/repositories.dart';

// Events
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class GetNotificationsEvent extends NotificationEvent {}

class MarkNotificationAsReadEvent extends NotificationEvent {
  final String id;

  const MarkNotificationAsReadEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class MarkAllNotificationsAsReadEvent extends NotificationEvent {}

// States
abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationsLoaded extends NotificationState {
  final List<AppNotification> notifications;

  const NotificationsLoaded(this.notifications);

  @override
  List<Object?> get props => [notifications];
}

class NotificationMarkedAsRead extends NotificationState {}

class AllNotificationsMarkedAsRead extends NotificationState {}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository notificationRepository;

  NotificationBloc({required this.notificationRepository}) : super(NotificationInitial()) {
    on<GetNotificationsEvent>(_onGetNotifications);
    on<MarkNotificationAsReadEvent>(_onMarkNotificationAsRead);
    on<MarkAllNotificationsAsReadEvent>(_onMarkAllNotificationsAsRead);
  }

  Future<void> _onGetNotifications(GetNotificationsEvent event, Emitter<NotificationState> emit) async {
    emit(NotificationLoading());
    final result = await notificationRepository.getNotifications();
    result.fold(
      (failure) => emit(NotificationError(failure.toString())),
      (notifications) => emit(NotificationsLoaded(notifications)),
    );
  }

  Future<void> _onMarkNotificationAsRead(MarkNotificationAsReadEvent event, Emitter<NotificationState> emit) async {
    emit(NotificationLoading());
    final result = await notificationRepository.markNotificationAsRead(event.id);
    result.fold(
      (failure) => emit(NotificationError(failure.toString())),
      (_) => emit(NotificationMarkedAsRead()),
    );
  }

  Future<void> _onMarkAllNotificationsAsRead(MarkAllNotificationsAsReadEvent event, Emitter<NotificationState> emit) async {
    emit(NotificationLoading());
    final result = await notificationRepository.markAllNotificationsAsRead();
    result.fold(
      (failure) => emit(NotificationError(failure.toString())),
      (_) => emit(AllNotificationsMarkedAsRead()),
    );
  }
}