package com.ahmadramadhan.mudahtitip.entities;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.ArrayList;
import java.util.List;

/**
 * Shop entity representing a physical store that receives consigned products.
 * Each shop has one owner (SHOP_OWNER role user).
 */
@Entity
@Table(name = "shops")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Shop extends BaseEntity {

    @NotBlank(message = "Nama toko wajib diisi")
    @Size(min = 2, max = 100, message = "Nama toko harus antara 2-100 karakter")
    @Column(nullable = false)
    private String name;

    @Size(max = 500, message = "Alamat maksimal 500 karakter")
    private String address;

    @Size(max = 15, message = "Nomor telepon maksimal 15 karakter")
    private String phone;

    @Size(max = 500, message = "Deskripsi maksimal 500 karakter")
    private String description;

    @Builder.Default
    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    @OneToOne
    @JoinColumn(name = "owner_id", nullable = false)
    private User owner;

    @JsonIgnore
    @Builder.Default
    @OneToMany(mappedBy = "shop", cascade = CascadeType.ALL)
    private List<Consignment> consignments = new ArrayList<>();
}
