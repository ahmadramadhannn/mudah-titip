import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../data/models/guest_consignor.dart';
import '../../data/models/guest_consignor_request.dart';
import '../../data/repositories/guest_consignor_repository.dart';

part 'guest_consignor_event.dart';
part 'guest_consignor_state.dart';

/// Bloc for managing guest consignor operations.
class GuestConsignorBloc
    extends Bloc<GuestConsignorEvent, GuestConsignorState> {
  final GuestConsignorRepository _repository;

  GuestConsignorBloc(this._repository) : super(const GuestConsignorInitial()) {
    on<GuestConsignorLoadRequested>(_onLoadRequested);
    on<GuestConsignorCreateRequested>(_onCreateRequested);
    on<GuestConsignorUpdateRequested>(_onUpdateRequested);
    on<GuestConsignorDeleteRequested>(_onDeleteRequested);
    on<GuestConsignorSearchRequested>(_onSearchRequested);
  }

  Future<void> _onLoadRequested(
    GuestConsignorLoadRequested event,
    Emitter<GuestConsignorState> emit,
  ) async {
    emit(const GuestConsignorLoading());
    try {
      final guestConsignors = await _repository.getAll();
      emit(GuestConsignorLoaded(guestConsignors: guestConsignors));
    } on Failure catch (e) {
      emit(GuestConsignorError(e.message));
    } catch (e) {
      emit(GuestConsignorError('Gagal memuat data penitip: $e'));
    }
  }

  Future<void> _onCreateRequested(
    GuestConsignorCreateRequested event,
    Emitter<GuestConsignorState> emit,
  ) async {
    emit(const GuestConsignorLoading());
    try {
      final created = await _repository.create(event.request);
      emit(
        GuestConsignorOperationSuccess(
          message: 'Penitip berhasil ditambahkan',
          guestConsignor: created,
        ),
      );
    } on Failure catch (e) {
      emit(GuestConsignorError(e.message));
    } catch (e) {
      emit(GuestConsignorError('Gagal menambahkan penitip: $e'));
    }
  }

  Future<void> _onUpdateRequested(
    GuestConsignorUpdateRequested event,
    Emitter<GuestConsignorState> emit,
  ) async {
    emit(const GuestConsignorLoading());
    try {
      final updated = await _repository.update(event.id, event.request);
      emit(
        GuestConsignorOperationSuccess(
          message: 'Data penitip berhasil diperbarui',
          guestConsignor: updated,
        ),
      );
    } on Failure catch (e) {
      emit(GuestConsignorError(e.message));
    } catch (e) {
      emit(GuestConsignorError('Gagal memperbarui data penitip: $e'));
    }
  }

  Future<void> _onDeleteRequested(
    GuestConsignorDeleteRequested event,
    Emitter<GuestConsignorState> emit,
  ) async {
    emit(const GuestConsignorLoading());
    try {
      await _repository.delete(event.id);
      emit(
        const GuestConsignorOperationSuccess(
          message: 'Penitip berhasil dihapus',
        ),
      );
    } on Failure catch (e) {
      emit(GuestConsignorError(e.message));
    } catch (e) {
      emit(GuestConsignorError('Gagal menghapus penitip: $e'));
    }
  }

  Future<void> _onSearchRequested(
    GuestConsignorSearchRequested event,
    Emitter<GuestConsignorState> emit,
  ) async {
    emit(const GuestConsignorLoading());
    try {
      final results = await _repository.search(
        phone: event.phone,
        name: event.name,
      );
      emit(GuestConsignorLoaded(guestConsignors: results));
    } on Failure catch (e) {
      emit(GuestConsignorError(e.message));
    } catch (e) {
      emit(GuestConsignorError('Gagal mencari penitip: $e'));
    }
  }
}
