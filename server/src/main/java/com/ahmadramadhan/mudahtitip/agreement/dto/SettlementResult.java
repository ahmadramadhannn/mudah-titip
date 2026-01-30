package com.ahmadramadhan.mudahtitip.agreement.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

/**
 * DTO for settlement calculation result at end of consignment.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SettlementResult {

    private Long consignmentId;
    private String productName;
    private String shopName;
    private String consignorName;

    private Integer initialQuantity;
    private Integer soldQuantity;
    private Integer remainingQuantity;
    private BigDecimal soldPercentage;

    private BigDecimal totalSalesAmount;
    private BigDecimal shopCommission;
    private BigDecimal bonusAmount;
    private BigDecimal totalShopEarning;
    private BigDecimal consignorEarning;

    private String commissionBreakdown;
    private boolean bonusApplied;
}
