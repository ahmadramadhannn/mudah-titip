package com.ahmadramadhan.mudahtitip.complaint.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Request DTO for resolving a complaint.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ResolveComplaintRequest {

    @NotBlank(message = "Resolusi wajib diisi")
    @Size(min = 10, max = 1000, message = "Resolusi harus 10-1000 karakter")
    private String resolution;

    /**
     * Whether to accept or reject the complaint.
     * true = resolved, false = rejected
     */
    private boolean accepted;
}
