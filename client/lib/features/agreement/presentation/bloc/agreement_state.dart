part of 'agreement_bloc.dart';

/// Base class for all agreement states.
sealed class AgreementState extends Equatable {
  const AgreementState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any action.
final class AgreementInitial extends AgreementState {
  const AgreementInitial();
}

/// Loading pending agreements.
final class AgreementLoading extends AgreementState {
  const AgreementLoading();
}

/// Performing an action (propose, counter, accept, reject).
final class AgreementActionInProgress extends AgreementState {
  const AgreementActionInProgress();
}

/// Pending agreements loaded successfully.
final class AgreementsLoaded extends AgreementState {
  final List<Agreement> agreements;

  const AgreementsLoaded(this.agreements);

  @override
  List<Object?> get props => [agreements];
}

/// Agreement action completed successfully.
final class AgreementActionSuccess extends AgreementState {
  final Agreement agreement;
  final String message;

  const AgreementActionSuccess({
    required this.agreement,
    required this.message,
  });

  @override
  List<Object?> get props => [agreement, message];
}

/// Settlement loaded successfully.
final class SettlementLoaded extends AgreementState {
  final SettlementResult settlement;

  const SettlementLoaded(this.settlement);

  @override
  List<Object?> get props => [settlement];
}

/// Error state.
final class AgreementError extends AgreementState {
  final String message;

  const AgreementError(this.message);

  @override
  List<Object?> get props => [message];
}
