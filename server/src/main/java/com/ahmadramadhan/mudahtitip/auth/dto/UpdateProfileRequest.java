package com.ahmadramadhan.mudahtitip.auth.dto;

import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Request DTO for updating user profile (name and phone).
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UpdateProfileRequest {

    @Size(min = 2, max = 100, message = "Nama harus antara 2-100 karakter")
    private String name;

    @Size(max = 15, message = "Nomor telepon maksimal 15 karakter")
    private String phone;
}
