package com.ahmadramadhan.mudahtitip.admin.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

/**
 * Request DTO for shop verification.
 */
@Data
public class ShopVerificationRequest {
    @NotNull(message = "Approval status is required")
    private Boolean approved;

    private String message;
}
