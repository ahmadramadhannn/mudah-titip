package com.ahmadramadhan.mudahtitip.notification;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO for notification preferences.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class NotificationPreferenceDto {

    // Stock notifications
    private Boolean stockLowEnabled;
    private Boolean stockOutEnabled;

    @Min(1)
    @Max(100)
    private Integer lowStockThreshold;
    private Boolean weeklySummaryEnabled;

    // Agreement notifications
    private Boolean agreementUpdatesEnabled;

    // Sales notifications
    private Boolean salesNotificationsEnabled;

    // Expiry notifications
    private Boolean expiryRemindersEnabled;

    @Min(1)
    @Max(30)
    private Integer expiryReminderDays;

    // Financial notifications
    private Boolean payoutNotificationsEnabled;

    /**
     * Create DTO from entity.
     */
    public static NotificationPreferenceDto fromEntity(NotificationPreference entity) {
        return NotificationPreferenceDto.builder()
                .stockLowEnabled(entity.getStockLowEnabled())
                .stockOutEnabled(entity.getStockOutEnabled())
                .lowStockThreshold(entity.getLowStockThreshold())
                .weeklySummaryEnabled(entity.getWeeklySummaryEnabled())
                .agreementUpdatesEnabled(entity.getAgreementUpdatesEnabled())
                .salesNotificationsEnabled(entity.getSalesNotificationsEnabled())
                .expiryRemindersEnabled(entity.getExpiryRemindersEnabled())
                .expiryReminderDays(entity.getExpiryReminderDays())
                .payoutNotificationsEnabled(entity.getPayoutNotificationsEnabled())
                .build();
    }

    /**
     * Apply DTO values to entity (only non-null fields).
     */
    public void applyTo(NotificationPreference entity) {
        if (stockLowEnabled != null)
            entity.setStockLowEnabled(stockLowEnabled);
        if (stockOutEnabled != null)
            entity.setStockOutEnabled(stockOutEnabled);
        if (lowStockThreshold != null)
            entity.setLowStockThreshold(lowStockThreshold);
        if (weeklySummaryEnabled != null)
            entity.setWeeklySummaryEnabled(weeklySummaryEnabled);
        if (agreementUpdatesEnabled != null)
            entity.setAgreementUpdatesEnabled(agreementUpdatesEnabled);
        if (salesNotificationsEnabled != null)
            entity.setSalesNotificationsEnabled(salesNotificationsEnabled);
        if (expiryRemindersEnabled != null)
            entity.setExpiryRemindersEnabled(expiryRemindersEnabled);
        if (expiryReminderDays != null)
            entity.setExpiryReminderDays(expiryReminderDays);
        if (payoutNotificationsEnabled != null)
            entity.setPayoutNotificationsEnabled(payoutNotificationsEnabled);
    }
}
