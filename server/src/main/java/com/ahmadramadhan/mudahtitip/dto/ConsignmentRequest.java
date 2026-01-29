package com.ahmadramadhan.mudahtitip.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * DTO for creating a new consignment.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ConsignmentRequest {

    private Long productId;
    private Long shopId;
    private Integer quantity;
    private BigDecimal sellingPrice;
    private BigDecimal commissionPercent;
    private LocalDate productionDate;
    private LocalDate expiryDate;
    private String notes;
}
