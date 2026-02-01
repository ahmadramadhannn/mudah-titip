package com.ahmadramadhan.mudahtitip.analytics.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

/**
 * DTO for top performing product analytics.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TopProductDTO {
    private Long productId;
    private String productName;
    private String category;
    private int totalSold;
    private BigDecimal totalRevenue;
    private BigDecimal totalEarnings;
}
