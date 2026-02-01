part of 'sale_bloc.dart';

/// Base class for sale states.
sealed class SaleState extends Equatable {
  const SaleState();

  @override
  List<Object?> get props => [];
}

/// Initial state.
final class SaleInitial extends SaleState {}

/// Loading state.
final class SaleLoading extends SaleState {}

/// Sales loaded with summary.
final class SalesLoaded extends SaleState {
  final List<Sale> sales;
  final SalesSummary summary;
  final DateTime? startDate;
  final DateTime? endDate;

  const SalesLoaded({
    required this.sales,
    required this.summary,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [sales, summary, startDate, endDate];
}

/// Single summary loaded.
final class SummaryLoaded extends SaleState {
  final SalesSummary summary;

  const SummaryLoaded(this.summary);

  @override
  List<Object?> get props => [summary];
}

/// Sale recorded successfully.
final class SaleRecorded extends SaleState {
  final Sale sale;

  const SaleRecorded(this.sale);

  @override
  List<Object?> get props => [sale];
}

/// Error state.
final class SaleError extends SaleState {
  final String message;

  const SaleError(this.message);

  @override
  List<Object?> get props => [message];
}
