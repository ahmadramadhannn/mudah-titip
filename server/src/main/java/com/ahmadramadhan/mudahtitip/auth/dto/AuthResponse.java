package com.ahmadramadhan.mudahtitip.auth.dto;

import com.ahmadramadhan.mudahtitip.auth.UserRole;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO for authentication response containing JWT token and user info.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AuthResponse {

    private String token;
    private String tokenType;
    private Long userId;
    private String name;
    private String email;
    private UserRole role;
    private Long shopId; // Only for SHOP_OWNER
}
