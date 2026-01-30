package com.ahmadramadhan.mudahtitip.consignment;

import com.ahmadramadhan.mudahtitip.auth.User;
import com.ahmadramadhan.mudahtitip.consignment.dto.ConsignmentRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * REST controller for consignment management.
 */
@RestController
@RequestMapping("/api/consignments")
@RequiredArgsConstructor
public class ConsignmentController {

    private final ConsignmentService consignmentService;

    /**
     * Create a new consignment. Only consignors can create.
     */
    @PostMapping
    @PreAuthorize("hasRole('CONSIGNOR')")
    public ResponseEntity<Consignment> createConsignment(
            @Valid @RequestBody ConsignmentRequest request,
            @AuthenticationPrincipal User currentUser) {
        Consignment created = consignmentService.createConsignment(request, currentUser);
        return ResponseEntity.ok(created);
    }

    /**
     * Get all consignments for current user.
     */
    @GetMapping("/my")
    public ResponseEntity<List<Consignment>> getMyConsignments(
            @AuthenticationPrincipal User currentUser,
            @RequestParam(required = false) ConsignmentStatus status) {
        List<Consignment> consignments = consignmentService.getConsignmentsForUser(currentUser, status);
        return ResponseEntity.ok(consignments);
    }

    /**
     * Get a single consignment by ID.
     */
    @GetMapping("/{id}")
    public ResponseEntity<Consignment> getConsignment(@PathVariable Long id) {
        Consignment consignment = consignmentService.getById(id);
        return ResponseEntity.ok(consignment);
    }

    /**
     * Update consignment status.
     */
    @PatchMapping("/{id}/status")
    public ResponseEntity<Consignment> updateStatus(
            @PathVariable Long id,
            @RequestParam ConsignmentStatus status,
            @AuthenticationPrincipal User currentUser) {
        Consignment updated = consignmentService.updateStatus(id, status, currentUser);
        return ResponseEntity.ok(updated);
    }

    /**
     * Get consignments expiring soon.
     */
    @GetMapping("/expiring")
    public ResponseEntity<List<Consignment>> getExpiringSoon(
            @RequestParam(defaultValue = "7") int days) {
        List<Consignment> expiring = consignmentService.findExpiringSoon(days);
        return ResponseEntity.ok(expiring);
    }
}
