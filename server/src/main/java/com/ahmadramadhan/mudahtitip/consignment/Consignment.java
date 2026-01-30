package com.ahmadramadhan.mudahtitip.consignment;

import com.ahmadramadhan.mudahtitip.common.entity.BaseEntity;
import com.ahmadramadhan.mudahtitip.product.Product;
import com.ahmadramadhan.mudahtitip.sale.Sale;
import com.ahmadramadhan.mudahtitip.shop.Shop;
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
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Consignment entity representing a batch of products placed at a shop.
 * Tracks quantity, pricing, commission, expiry, and status.
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
     * Initial quantity placed at the shop.
     */
    @NotNull(message = "Jumlah awal wajib diisi")
    @Positive(message = "Jumlah harus positif")
    @Column(name = "initial_quantity", nullable = false)
    private Integer initialQuantity;

    /**
     * Current remaining quantity (initial - sold - returned).
     */
    @PositiveOrZero(message = "Jumlah tidak boleh negatif")
    @Column(name = "current_quantity", nullable = false)
    private Integer currentQuantity;

    /**
     * Selling price at the shop (may differ from base price).
     */
    @NotNull(message = "Harga jual wajib diisi")
    @Positive(message = "Harga harus positif")
    @Column(name = "selling_price", nullable = false, precision = 12, scale = 2)
    private BigDecimal sellingPrice;

    /**
     * Commission percentage for the shop (e.g., 10 for 10%).
     */
    @NotNull(message = "Persentase komisi wajib diisi")
    @PositiveOrZero(message = "Komisi tidak boleh negatif")
    @Column(name = "commission_percent", nullable = false, precision = 5, scale = 2)
    private BigDecimal commissionPercent;

    @Column(name = "consignment_date")
    private LocalDate consignmentDate;

    @Column(name = "expiry_date")
    private LocalDate expiryDate;

    @Builder.Default
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ConsignmentStatus status = ConsignmentStatus.ACTIVE;

    @Column(length = 500)
    private String notes;

    /**
     * Sales made from this consignment.
     */
    @JsonIgnore
    @Builder.Default
    @OneToMany(mappedBy = "consignment", cascade = CascadeType.ALL)
    private List<Sale> sales = new ArrayList<>();

    /**
     * Check if consignment is expired based on expiry date.
     */
    public boolean isExpired() {
        if (expiryDate == null)
            return false;
        return LocalDate.now().isAfter(expiryDate);
    }

    /**
     * Check if consignment is expiring within given days.
     */
    public boolean isExpiringWithin(int days) {
        if (expiryDate == null)
            return false;
        return LocalDate.now().plusDays(days).isAfter(expiryDate);
    }
}
