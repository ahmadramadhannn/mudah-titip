import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';

part 'notification_event.dart';
part 'notification_state.dart';

/// Bloc for managing notification state and operations.
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _repository;

  NotificationBloc(this._repository) : super(const NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<LoadUnreadCount>(_onLoadUnreadCount);
    on<MarkNotificationAsRead>(_onMarkAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllAsRead);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(
      NotificationLoading(
        notifications: state.notifications,
        unreadCount: state.unreadCount,
      ),
    );

    try {
      final notifications = await _repository.getNotifications();
      final unreadCount = notifications.where((n) => !n.isRead).length;
      emit(
        NotificationLoaded(
          notifications: notifications,
          unreadCount: unreadCount,
        ),
      );
    } catch (e) {
      emit(
        NotificationError(
          message: e.toString(),
          notifications: state.notifications,
          unreadCount: state.unreadCount,
        ),
      );
    }
  }

  Future<void> _onLoadUnreadCount(
    LoadUnreadCount event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final count = await _repository.getUnreadCount();
      emit(state.copyWith(unreadCount: count));
    } catch (e) {
      // Silently fail for polling - don't disrupt user experience
    }
  }

  Future<void> _onMarkAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _repository.markAsRead(event.notificationId);

      // Update local state
      final updated = state.notifications.map((n) {
        if (n.id == event.notificationId) {
          return n.copyWith(isRead: true, readAt: DateTime.now());
        }
        return n;
      }).toList();

      emit(
        state.copyWith(
          notifications: updated,
          unreadCount: updated.where((n) => !n.isRead).length,
        ),
      );
    } catch (e) {
      emit(
        NotificationError(
          message: e.toString(),
          notifications: state.notifications,
          unreadCount: state.unreadCount,
        ),
      );
    }
  }

  Future<void> _onMarkAllAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _repository.markAllAsRead();

      // Update local state
      final updated = state.notifications
          .map((n) => n.copyWith(isRead: true, readAt: DateTime.now()))
          .toList();

      emit(state.copyWith(notifications: updated, unreadCount: 0));
    } catch (e) {
      emit(
        NotificationError(
          message: e.toString(),
          notifications: state.notifications,
          unreadCount: state.unreadCount,
        ),
      );
    }
  }
}
