package com.ahmadramadhan.mudahtitip.storage.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Request DTO for generating a presigned upload URL.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PresignedUrlRequest {

    /**
     * Original file name (used to determine extension).
     */
    @NotBlank(message = "File name is required")
    private String fileName;

    /**
     * MIME type of the file (e.g., "image/jpeg", "image/png").
     */
    @NotBlank(message = "Content type is required")
    private String contentType;

    /**
     * Folder/category for organizing uploads (e.g., "products", "profiles").
     * Defaults to "uploads" if not specified.
     */
    @Builder.Default
    private String folder = "uploads";
}
