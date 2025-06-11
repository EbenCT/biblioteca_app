import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/services/graphql_service.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';
import '../datasources/graphql_queries.dart';
import '../models/graphql_models.dart' as gql_models;

class GraphQLReservationRepository implements ReservationRepository {
  final GraphQLService _graphQLService;

  GraphQLReservationRepository(this._graphQLService);

  @override
  Future<Either<Failure, List<Reservation>>> getReservations({bool? isActive}) async {
    try {
      final result = await _graphQLService.query(
        GraphQLQueries.getReservas,
        variables: {'page': 0, 'size': 50},
      );

      if (result.hasException) {
        print('GraphQL Exception details: ${result.exception}');
        
        // Si es un error de campo null, devolver lista vacía
        if (result.exception.toString().contains('null value') || 
            result.exception.toString().contains('NullValueInNonNullableField')) {
          print('⚠️ Backend returned null for reservas - returning empty list');
          return const Right([]);
        }
        
        return Left(ServerFailure(result.exception.toString()));
      }

      final data = result.data;
      if (data == null) {
        print('⚠️ No data received for reservas - returning empty list');
        return const Right([]);
      }

      // Verificar si la respuesta de reservas es null
      if (data['reservas'] == null) {
        print('⚠️ reservas field is null - returning empty list');
        return const Right([]);
      }

      final paginatedResult = gql_models.PaginatedResult<gql_models.Reserva>.fromJson(
        data['reservas'],
        (json) => gql_models.Reserva.fromJson(json),
      );

      // Convertir a entidades del dominio
      List<Reservation> reservations = paginatedResult.content
          .map((reserva) => _mapReservaToReservation(reserva))
          .toList();

      // Aplicar filtros según isActive
      if (isActive == true) {
        reservations = reservations.where((reservation) => reservation.status == 'active').toList();
      }

      return Right(reservations);
    } catch (e) {
      print('❌ Error in getReservations: $e');
      
      // Si es un error de parsing o conexión, devolver lista vacía como fallback
      if (e.toString().contains('null') || e.toString().contains('parsing')) {
        print('🔄 Fallback: returning empty reservations list');
        return const Right([]);
      }
      
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Reservation>> getReservationById(String id) async {
    try {
      // Primero intentar obtener todas las reservas
      final reservationsResult = await getReservations();
      
      return reservationsResult.fold(
        (failure) => Left(failure),
        (reservations) {
          try {
            // Buscar la reserva específica
            final reservation = reservations.firstWhere(
              (r) => r.id == id,
              orElse: () => throw Exception('Reservation not found'),
            );
            return Right(reservation);
          } catch (e) {
            return Left(ServerFailure('Reservation with id $id not found'));
          }
        },
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Reservation>> createReservation(String bookId) async {
    try {
      // Para crear una reserva, necesitaríamos:
      // 1. El ID del miembro (usuario actual)
      // 2. Una mutation para crear reservas
      
      // Por ahora, simular la creación de una reserva exitosa
      // En un sistema real, necesitaríamos implementar la mutation en el backend
      
      print('⚠️ createReservation called but mutation not implemented in backend');
      
      // Simular una reserva creada exitosamente
      final mockReservation = Reservation(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        bookId: bookId,
        bookTitle: 'Libro Reservado',
        bookImageUrl: 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400&h=600&fit=crop',
        reservationDate: DateTime.now(),
        expirationDate: DateTime.now().add(const Duration(days: 3)),
        status: 'active',
      );
      
      return Right(mockReservation);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelReservation(String id) async {
    try {
      // Por ahora, simular cancelación exitosa
      print('⚠️ cancelReservation called but mutation not implemented in backend');
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<Reservation>>> getReservationsByMemberId(String memberId) async {
    try {
      final result = await _graphQLService.query(
        GraphQLQueries.getReservasPorMiembro,
        variables: {'miembroId': memberId},
      );

      if (result.hasException) {
        print('GraphQL Exception for member reservations: ${result.exception}');
        return const Right([]); // Devolver lista vacía en caso de error
      }

      final data = result.data;
      if (data == null || data['reservasPorMiembro'] == null) {
        return const Right([]);
      }

      final reservas = (data['reservasPorMiembro'] as List)
          .map((json) => gql_models.Reserva.fromJson(json))
          .toList();

      final reservations = reservas.map((reserva) => _mapReservaToReservation(reserva)).toList();
      return Right(reservations);
    } catch (e) {
      print('❌ Error getting reservations by member: $e');
      return const Right([]); // Devolver lista vacía como fallback
    }
  }

  Reservation _mapReservaToReservation(gql_models.Reserva reserva) {
    // Determinar el estado de la reserva
    final now = DateTime.now();
    String status;
    
    if (reserva.fechaRecojo.isBefore(now)) {
      status = 'expired'; // Expirada si la fecha de recojo ya pasó
    } else {
      status = 'active'; // Activa si aún se puede recoger
    }

    // Obtener información del primer libro de la reserva
    final firstDetail = reserva.detalles.isNotEmpty ? reserva.detalles.first : null;
    final bookTitle = firstDetail?.ejemplar.nombre ?? 'Libro desconocido';
    final bookImageUrl = _generateBookImageUrl(bookTitle);

    return Reservation(
      id: reserva.id,
      bookId: firstDetail?.ejemplar.id ?? '',
      bookTitle: bookTitle,
      bookImageUrl: bookImageUrl,
      reservationDate: reserva.fechaRegistro,
      expirationDate: reserva.fechaRecojo,
      status: status,
    );
  }

  String _generateBookImageUrl(String bookTitle) {
    // Generar una URL de imagen usando un servicio de placeholders
    return 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400&h=600&fit=crop&q=80';
  }
}