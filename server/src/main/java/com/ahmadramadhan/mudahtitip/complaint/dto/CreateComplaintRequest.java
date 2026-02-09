package com.ahmadramadhan.mudahtitip.complaint.dto;

import com.ahmadramadhan.mudahtitip.complaint.ComplaintCategory;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * Request DTO for creating a new complaint.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateComplaintRequest {

    @NotNull(message = "ID konsinyasi wajib diisi")
    private Long consignmentId;

    @NotNull(message = "Kategori keluhan wajib diisi")
    private ComplaintCategory category;

    @NotBlank(message = "Deskripsi keluhan wajib diisi")
    @Size(min = 10, max = 1000, message = "Deskripsi harus 10-1000 karakter")
    private String description;

    /**
     * List of media URLs (images/videos) attached to the complaint.
     */
    private List<String> mediaUrls;
}
