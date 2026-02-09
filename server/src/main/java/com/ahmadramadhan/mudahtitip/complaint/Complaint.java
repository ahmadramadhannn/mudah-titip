package com.ahmadramadhan.mudahtitip.complaint;

import com.ahmadramadhan.mudahtitip.auth.User;
import com.ahmadramadhan.mudahtitip.common.entity.BaseEntity;
import com.ahmadramadhan.mudahtitip.consignment.Consignment;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

/**
 * Complaint entity for tracking product quality issues reported by shop owners.
 * Allows shop owners to report problems with consigned products to consignors.
 */
@Entity
@Table(name = "complaints")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Complaint extends BaseEntity {

    @ManyToOne
    @JoinColumn(name = "consignment_id", nullable = false)
    private Consignment consignment;

    @ManyToOne
    @JoinColumn(name = "reporter_id", nullable = false)
    private User reporter;

    @NotNull(message = "Kategori keluhan wajib diisi")
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ComplaintCategory category;

    @NotBlank(message = "Deskripsi keluhan wajib diisi")
    @Size(min = 10, max = 1000, message = "Deskripsi harus 10-1000 karakter")
    @Column(nullable = false, length = 1000)
    private String description;

    /**
     * JSON array of media URLs (images/videos).
     * Stored as text to allow flexible number of attachments.
     */
    @Column(name = "media_urls", columnDefinition = "TEXT")
    private String mediaUrls;

    @Builder.Default
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ComplaintStatus status = ComplaintStatus.OPEN;

    /**
     * Consignor's response/resolution to the complaint.
     */
    @Size(max = 1000, message = "Resolusi maksimal 1000 karakter")
    @Column(length = 1000)
    private String resolution;

    @Column(name = "resolved_at")
    private LocalDateTime resolvedAt;

    @ManyToOne
    @JoinColumn(name = "resolved_by_id")
    private User resolvedBy;
}
