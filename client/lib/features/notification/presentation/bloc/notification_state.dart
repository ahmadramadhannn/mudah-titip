part of 'notification_bloc.dart';

/// Base class for notification states.
sealed class NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;

  const NotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
  });

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    int? unreadCount,
  });
}

/// Initial state before any data is loaded.
class NotificationInitial extends NotificationState {
  const NotificationInitial() : super();

  @override
  NotificationState copyWith({
    List<NotificationModel>? notifications,
    int? unreadCount,
  }) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

/// Loading state while fetching data.
class NotificationLoading extends NotificationState {
  const NotificationLoading({super.notifications, super.unreadCount});

  @override
  NotificationState copyWith({
    List<NotificationModel>? notifications,
    int? unreadCount,
  }) {
    return NotificationLoading(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

/// State when notifications are loaded successfully.
class NotificationLoaded extends NotificationState {
  const NotificationLoaded({super.notifications, super.unreadCount});

  @override
  NotificationState copyWith({
    List<NotificationModel>? notifications,
    int? unreadCount,
  }) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

/// State when an error occurred.
class NotificationError extends NotificationState {
  final String message;

  const NotificationError({
    required this.message,
    super.notifications,
    super.unreadCount,
  });

  @override
  NotificationState copyWith({
    List<NotificationModel>? notifications,
    int? unreadCount,
  }) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
