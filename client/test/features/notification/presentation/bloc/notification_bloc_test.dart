import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:client/features/notification/data/models/notification_model.dart';
import 'package:client/features/notification/data/repositories/notification_repository.dart';
import 'package:client/features/notification/presentation/bloc/notification_bloc.dart';

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

void main() {
  late MockNotificationRepository mockRepository;
  late NotificationBloc bloc;

  final testNotifications = [
    NotificationModel(
      id: 1,
      type: NotificationType.stockLow,
      title: 'Stok Menipis',
      message: 'Stok produk tinggal 3 unit',
      referenceId: 100,
      referenceType: 'CONSIGNMENT',
      isRead: false,
      createdAt: DateTime.now(),
    ),
    NotificationModel(
      id: 2,
      type: NotificationType.saleRecorded,
      title: 'Penjualan Tercatat',
      message: '5 produk terjual',
      referenceId: 101,
      referenceType: 'SALE',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  setUp(() {
    mockRepository = MockNotificationRepository();
    bloc = NotificationBloc(mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  group('NotificationBloc', () {
    test('initial state is NotificationInitial', () {
      expect(bloc.state, isA<NotificationInitial>());
      expect(bloc.state.notifications, isEmpty);
      expect(bloc.state.unreadCount, 0);
    });

    group('LoadNotifications', () {
      blocTest<NotificationBloc, NotificationState>(
        'emits [NotificationLoading, NotificationLoaded] on success',
        build: () {
          when(
            () => mockRepository.getNotifications(),
          ).thenAnswer((_) async => testNotifications);
          return bloc;
        },
        act: (bloc) => bloc.add(LoadNotifications()),
        expect: () => [
          isA<NotificationLoading>(),
          isA<NotificationLoaded>()
              .having((s) => s.notifications.length, 'notifications.length', 2)
              .having((s) => s.unreadCount, 'unreadCount', 1),
        ],
        verify: (_) {
          verify(() => mockRepository.getNotifications()).called(1);
        },
      );

      blocTest<NotificationBloc, NotificationState>(
        'emits [NotificationLoading, NotificationError] on failure',
        build: () {
          when(
            () => mockRepository.getNotifications(),
          ).thenThrow(Exception('Network error'));
          return bloc;
        },
        act: (bloc) => bloc.add(LoadNotifications()),
        expect: () => [
          isA<NotificationLoading>(),
          isA<NotificationError>().having(
            (s) => s.message,
            'message',
            contains('Exception'),
          ),
        ],
      );
    });

    group('LoadUnreadCount', () {
      blocTest<NotificationBloc, NotificationState>(
        'updates unread count on success',
        build: () {
          when(
            () => mockRepository.getUnreadCount(),
          ).thenAnswer((_) async => 5);
          return bloc;
        },
        act: (bloc) => bloc.add(LoadUnreadCount()),
        expect: () => [
          isA<NotificationState>().having(
            (s) => s.unreadCount,
            'unreadCount',
            5,
          ),
        ],
        verify: (_) {
          verify(() => mockRepository.getUnreadCount()).called(1);
        },
      );

      blocTest<NotificationBloc, NotificationState>(
        'silently fails on error (no error state emitted)',
        build: () {
          when(
            () => mockRepository.getUnreadCount(),
          ).thenThrow(Exception('Network error'));
          return bloc;
        },
        act: (bloc) => bloc.add(LoadUnreadCount()),
        expect: () => <NotificationState>[], // No state changes on failure
      );
    });

    group('MarkNotificationAsRead', () {
      blocTest<NotificationBloc, NotificationState>(
        'marks notification as read and updates local state',
        build: () {
          when(() => mockRepository.markAsRead(1)).thenAnswer((_) async {});
          return bloc;
        },
        seed: () => NotificationLoaded(
          notifications: testNotifications,
          unreadCount: 1,
        ),
        act: (bloc) => bloc.add(MarkNotificationAsRead(1)),
        expect: () => [
          isA<NotificationLoaded>()
              .having((s) => s.notifications.first.isRead, 'first.isRead', true)
              .having((s) => s.unreadCount, 'unreadCount', 0),
        ],
        verify: (_) {
          verify(() => mockRepository.markAsRead(1)).called(1);
        },
      );

      blocTest<NotificationBloc, NotificationState>(
        'emits NotificationError on failure',
        build: () {
          when(
            () => mockRepository.markAsRead(1),
          ).thenThrow(Exception('Failed'));
          return bloc;
        },
        seed: () => NotificationLoaded(
          notifications: testNotifications,
          unreadCount: 1,
        ),
        act: (bloc) => bloc.add(MarkNotificationAsRead(1)),
        expect: () => [
          isA<NotificationError>().having(
            (s) => s.message,
            'message',
            contains('Exception'),
          ),
        ],
      );
    });

    group('MarkAllNotificationsAsRead', () {
      blocTest<NotificationBloc, NotificationState>(
        'marks all notifications as read',
        build: () {
          when(() => mockRepository.markAllAsRead()).thenAnswer((_) async => 1);
          return bloc;
        },
        seed: () => NotificationLoaded(
          notifications: testNotifications,
          unreadCount: 1,
        ),
        act: (bloc) => bloc.add(MarkAllNotificationsAsRead()),
        expect: () => [
          isA<NotificationLoaded>()
              .having(
                (s) => s.notifications.every((n) => n.isRead),
                'all read',
                true,
              )
              .having((s) => s.unreadCount, 'unreadCount', 0),
        ],
        verify: (_) {
          verify(() => mockRepository.markAllAsRead()).called(1);
        },
      );

      blocTest<NotificationBloc, NotificationState>(
        'emits NotificationError on failure',
        build: () {
          when(
            () => mockRepository.markAllAsRead(),
          ).thenThrow(Exception('Failed'));
          return bloc;
        },
        seed: () => NotificationLoaded(
          notifications: testNotifications,
          unreadCount: 1,
        ),
        act: (bloc) => bloc.add(MarkAllNotificationsAsRead()),
        expect: () => [
          isA<NotificationError>().having(
            (s) => s.message,
            'message',
            contains('Exception'),
          ),
        ],
      );
    });
  });
}
