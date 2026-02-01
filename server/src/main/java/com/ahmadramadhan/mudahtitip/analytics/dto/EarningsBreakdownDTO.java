package com.ahmadramadhan.mudahtitip.analytics.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

/**
 * DTO for earnings breakdown by product.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EarningsBreakdownDTO {
    private Long productId;
    private String productName;
    private String category;
    private BigDecimal earnings;
    private double percentage;
}
