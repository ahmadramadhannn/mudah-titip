part of 'notification_bloc.dart';

/// Base class for notification events.
sealed class NotificationEvent {}

/// Load all notifications for the current user.
class LoadNotifications extends NotificationEvent {}

/// Get count of unread notifications (lightweight for polling).
class LoadUnreadCount extends NotificationEvent {}

/// Mark a specific notification as read.
class MarkNotificationAsRead extends NotificationEvent {
  final int notificationId;
  MarkNotificationAsRead(this.notificationId);
}

/// Mark all notifications as read.
class MarkAllNotificationsAsRead extends NotificationEvent {}
