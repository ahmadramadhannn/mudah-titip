package com.ahmadramadhan.mudahtitip.controllers;

import com.ahmadramadhan.mudahtitip.dto.ConsignmentRequest;
import com.ahmadramadhan.mudahtitip.entities.Consignment;
import com.ahmadramadhan.mudahtitip.entities.ConsignmentStatus;
import com.ahmadramadhan.mudahtitip.entities.User;
import com.ahmadramadhan.mudahtitip.entities.UserRole;
import com.ahmadramadhan.mudahtitip.repositories.ShopRepository;
import com.ahmadramadhan.mudahtitip.services.ConsignmentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * REST controller for consignment (titipan) management.
 */
@RestController
@RequestMapping("/api/consignments")
@RequiredArgsConstructor
public class ConsignmentController {

    private final ConsignmentService consignmentService;
    private final ShopRepository shopRepository;

    @PostMapping
    public ResponseEntity<Consignment> createConsignment(
            @RequestBody ConsignmentRequest request,
            @AuthenticationPrincipal User currentUser) {
        Consignment consignment = consignmentService.createConsignment(request, currentUser);
        return ResponseEntity.ok(consignment);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Consignment> getConsignment(@PathVariable Long id) {
        Consignment consignment = consignmentService.getById(id);
        return ResponseEntity.ok(consignment);
    }

    /**
     * Get consignments for current user.
     * Shop owners see consignments at their shop.
     * Consignors see their own consignments across all shops.
     */
    @GetMapping("/my")
    public ResponseEntity<List<Consignment>> getMyConsignments(
            @AuthenticationPrincipal User currentUser,
            @RequestParam(required = false) ConsignmentStatus status) {
        if (currentUser.getRole() == UserRole.SHOP_OWNER) {
            Long shopId = shopRepository.findByOwner(currentUser)
                    .map(shop -> shop.getId())
                    .orElseThrow(() -> new IllegalStateException("Toko tidak ditemukan"));

            if (status != null) {
                return ResponseEntity.ok(consignmentService.getConsignmentsByShopAndStatus(shopId, status));
            }
            return ResponseEntity.ok(consignmentService.getConsignmentsByShop(shopId));
        } else {
            if (status != null) {
                return ResponseEntity.ok(consignmentService.getConsignmentsByOwner(currentUser.getId())
                        .stream()
                        .filter(c -> c.getStatus() == status)
                        .toList());
            }
            return ResponseEntity.ok(consignmentService.getConsignmentsByOwner(currentUser.getId()));
        }
    }

    /**
     * Get consignments expiring soon (within N days).
     */
    @GetMapping("/expiring-soon")
    public ResponseEntity<List<Consignment>> getExpiringSoon(
            @RequestParam(defaultValue = "3") int days) {
        List<Consignment> expiring = consignmentService.getExpiringSoon(days);
        return ResponseEntity.ok(expiring);
    }

    /**
     * Update consignment status.
     */
    @PatchMapping("/{id}/status")
    public ResponseEntity<Consignment> updateStatus(
            @PathVariable Long id,
            @RequestParam ConsignmentStatus status) {
        Consignment updated = consignmentService.updateStatus(id, status);
        return ResponseEntity.ok(updated);
    }
}
