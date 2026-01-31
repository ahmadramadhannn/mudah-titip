part of 'guest_consignor_bloc.dart';

/// Base class for all guest consignor states.
sealed class GuestConsignorState extends Equatable {
  const GuestConsignorState();

  @override
  List<Object?> get props => [];
}

/// Initial state.
final class GuestConsignorInitial extends GuestConsignorState {
  const GuestConsignorInitial();
}

/// Loading state.
final class GuestConsignorLoading extends GuestConsignorState {
  const GuestConsignorLoading();
}

/// Successfully loaded guest consignors.
final class GuestConsignorLoaded extends GuestConsignorState {
  final List<GuestConsignor> guestConsignors;

  const GuestConsignorLoaded({required this.guestConsignors});

  @override
  List<Object?> get props => [guestConsignors];
}

/// Operation (create/update/delete) succeeded.
final class GuestConsignorOperationSuccess extends GuestConsignorState {
  final String message;
  final GuestConsignor? guestConsignor;

  const GuestConsignorOperationSuccess({
    required this.message,
    this.guestConsignor,
  });

  @override
  List<Object?> get props => [message, guestConsignor];
}

/// Error state.
final class GuestConsignorError extends GuestConsignorState {
  final String message;

  const GuestConsignorError(this.message);

  @override
  List<Object?> get props => [message];
}
