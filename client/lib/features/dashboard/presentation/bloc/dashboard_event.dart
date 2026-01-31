part of 'dashboard_bloc.dart';

/// Base class for all dashboard events.
sealed class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load dashboard data.
class DashboardLoadRequested extends DashboardEvent {
  final bool isConsignor;

  const DashboardLoadRequested({required this.isConsignor});

  @override
  List<Object?> get props => [isConsignor];
}

/// Event to refresh dashboard data.
class DashboardRefreshRequested extends DashboardEvent {
  final bool isConsignor;

  const DashboardRefreshRequested({required this.isConsignor});

  @override
  List<Object?> get props => [isConsignor];
}
