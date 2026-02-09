part of 'complaint_bloc.dart';

/// Base class for complaint events.
sealed class ComplaintEvent {}

/// Load all complaints for the current user.
class LoadComplaints extends ComplaintEvent {}

/// Load count of open complaints (for badge display).
class LoadOpenComplaintsCount extends ComplaintEvent {}

/// Create a new complaint.
class CreateComplaint extends ComplaintEvent {
  final int consignmentId;
  final ComplaintCategory category;
  final String description;
  final List<String>? mediaUrls;

  CreateComplaint({
    required this.consignmentId,
    required this.category,
    required this.description,
    this.mediaUrls,
  });
}

/// Resolve a complaint (consignor only).
class ResolveComplaint extends ComplaintEvent {
  final int id;
  final String resolution;
  final bool accepted;

  ResolveComplaint({
    required this.id,
    required this.resolution,
    required this.accepted,
  });
}
