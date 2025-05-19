import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/entities.dart';
import '../../../../domain/repositories/repositories.dart';

// Events
abstract class LoanEvent extends Equatable {
  const LoanEvent();

  @override
  List<Object?> get props => [];
}

class GetLoansEvent extends LoanEvent {
  final bool? isActive;

  const GetLoansEvent({this.isActive});

  @override
  List<Object?> get props => [isActive];
}

class GetLoanByIdEvent extends LoanEvent {
  final String id;

  const GetLoanByIdEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class GetLoanHistoryEvent extends LoanEvent {}

class GetPenaltyEvent extends LoanEvent {
  final String loanId;

  const GetPenaltyEvent(this.loanId);

  @override
  List<Object?> get props => [loanId];
}

// States
abstract class LoanState extends Equatable {
  const LoanState();

  @override
  List<Object?> get props => [];
}

class LoanInitial extends LoanState {}

class LoanLoading extends LoanState {}

class LoansLoaded extends LoanState {
  final List<Loan> loans;

  const LoansLoaded(this.loans);

  @override
  List<Object?> get props => [loans];
}

class LoanDetailsLoaded extends LoanState {
  final Loan loan;

  const LoanDetailsLoaded(this.loan);

  @override
  List<Object?> get props => [loan];
}

class LoanHistoryLoaded extends LoanState {
  final List<Loan> loanHistory;

  const LoanHistoryLoaded(this.loanHistory);

  @override
  List<Object?> get props => [loanHistory];
}

class PenaltyLoaded extends LoanState {
  final double penalty;

  const PenaltyLoaded(this.penalty);

  @override
  List<Object?> get props => [penalty];
}

class LoanError extends LoanState {
  final String message;

  const LoanError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class LoanBloc extends Bloc<LoanEvent, LoanState> {
  final LoanRepository loanRepository;

  LoanBloc({required this.loanRepository}) : super(LoanInitial()) {
    on<GetLoansEvent>(_onGetLoans);
    on<GetLoanByIdEvent>(_onGetLoanById);
    on<GetLoanHistoryEvent>(_onGetLoanHistory);
    on<GetPenaltyEvent>(_onGetPenalty);
  }

  Future<void> _onGetLoans(GetLoansEvent event, Emitter<LoanState> emit) async {
    emit(LoanLoading());
    final result = await loanRepository.getLoans(isActive: event.isActive);
    result.fold(
      (failure) => emit(LoanError(failure.toString())),
      (loans) => emit(LoansLoaded(loans)),
    );
  }

  Future<void> _onGetLoanById(GetLoanByIdEvent event, Emitter<LoanState> emit) async {
    emit(LoanLoading());
    final result = await loanRepository.getLoanById(event.id);
    result.fold(
      (failure) => emit(LoanError(failure.toString())),
      (loan) => emit(LoanDetailsLoaded(loan)),
    );
  }

  Future<void> _onGetLoanHistory(GetLoanHistoryEvent event, Emitter<LoanState> emit) async {
    emit(LoanLoading());
    final result = await loanRepository.getLoanHistory();
    result.fold(
      (failure) => emit(LoanError(failure.toString())),
      (loanHistory) => emit(LoanHistoryLoaded(loanHistory)),
    );
  }

  Future<void> _onGetPenalty(GetPenaltyEvent event, Emitter<LoanState> emit) async {
    emit(LoanLoading());
    final result = await loanRepository.getPenalty(event.loanId);
    result.fold(
      (failure) => emit(LoanError(failure.toString())),
      (penalty) => emit(PenaltyLoaded(penalty)),
    );
  }
}
