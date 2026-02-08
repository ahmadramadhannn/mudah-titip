package com.ahmadramadhan.mudahtitip.notification;

import com.ahmadramadhan.mudahtitip.auth.User;
import com.ahmadramadhan.mudahtitip.auth.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Service for managing notification preferences.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class NotificationPreferenceService {

    private final NotificationPreferenceRepository preferenceRepository;
    private final UserRepository userRepository;

    /**
     * Get preferences for a user, creating default if not exists.
     */
    @Transactional
    public NotificationPreference getOrCreatePreferences(Long userId) {
        return preferenceRepository.findByUserId(userId)
                .orElseGet(() -> {
                    User user = userRepository.findById(userId)
                            .orElseThrow(() -> new IllegalArgumentException("User not found"));
                    NotificationPreference pref = NotificationPreference.createDefault(user);
                    return preferenceRepository.save(pref);
                });
    }

    /**
     * Get preferences DTO for a user.
     */
    public NotificationPreferenceDto getPreferencesDto(Long userId) {
        NotificationPreference pref = getOrCreatePreferences(userId);
        return NotificationPreferenceDto.fromEntity(pref);
    }

    /**
     * Update preferences for a user.
     */
    @Transactional
    public NotificationPreferenceDto updatePreferences(Long userId, NotificationPreferenceDto dto) {
        NotificationPreference pref = getOrCreatePreferences(userId);
        dto.applyTo(pref);
        pref = preferenceRepository.save(pref);
        log.info("Updated notification preferences for user {}", userId);
        return NotificationPreferenceDto.fromEntity(pref);
    }

    /**
     * Check if a specific notification type is enabled for a user.
     */
    public boolean isNotificationEnabled(Long userId, NotificationType type) {
        NotificationPreference pref = getOrCreatePreferences(userId);

        return switch (type) {
            case STOCK_LOW -> pref.getStockLowEnabled();
            case STOCK_OUT -> pref.getStockOutEnabled();
            case STOCK_WEEKLY_SUMMARY -> pref.getWeeklySummaryEnabled();
            case AGREEMENT_PROPOSED, AGREEMENT_ACCEPTED, AGREEMENT_REJECTED,
                    AGREEMENT_COUNTERED, AGREEMENT_EXTENDED, AGREEMENT_DISCONTINUED ->
                pref.getAgreementUpdatesEnabled();
            case SALE_RECORDED -> pref.getSalesNotificationsEnabled();
            case CONSIGNMENT_EXPIRING, CONSIGNMENT_EXPIRED, CONSIGNMENT_COMPLETED ->
                pref.getExpiryRemindersEnabled();
            case PAYOUT_READY -> pref.getPayoutNotificationsEnabled();
        };
    }

    /**
     * Get low stock threshold for a user.
     */
    public int getLowStockThreshold(Long userId) {
        NotificationPreference pref = getOrCreatePreferences(userId);
        return pref.getLowStockThreshold();
    }

    /**
     * Get expiry reminder days for a user.
     */
    public int getExpiryReminderDays(Long userId) {
        NotificationPreference pref = getOrCreatePreferences(userId);
        return pref.getExpiryReminderDays();
    }
}
