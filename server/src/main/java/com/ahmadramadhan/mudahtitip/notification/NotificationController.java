package com.ahmadramadhan.mudahtitip.notification;

import com.ahmadramadhan.mudahtitip.common.security.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

/**
 * REST controller for notification endpoints.
 */
@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;
    private final JwtUtil jwtUtil;

    /**
     * Get all notifications for the current user.
     */
    @GetMapping
    public ResponseEntity<List<NotificationResponse>> getNotifications(
            @RequestHeader("Authorization") String authHeader) {
        Long userId = extractUserId(authHeader);
        List<Notification> notifications = notificationService.getNotifications(userId);
        List<NotificationResponse> responses = notifications.stream()
                .map(NotificationResponse::fromEntity)
                .toList();
        return ResponseEntity.ok(responses);
    }

    /**
     * Get count of unread notifications.
     */
    @GetMapping("/unread-count")
    public ResponseEntity<Map<String, Long>> getUnreadCount(
            @RequestHeader("Authorization") String authHeader) {
        Long userId = extractUserId(authHeader);
        long count = notificationService.getUnreadCount(userId);
        return ResponseEntity.ok(Map.of("count", count));
    }

    /**
     * Mark a notification as read.
     */
    @PutMapping("/{id}/read")
    public ResponseEntity<Void> markAsRead(
            @PathVariable Long id,
            @RequestHeader("Authorization") String authHeader) {
        Long userId = extractUserId(authHeader);
        notificationService.markAsRead(id, userId);
        return ResponseEntity.ok().build();
    }

    /**
     * Mark all notifications as read.
     */
    @PutMapping("/read-all")
    public ResponseEntity<Map<String, Integer>> markAllAsRead(
            @RequestHeader("Authorization") String authHeader) {
        Long userId = extractUserId(authHeader);
        int count = notificationService.markAllAsRead(userId);
        return ResponseEntity.ok(Map.of("markedCount", count));
    }

    private Long extractUserId(String authHeader) {
        String token = authHeader.replace("Bearer ", "");
        return jwtUtil.extractUserId(token);
    }
}
