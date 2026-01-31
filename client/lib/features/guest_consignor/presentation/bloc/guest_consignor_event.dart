part of 'guest_consignor_bloc.dart';

/// Base class for all guest consignor events.
sealed class GuestConsignorEvent extends Equatable {
  const GuestConsignorEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all guest consignors.
class GuestConsignorLoadRequested extends GuestConsignorEvent {
  const GuestConsignorLoadRequested();
}

/// Event to create a new guest consignor.
class GuestConsignorCreateRequested extends GuestConsignorEvent {
  final GuestConsignorRequest request;

  const GuestConsignorCreateRequested({required this.request});

  @override
  List<Object?> get props => [request];
}

/// Event to update an existing guest consignor.
class GuestConsignorUpdateRequested extends GuestConsignorEvent {
  final int id;
  final GuestConsignorRequest request;

  const GuestConsignorUpdateRequested({
    required this.id,
    required this.request,
  });

  @override
  List<Object?> get props => [id, request];
}

/// Event to delete a guest consignor.
class GuestConsignorDeleteRequested extends GuestConsignorEvent {
  final int id;

  const GuestConsignorDeleteRequested({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Event to search guest consignors.
class GuestConsignorSearchRequested extends GuestConsignorEvent {
  final String? phone;
  final String? name;

  const GuestConsignorSearchRequested({this.phone, this.name});

  @override
  List<Object?> get props => [phone, name];
}
