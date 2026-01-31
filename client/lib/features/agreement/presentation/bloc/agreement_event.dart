part of 'agreement_bloc.dart';

/// Base class for all agreement events.
sealed class AgreementEvent extends Equatable {
  const AgreementEvent();

  @override
  List<Object?> get props => [];
}

/// Load pending agreements for current user.
final class LoadPendingAgreements extends AgreementEvent {
  const LoadPendingAgreements();
}

/// Propose a new agreement.
final class ProposeAgreement extends AgreementEvent {
  final AgreementRequest request;

  const ProposeAgreement(this.request);

  @override
  List<Object?> get props => [request];
}

/// Counter an existing proposal with new terms.
final class CounterAgreement extends AgreementEvent {
  final int agreementId;
  final AgreementRequest request;

  const CounterAgreement({required this.agreementId, required this.request});

  @override
  List<Object?> get props => [agreementId, request];
}

/// Accept a proposal.
final class AcceptAgreement extends AgreementEvent {
  final int agreementId;
  final String? message;

  const AcceptAgreement({required this.agreementId, this.message});

  @override
  List<Object?> get props => [agreementId, message];
}

/// Reject a proposal.
final class RejectAgreement extends AgreementEvent {
  final int agreementId;
  final String? reason;

  const RejectAgreement({required this.agreementId, this.reason});

  @override
  List<Object?> get props => [agreementId, reason];
}

/// Load settlement calculation for a consignment.
final class LoadSettlement extends AgreementEvent {
  final int consignmentId;

  const LoadSettlement(this.consignmentId);

  @override
  List<Object?> get props => [consignmentId];
}
