import 'package:dio/dio.dart';

import '../models/notification_model.dart';
import '../models/notification_preferences_model.dart';

/// Repository for notification API operations.
class NotificationRepository {
  final Dio _dio;

  NotificationRepository(this._dio);

  /// Get all notifications for the current user.
  Future<List<NotificationModel>> getNotifications() async {
    final response = await _dio.get<List<dynamic>>('/notifications');
    return (response.data ?? [])
        .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get count of unread notifications.
  Future<int> getUnreadCount() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/notifications/unread-count',
    );
    return (response.data?['count'] as int?) ?? 0;
  }

  /// Mark a notification as read.
  Future<void> markAsRead(int notificationId) async {
    await _dio.put('/notifications/$notificationId/read');
  }

  /// Mark all notifications as read.
  Future<int> markAllAsRead() async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/notifications/read-all',
    );
    return (response.data?['markedCount'] as int?) ?? 0;
  }

  // ===== Preferences API =====

  /// Get notification preferences for the current user.
  Future<NotificationPreferencesModel> getPreferences() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/notifications/preferences',
    );
    return NotificationPreferencesModel.fromJson(response.data ?? {});
  }

  /// Update notification preferences.
  Future<NotificationPreferencesModel> updatePreferences(
    NotificationPreferencesModel preferences,
  ) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/notifications/preferences',
      data: preferences.toJson(),
    );
    return NotificationPreferencesModel.fromJson(response.data ?? {});
  }
}
