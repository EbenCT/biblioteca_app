// lib/data/repositories/hybrid_reservation_repository.dart (ACTUALIZADO)

import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/services/reservation_cache_service.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';
import 'graphql_reservation_repository.dart';
import 'repositories_impl.dart';

/// Repositorio híbrido que usa GraphQL cuando funciona, 
/// cache local para nuevas reservas, y fallback a datos mock
class HybridReservationRepository implements ReservationRepository {
  final GraphQLReservationRepository _graphqlRepository;
  final ReservationRepositoryImpl _mockRepository;
  final ReservationCacheService _cacheService;
  final BookRepository _bookRepository;

  HybridReservationRepository(
    this._graphqlRepository,
    this._mockRepository,
    this._bookRepository,
  ) : _cacheService = ReservationCacheService.instance;

  @override
  Future<Either<Failure, List<Reservation>>> getReservations({bool? isActive}) async {
    try {
      print('🔄 Obteniendo reservas - prioridad: Cache > GraphQL > Mock');
      
      // 1. Primero intentar con GraphQL para obtener reservas del servidor
      List<Reservation> serverReservations = [];
      
      final graphqlResult = await _graphqlRepository.getReservations(isActive: isActive);
      graphqlResult.fold(
        (failure) {
          print('⚠️ GraphQL falló para reservas: ${failure.message}');
        },
        (reservations) {
          serverReservations = reservations;
          print('✅ GraphQL devolvió ${reservations.length} reservas del servidor');
        },
      );
      
      // 2. Obtener reservas del cache local (incluye las creadas localmente)
      final cachedReservations = _cacheService.getAllReservations(isActive: isActive);
      print('📱 Cache local tiene ${cachedReservations.length} reservas');
      
      // 3. Combinar reservas: servidor + cache local
      // Evitar duplicados usando el ID
      final Map<String, Reservation> reservationMap = {};
      
      // Primero agregar las del servidor
      for (var reservation in serverReservations) {
        reservationMap[reservation.id] = reservation;
      }
      
      // Luego agregar las del cache local (las locales tienen prioridad si hay conflicto)
      for (var reservation in cachedReservations) {
        reservationMap[reservation.id] = reservation;
      }
      
      final combinedReservations = reservationMap.values.toList();
      
      // 4. Si no hay reservas, usar datos mock como última opción
      if (combinedReservations.isEmpty) {
        print('⚠️ No hay reservas en servidor ni cache, usando mock como fallback');
        return _mockRepository.getReservations(isActive: isActive);
      }
      
      // 5. Ordenar por fecha de reserva (más recientes primero)
      combinedReservations.sort((a, b) => b.reservationDate.compareTo(a.reservationDate));
      
      print('✅ Devolviendo ${combinedReservations.length} reservas combinadas');
      _cacheService.debugPrintReservations();
      
      return Right(combinedReservations);
      
    } catch (e) {
      print('❌ Error en getReservations, usando cache local: $e');
      final cachedReservations = _cacheService.getAllReservations(isActive: isActive);
      return Right(cachedReservations);
    }
  }

  @override
  Future<Either<Failure, Reservation>> getReservationById(String id) async {
    try {
      print('🔍 Buscando reserva por ID: $id');
      
      // 1. Buscar primero en cache local
      final cachedReservation = _cacheService.getReservationById(id);
      if (cachedReservation != null) {
        print('✅ Reserva encontrada en cache local: ${cachedReservation.bookTitle}');
        return Right(cachedReservation);
      }
      
      // 2. Si no está en cache, buscar en GraphQL
      final graphqlResult = await _graphqlRepository.getReservationById(id);
      return graphqlResult.fold(
        (failure) {
          print('⚠️ GraphQL falló, intentando con mock repository');
          return _mockRepository.getReservationById(id);
        },
        (reservation) {
          print('✅ Reserva encontrada en GraphQL: ${reservation.bookTitle}');
          return Right(reservation);
        },
      );
      
    } catch (e) {
      print('❌ Error en getReservationById: $e');
      return Left(ServerFailure('No se pudo obtener la reserva'));
    }
  }

