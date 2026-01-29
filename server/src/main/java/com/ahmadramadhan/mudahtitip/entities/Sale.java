package com.ahmadramadhan.mudahtitip.entities;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Sale entity representing a sale of consigned products.
 * 
 * Records:
 * - Quantity sold from a consignment
 * - Total amount
 * - Shop's commission
 * - Consignor's earning
 */
@Entity
@Table(name = "sales")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Sale extends BaseEntity {

    @ManyToOne
    @JoinColumn(name = "consignment_id", nullable = false)
    private Consignment consignment;

    @NotNull(message = "Jumlah terjual wajib diisi")
    @Positive(message = "Jumlah terjual harus positif")
    @Column(name = "quantity_sold", nullable = false)
    private Integer quantitySold;

    /**
     * Total sale amount (quantity_sold * selling_price).
     */
    @NotNull
    @Column(name = "total_amount", nullable = false, precision = 12, scale = 2)
    private BigDecimal totalAmount;

    /**
     * Shop's commission from this sale.
     * Calculated as: total_amount * (commission_percent / 100)
     */
    @NotNull
    @Column(name = "shop_commission", nullable = false, precision = 12, scale = 2)
    private BigDecimal shopCommission;

    /**
     * Consignor's earning from this sale.
     * Calculated as: total_amount - shop_commission
     */
    @NotNull
    @Column(name = "consignor_earning", nullable = false, precision = 12, scale = 2)
    private BigDecimal consignorEarning;

    /**
     * Timestamp when the sale was made.
     */
    @NotNull
    @Column(name = "sold_at", nullable = false)
    private LocalDateTime soldAt;

    @Column(length = 500)
    private String notes;
}
