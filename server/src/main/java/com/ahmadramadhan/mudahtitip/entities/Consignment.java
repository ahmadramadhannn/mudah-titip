package com.ahmadramadhan.mudahtitip.entities;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.PositiveOrZero;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * Consignment (titipan) entity representing a batch of products
 * left at a shop by a consignor for sale.
 * 
 * This is the core entity that tracks:
 * - How many items were consigned
 * - Current remaining stock
 * - Selling price and commission agreement
 * - Expiry date for perishable goods
 */
@Entity
@Table(name = "consignments")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Consignment extends BaseEntity {

    @ManyToOne
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @ManyToOne
    @JoinColumn(name = "shop_id", nullable = false)
    private Shop shop;

    /**
     * Initial quantity of products consigned.
     */
    @NotNull(message = "Jumlah awal wajib diisi")
    @Positive(message = "Jumlah harus positif")
    @Column(name = "initial_quantity", nullable = false)
    private Integer initialQuantity;

    /**
     * Current remaining quantity available for sale.
     */
    @NotNull(message = "Jumlah saat ini wajib diisi")
    @PositiveOrZero(message = "Jumlah tidak boleh negatif")
    @Column(name = "current_quantity", nullable = false)
    private Integer currentQuantity;

    /**
     * Price at which products are sold at this shop.
     * May differ from the product's base price.
     */
    @NotNull(message = "Harga jual wajib diisi")
    @Positive(message = "Harga jual harus positif")
    @Column(name = "selling_price", nullable = false, precision = 12, scale = 2)
    private BigDecimal sellingPrice;

    /**
     * Commission percentage for the shop owner (0-100).
     * E.g., 10 means shop gets 10% of each sale.
     */
    @NotNull(message = "Persentase komisi wajib diisi")
    @PositiveOrZero(message = "Komisi tidak boleh negatif")
    @Column(name = "commission_percent", nullable = false, precision = 5, scale = 2)
    private BigDecimal commissionPercent;

    /**
     * Date when products were made/produced.
     * Used together with product's shelf life to calculate expiry.
     */
    @Column(name = "production_date")
    private LocalDate productionDate;

    /**
     * Date when products will expire.
     * Can be set manually or calculated from production_date + shelf_life_days.
     */
    @Column(name = "expiry_date")
    private LocalDate expiryDate;

    @Builder.Default
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ConsignmentStatus status = ConsignmentStatus.ACTIVE;

    @Column(length = 500)
    private String notes;

    @JsonIgnore
    @Builder.Default
    @OneToMany(mappedBy = "consignment", cascade = CascadeType.ALL)
    private List<Sale> sales = new ArrayList<>();

    /**
     * Check if this consignment has expired based on expiry date.
     */
    public boolean isExpired() {
        return expiryDate != null && LocalDate.now().isAfter(expiryDate);
    }

    /**
     * Check if this consignment is expiring within the given number of days.
     */
    public boolean isExpiringSoon(int withinDays) {
        if (expiryDate == null) {
            return false;
        }
        LocalDate threshold = LocalDate.now().plusDays(withinDays);
        return !expiryDate.isAfter(threshold);
    }
}
