package com.ahmadramadhan.mudahtitip.dto;

import com.ahmadramadhan.mudahtitip.entities.UserRole;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO for user registration request.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RegisterRequest {

    @NotBlank(message = "Nama wajib diisi")
    @Size(min = 2, max = 100, message = "Nama harus antara 2-100 karakter")
    private String name;

    @NotBlank(message = "Email wajib diisi")
    @Email(message = "Format email tidak valid")
    private String email;

    @NotBlank(message = "Password wajib diisi")
    @Size(min = 6, message = "Password minimal 6 karakter")
    private String password;

    @Size(max = 15, message = "Nomor telepon maksimal 15 karakter")
    private String phone;

    @NotNull(message = "Role wajib dipilih")
    private UserRole role;

    // Shop details (required if role is SHOP_OWNER)
    private String shopName;
    private String shopAddress;
    private String shopPhone;
    private String shopDescription;
}