  @override
  Future<Either<Failure, Reservation>> createReservation(String bookId) async {
    try {
      print('📚 Creando nueva reserva para libro: $bookId');
      
      // 1. Obtener información del libro
      final bookResult = await _bookRepository.getBookById(bookId);
      
      return bookResult.fold(
        (failure) {
          print('❌ No se pudo obtener información del libro: ${failure.message}');
          return Left(failure);
        },
        (book) async {
          // 2. Verificar que el libro esté disponible
          if (!book.isAvailable) {
            print('❌ Libro no disponible para reserva: ${book.title}');
            return Left(ServerFailure('El libro "${book.title}" no está disponible para reserva'));
          }
          
          // 3. Intentar crear la reserva en el servidor primero
          bool serverReservationFailed = false;
          
          final graphqlResult = await _graphqlRepository.createReservation(bookId);
          final serverReservation = graphqlResult.fold(
            (failure) {
              print('⚠️ No se pudo crear reserva en servidor: ${failure.message}');
              serverReservationFailed = true;
              return null;
            },
            (reservation) {
              print('✅ Reserva creada en servidor: ${reservation.id}');
              return reservation;
            },
          );
          
          // 4. Crear reserva en cache local (siempre, como backup)
          final localReservation = _cacheService.createReservation(
            bookId,
            book.title,
            book.imageUrl,
          );
          
          // 5. Retornar la reserva del servidor si existe, sino la local
          final finalReservation = serverReservation ?? localReservation;
          
          if (serverReservationFailed) {
            print('📱 Reserva creada solo en cache local (servidor no disponible)');
          } else {
            print('✅ Reserva creada tanto en servidor como en cache local');
          }
          
          return Right(finalReservation);
        },
      );
      
    } catch (e) {
      print('❌ Error en createReservation: $e');
      return Left(ServerFailure('Error al crear la reserva: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelReservation(String id) async {
    try {
      print('🗑️ Cancelando reserva: $id');
      
      // 1. Intentar cancelar en el servidor
      bool serverCancellationFailed = false;
      
      final graphqlResult = await _graphqlRepository.cancelReservation(id);
      graphqlResult.fold(
        (failure) {
          print('⚠️ No se pudo cancelar en servidor: ${failure.message}');
          serverCancellationFailed = true;
        },
        (_) {
          print('✅ Reserva cancelada en servidor');
        },
      );
      
      // 2. Cancelar en cache local (siempre)
      final localCancelled = _cacheService.cancelReservation(id);
      
      if (!localCancelled && serverCancellationFailed) {
        print('❌ No se pudo cancelar la reserva ni en servidor ni en cache');
        return Left(ServerFailure('No se pudo cancelar la reserva'));
      }
      
      if (serverCancellationFailed) {
        print('📱 Reserva cancelada solo en cache local (servidor no disponible)');
      } else {
        print('✅ Reserva cancelada tanto en servidor como en cache local');
      }
      
      return const Right(null);
      
    } catch (e) {
      print('❌ Error en cancelReservation: $e');
      return Left(ServerFailure('Error al cancelar la reserva'));
    }
  }

  // Método adicional para debugging
  void debugCacheStatus() {
    print('🔍 ESTADO DEL CACHE DE RESERVAS:');
    final stats = _cacheService.getCacheStats();
    print('   Total: ${stats['total']}');
    print('   Activas: ${stats['active']}');
    print('   Canceladas: ${stats['cancelled']}');
    print('   Expiradas: ${stats['expired']}');
    print('   Inicializado: ${stats['initialized']}');
    
    _cacheService.debugPrintReservations();
  }

  // Método para limpiar cache (útil para logout)
  void clearCache() {
    _cacheService.clearCache();
    print('🗑️ Cache de reservas limpiado');
  }
}