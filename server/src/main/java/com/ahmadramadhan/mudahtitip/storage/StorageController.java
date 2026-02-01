package com.ahmadramadhan.mudahtitip.storage;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

import com.ahmadramadhan.mudahtitip.common.config.ApiV1Controller;

import com.ahmadramadhan.mudahtitip.storage.dto.PresignedUrlRequest;
import com.ahmadramadhan.mudahtitip.storage.dto.PresignedUrlResponse;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

/**
 * REST controller for file storage operations.
 * Provides presigned URLs for direct client uploads to R2.
 */
@ApiV1Controller
@RequestMapping("/api/v1/storage")
@RequiredArgsConstructor
@Tag(name = "Storage", description = "File upload and storage operations")
public class StorageController {

    private final R2StorageService storageService;

    /**
     * Check if storage service is configured and available.
     */
    @GetMapping("/status")
    @Operation(summary = "Check storage status", description = "Check if R2 storage is configured and available")
    public ResponseEntity<StorageStatusResponse> getStatus() {
        boolean configured = storageService.isConfigured();
        return ResponseEntity.ok(new StorageStatusResponse(configured));
    }

    /**
     * Generate a presigned URL for uploading a file directly to R2.
     * The client should use this URL to PUT the file directly.
     */
    @PostMapping("/presigned-url")
    @Operation(summary = "Generate presigned upload URL", description = "Generate a presigned URL for direct file upload to R2 storage")
    public ResponseEntity<PresignedUrlResponse> generatePresignedUrl(
            @Valid @RequestBody PresignedUrlRequest request) {

        if (!storageService.isConfigured()) {
            return ResponseEntity.status(503).build();
        }

        // Validate content type (only allow images for now)
        if (!isAllowedContentType(request.getContentType())) {
            return ResponseEntity.badRequest().build();
        }

        String folder = request.getFolder() != null ? request.getFolder() : "uploads";
        String objectKey = storageService.generateObjectKey(folder, request.getFileName());
        String uploadUrl = storageService.generatePresignedUploadUrl(objectKey, request.getContentType());
        String publicUrl = storageService.getPublicUrl(objectKey);

        PresignedUrlResponse response = PresignedUrlResponse.builder()
                .uploadUrl(uploadUrl)
                .publicUrl(publicUrl)
                .objectKey(objectKey)
                .expiresInMinutes(5)
                .build();

        return ResponseEntity.ok(response);
    }

    private boolean isAllowedContentType(String contentType) {
        return contentType != null && (contentType.equals("image/jpeg") ||
                contentType.equals("image/jpg") ||
                contentType.equals("image/png") ||
                contentType.equals("image/gif") ||
                contentType.equals("image/webp"));
    }

    /**
     * Simple response for storage status check.
     */
    public record StorageStatusResponse(boolean configured) {
    }
}
