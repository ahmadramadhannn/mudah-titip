part of 'dashboard_bloc.dart';

/// Base class for all dashboard states.
sealed class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

/// Initial state before data is loaded.
class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

/// State while dashboard data is loading.
class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

/// State when dashboard data is successfully loaded.
class DashboardLoaded extends DashboardState {
  final DashboardSummary summary;
  final List<Consignment> activeConsignments;
  final List<Consignment> expiringConsignments;
  final List<Consignment> lowStockConsignments;
  final int totalProducts;

  const DashboardLoaded({
    required this.summary,
    required this.activeConsignments,
    required this.expiringConsignments,
    required this.lowStockConsignments,
    required this.totalProducts,
  });

  @override
  List<Object?> get props => [
    summary,
    activeConsignments,
    expiringConsignments,
    lowStockConsignments,
    totalProducts,
  ];
}

/// State when dashboard data loading fails.
class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
