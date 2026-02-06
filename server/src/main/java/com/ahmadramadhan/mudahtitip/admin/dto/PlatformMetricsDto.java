package com.ahmadramadhan.mudahtitip.admin.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

/**
 * Platform-wide metrics for admin dashboard.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PlatformMetricsDto {
    // User metrics
    private Long totalUsers;
    private Long totalShopOwners;
    private Long totalConsignors;
    private Long activeUsersLast7Days;
    private Long newUsersThisMonth;

    // Shop metrics
    private Long totalShops;
    private Long activeShops;
    private Long pendingVerifications;

    // Product metrics
    private Long totalProducts;
    private Long activeProducts;

    // Consignment metrics
    private Long totalConsignments;
    private Long activeConsignments;
    private Long expiringConsignments;

    // Financial metrics
    private BigDecimal totalGMV;
    private BigDecimal monthlyGMV;
    private BigDecimal platformRevenue;
    private Long totalTransactions;

    // Growth metrics
    private Double userGrowthRate;
    private Double revenueGrowthRate;
}
