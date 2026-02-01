part of 'analytics_bloc.dart';

/// Base class for analytics events.
sealed class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object?> get props => [];
}

/// Load all analytics data.
final class LoadAnalytics extends AnalyticsEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final int topProductsLimit;

  const LoadAnalytics({
    this.startDate,
    this.endDate,
    this.topProductsLimit = 5,
  });

  @override
  List<Object?> get props => [startDate, endDate, topProductsLimit];
}
