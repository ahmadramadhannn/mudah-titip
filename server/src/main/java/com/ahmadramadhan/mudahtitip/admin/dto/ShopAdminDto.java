package com.ahmadramadhan.mudahtitip.admin.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Admin view of shop data with statistics.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ShopAdminDto {
    private Long id;
    private String name;
    private String address;
    private String phone;
    private String description;
    private String ownerName;
    private String ownerEmail;
    private Boolean isActive;
    private Boolean isVerified;
    private LocalDateTime createdAt;

    // Statistics
    private Long totalProducts;
    private Long totalConsignments;
    private Long totalSales;
    private Double totalRevenue;
    private Double averageRating;
}
