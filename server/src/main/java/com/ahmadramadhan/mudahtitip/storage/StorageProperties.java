package com.ahmadramadhan.mudahtitip.storage;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import lombok.Getter;
import lombok.Setter;

/**
 * Configuration properties for Cloudflare R2 object storage.
 * R2 is S3-compatible, so we use AWS S3 SDK with custom endpoint.
 */
@Component
@ConfigurationProperties(prefix = "r2")
@Getter
@Setter
public class StorageProperties {

    /**
     * R2 Access Key ID (from Cloudflare dashboard).
     */
    private String accessKeyId;

    /**
     * R2 Secret Access Key (from Cloudflare dashboard).
     */
    private String secretAccessKey;

    /**
     * Cloudflare Account ID.
     */
    private String accountId;

    /**
     * R2 bucket name.
     */
    private String bucketName;

    /**
     * Public URL for accessing uploaded objects.
     * Can be the R2.dev subdomain or a custom domain.
     */
    private String publicUrl;

    /**
     * Presigned URL expiration time in minutes.
     */
    private int presignedUrlExpirationMinutes = 5;

    /**
     * Get the S3-compatible endpoint URL for R2.
     */
    public String getEndpoint() {
        return String.format("https://%s.r2.cloudflarestorage.com", accountId);
    }
}
