// lib/data/repositories/hybrid_loan_repository.dart

import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';
import 'graphql_loan_repository.dart';
import 'repositories_impl.dart';
import '../mock_data.dart';

/// Repositorio híbrido que siempre incluye datos estáticos de préstamos
class HybridLoanRepository implements LoanRepository {
  final GraphQLLoanRepository _graphqlRepository;
  final LoanRepositoryImpl _mockRepository;

  HybridLoanRepository(
    this._graphqlRepository,
    this._mockRepository,
  );

  @override
  Future<Either<Failure, List<Loan>>> getLoans({bool? isActive}) async {
    try {
      print('🔄 Obteniendo préstamos - GraphQL + datos estáticos');
      
      // 1. Intentar obtener préstamos del servidor
      List<Loan> serverLoans = [];
      
      final graphqlResult = await _graphqlRepository.getLoans(isActive: isActive);
      graphqlResult.fold(
        (failure) {
          print('⚠️ GraphQL falló para préstamos: ${failure.message}');
        },
        (loans) {
          serverLoans = loans;
          print('✅ GraphQL devolvió ${loans.length} préstamos del servidor');
        },
      );
      
      // 2. SIEMPRE agregar los datos estáticos (especialmente el préstamo por vencer)
      final mockResult = await _mockRepository.getLoans(isActive: isActive);
      
      return mockResult.fold(
        (failure) {
          // Si falla mock, al menos devolver del servidor
          if (serverLoans.isNotEmpty) {
            return Right(serverLoans);
          }
          return Left(failure);
        },
        (mockLoans) {
          // 3. Combinar servidor + mock, evitando duplicados
          final Map<String, Loan> loanMap = {};
          
          // Primero agregar los del servidor
          for (var loan in serverLoans) {
            loanMap[loan.id] = loan;
          }
          
          // Luego agregar los mock (los estáticos tienen prioridad si hay conflicto)
          for (var loan in mockLoans) {
            loanMap[loan.id] = loan;
          }
          
          final combinedLoans = loanMap.values.toList();
          
          // 4. Ordenar por fecha de préstamo (más recientes primero)
          combinedLoans.sort((a, b) => b.loanDate.compareTo(a.loanDate));
          
          print('✅ Devolviendo ${combinedLoans.length} préstamos combinados');
          
          // 5. Verificar que tenemos el préstamo próximo a vencer
          final expiringSoon = combinedLoans.where((loan) {
            if (loan.isReturned || loan.isLate) return false;
            final daysUntilDue = loan.dueDate.difference(DateTime.now()).inDays;
            return daysUntilDue <= 3 && daysUntilDue >= 0;
          }).toList();
          
          print('📊 Préstamos próximos a vencer en la respuesta: ${expiringSoon.length}');
          
          return Right(combinedLoans);
        },
      );
      
    } catch (e) {
      print('❌ Error en HybridLoanRepository: $e');
      // Fallback final: solo datos mock
      return _mockRepository.getLoans(isActive: isActive);
    }
  }

  @override
  Future<Either<Failure, Loan>> getLoanById(String id) async {
    try {
      // 1. Buscar primero en datos estáticos
      final allMockLoans = [...MockData.loans, ...MockData.loanHistory];
      final mockLoan = allMockLoans.where((loan) => loan.id == id).firstOrNull;
      
      if (mockLoan != null) {
        print('✅ Préstamo encontrado en datos estáticos: ${mockLoan.bookTitle}');
        return Right(mockLoan);
      }
      
      // 2. Si no está en mock, buscar en GraphQL
      final graphqlResult = await _graphqlRepository.getLoanById(id);
      return graphqlResult.fold(
        (failure) {
          print('⚠️ GraphQL falló, intentando con mock repository');
          return _mockRepository.getLoanById(id);
        },
        (loan) {
          print('✅ Préstamo encontrado en GraphQL: ${loan.bookTitle}');
          return Right(loan);
        },
      );
      
    } catch (e) {
      print('❌ Error en getLoanById: $e');
      return Left(ServerFailure('No se pudo obtener el préstamo'));
    }
  }

  @override
  Future<Either<Failure, List<Loan>>> getLoanHistory() async {
    return getLoans(isActive: false);
  }

  @override
  Future<Either<Failure, double>> getPenalty(String loanId) async {
    try {
      // Intentar GraphQL primero
      final graphqlResult = await _graphqlRepository.getPenalty(loanId);
      
      return graphqlResult.fold(
        (failure) {
          print('⚠️ GraphQL falló para penalty, usando mock');
          return _mockRepository.getPenalty(loanId);
        },
        (penalty) {
          return Right(penalty);
        },
      );
    } catch (e) {
      return _mockRepository.getPenalty(loanId);
    }
  }

  // Método auxiliar para debugging
  void debugLoansStatus() {
    print('🔍 ESTADO DE PRÉSTAMOS:');
    final expiringSoon = MockData.getLoansExpiringSoon(daysThreshold: 3);
    print('   Próximos a vencer: ${expiringSoon.length}');
    
    for (var loan in expiringSoon) {
      final daysLeft = loan.dueDate.difference(DateTime.now()).inDays;
      print('   - ${loan.bookTitle}: vence en $daysLeft días');
    }
  }
}