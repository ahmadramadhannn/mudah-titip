package com.ahmadramadhan.mudahtitip.agreement.dto;

import com.ahmadramadhan.mudahtitip.agreement.CommissionType;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

/**
 * DTO for proposing or countering an agreement.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AgreementRequest {

    @NotNull(message = "Consignment ID wajib diisi")
    private Long consignmentId;

    @NotNull(message = "Tipe komisi wajib dipilih")
    private CommissionType commissionType;

    /**
     * For PERCENTAGE: the percentage (e.g., 10 for 10%)
     * For FIXED_PER_ITEM: amount per item (e.g., 2000)
     */
    @PositiveOrZero(message = "Nilai komisi tidak boleh negatif")
    private BigDecimal commissionValue;

    /**
     * For TIERED_BONUS: minimum sold percentage to trigger bonus
     */
    @PositiveOrZero(message = "Threshold tidak boleh negatif")
    private Integer bonusThresholdPercent;

    /**
     * For TIERED_BONUS: bonus amount when threshold is met
     */
    @PositiveOrZero(message = "Bonus tidak boleh negatif")
    private BigDecimal bonusAmount;

    /**
     * Additional terms or notes.
     */
    private String termsNote;
}
