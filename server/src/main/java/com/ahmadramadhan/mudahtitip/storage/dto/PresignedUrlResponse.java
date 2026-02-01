package com.ahmadramadhan.mudahtitip.storage.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Response DTO containing presigned upload URL and public URL.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PresignedUrlResponse {

    /**
     * Presigned URL for uploading the file (PUT request).
     */
    private String uploadUrl;

    /**
     * Public URL where the file will be accessible after upload.
     */
    private String publicUrl;

    /**
     * The object key in the bucket.
     */
    private String objectKey;

    /**
     * Expiration time in minutes for the presigned URL.
     */
    private int expiresInMinutes;
}
