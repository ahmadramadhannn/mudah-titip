package com.ahmadramadhan.mudahtitip.product;

import com.ahmadramadhan.mudahtitip.auth.User;
import com.ahmadramadhan.mudahtitip.common.entity.BaseEntity;
import com.ahmadramadhan.mudahtitip.consignment.Consignment;
import com.ahmadramadhan.mudahtitip.consignor.GuestConsignor;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

/**
 * Product entity representing a product type owned by a consignor.
 * Each product can be consigned to multiple shops.
 * 
 * A product can be owned by either:
 * - A registered User (consignor with app account)
 * - A GuestConsignor (consignor managed by shop owner)
 * 
 * Exactly one of owner/guestOwner must be set.
 */
@Entity
@Table(name = "products")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Product extends BaseEntity {

    @NotBlank(message = "Nama produk wajib diisi")
    @Size(min = 2, max = 100, message = "Nama produk harus antara 2-100 karakter")
    @Column(nullable = false)
    private String name;

    @Size(max = 500, message = "Deskripsi maksimal 500 karakter")
    private String description;

    @Size(max = 50, message = "Kategori maksimal 50 karakter")
    private String category;

    /**
     * Default shelf life in days for this product type.
     * Used to calculate expiry dates when creating consignments.
     */
    @Positive(message = "Masa simpan harus positif")
    @Column(name = "shelf_life_days")
    private Integer shelfLifeDays;

    /**
     * Base/suggested selling price set by the consignor.
     */
    @NotNull(message = "Harga dasar wajib diisi")
    @Positive(message = "Harga harus positif")
    @Column(name = "base_price", nullable = false, precision = 12, scale = 2)
    private BigDecimal basePrice;

    @Column(name = "image_url")
    private String imageUrl;

    @Builder.Default
    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    /**
     * Owner for registered consignors (users with app accounts).
     * Either owner OR guestOwner must be set, not both.
     */
    @ManyToOne
    @JoinColumn(name = "owner_id")
    private User owner;

    /**
     * Owner for guest consignors (managed by shop owner).
     * Either owner OR guestOwner must be set, not both.
     */
    @ManyToOne
    @JoinColumn(name = "guest_owner_id")
    private GuestConsignor guestOwner;

    @JsonIgnore
    @Builder.Default
    @OneToMany(mappedBy = "product", cascade = CascadeType.ALL)
    private List<Consignment> consignments = new ArrayList<>();

    /**
     * Check if this product is owned by a guest consignor.
     */
    public boolean isGuestOwned() {
        return guestOwner != null;
    }

    /**
     * Get the owner name (works for both user and guest owners).
     */
    public String getOwnerName() {
        if (owner != null) {
            return owner.getName();
        } else if (guestOwner != null) {
            return guestOwner.getName();
        }
        return null;
    }
}
