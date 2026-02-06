package com.ahmadramadhan.mudahtitip.notification;

import com.ahmadramadhan.mudahtitip.agreement.Agreement;
import com.ahmadramadhan.mudahtitip.auth.User;
import com.ahmadramadhan.mudahtitip.consignment.Consignment;
import com.ahmadramadhan.mudahtitip.sale.Sale;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Service for managing notifications.
 * Provides methods for creating, retrieving, and marking notifications as read.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class NotificationService {

    private final NotificationRepository notificationRepository;

    /**
     * Create a notification for a user.
     */
    public Notification createNotification(User recipient, NotificationType type,
            String title, String message, Long referenceId, String referenceType) {
        Notification notification = Notification.builder()
                .recipient(recipient)
                .type(type)
                .title(title)
                .message(message)
                .referenceId(referenceId)
                .referenceType(referenceType)
                .read(false)
                .build();
        notification = notificationRepository.save(notification);
        log.info("Created notification for user {}: {}", recipient.getEmail(), title);
        return notification;
    }

    /**
     * Notify when a new agreement is proposed.
     * Notifies the party who needs to respond (opposite of proposer).
     */
    public void notifyAgreementProposed(Agreement agreement) {
        Consignment consignment = agreement.getConsignment();
        User proposer = agreement.getProposedBy();
        User recipient;

        // Determine who should receive notification (the other party)
        if (proposer.getId().equals(consignment.getShop().getOwner().getId())) {
            // Shop owner proposed, notify consignor
            recipient = consignment.getProduct().getOwner();
        } else {
            // Consignor proposed, notify shop owner
            recipient = consignment.getShop().getOwner();
        }

        if (recipient == null) {
            log.warn("Cannot notify - product has no registered owner");
            return;
        }

        String productName = consignment.getProduct().getName();
        createNotification(
                recipient,
                NotificationType.AGREEMENT_PROPOSED,
                "Permintaan Perjanjian Baru",
                String.format("%s mengajukan perjanjian untuk %s", proposer.getName(), productName),
                agreement.getId(),
                "AGREEMENT");
    }

    /**
     * Notify when an agreement is accepted.
     */
    public void notifyAgreementAccepted(Agreement agreement) {
        User proposer = agreement.getProposedBy();
        String productName = agreement.getConsignment().getProduct().getName();

        createNotification(
                proposer,
                NotificationType.AGREEMENT_ACCEPTED,
                "Perjanjian Diterima",
                String.format("Perjanjian untuk %s telah diterima!", productName),
                agreement.getId(),
                "AGREEMENT");
    }

    /**
     * Notify when an agreement is rejected.
     */
    public void notifyAgreementRejected(Agreement agreement) {
        User proposer = agreement.getProposedBy();
        String productName = agreement.getConsignment().getProduct().getName();
        String reason = agreement.getResponseMessage() != null ? agreement.getResponseMessage() : "";

        createNotification(
                proposer,
                NotificationType.AGREEMENT_REJECTED,
                "Perjanjian Ditolak",
                String.format("Perjanjian untuk %s ditolak. %s", productName, reason),
                agreement.getId(),
                "AGREEMENT");
    }

    /**
     * Notify when a counter-offer is made.
     */
    public void notifyAgreementCountered(Agreement agreement, Agreement previousAgreement) {
        User originalProposer = previousAgreement.getProposedBy();
        String productName = agreement.getConsignment().getProduct().getName();

        createNotification(
                originalProposer,
                NotificationType.AGREEMENT_COUNTERED,
                "Penawaran Balik Diterima",
                String.format("Ada penawaran balik untuk %s", productName),
                agreement.getId(),
                "AGREEMENT");
    }

    /**
     * Notify consignor when a sale is recorded.
     */
    public void notifySaleRecorded(Sale sale) {
        Consignment consignment = sale.getConsignment();
        User consignor = consignment.getProduct().getOwner();

        if (consignor == null) {
            log.warn("Cannot notify sale - product has no registered owner");
            return;
        }

        String productName = consignment.getProduct().getName();
        createNotification(
                consignor,
                NotificationType.SALE_RECORDED,
                "Penjualan Tercatat",
                String.format("%d %s terjual di %s",
                        sale.getQuantitySold(), productName, consignment.getShop().getName()),
                sale.getId(),
                "SALE");
    }

    /**
     * Get all notifications for a user.
     */
    public List<Notification> getNotifications(Long userId) {
        return notificationRepository.findByRecipientIdOrderByCreatedAtDesc(userId);
    }

    /**
     * Get unread notifications for a user.
     */
    public List<Notification> getUnreadNotifications(Long userId) {
        return notificationRepository.findByRecipientIdAndReadFalseOrderByCreatedAtDesc(userId);
    }

    /**
     * Get count of unread notifications for a user.
     */
    public long getUnreadCount(Long userId) {
        return notificationRepository.countByRecipientIdAndReadFalse(userId);
    }

    /**
     * Mark a single notification as read.
     */
    @Transactional
    public void markAsRead(Long notificationId, Long userId) {
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new IllegalArgumentException("Notifikasi tidak ditemukan"));

        if (!notification.getRecipient().getId().equals(userId)) {
            throw new IllegalArgumentException("Anda tidak memiliki akses ke notifikasi ini");
        }

        if (!notification.getRead()) {
            notification.setRead(true);
            notification.setReadAt(LocalDateTime.now());
            notificationRepository.save(notification);
        }
    }

    /**
     * Mark all notifications as read for a user.
     */
    @Transactional
    public int markAllAsRead(Long userId) {
        return notificationRepository.markAllAsReadByRecipientId(userId);
    }
}
