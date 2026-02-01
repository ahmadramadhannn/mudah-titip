part of 'consignment_bloc.dart';

/// Base class for consignment states.
sealed class ConsignmentState extends Equatable {
  const ConsignmentState();

  @override
  List<Object?> get props => [];
}

/// Initial state.
final class ConsignmentInitial extends ConsignmentState {}

/// Loading consignments.
final class ConsignmentLoading extends ConsignmentState {}

/// Consignments loaded successfully.
final class ConsignmentsLoaded extends ConsignmentState {
  final List<Consignment> consignments;
  final ConsignmentStatus? filterStatus;

  const ConsignmentsLoaded({required this.consignments, this.filterStatus});

  @override
  List<Object?> get props => [consignments, filterStatus];
}

/// Single consignment loaded.
final class ConsignmentDetailLoaded extends ConsignmentState {
  final Consignment consignment;

  const ConsignmentDetailLoaded(this.consignment);

  @override
  List<Object?> get props => [consignment];
}

/// Consignment created successfully.
final class ConsignmentCreated extends ConsignmentState {
  final Consignment consignment;

  const ConsignmentCreated(this.consignment);

  @override
  List<Object?> get props => [consignment];
}

/// Consignment status updated.
final class ConsignmentStatusUpdated extends ConsignmentState {
  final Consignment consignment;

  const ConsignmentStatusUpdated(this.consignment);

  @override
  List<Object?> get props => [consignment];
}

/// Expiring consignments loaded.
final class ExpiringConsignmentsLoaded extends ConsignmentState {
  final List<Consignment> consignments;
  final int days;

  const ExpiringConsignmentsLoaded({
    required this.consignments,
    required this.days,
  });

  @override
  List<Object?> get props => [consignments, days];
}

/// Error state.
final class ConsignmentError extends ConsignmentState {
  final String message;

  const ConsignmentError(this.message);

  @override
  List<Object?> get props => [message];
}
