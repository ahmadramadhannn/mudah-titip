package com.ahmadramadhan.mudahtitip.admin;

import com.ahmadramadhan.mudahtitip.admin.dto.*;
import com.ahmadramadhan.mudahtitip.auth.UserRole;
import com.ahmadramadhan.mudahtitip.common.config.ApiV1Controller;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * REST controller for admin operations.
 * All endpoints require SUPER_ADMIN role.
 */
@ApiV1Controller
@RequestMapping("/api/v1/admin")
@RequiredArgsConstructor
@PreAuthorize("hasRole('SUPER_ADMIN')")
public class AdminController {

    private final AdminService adminService;

    // ============================================================
    // User Management
    // ============================================================

    /**
     * Get all users with optional filtering.
     * 
     * @param role     Filter by user role (optional)
     * @param status   Filter by user status (optional)
     * @param pageable Pagination parameters
     * @return Page of users
     */
    @GetMapping("/users")
    public ResponseEntity<Page<UserAdminDto>> getAllUsers(
            @RequestParam(required = false) UserRole role,
            @RequestParam(required = false) String status,
            Pageable pageable) {
        return ResponseEntity.ok(adminService.getAllUsers(role, status, pageable));
    }

    /**
     * Get detailed information about a specific user.
     * 
     * @param id User ID
     * @return User details with statistics
     */
    @GetMapping("/users/{id}")
    public ResponseEntity<UserAdminDto> getUserDetails(@PathVariable Long id) {
        return ResponseEntity.ok(adminService.getUserDetails(id));
    }

    /**
     * Suspend a user account.
     * 
     * @param id      User ID
     * @param request Action request with reason
     * @return Success response
     */
    @PutMapping("/users/{id}/suspend")
    public ResponseEntity<Void> suspendUser(
            @PathVariable Long id,
            @Valid @RequestBody UserActionRequest request) {
        adminService.suspendUser(id, request.getReason());
        return ResponseEntity.ok().build();
    }

    /**
     * Activate a suspended user account.
     * 
     * @param id User ID
     * @return Success response
     */
    @PutMapping("/users/{id}/activate")
    public ResponseEntity<Void> activateUser(@PathVariable Long id) {
        adminService.activateUser(id);
        return ResponseEntity.ok().build();
    }

    /**
     * Ban a user account permanently.
     * 
     * @param id      User ID
     * @param request Action request with reason
     * @return Success response
     */
    @PutMapping("/users/{id}/ban")
    public ResponseEntity<Void> banUser(
            @PathVariable Long id,
            @Valid @RequestBody UserActionRequest request) {
        adminService.banUser(id, request.getReason());
        return ResponseEntity.ok().build();
    }

    // ============================================================
    // Shop Management
    // ============================================================

    /**
     * Get all shops with optional filtering.
     * 
     * @param verified Filter by verification status (optional)
     * @param pageable Pagination parameters
     * @return Page of shops
     */
    @GetMapping("/shops")
    public ResponseEntity<Page<ShopAdminDto>> getAllShops(
            @RequestParam(required = false) Boolean verified,
            Pageable pageable) {
        return ResponseEntity.ok(adminService.getAllShops(verified, pageable));
    }

    /**
     * Get shops pending verification.
     * 
     * @return List of unverified shops
     */
    @GetMapping("/shops/pending")
    public ResponseEntity<List<ShopAdminDto>> getPendingVerifications() {
        return ResponseEntity.ok(adminService.getPendingVerifications());
    }

    /**
     * Verify a shop.
     * 
     * @param id      Shop ID
     * @param request Verification request with message
     * @return Success response
     */
    @PutMapping("/shops/{id}/verify")
    public ResponseEntity<Void> verifyShop(
            @PathVariable Long id,
            @Valid @RequestBody ShopVerificationRequest request) {
        if (Boolean.TRUE.equals(request.getApproved())) {
            adminService.verifyShop(id, request.getMessage());
        } else {
            adminService.rejectShop(id, request.getMessage());
        }
        return ResponseEntity.ok().build();
    }

    /**
     * Reject a shop verification.
     * 
     * @param id      Shop ID
     * @param request Verification request with message
     * @return Success response
     */
    @PutMapping("/shops/{id}/reject")
    public ResponseEntity<Void> rejectShop(
            @PathVariable Long id,
            @Valid @RequestBody ShopVerificationRequest request) {
        adminService.rejectShop(id, request.getMessage());
        return ResponseEntity.ok().build();
    }

    // ============================================================
    // Analytics
    // ============================================================

    /**
     * Get platform-wide metrics and statistics.
     * 
     * @return Platform metrics
     */
    @GetMapping("/analytics/overview")
    public ResponseEntity<PlatformMetricsDto> getPlatformMetrics() {
        return ResponseEntity.ok(adminService.getPlatformMetrics());
    }
}
