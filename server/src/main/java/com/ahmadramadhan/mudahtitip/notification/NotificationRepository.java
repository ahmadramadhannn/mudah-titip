package com.ahmadramadhan.mudahtitip.notification;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * Repository for Notification entity.
 */
@Repository
public interface NotificationRepository extends JpaRepository<Notification, Long> {

    /**
     * Find all notifications for a user, ordered by creation date (newest first).
     */
    List<Notification> findByRecipientIdOrderByCreatedAtDesc(Long recipientId);

    /**
     * Find unread notifications for a user.
     */
    List<Notification> findByRecipientIdAndReadFalseOrderByCreatedAtDesc(Long recipientId);

    /**
     * Count unread notifications for a user.
     */
    long countByRecipientIdAndReadFalse(Long recipientId);

    /**
     * Mark all notifications as read for a user.
     */
    @Modifying
    @Query("UPDATE Notification n SET n.read = true, n.readAt = CURRENT_TIMESTAMP WHERE n.recipient.id = :recipientId AND n.read = false")
    int markAllAsReadByRecipientId(@Param("recipientId") Long recipientId);

    /**
     * Delete all notifications (dev only).
     */
    @Modifying
    @Transactional
    @Query("DELETE FROM Notification n")
    void deleteAllNotifications();
}
