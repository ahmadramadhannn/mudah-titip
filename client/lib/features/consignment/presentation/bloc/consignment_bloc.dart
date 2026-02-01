import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/consignment_repository.dart';
import '../../data/models/consignment.dart';
import '../../data/models/consignment_request.dart';

part 'consignment_event.dart';
part 'consignment_state.dart';

/// Bloc for managing consignment state.
class ConsignmentBloc extends Bloc<ConsignmentEvent, ConsignmentState> {
  final ConsignmentRepository _repository;

  ConsignmentBloc(this._repository) : super(ConsignmentInitial()) {
    on<LoadConsignments>(_onLoadConsignments);
    on<LoadConsignmentDetail>(_onLoadDetail);
    on<CreateConsignment>(_onCreateConsignment);
    on<UpdateConsignmentStatus>(_onUpdateStatus);
    on<LoadExpiringSoon>(_onLoadExpiring);
  }

  Future<void> _onLoadConsignments(
    LoadConsignments event,
    Emitter<ConsignmentState> emit,
  ) async {
    emit(ConsignmentLoading());
    try {
      final consignments = await _repository.getMyConsignments(
        status: event.status,
      );
      emit(
        ConsignmentsLoaded(
          consignments: consignments,
          filterStatus: event.status,
        ),
      );
    } catch (e) {
      emit(ConsignmentError(e.toString()));
    }
  }

  Future<void> _onLoadDetail(
    LoadConsignmentDetail event,
    Emitter<ConsignmentState> emit,
  ) async {
    emit(ConsignmentLoading());
    try {
      final consignment = await _repository.getConsignment(event.consignmentId);
      emit(ConsignmentDetailLoaded(consignment));
    } catch (e) {
      emit(ConsignmentError(e.toString()));
    }
  }

  Future<void> _onCreateConsignment(
    CreateConsignment event,
    Emitter<ConsignmentState> emit,
  ) async {
    emit(ConsignmentLoading());
    try {
      final consignment = await _repository.createConsignment(event.request);
      emit(ConsignmentCreated(consignment));
    } catch (e) {
      emit(ConsignmentError(e.toString()));
    }
  }

  Future<void> _onUpdateStatus(
    UpdateConsignmentStatus event,
    Emitter<ConsignmentState> emit,
  ) async {
    emit(ConsignmentLoading());
    try {
      final consignment = await _repository.updateStatus(
        event.consignmentId,
        event.status,
      );
      emit(ConsignmentStatusUpdated(consignment));
    } catch (e) {
      emit(ConsignmentError(e.toString()));
    }
  }

  Future<void> _onLoadExpiring(
    LoadExpiringSoon event,
    Emitter<ConsignmentState> emit,
  ) async {
    emit(ConsignmentLoading());
    try {
      final consignments = await _repository.getExpiringSoon(days: event.days);
      emit(
        ExpiringConsignmentsLoaded(
          consignments: consignments,
          days: event.days,
        ),
      );
    } catch (e) {
      emit(ConsignmentError(e.toString()));
    }
  }
}
