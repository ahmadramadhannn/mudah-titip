part of 'sale_bloc.dart';

/// Base class for sale events.
sealed class SaleEvent extends Equatable {
  const SaleEvent();

  @override
  List<Object?> get props => [];
}

/// Load sales for current user.
final class LoadMySales extends SaleEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadMySales({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

/// Record a new sale. (Shop owner only)
final class RecordSale extends SaleEvent {
  final SaleRequest request;

  const RecordSale(this.request);

  @override
  List<Object?> get props => [request];
}

/// Load sales summary.
final class LoadSalesSummary extends SaleEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadSalesSummary({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}
