package com.ahmadramadhan.mudahtitip.complaint;

import com.ahmadramadhan.mudahtitip.auth.User;
import com.ahmadramadhan.mudahtitip.auth.UserRole;
import com.ahmadramadhan.mudahtitip.complaint.dto.ComplaintResponse;
import com.ahmadramadhan.mudahtitip.complaint.dto.CreateComplaintRequest;
import com.ahmadramadhan.mudahtitip.complaint.dto.ResolveComplaintRequest;
import com.ahmadramadhan.mudahtitip.common.config.ApiV1Controller;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;
import java.util.Map;

/**
 * REST controller for complaint operations.
 */
@ApiV1Controller
@RequestMapping("/api/v1/complaints")
@RequiredArgsConstructor
@Tag(name = "Complaints", description = "Product complaint/feedback operations")
public class ComplaintController {

    private final ComplaintService complaintService;

    /**
     * Create a new complaint (shop owner only).
     */
    @PostMapping
    @Operation(summary = "Create complaint", description = "File a new product complaint (shop owners only)")
    public ResponseEntity<ComplaintResponse> createComplaint(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody CreateComplaintRequest request) {
        Complaint complaint = complaintService.createComplaint(user, request);
        return ResponseEntity.ok(ComplaintResponse.fromEntity(complaint));
    }

    /**
     * Get all complaints for the current user.
     * Returns complaints based on user role:
     * - Shop owners see complaints they filed
     * - Consignors see complaints about their products
     */
    @GetMapping
    @Operation(summary = "Get complaints", description = "Get complaints based on user role")
    public ResponseEntity<List<ComplaintResponse>> getComplaints(@AuthenticationPrincipal User user) {
        List<Complaint> complaints;

        if (user.getRole() == UserRole.SHOP_OWNER) {
            complaints = complaintService.getComplaintsForShopOwner(user.getId());
        } else if (user.getRole() == UserRole.CONSIGNOR) {
            complaints = complaintService.getComplaintsForConsignor(user.getId());
        } else {
            return ResponseEntity.ok(List.of());
        }

        List<ComplaintResponse> responses = complaints.stream()
                .map(ComplaintResponse::fromEntity)
                .toList();

        return ResponseEntity.ok(responses);
    }

    /**
     * Get a specific complaint by ID.
     */
    @GetMapping("/{id}")
    @Operation(summary = "Get complaint", description = "Get complaint details by ID")
    public ResponseEntity<ComplaintResponse> getComplaint(
            @AuthenticationPrincipal User user,
            @PathVariable Long id) {
        Complaint complaint = complaintService.getComplaint(id, user);
        return ResponseEntity.ok(ComplaintResponse.fromEntity(complaint));
    }

    /**
     * Resolve a complaint (consignor only).
     */
    @PutMapping("/{id}/resolve")
    @Operation(summary = "Resolve complaint", description = "Resolve or reject a complaint (consignors only)")
    public ResponseEntity<ComplaintResponse> resolveComplaint(
            @AuthenticationPrincipal User user,
            @PathVariable Long id,
            @Valid @RequestBody ResolveComplaintRequest request) {
        Complaint complaint = complaintService.resolveComplaint(id, user, request);
        return ResponseEntity.ok(ComplaintResponse.fromEntity(complaint));
    }

    /**
     * Get count of open complaints for consignor.
     */
    @GetMapping("/count/open")
    @Operation(summary = "Count open complaints", description = "Get count of unresolved complaints")
    public ResponseEntity<Map<String, Long>> countOpenComplaints(@AuthenticationPrincipal User user) {
        long count = 0;
        if (user.getRole() == UserRole.CONSIGNOR) {
            count = complaintService.countOpenComplaints(user.getId());
        }
        return ResponseEntity.ok(Map.of("count", count));
    }
}
