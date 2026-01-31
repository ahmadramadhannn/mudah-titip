import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../products/data/repositories/product_repository.dart';
import '../../data/models/consignment.dart';
import '../../data/models/dashboard_summary.dart';
import '../../data/repositories/dashboard_repository.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

/// Bloc for managing dashboard state.
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository _dashboardRepository;
  final ProductRepository _productRepository;

  DashboardBloc(this._dashboardRepository, this._productRepository)
    : super(const DashboardInitial()) {
    on<DashboardLoadRequested>(_onLoadRequested);
    on<DashboardRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onLoadRequested(
    DashboardLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    await _loadDashboardData(emit, isConsignor: event.isConsignor);
  }

  Future<void> _onRefreshRequested(
    DashboardRefreshRequested event,
    Emitter<DashboardState> emit,
  ) async {
    // Keep current state visible during refresh
    await _loadDashboardData(emit, isConsignor: event.isConsignor);
  }

  Future<void> _loadDashboardData(
    Emitter<DashboardState> emit, {
    required bool isConsignor,
  }) async {
    try {
      // Load common data in parallel
      final commonFutures = [
        _dashboardRepository.getSalesSummary(),
        _dashboardRepository.getMyConsignments(
          status: ConsignmentStatus.active,
        ),
        _dashboardRepository.getExpiringConsignments(),
        _dashboardRepository.getLowStockConsignments(),
      ];

      // Only load products for consignors (shop owners don't have products)
      if (isConsignor) {
        commonFutures.add(_productRepository.getMyProducts());
      }

      final results = await Future.wait(commonFutures);

      final summary = results[0] as DashboardSummary;
      final activeConsignments = results[1] as List<Consignment>;
      final expiringConsignments = results[2] as List<Consignment>;
      final lowStockConsignments = results[3] as List<Consignment>;
      final products = isConsignor ? results[4] as List : [];

      emit(
        DashboardLoaded(
          summary: summary,
          activeConsignments: activeConsignments,
          expiringConsignments: expiringConsignments,
          lowStockConsignments: lowStockConsignments,
          totalProducts: products.length,
        ),
      );
    } on Failure catch (e) {
      emit(DashboardError(e.message));
    } catch (e) {
      emit(DashboardError('Gagal memuat data dashboard: $e'));
    }
  }
}
