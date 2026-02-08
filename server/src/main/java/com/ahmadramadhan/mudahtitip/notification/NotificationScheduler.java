package com.ahmadramadhan.mudahtitip.notification;

import com.ahmadramadhan.mudahtitip.auth.User;
import com.ahmadramadhan.mudahtitip.consignment.Consignment;
import com.ahmadramadhan.mudahtitip.consignment.ConsignmentRepository;
import com.ahmadramadhan.mudahtitip.consignment.ConsignmentStatus;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * Scheduled jobs for sending notifications.
 * Handles stock monitoring, expiry reminders, and weekly summaries.
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class NotificationScheduler {

    private final ConsignmentRepository consignmentRepository;
    private final NotificationService notificationService;
    private final NotificationPreferenceService preferenceService;

    /**
     * Check for low/out of stock consignments every 6 hours.
     * Runs at 00:00, 06:00, 12:00, 18:00.
     */
    @Scheduled(cron = "0 0 */6 * * *")
    @Transactional(readOnly = true)
    public void checkLowStock() {
        log.info("Running low stock check...");

        List<Consignment> activeConsignments = consignmentRepository
                .findByStatus(ConsignmentStatus.ACTIVE);

        Set<Long> notifiedOutOfStock = new HashSet<>();
        Set<Long> notifiedLowStock = new HashSet<>();

        for (Consignment consignment : activeConsignments) {
            User consignor = consignment.getProduct().getOwner();
            if (consignor == null)
                continue;

            int currentQty = consignment.getCurrentQuantity();

            // Out of stock check
            if (currentQty == 0) {
                if (preferenceService.isNotificationEnabled(consignor.getId(), NotificationType.STOCK_OUT)) {
                    // Avoid duplicate notifications (check last 24h)
                    if (!hasRecentNotification(consignor.getId(), consignment.getId(), NotificationType.STOCK_OUT)) {
                        notificationService.notifyStockOut(consignment);
                        notifiedOutOfStock.add(consignment.getId());
                    }
                }
            }
            // Low stock check
            else {
                int threshold = preferenceService.getLowStockThreshold(consignor.getId());
                if (currentQty <= threshold) {
                    if (preferenceService.isNotificationEnabled(consignor.getId(), NotificationType.STOCK_LOW)) {
                        if (!hasRecentNotification(consignor.getId(), consignment.getId(),
                                NotificationType.STOCK_LOW)) {
                            notificationService.notifyStockLow(consignment, currentQty);
                            notifiedLowStock.add(consignment.getId());
                        }
                    }
                }
            }
        }

        log.info("Low stock check complete. Out of stock: {}, Low stock: {}",
                notifiedOutOfStock.size(), notifiedLowStock.size());
    }

    /**
     * Check for expiring consignments daily at 8 AM.
     */
    @Scheduled(cron = "0 0 8 * * *")
    @Transactional(readOnly = true)
    public void checkExpiringConsignments() {
        log.info("Running expiry check...");

        List<Consignment> activeConsignments = consignmentRepository
                .findByStatus(ConsignmentStatus.ACTIVE);

        int notified = 0;

        for (Consignment consignment : activeConsignments) {
            if (consignment.getExpiryDate() == null)
                continue;

            User consignor = consignment.getProduct().getOwner();
            if (consignor == null)
                continue;

            if (!preferenceService.isNotificationEnabled(consignor.getId(), NotificationType.CONSIGNMENT_EXPIRING)) {
                continue;
            }

            int reminderDays = preferenceService.getExpiryReminderDays(consignor.getId());
            LocalDate reminderDate = consignment.getExpiryDate().minusDays(reminderDays);

            // Only notify on the exact reminder date
            if (LocalDate.now().equals(reminderDate)) {
                notificationService.notifyExpiryReminder(consignment, reminderDays);
                notified++;
            }
        }

        log.info("Expiry check complete. Sent {} reminder(s)", notified);
    }

    /**
     * Send weekly summary on Mondays at 9 AM.
     */
    @Scheduled(cron = "0 0 9 * * MON")
    @Transactional(readOnly = true)
    public void sendWeeklySummary() {
        log.info("Running weekly summary generation...");
        // TODO: Implement weekly summary aggregation
        // This would aggregate sales data per consignor and send a summary
        log.info("Weekly summary generation complete (not yet implemented)");
    }

    /**
     * Check if a recent notification of the same type was already sent.
     * This prevents duplicate notifications within 24 hours.
     */
    private boolean hasRecentNotification(Long userId, Long referenceId, NotificationType type) {
        // For now, always return false - implement deduplication later
        // Could query notification table for recent entries
        return false;
    }
}
