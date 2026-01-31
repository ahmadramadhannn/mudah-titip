import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../data/models/agreement.dart';
import '../../data/models/agreement_request.dart';
import '../../data/models/settlement_result.dart';
import '../../data/repositories/agreement_repository.dart';

part 'agreement_event.dart';
part 'agreement_state.dart';

/// Bloc for managing agreement negotiations.
class AgreementBloc extends Bloc<AgreementEvent, AgreementState> {
  final AgreementRepository _repository;

  AgreementBloc(this._repository) : super(const AgreementInitial()) {
    on<LoadPendingAgreements>(_onLoadPending);
    on<ProposeAgreement>(_onPropose);
    on<CounterAgreement>(_onCounter);
    on<AcceptAgreement>(_onAccept);
    on<RejectAgreement>(_onReject);
    on<LoadSettlement>(_onLoadSettlement);
  }

  Future<void> _onLoadPending(
    LoadPendingAgreements event,
    Emitter<AgreementState> emit,
  ) async {
    emit(const AgreementLoading());
    try {
      final agreements = await _repository.getPendingAgreements();
      emit(AgreementsLoaded(agreements));
    } on Failure catch (e) {
      emit(AgreementError(e.message));
    } catch (e) {
      emit(AgreementError('Gagal memuat perjanjian: $e'));
    }
  }

  Future<void> _onPropose(
    ProposeAgreement event,
    Emitter<AgreementState> emit,
  ) async {
    emit(const AgreementActionInProgress());
    try {
      final agreement = await _repository.propose(event.request);
      emit(
        AgreementActionSuccess(
          agreement: agreement,
          message: 'Perjanjian berhasil diajukan',
        ),
      );
    } on Failure catch (e) {
      emit(AgreementError(e.message));
    } catch (e) {
      emit(AgreementError('Gagal mengajukan perjanjian: $e'));
    }
  }

  Future<void> _onCounter(
    CounterAgreement event,
    Emitter<AgreementState> emit,
  ) async {
    emit(const AgreementActionInProgress());
    try {
      final agreement = await _repository.counter(
        event.agreementId,
        event.request,
      );
      emit(
        AgreementActionSuccess(
          agreement: agreement,
          message: 'Penawaran balik berhasil dikirim',
        ),
      );
    } on Failure catch (e) {
      emit(AgreementError(e.message));
    } catch (e) {
      emit(AgreementError('Gagal mengirim penawaran balik: $e'));
    }
  }

  Future<void> _onAccept(
    AcceptAgreement event,
    Emitter<AgreementState> emit,
  ) async {
    emit(const AgreementActionInProgress());
    try {
      final agreement = await _repository.accept(
        event.agreementId,
        message: event.message,
      );
      emit(
        AgreementActionSuccess(
          agreement: agreement,
          message: 'Perjanjian berhasil disetujui',
        ),
      );
    } on Failure catch (e) {
      emit(AgreementError(e.message));
    } catch (e) {
      emit(AgreementError('Gagal menyetujui perjanjian: $e'));
    }
  }

  Future<void> _onReject(
    RejectAgreement event,
    Emitter<AgreementState> emit,
  ) async {
    emit(const AgreementActionInProgress());
    try {
      final agreement = await _repository.reject(
        event.agreementId,
        reason: event.reason,
      );
      emit(
        AgreementActionSuccess(
          agreement: agreement,
          message: 'Perjanjian ditolak',
        ),
      );
    } on Failure catch (e) {
      emit(AgreementError(e.message));
    } catch (e) {
      emit(AgreementError('Gagal menolak perjanjian: $e'));
    }
  }

  Future<void> _onLoadSettlement(
    LoadSettlement event,
    Emitter<AgreementState> emit,
  ) async {
    emit(const AgreementLoading());
    try {
      final settlement = await _repository.getSettlement(event.consignmentId);
      emit(SettlementLoaded(settlement));
    } on Failure catch (e) {
      emit(AgreementError(e.message));
    } catch (e) {
      emit(AgreementError('Gagal memuat perhitungan: $e'));
    }
  }
}
