package com.ahmadramadhan.mudahtitip.dev;

import com.ahmadramadhan.mudahtitip.notification.NotificationRepository;
import com.ahmadramadhan.mudahtitip.notification.NotificationSeeder;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Profile;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/**
 * Dev-only controller for resetting data.
 * Only available in dev profile.
 */
@RestController
@RequestMapping("/api/v1/dev")
@Profile("dev")
@RequiredArgsConstructor
@Slf4j
public class DevController {

    private final NotificationRepository notificationRepository;
    private final NotificationSeeder notificationSeeder;

    /**
     * Clear all notifications and re-seed with new unique data.
     */
    @PostMapping("/reset-notifications")
    public ResponseEntity<Map<String, Object>> resetNotifications() {
        log.info("DEV: Resetting all notifications...");

        // Delete all existing notifications
        notificationRepository.deleteAllNotifications();
        log.info("DEV: Deleted all existing notifications");

        // Re-seed with new data
        try {
            notificationSeeder.run();
            log.info("DEV: Re-seeded notifications");
        } catch (Exception e) {
            log.error("DEV: Failed to re-seed notifications", e);
            return ResponseEntity.internalServerError()
                    .body(Map.of("error", e.getMessage()));
        }

        long newCount = notificationRepository.count();
        return ResponseEntity.ok(Map.of(
                "message", "Notifications reset and re-seeded",
                "totalNotifications", newCount));
    }

    /**
     * Just delete all notifications without re-seeding.
     */
    @DeleteMapping("/notifications")
    public ResponseEntity<Map<String, String>> deleteAllNotifications() {
        log.info("DEV: Deleting all notifications...");
        notificationRepository.deleteAllNotifications();
        return ResponseEntity.ok(Map.of("message", "All notifications deleted"));
    }
}
