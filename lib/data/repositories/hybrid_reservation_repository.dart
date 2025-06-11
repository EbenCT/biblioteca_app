import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';
import 'graphql_reservation_repository.dart';
import 'repositories_impl.dart';

/// Repositorio híbrido que usa GraphQL cuando funciona, 
/// y fallback a datos mock cuando hay problemas
class HybridReservationRepository implements ReservationRepository {
  final GraphQLReservationRepository _graphqlRepository;
  final ReservationRepositoryImpl _mockRepository;

  HybridReservationRepository(
    this._graphqlRepository,
    this._mockRepository,
  );

  @override
  Future<Either<Failure, List<Reservation>>> getReservations({bool? isActive}) async {
    try {
      print('🔄 Trying GraphQL for getReservations...');
      
      // Intentar con GraphQL primero
      final graphqlResult = await _graphqlRepository.getReservations(isActive: isActive);
      
      return graphqlResult.fold(
        (failure) {
          print('⚠️ GraphQL failed, falling back to mock data: ${failure.message}');
          // Si GraphQL falla, usar datos mock
          return _mockRepository.getReservations(isActive: isActive);
        },
        (reservations) {
          print('✅ GraphQL succeeded with ${reservations.length} reservations');
          return Right(reservations);
        },
      );
    } catch (e) {
      print('❌ Exception in getReservations, using mock fallback: $e');
      return _mockRepository.getReservations(isActive: isActive);
    }
  }

  @override
  Future<Either<Failure, Reservation>> getReservationById(String id) async {
    try {
      print('🔄 Trying GraphQL for getReservationById...');
      
      final graphqlResult = await _graphqlRepository.getReservationById(id);
      
      return graphqlResult.fold(
        (failure) {
          print('⚠️ GraphQL failed, falling back to mock data');
          return _mockRepository.getReservationById(id);
        },
        (reservation) {
          print('✅ GraphQL succeeded for reservation $id');
          return Right(reservation);
        },
      );
    } catch (e) {
      print('❌ Exception in getReservationById, using mock fallback: $e');
      return _mockRepository.getReservationById(id);
    }
  }

  @override
  Future<Either<Failure, Reservation>> createReservation(String bookId) async {
    try {
      print('🔄 Trying GraphQL for createReservation...');
      
      // Intentar con GraphQL primero
      final graphqlResult = await _graphqlRepository.createReservation(bookId);
      
      return graphqlResult.fold(
        (failure) {
          print('⚠️ GraphQL createReservation failed, using mock fallback');
          return _mockRepository.createReservation(bookId);
        },
        (reservation) {
          print('✅ GraphQL createReservation succeeded');
          return Right(reservation);
        },
      );
    } catch (e) {
      print('❌ Exception in createReservation, using mock fallback: $e');
      return _mockRepository.createReservation(bookId);
    }
  }

  @override
  Future<Either<Failure, void>> cancelReservation(String id) async {
    try {
      print('🔄 Trying GraphQL for cancelReservation...');
      
      final graphqlResult = await _graphqlRepository.cancelReservation(id);
      
      return graphqlResult.fold(
        (failure) {
          print('⚠️ GraphQL cancelReservation failed, using mock fallback');
          return _mockRepository.cancelReservation(id);
        },
        (result) {
          print('✅ GraphQL cancelReservation succeeded');
          return Right(result);
        },
      );
    } catch (e) {
      print('❌ Exception in cancelReservation, using mock fallback: $e');
      return _mockRepository.cancelReservation(id);
    }
  }
}