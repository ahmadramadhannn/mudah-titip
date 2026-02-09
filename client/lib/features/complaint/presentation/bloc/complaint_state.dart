part of 'complaint_bloc.dart';

/// Base class for complaint states.
sealed class ComplaintState {
  final List<ComplaintModel> complaints;
  final int openCount;

  const ComplaintState({this.complaints = const [], this.openCount = 0});

  ComplaintState copyWith({List<ComplaintModel>? complaints, int? openCount});
}

/// Initial state before data is loaded.
class ComplaintInitial extends ComplaintState {
  const ComplaintInitial() : super();

  @override
  ComplaintState copyWith({List<ComplaintModel>? complaints, int? openCount}) {
    return ComplaintLoaded(
      complaints: complaints ?? this.complaints,
      openCount: openCount ?? this.openCount,
    );
  }
}

/// Loading state while fetching data.
class ComplaintLoading extends ComplaintState {
  const ComplaintLoading({super.complaints, super.openCount});

  @override
  ComplaintState copyWith({List<ComplaintModel>? complaints, int? openCount}) {
    return ComplaintLoading(
      complaints: complaints ?? this.complaints,
      openCount: openCount ?? this.openCount,
    );
  }
}

/// State when complaints are loaded successfully.
class ComplaintLoaded extends ComplaintState {
  const ComplaintLoaded({super.complaints, super.openCount});

  @override
  ComplaintState copyWith({List<ComplaintModel>? complaints, int? openCount}) {
    return ComplaintLoaded(
      complaints: complaints ?? this.complaints,
      openCount: openCount ?? this.openCount,
    );
  }
}

/// State while submitting a new complaint.
class ComplaintSubmitting extends ComplaintState {
  const ComplaintSubmitting({super.complaints, super.openCount});

  @override
  ComplaintState copyWith({List<ComplaintModel>? complaints, int? openCount}) {
    return ComplaintSubmitting(
      complaints: complaints ?? this.complaints,
      openCount: openCount ?? this.openCount,
    );
  }
}

/// State after a complaint is submitted successfully.
class ComplaintSubmitted extends ComplaintState {
  final ComplaintModel complaint;

  const ComplaintSubmitted({
    required this.complaint,
    super.complaints,
    super.openCount,
  });

  @override
  ComplaintState copyWith({List<ComplaintModel>? complaints, int? openCount}) {
    return ComplaintLoaded(
      complaints: complaints ?? this.complaints,
      openCount: openCount ?? this.openCount,
    );
  }
}

/// Error state.
class ComplaintError extends ComplaintState {
  final String message;

  const ComplaintError({
    required this.message,
    super.complaints,
    super.openCount,
  });

  @override
  ComplaintState copyWith({List<ComplaintModel>? complaints, int? openCount}) {
    return ComplaintLoaded(
      complaints: complaints ?? this.complaints,
      openCount: openCount ?? this.openCount,
    );
  }
}
