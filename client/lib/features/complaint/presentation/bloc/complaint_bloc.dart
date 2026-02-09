import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/complaint_model.dart';
import '../../data/repositories/complaint_repository.dart';

part 'complaint_event.dart';
part 'complaint_state.dart';

/// BLoC for managing complaint state.
class ComplaintBloc extends Bloc<ComplaintEvent, ComplaintState> {
  final ComplaintRepository _repository;

  ComplaintBloc(this._repository) : super(const ComplaintInitial()) {
    on<LoadComplaints>(_onLoadComplaints);
    on<CreateComplaint>(_onCreateComplaint);
    on<ResolveComplaint>(_onResolveComplaint);
    on<LoadOpenComplaintsCount>(_onLoadOpenComplaintsCount);
  }

  Future<void> _onLoadComplaints(
    LoadComplaints event,
    Emitter<ComplaintState> emit,
  ) async {
    emit(
      ComplaintLoading(
        complaints: state.complaints,
        openCount: state.openCount,
      ),
    );

    try {
      final complaints = await _repository.getComplaints();
      final openCount = complaints
          .where((c) => c.status == ComplaintStatus.open)
          .length;
      emit(ComplaintLoaded(complaints: complaints, openCount: openCount));
    } catch (e) {
      emit(
        ComplaintError(
          message: e.toString(),
          complaints: state.complaints,
          openCount: state.openCount,
        ),
      );
    }
  }

  Future<void> _onCreateComplaint(
    CreateComplaint event,
    Emitter<ComplaintState> emit,
  ) async {
    emit(
      ComplaintSubmitting(
        complaints: state.complaints,
        openCount: state.openCount,
      ),
    );

    try {
      final complaint = await _repository.createComplaint(
        consignmentId: event.consignmentId,
        category: event.category,
        description: event.description,
        mediaUrls: event.mediaUrls,
      );
      emit(
        ComplaintSubmitted(
          complaint: complaint,
          complaints: [complaint, ...state.complaints],
          openCount: state.openCount + 1,
        ),
      );
    } catch (e) {
      emit(
        ComplaintError(
          message: e.toString(),
          complaints: state.complaints,
          openCount: state.openCount,
        ),
      );
    }
  }

  Future<void> _onResolveComplaint(
    ResolveComplaint event,
    Emitter<ComplaintState> emit,
  ) async {
    try {
      final resolved = await _repository.resolveComplaint(
        id: event.id,
        resolution: event.resolution,
        accepted: event.accepted,
      );

      // Update local state
      final updated = state.complaints.map((c) {
        return c.id == resolved.id ? resolved : c;
      }).toList();

      final openCount = updated
          .where((c) => c.status == ComplaintStatus.open)
          .length;

      emit(ComplaintLoaded(complaints: updated, openCount: openCount));
    } catch (e) {
      emit(
        ComplaintError(
          message: e.toString(),
          complaints: state.complaints,
          openCount: state.openCount,
        ),
      );
    }
  }

  Future<void> _onLoadOpenComplaintsCount(
    LoadOpenComplaintsCount event,
    Emitter<ComplaintState> emit,
  ) async {
    try {
      final count = await _repository.getOpenComplaintsCount();
      emit(state.copyWith(openCount: count));
    } catch (_) {
      // Silently fail
    }
  }
}
