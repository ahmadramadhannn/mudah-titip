import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/notification_model.dart';
import '../bloc/notification_bloc.dart';

/// Page displaying list of notifications.
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state.unreadCount > 0) {
                return TextButton.icon(
                  onPressed: () {
                    context.read<NotificationBloc>().add(
                      MarkAllNotificationsAsRead(),
                    );
                  },
                  icon: const Icon(Icons.done_all),
                  label: const Text('Tandai Semua'),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading && state.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationError && state.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text('Gagal memuat notifikasi'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      context.read<NotificationBloc>().add(LoadNotifications());
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (state.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada notifikasi',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<NotificationBloc>().add(LoadNotifications());
              // Wait a bit for the state to update
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView.separated(
              itemCount: state.notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = state.notifications[index];
                return _NotificationTile(notification: notification);
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: notification.isRead
              ? colorScheme.surfaceContainerHighest
              : colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(
          _getIconForType(notification.type),
          color: notification.isRead
              ? colorScheme.outline
              : colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        notification.title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            notification.message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            _formatRelativeTime(notification.createdAt),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.outline,
            ),
          ),
        ],
      ),
      trailing: notification.isRead
          ? null
          : Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
      tileColor: notification.isRead
          ? null
          : colorScheme.primaryContainer.withValues(alpha: 0.1),
      onTap: () {
        if (!notification.isRead) {
          context.read<NotificationBloc>().add(
            MarkNotificationAsRead(notification.id),
          );
        }
        _handleNotificationTap(context, notification);
      },
    );
  }

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.agreementProposed:
        return Icons.description_outlined;
      case NotificationType.agreementAccepted:
        return Icons.check_circle_outline;
      case NotificationType.agreementRejected:
        return Icons.cancel_outlined;
      case NotificationType.agreementCountered:
        return Icons.swap_horiz;
      case NotificationType.saleRecorded:
        return Icons.shopping_cart_outlined;
      case NotificationType.consignmentExpiring:
        return Icons.schedule;
      case NotificationType.consignmentExpired:
        return Icons.warning_amber;
    }
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }

  void _handleNotificationTap(
    BuildContext context,
    NotificationModel notification,
  ) {
    // TODO: Navigate to related screen based on referenceType and referenceId
    // For now, just mark as read
  }
}
