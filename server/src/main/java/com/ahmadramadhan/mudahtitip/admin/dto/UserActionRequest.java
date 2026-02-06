package com.ahmadramadhan.mudahtitip.admin.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

/**
 * Request DTO for admin actions on users.
 */
@Data
public class UserActionRequest {
    @NotBlank(message = "Action is required")
    private String action; // SUSPEND, ACTIVATE, BAN

    private String reason;
}
