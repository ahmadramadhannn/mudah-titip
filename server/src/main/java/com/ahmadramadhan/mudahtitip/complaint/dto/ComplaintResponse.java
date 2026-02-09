package com.ahmadramadhan.mudahtitip.complaint.dto;

import com.ahmadramadhan.mudahtitip.complaint.Complaint;
import com.ahmadramadhan.mudahtitip.complaint.ComplaintCategory;
import com.ahmadramadhan.mudahtitip.complaint.ComplaintStatus;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Response DTO for complaint data.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ComplaintResponse {

    private Long id;
    private Long consignmentId;
    private String productName;
    private String shopName;
    private String reporterName;
    private Long reporterId;
    private ComplaintCategory category;
    private String description;
    private List<String> mediaUrls;
    private ComplaintStatus status;
    private String resolution;
    private LocalDateTime resolvedAt;
    private String resolvedByName;
    private LocalDateTime createdAt;

    private static final ObjectMapper objectMapper = new ObjectMapper();

    public static ComplaintResponse fromEntity(Complaint complaint) {
        List<String> mediaUrlList = null;
        if (complaint.getMediaUrls() != null && !complaint.getMediaUrls().isEmpty()) {
            try {
                mediaUrlList = objectMapper.readValue(
                        complaint.getMediaUrls(),
                        new TypeReference<List<String>>() {
                        });
            } catch (Exception e) {
                mediaUrlList = List.of();
            }
        }

        return ComplaintResponse.builder()
                .id(complaint.getId())
                .consignmentId(complaint.getConsignment().getId())
                .productName(complaint.getConsignment().getProduct().getName())
                .shopName(complaint.getConsignment().getShop().getName())
                .reporterName(complaint.getReporter().getName())
                .reporterId(complaint.getReporter().getId())
                .category(complaint.getCategory())
                .description(complaint.getDescription())
                .mediaUrls(mediaUrlList)
                .status(complaint.getStatus())
                .resolution(complaint.getResolution())
                .resolvedAt(complaint.getResolvedAt())
                .resolvedByName(complaint.getResolvedBy() != null ? complaint.getResolvedBy().getName() : null)
                .createdAt(complaint.getCreatedAt())
                .build();
    }
}
