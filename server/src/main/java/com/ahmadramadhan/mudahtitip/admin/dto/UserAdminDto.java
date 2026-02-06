package com.ahmadramadhan.mudahtitip.admin.dto;

import com.ahmadramadhan.mudahtitip.auth.UserRole;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Admin view of user data with statistics.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserAdminDto {
    private Long id;
    private String name;
    private String email;
    private String phone;
    private UserRole role;
    private String status; // ACTIVE, SUSPENDED, BANNED
    private LocalDateTime createdAt;
    private LocalDateTime lastLoginAt;

    // Statistics
    private Long totalProducts;
    private Long totalConsignments;
    private Long totalSales;
    private Double totalRevenue;
    private Double averageRating;
}
