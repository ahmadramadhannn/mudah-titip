package com.ahmadramadhan.mudahtitip.notification;

import com.ahmadramadhan.mudahtitip.auth.User;
import com.ahmadramadhan.mudahtitip.auth.UserRole;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * Unit tests for NotificationService.
 * Tests notification creation, retrieval, and marking as read functionality.
 */
@ExtendWith(MockitoExtension.class)
class NotificationServiceTest {

    @Mock
    private NotificationRepository notificationRepository;

    @InjectMocks
    private NotificationService notificationService;

    private User testUser;

    @BeforeEach
    void setUp() {
        testUser = User.builder()
                .name("Test User")
                .email("test@example.com")
                .role(UserRole.CONSIGNOR)
                .build();
        testUser.setId(1L);
    }

    @Nested
    @DisplayName("createNotification")
    class CreateNotificationTests {

        @Test
        @DisplayName("should create notification with correct fields")
        void createNotification_success() {
            // given
            NotificationType type = NotificationType.STOCK_LOW;
            String title = "Stok Menipis";
            String message = "Stok produk tinggal 3 unit";
            Long referenceId = 100L;
            String referenceType = "CONSIGNMENT";

            when(notificationRepository.save(any(Notification.class))).thenAnswer(inv -> {
                Notification n = inv.getArgument(0);
                n.setId(1L);
                return n;
            });

            // when
            Notification result = notificationService.createNotification(
                    testUser, type, title, message, referenceId, referenceType);

            // then
            assertThat(result).isNotNull();
            assertThat(result.getRecipient()).isEqualTo(testUser);
            assertThat(result.getType()).isEqualTo(type);
            assertThat(result.getTitle()).isEqualTo(title);
            assertThat(result.getMessage()).isEqualTo(message);
            assertThat(result.getReferenceId()).isEqualTo(referenceId);
            assertThat(result.getReferenceType()).isEqualTo(referenceType);
            assertThat(result.getRead()).isFalse();
            verify(notificationRepository).save(any(Notification.class));
        }
    }

    @Nested
    @DisplayName("getNotifications")
    class GetNotificationsTests {

        @Test
        @DisplayName("should return notifications for user ordered by date")
        void getNotifications_returnsOrderedList() {
            // given
            Notification notification1 = createTestNotification(1L, "First");
            Notification notification2 = createTestNotification(2L, "Second");
            List<Notification> notifications = Arrays.asList(notification2, notification1);

            when(notificationRepository.findByRecipientIdOrderByCreatedAtDesc(1L))
                    .thenReturn(notifications);

            // when
            List<Notification> result = notificationService.getNotifications(1L);

            // then
            assertThat(result).hasSize(2);
            verify(notificationRepository).findByRecipientIdOrderByCreatedAtDesc(1L);
        }

        @Test
        @DisplayName("should return empty list when no notifications")
        void getNotifications_emptyList() {
            // given
            when(notificationRepository.findByRecipientIdOrderByCreatedAtDesc(1L))
                    .thenReturn(List.of());

            // when
            List<Notification> result = notificationService.getNotifications(1L);

            // then
            assertThat(result).isEmpty();
        }
    }

    @Nested
    @DisplayName("getUnreadCount")
    class GetUnreadCountTests {

        @Test
        @DisplayName("should return count of unread notifications")
        void getUnreadCount_returnsCount() {
            // given
            when(notificationRepository.countByRecipientIdAndReadFalse(1L)).thenReturn(5L);

            // when
            long count = notificationService.getUnreadCount(1L);

            // then
            assertThat(count).isEqualTo(5L);
            verify(notificationRepository).countByRecipientIdAndReadFalse(1L);
        }

        @Test
        @DisplayName("should return zero when no unread notifications")
        void getUnreadCount_returnsZero() {
            // given
            when(notificationRepository.countByRecipientIdAndReadFalse(1L)).thenReturn(0L);

            // when
            long count = notificationService.getUnreadCount(1L);

            // then
            assertThat(count).isZero();
        }
    }

    @Nested
    @DisplayName("markAsRead")
    class MarkAsReadTests {

        @Test
        @DisplayName("should mark notification as read")
        void markAsRead_success() {
            // given
            Notification notification = createTestNotification(1L, "Test");
            notification.setRead(false);

            when(notificationRepository.findById(1L)).thenReturn(Optional.of(notification));
            when(notificationRepository.save(any(Notification.class))).thenAnswer(inv -> inv.getArgument(0));

            // when
            notificationService.markAsRead(1L, 1L);

            // then
            assertThat(notification.getRead()).isTrue();
            assertThat(notification.getReadAt()).isNotNull();
            verify(notificationRepository).save(notification);
        }

        @Test
        @DisplayName("should not save if already read")
        void markAsRead_alreadyRead_noSave() {
            // given
            Notification notification = createTestNotification(1L, "Test");
            notification.setRead(true);
            notification.setReadAt(LocalDateTime.now().minusDays(1));

            when(notificationRepository.findById(1L)).thenReturn(Optional.of(notification));

            // when
            notificationService.markAsRead(1L, 1L);

            // then
            verify(notificationRepository, never()).save(any(Notification.class));
        }

        @Test
        @DisplayName("should throw when notification not found")
        void markAsRead_notFound_throws() {
            // given
            when(notificationRepository.findById(999L)).thenReturn(Optional.empty());

            // when/then
            assertThatThrownBy(() -> notificationService.markAsRead(999L, 1L))
                    .isInstanceOf(IllegalArgumentException.class)
                    .hasMessageContaining("tidak ditemukan");
        }

        @Test
        @DisplayName("should throw when user not authorized")
        void markAsRead_unauthorized_throws() {
            // given
            Notification notification = createTestNotification(1L, "Test");
            when(notificationRepository.findById(1L)).thenReturn(Optional.of(notification));

            // when/then - different user ID
            assertThatThrownBy(() -> notificationService.markAsRead(1L, 999L))
                    .isInstanceOf(IllegalArgumentException.class)
                    .hasMessageContaining("tidak memiliki akses");
        }
    }

    @Nested
    @DisplayName("markAllAsRead")
    class MarkAllAsReadTests {

        @Test
        @DisplayName("should return count of marked notifications")
        void markAllAsRead_returnsCount() {
            // given
            when(notificationRepository.markAllAsReadByRecipientId(1L)).thenReturn(3);

            // when
            int count = notificationService.markAllAsRead(1L);

            // then
            assertThat(count).isEqualTo(3);
            verify(notificationRepository).markAllAsReadByRecipientId(1L);
        }

        @Test
        @DisplayName("should return zero when no notifications to mark")
        void markAllAsRead_returnsZero() {
            // given
            when(notificationRepository.markAllAsReadByRecipientId(1L)).thenReturn(0);

            // when
            int count = notificationService.markAllAsRead(1L);

            // then
            assertThat(count).isZero();
        }
    }

    // Helper method to create test notification
    private Notification createTestNotification(Long id, String title) {
        Notification notification = Notification.builder()
                .recipient(testUser)
                .type(NotificationType.STOCK_LOW)
                .title(title)
                .message("Test message")
                .referenceId(100L)
                .referenceType("CONSIGNMENT")
                .read(false)
                .build();
        notification.setId(id);
        return notification;
    }
}
