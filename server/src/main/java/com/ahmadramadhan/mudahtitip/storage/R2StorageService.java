package com.ahmadramadhan.mudahtitip.storage;

import java.net.URI;
import java.time.Duration;
import java.util.UUID;

import org.springframework.stereotype.Service;

import lombok.extern.slf4j.Slf4j;
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.DeleteObjectRequest;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;
import software.amazon.awssdk.services.s3.presigner.S3Presigner;
import software.amazon.awssdk.services.s3.presigner.model.PresignedPutObjectRequest;
import software.amazon.awssdk.services.s3.presigner.model.PutObjectPresignRequest;

/**
 * Service for managing file uploads to Cloudflare R2 object storage.
 * Uses AWS S3 SDK v2 with R2's S3-compatible API.
 */
@Service
@Slf4j
public class R2StorageService {

    private final StorageProperties properties;
    private final S3Client s3Client;
    private final S3Presigner presigner;

    public R2StorageService(StorageProperties properties) {
        this.properties = properties;

        // Only initialize clients if properties are configured
        if (isConfigured()) {
            AwsBasicCredentials credentials = AwsBasicCredentials.create(
                    properties.getAccessKeyId(),
                    properties.getSecretAccessKey());

            StaticCredentialsProvider credentialsProvider = StaticCredentialsProvider.create(credentials);

            this.s3Client = S3Client.builder()
                    .endpointOverride(URI.create(properties.getEndpoint()))
                    .credentialsProvider(credentialsProvider)
                    .region(Region.of("auto")) // R2 uses "auto" region
                    .forcePathStyle(true)
                    .build();

            this.presigner = S3Presigner.builder()
                    .endpointOverride(URI.create(properties.getEndpoint()))
                    .credentialsProvider(credentialsProvider)
                    .region(Region.of("auto"))
                    .build();

            log.info("R2 storage service initialized for bucket: {}", properties.getBucketName());
        } else {
            this.s3Client = null;
            this.presigner = null;
            log.warn("R2 storage service not configured - file uploads will be disabled");
        }
    }

    /**
     * Check if R2 storage is properly configured.
     */
    public boolean isConfigured() {
        return properties.getAccessKeyId() != null
                && !properties.getAccessKeyId().isEmpty()
                && properties.getSecretAccessKey() != null
                && !properties.getSecretAccessKey().isEmpty()
                && properties.getAccountId() != null
                && !properties.getAccountId().isEmpty();
    }

    /**
     * Generate a unique object key for a file upload.
     * 
     * @param folder           The folder/prefix (e.g., "products", "profiles")
     * @param originalFileName Original file name to extract extension
     * @return Unique object key
     */
    public String generateObjectKey(String folder, String originalFileName) {
        String extension = "";
        int lastDot = originalFileName.lastIndexOf('.');
        if (lastDot > 0) {
            extension = originalFileName.substring(lastDot);
        }
        return String.format("%s/%s%s", folder, UUID.randomUUID().toString(), extension);
    }

    /**
     * Generate a presigned URL for uploading a file directly to R2.
     * 
     * @param objectKey   The object key (path) in the bucket
     * @param contentType MIME type of the file
     * @return Presigned PUT URL valid for configured duration
     */
    public String generatePresignedUploadUrl(String objectKey, String contentType) {
        if (!isConfigured()) {
            throw new IllegalStateException("R2 storage is not configured");
        }

        PutObjectRequest putRequest = PutObjectRequest.builder()
                .bucket(properties.getBucketName())
                .key(objectKey)
                .contentType(contentType)
                .build();

        PutObjectPresignRequest presignRequest = PutObjectPresignRequest.builder()
                .signatureDuration(Duration.ofMinutes(properties.getPresignedUrlExpirationMinutes()))
                .putObjectRequest(putRequest)
                .build();

        PresignedPutObjectRequest presignedRequest = presigner.presignPutObject(presignRequest);
        return presignedRequest.url().toString();
    }

    /**
     * Get the public URL for an uploaded object.
     * 
     * @param objectKey The object key in the bucket
     * @return Public URL to access the object
     */
    public String getPublicUrl(String objectKey) {
        String publicUrl = properties.getPublicUrl();
        if (publicUrl == null || publicUrl.isEmpty()) {
            // Fall back to R2.dev URL format
            publicUrl = String.format("https://%s.r2.dev", properties.getBucketName());
        }
        // Remove trailing slash if present
        if (publicUrl.endsWith("/")) {
            publicUrl = publicUrl.substring(0, publicUrl.length() - 1);
        }
        return publicUrl + "/" + objectKey;
    }

    /**
     * Delete an object from R2 storage.
     * 
     * @param objectKey The object key to delete
     */
    public void deleteObject(String objectKey) {
        if (!isConfigured()) {
            log.warn("R2 storage not configured, skipping delete for: {}", objectKey);
            return;
        }

        try {
            DeleteObjectRequest deleteRequest = DeleteObjectRequest.builder()
                    .bucket(properties.getBucketName())
                    .key(objectKey)
                    .build();

            s3Client.deleteObject(deleteRequest);
            log.info("Deleted object from R2: {}", objectKey);
        } catch (Exception e) {
            log.error("Failed to delete object from R2: {}", objectKey, e);
        }
    }

    /**
     * Extract object key from a full public URL.
     * 
     * @param publicUrl The full public URL
     * @return The object key, or null if unable to extract
     */
    public String extractObjectKeyFromUrl(String publicUrl) {
        if (publicUrl == null || publicUrl.isEmpty()) {
            return null;
        }

        String baseUrl = properties.getPublicUrl();
        if (baseUrl != null && publicUrl.startsWith(baseUrl)) {
            String key = publicUrl.substring(baseUrl.length());
            return key.startsWith("/") ? key.substring(1) : key;
        }

        // Try to extract from path
        int lastSlashAfterDomain = publicUrl.indexOf('/', publicUrl.indexOf("//") + 2);
        if (lastSlashAfterDomain > 0) {
            return publicUrl.substring(lastSlashAfterDomain + 1);
        }

        return null;
    }
}
