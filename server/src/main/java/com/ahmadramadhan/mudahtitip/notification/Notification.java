package com.ahmadramadhan.mudahtitip.notification;

import com.ahmadramadhan.mudahtitip.auth.User;
import com.ahmadramadhan.mudahtitip.common.entity.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

/**
 * Notification entity for in-app notifications.
 * Stores notifications for various events like agreements, sales, and
 * consignment updates.
 */
@Entity
@Table(name = "notifications")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Notification extends BaseEntity {

    /**
     * User who receives this notification.
     */
    @ManyToOne
    @JoinColumn(name = "recipient_id", nullable = false)
    private User recipient;

    /**
     * Type of notification event.
     */
    @NotNull
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private NotificationType type;

    /**
     * Display title for the notification.
     */
    @NotBlank
    @Column(nullable = false)
    private String title;

    /**
     * Display message body.
     */
    @NotBlank
    @Column(nullable = false, length = 500)
    private String message;

    /**
     * ID of the related entity (e.g., agreementId, saleId).
     */
    @Column(name = "reference_id")
    private Long referenceId;

    /**
     * Type of the referenced entity ("AGREEMENT", "SALE", "CONSIGNMENT").
     */
    @Column(name = "reference_type")
    private String referenceType;

    /**
     * Whether this notification has been read.
     */
    @Builder.Default
    @Column(name = "is_read", nullable = false)
    private Boolean read = false;

    /**
     * When the notification was marked as read.
     */
    @Column(name = "read_at")
    private LocalDateTime readAt;
}
