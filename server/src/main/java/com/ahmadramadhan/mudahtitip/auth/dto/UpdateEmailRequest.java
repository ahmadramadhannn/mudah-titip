package com.ahmadramadhan.mudahtitip.auth.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Request DTO for updating user email.
 * Requires current password for verification.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UpdateEmailRequest {

    @NotBlank(message = "Email baru wajib diisi")
    @Email(message = "Format email tidak valid")
    private String newEmail;

    @NotBlank(message = "Password saat ini wajib diisi")
    private String currentPassword;
}
