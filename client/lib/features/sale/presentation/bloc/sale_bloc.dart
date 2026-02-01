import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/sale.dart';
import '../../data/models/sale_request.dart';
import '../../data/sale_repository.dart';

part 'sale_event.dart';
part 'sale_state.dart';

/// Bloc for managing sale state.
class SaleBloc extends Bloc<SaleEvent, SaleState> {
  final SaleRepository _repository;

  SaleBloc(this._repository) : super(SaleInitial()) {
    on<LoadMySales>(_onLoadMySales);
    on<RecordSale>(_onRecordSale);
    on<LoadSalesSummary>(_onLoadSummary);
  }

  Future<void> _onLoadMySales(
    LoadMySales event,
    Emitter<SaleState> emit,
  ) async {
    emit(SaleLoading());
    try {
      final sales = await _repository.getMySales(
        startDate: event.startDate,
        endDate: event.endDate,
      );
      final summary = await _repository.getSummary(
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(
        SalesLoaded(
          sales: sales,
          summary: summary,
          startDate: event.startDate,
          endDate: event.endDate,
        ),
      );
    } catch (e) {
      emit(SaleError(e.toString()));
    }
  }

  Future<void> _onRecordSale(RecordSale event, Emitter<SaleState> emit) async {
    emit(SaleLoading());
    try {
      final sale = await _repository.recordSale(event.request);
      emit(SaleRecorded(sale));
    } catch (e) {
      emit(SaleError(e.toString()));
    }
  }

  Future<void> _onLoadSummary(
    LoadSalesSummary event,
    Emitter<SaleState> emit,
  ) async {
    emit(SaleLoading());
    try {
      final summary = await _repository.getSummary(
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(SummaryLoaded(summary));
    } catch (e) {
      emit(SaleError(e.toString()));
    }
  }
}
