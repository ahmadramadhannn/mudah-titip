package com.ahmadramadhan.mudahtitip.analytics.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * DTO for daily sales/earnings trend data.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TrendDataDTO {
    private LocalDate date;
    private int salesCount;
    private int itemsSold;
    private BigDecimal totalAmount;
    private BigDecimal earnings;
}
