package com.ahmadramadhan.mudahtitip.consignment.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.PositiveOrZero;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * DTO for creating a consignment.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ConsignmentRequest {

    @NotNull(message = "Product ID wajib diisi")
    private Long productId;

    @NotNull(message = "Shop ID wajib diisi")
    private Long shopId;

    @NotNull(message = "Jumlah wajib diisi")
    @Positive(message = "Jumlah harus positif")
    private Integer quantity;

    @NotNull(message = "Harga jual wajib diisi")
    @Positive(message = "Harga harus positif")
    private BigDecimal sellingPrice;

    @PositiveOrZero(message = "Komisi tidak boleh negatif")
    private BigDecimal commissionPercent;

    private LocalDate consignmentDate;

    private LocalDate expiryDate;

    private String notes;
}
