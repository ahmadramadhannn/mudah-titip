part of 'analytics_bloc.dart';

/// Base class for analytics states.
sealed class AnalyticsState extends Equatable {
  const AnalyticsState();

  @override
  List<Object?> get props => [];
}

/// Initial state.
final class AnalyticsInitial extends AnalyticsState {}

/// Loading state.
final class AnalyticsLoading extends AnalyticsState {}

/// Analytics loaded.
final class AnalyticsLoaded extends AnalyticsState {
  final List<TrendData> trends;
  final List<TopProduct> topProducts;
  final List<EarningsBreakdown> breakdown;
  final DateTime? startDate;
  final DateTime? endDate;

  const AnalyticsLoaded({
    required this.trends,
    required this.topProducts,
    required this.breakdown,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [
    trends,
    topProducts,
    breakdown,
    startDate,
    endDate,
  ];
}

/// Error state.
final class AnalyticsError extends AnalyticsState {
  final String message;

  const AnalyticsError(this.message);

  @override
  List<Object?> get props => [message];
}
