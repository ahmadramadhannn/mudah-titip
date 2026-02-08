package com.ahmadramadhan.mudahtitip.notification;

import com.ahmadramadhan.mudahtitip.auth.User;
import com.ahmadramadhan.mudahtitip.common.entity.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * User preferences for notification settings.
 * Controls which notifications a user wants to receive.
 */
@Entity
@Table(name = "notification_preferences")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class NotificationPreference extends BaseEntity {

    /**
     * User this preference belongs to.
     */
    @OneToOne
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    // ===== Stock Notifications =====

    /**
     * Notify when stock falls below threshold.
     */
    @Builder.Default
    @Column(name = "stock_low_enabled", nullable = false)
    private Boolean stockLowEnabled = true;

    /**
     * Notify when stock reaches zero.
     */
    @Builder.Default
    @Column(name = "stock_out_enabled", nullable = false)
    private Boolean stockOutEnabled = true;

    /**
     * Threshold for low stock notification.
     */
    @Builder.Default
    @Min(1)
    @Max(100)
    @Column(name = "low_stock_threshold", nullable = false)
    private Integer lowStockThreshold = 5;

    /**
     * Receive weekly stock summary (opt-in).
     */
    @Builder.Default
    @Column(name = "weekly_summary_enabled", nullable = false)
    private Boolean weeklySummaryEnabled = false;

    // ===== Agreement Notifications =====

    /**
     * Notify on agreement updates (proposed, accepted, rejected, countered).
     */
    @Builder.Default
    @Column(name = "agreement_updates_enabled", nullable = false)
    private Boolean agreementUpdatesEnabled = true;

    // ===== Sales Notifications =====

    /**
     * Notify when a sale is recorded.
     */
    @Builder.Default
    @Column(name = "sales_notifications_enabled", nullable = false)
    private Boolean salesNotificationsEnabled = true;

    // ===== Expiry Notifications =====

    /**
     * Notify when consignment is about to expire.
     */
    @Builder.Default
    @Column(name = "expiry_reminders_enabled", nullable = false)
    private Boolean expiryRemindersEnabled = true;

    /**
     * Days before expiry to send reminder.
     */
    @Builder.Default
    @Min(1)
    @Max(30)
    @Column(name = "expiry_reminder_days", nullable = false)
    private Integer expiryReminderDays = 7;

    // ===== Financial Notifications =====

    /**
     * Notify when payout is ready.
     */
    @Builder.Default
    @Column(name = "payout_notifications_enabled", nullable = false)
    private Boolean payoutNotificationsEnabled = true;

    /**
     * Create default preferences for a user.
     */
    public static NotificationPreference createDefault(User user) {
        return NotificationPreference.builder()
                .user(user)
                .build();
    }
}
