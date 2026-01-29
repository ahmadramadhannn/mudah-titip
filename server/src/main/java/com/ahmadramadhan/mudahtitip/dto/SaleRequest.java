package com.ahmadramadhan.mudahtitip.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO for recording a sale.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SaleRequest {

    private Long consignmentId;
    private Integer quantity;
    private String notes;
}
