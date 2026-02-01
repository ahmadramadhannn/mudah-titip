part of 'consignment_bloc.dart';

/// Base class for consignment events.
sealed class ConsignmentEvent extends Equatable {
  const ConsignmentEvent();

  @override
  List<Object?> get props => [];
}

/// Load all consignments for current user.
final class LoadConsignments extends ConsignmentEvent {
  final ConsignmentStatus? status;

  const LoadConsignments({this.status});

  @override
  List<Object?> get props => [status];
}

/// Load a single consignment.
final class LoadConsignmentDetail extends ConsignmentEvent {
  final int consignmentId;

  const LoadConsignmentDetail(this.consignmentId);

  @override
  List<Object?> get props => [consignmentId];
}

/// Create a new consignment.
final class CreateConsignment extends ConsignmentEvent {
  final ConsignmentRequest request;

  const CreateConsignment(this.request);

  @override
  List<Object?> get props => [request];
}

/// Update consignment status.
final class UpdateConsignmentStatus extends ConsignmentEvent {
  final int consignmentId;
  final ConsignmentStatus status;

  const UpdateConsignmentStatus({
    required this.consignmentId,
    required this.status,
  });

  @override
  List<Object?> get props => [consignmentId, status];
}

/// Load consignments expiring soon.
final class LoadExpiringSoon extends ConsignmentEvent {
  final int days;

  const LoadExpiringSoon({this.days = 7});

  @override
  List<Object?> get props => [days];
}
