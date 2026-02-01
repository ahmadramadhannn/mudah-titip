import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/analytics_repository.dart';
import '../../data/models/analytics_models.dart';

part 'analytics_event.dart';
part 'analytics_state.dart';

/// Bloc for managing analytics state.
class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final AnalyticsRepository _repository;

  AnalyticsBloc(this._repository) : super(AnalyticsInitial()) {
    on<LoadAnalytics>(_onLoadAnalytics);
  }

  Future<void> _onLoadAnalytics(
    LoadAnalytics event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading());
    try {
      // Fetch all analytics data in parallel
      final results = await Future.wait([
        _repository.getTrends(
          startDate: event.startDate,
          endDate: event.endDate,
        ),
        _repository.getTopProducts(
          limit: event.topProductsLimit,
          startDate: event.startDate,
          endDate: event.endDate,
        ),
        _repository.getBreakdown(
          startDate: event.startDate,
          endDate: event.endDate,
        ),
      ]);

      emit(
        AnalyticsLoaded(
          trends: results[0] as List<TrendData>,
          topProducts: results[1] as List<TopProduct>,
          breakdown: results[2] as List<EarningsBreakdown>,
          startDate: event.startDate,
          endDate: event.endDate,
        ),
      );
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }
}
