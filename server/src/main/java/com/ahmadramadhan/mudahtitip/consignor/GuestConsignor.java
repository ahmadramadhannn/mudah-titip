package com.ahmadramadhan.mudahtitip.consignor;

import com.ahmadramadhan.mudahtitip.auth.User;
import com.ahmadramadhan.mudahtitip.common.entity.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * Guest consignor entity representing consignors who don't use the app.
 * Managed entirely by the shop owner.
 */
@Entity
@Table(name = "guest_consignors")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GuestConsignor extends BaseEntity {

    @NotBlank(message = "Nama penitip wajib diisi")
    @Size(min = 2, max = 100, message = "Nama harus antara 2-100 karakter")
    @Column(nullable = false)
    private String name;

    @NotBlank(message = "Nomor telepon wajib diisi")
    @Size(max = 20, message = "Nomor telepon maksimal 20 karakter")
    @Column(nullable = false)
    private String phone;

    @Size(max = 500, message = "Alamat maksimal 500 karakter")
    private String address;

    @Size(max = 500, message = "Catatan maksimal 500 karakter")
    private String notes;

    /**
     * The shop owner who manages this guest consignor.
     */
    @ManyToOne
    @JoinColumn(name = "managed_by_id", nullable = false)
    private User managedBy;

    @Builder.Default
    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;
}
