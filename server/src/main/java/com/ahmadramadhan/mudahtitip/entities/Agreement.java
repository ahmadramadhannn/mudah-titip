package com.ahmadramadhan.mudahtitip.entities;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;

/**
 * Agreement entity representing the negotiated terms between
 * shop owner and consignor for a consignment.
 * 
 * Supports flexible commission types:
 * - PERCENTAGE: shop gets X% of each sale
 * - FIXED_PER_ITEM: shop gets Rp X per item sold
 * - TIERED_BONUS: shop gets bonus if sales reach threshold
 */
@Entity
@Table(name = "agreements")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Agreement extends BaseEntity {

    @ManyToOne
    @JoinColumn(name = "consignment_id", nullable = false)
    private Consignment consignment;

    /**
     * User who proposed this agreement version (can be shop owner or consignor).
     */
    @ManyToOne
    @JoinColumn(name = "proposed_by_id", nullable = false)
    private User proposedBy;

    @NotNull
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private AgreementStatus status;

    @NotNull
    @Enumerated(EnumType.STRING)
    @Column(name = "commission_type", nullable = false)
    private CommissionType commissionType;

    /**
     * For PERCENTAGE: the percentage value (e.g., 10 for 10%)
     * For FIXED_PER_ITEM: the amount per item (e.g., 2000 for Rp2.000)
     */
    @PositiveOrZero
    @Column(name = "commission_value", precision = 12, scale = 2)
    private BigDecimal commissionValue;

    /**
     * For TIERED_BONUS: minimum percentage of items that must be sold (e.g., 90 for
     * 90%)
     */
    @PositiveOrZero
    @Column(name = "bonus_threshold_percent")
    private Integer bonusThresholdPercent;

    /**
     * For TIERED_BONUS: bonus amount if threshold is met (e.g., 50000 for Rp50.000)
     */
    @PositiveOrZero
    @Column(name = "bonus_amount", precision = 12, scale = 2)
    private BigDecimal bonusAmount;

    /**
     * Additional notes or terms for this agreement.
     */
    @Column(name = "terms_note", length = 1000)
    private String termsNote;

    /**
     * Message explaining counter-offer or rejection reason.
     */
    @Column(name = "response_message", length = 500)
    private String responseMessage;

    /**
     * Reference to the previous agreement version in negotiation chain.
     */
    @ManyToOne
    @JoinColumn(name = "previous_version_id")
    private Agreement previousVersion;
}
