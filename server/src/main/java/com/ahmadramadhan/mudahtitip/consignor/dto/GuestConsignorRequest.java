package com.ahmadramadhan.mudahtitip.consignor.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO for creating or updating a guest consignor.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GuestConsignorRequest {

    @NotBlank(message = "Nama penitip wajib diisi")
    @Size(min = 2, max = 100, message = "Nama harus antara 2-100 karakter")
    private String name;

    @NotBlank(message = "Nomor telepon wajib diisi")
    @Size(max = 20, message = "Nomor telepon maksimal 20 karakter")
    private String phone;

    @Size(max = 500, message = "Alamat maksimal 500 karakter")
    private String address;

    @Size(max = 500, message = "Catatan maksimal 500 karakter")
    private String notes;
}
