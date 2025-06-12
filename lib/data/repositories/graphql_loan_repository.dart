// ignore_for_file: dead_code

import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/services/graphql_service.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';
import '../datasources/graphql_queries.dart';
import '../mock_data.dart';
import '../models/graphql_models.dart' as gql_models;

class GraphQLLoanRepository implements LoanRepository {
  final GraphQLService _graphQLService;

  GraphQLLoanRepository(this._graphQLService);

// lib/data/repositories/graphql_loan_repository.dart
// ACTUALIZAR el método getLoans para incluir fallback:

@override
Future<Either<Failure, List<Loan>>> getLoans({bool? isActive}) async {
  try {
    String graphQLQuery;
    
    if (isActive == true) {
      graphQLQuery = GraphQLQueries.getPrestamos;
    } else if (isActive == false) {
      graphQLQuery = GraphQLQueries.getPrestamos;
    } else {
      graphQLQuery = GraphQLQueries.getPrestamos;
    }

    final result = await _graphQLService.query(
      graphQLQuery,
      variables: {'page': 0, 'size': 50},
    );

    if (result.hasException) {
      print('⚠️ Error en GraphQL para préstamos: ${result.exception}');
      // FALLBACK: usar datos mock que incluyen el préstamo por vencer
      return _getMockLoans(isActive: isActive);
    }

    final data = result.data;
    if (data == null || data['prestamos'] == null) {
      print('⚠️ No hay datos de préstamos en GraphQL, usando mock');
      // FALLBACK: usar datos mock
      return _getMockLoans(isActive: isActive);
    }

    final paginatedResult = gql_models.PaginatedResult<gql_models.Prestamo>.fromJson(
      data['prestamos'],
      (json) => gql_models.Prestamo.fromJson(json),
    );

    // Convertir a entidades del dominio
    List<Loan> loans = paginatedResult.content.map((prestamo) => _mapPrestamoToLoan(prestamo)).toList();

    // IMPORTANTE: Si no hay préstamos del servidor, agregar los estáticos
    if (loans.isEmpty) {
      print('📚 No hay préstamos del servidor, agregando datos estáticos');
      final mockResult = await _getMockLoans(isActive: isActive);
      return mockResult.fold(
        (failure) => Left(failure),
        (mockLoans) => Right(mockLoans),
      );
    }

    // COMBINAR: préstamos del servidor + préstamos estáticos mock
    final mockResult = await _getMockLoans(isActive: isActive);
    mockResult.fold(
      (failure) {
        // Si falla mock, solo devolver del servidor
      },
      (mockLoans) {
        // Agregar préstamos mock que no estén ya en la lista del servidor
        for (var mockLoan in mockLoans) {
          if (!loans.any((loan) => loan.id == mockLoan.id)) {
            loans.add(mockLoan);
          }
        }
      },
    );

    // Aplicar filtros según isActive
    if (isActive == true) {
      loans = loans.where((loan) => !loan.isReturned).toList();
    } else if (isActive == false) {
      loans = loans.where((loan) => loan.isReturned).toList();
    }

    print('✅ Devolviendo ${loans.length} préstamos (servidor + estáticos)');
    return Right(loans);
    
  } catch (e) {
    print('❌ Error en GraphQL préstamos: $e');
    // FALLBACK final: datos mock
    return _getMockLoans(isActive: isActive);
  }
}

// AGREGAR este método helper:
Future<Either<Failure, List<Loan>>> _getMockLoans({bool? isActive}) async {
  try {
    await Future.delayed(const Duration(milliseconds: 500)); // Simular delay

    if (isActive == true) {
      return Right(MockData.loans.where((loan) => !loan.isReturned).toList());
    } else if (isActive == false) {
      return Right(MockData.loanHistory);
    } else {
      return Right([...MockData.loans, ...MockData.loanHistory]);
    }
  } catch (e) {
    return Left(ServerFailure('Error en datos mock: $e'));
  }
}

// El resto de la clase se mantiene igual...
  @override
  Future<Either<Failure, Loan>> getLoanById(String id) async {
    try {
      // El schema no tiene una query específica para un préstamo por ID
      // Podríamos obtener todos y filtrar, o agregar la query al schema
      final result = await _graphQLService.query(
        GraphQLQueries.getPrestamos,
        variables: {'page': 0, 'size': 100},
      );

      if (result.hasException) {
        return Left(ServerFailure(result.exception.toString()));
      }

      final data = result.data;
      if (data == null) {
        return Left(ServerFailure('No data received'));
      }

      final paginatedResult = gql_models.PaginatedResult<gql_models.Prestamo>.fromJson(
        data['prestamos'],
        (json) => gql_models.Prestamo.fromJson(json),
      );

      // Buscar el préstamo específico
      final prestamo = paginatedResult.content.firstWhere(
        (p) => p.id == id,
        orElse: () => throw Exception('Loan not found'),
      );

      final loan = _mapPrestamoToLoan(prestamo);
      return Right(loan);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Loan>>> getLoanHistory() async {
    // Reutilizar getLoans con isActive = false
    return getLoans(isActive: false);
  }

  @override
  Future<Either<Failure, double>> getPenalty(String loanId) async {
    try {
      // Obtener el préstamo específico
      final loanResult = await getLoanById(loanId);
      
      return loanResult.fold(
        (failure) => Left(failure),
        (loan) {
          // Calcular penalidad si está atrasado
          if (loan.isLate && loan.penalty != null) {
            return Right(loan.penalty!);
          }
          return const Right(0.0);
        },
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<Loan>>> getLoansByMemberId(String memberId) async {
    try {
      final result = await _graphQLService.query(
        GraphQLQueries.getPrestamosPorMiembro,
        variables: {'miembroId': memberId},
      );

      if (result.hasException) {
        return Left(ServerFailure(result.exception.toString()));
      }

      final data = result.data;
      if (data == null) {
        return Left(ServerFailure('No data received'));
      }

      final prestamos = (data['prestamosPorMiembro'] as List)
          .map((json) => gql_models.Prestamo.fromJson(json))
          .toList();

      final loans = prestamos.map((prestamo) => _mapPrestamoToLoan(prestamo)).toList();
      return Right(loans);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<Loan>>> getOverdueLoans() async {
    try {
      final result = await _graphQLService.query(GraphQLQueries.getPrestamosVencidos);

      if (result.hasException) {
        return Left(ServerFailure(result.exception.toString()));
      }

      final data = result.data;
      if (data == null) {
        return Left(ServerFailure('No data received'));
      }

      final prestamos = (data['prestamosVencidos'] as List)
          .map((json) => gql_models.Prestamo.fromJson(json))
          .toList();

      final loans = prestamos.map((prestamo) => _mapPrestamoToLoan(prestamo)).toList();
      return Right(loans);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Loan _mapPrestamoToLoan(gql_models.Prestamo prestamo) {
    // Determinar si está atrasado
    final now = DateTime.now();
    final isLate = prestamo.fechaDevolucion.isBefore(now);
    
    // Calcular penalidad si está atrasado (ejemplo: 2 Bs por día)
    double? penalty;
    if (isLate) {
      final daysLate = now.difference(prestamo.fechaDevolucion).inDays;
      penalty = daysLate * 2.0; // 2 Bs por día de retraso
    }

    // Por ahora, consideramos que un préstamo está "devuelto" si la fecha de devolución ya pasó
    // En un sistema real, habría un campo específico para esto
    final isReturned = false; // Asumir que no está devuelto a menos que se especifique

    // Obtener información del primer libro del préstamo para la UI
    final firstDetail = prestamo.detalles.isNotEmpty ? prestamo.detalles.first : null;
    final bookTitle = firstDetail?.ejemplar.nombre ?? 'Libro desconocido';
    final bookImageUrl = _generateBookImageUrl(bookTitle);

    return Loan(
      id: prestamo.id,
      bookId: firstDetail?.ejemplar.id ?? '',
      bookTitle: bookTitle,
      bookImageUrl: bookImageUrl,
      loanDate: prestamo.fechaInicio,
      dueDate: prestamo.fechaDevolucion,
      isReturned: isReturned,
      returnDate: isReturned ? prestamo.fechaDevolucion : null,
      isLate: isLate && !isReturned,
      penalty: penalty,
    );
  }

  String _generateBookImageUrl(String bookTitle) {
    // Generar una URL de imagen usando un servicio de placeholders
    return 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400&h=600&fit=crop&q=80';
  }
}