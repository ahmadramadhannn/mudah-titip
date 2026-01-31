package com.ahmadramadhan.mudahtitip.consignor;

import com.ahmadramadhan.mudahtitip.auth.User;
import com.ahmadramadhan.mudahtitip.consignor.dto.GuestConsignorRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * REST controller for guest consignor management.
 * Only shop owners can manage guest consignors.
 */
@RestController
@RequestMapping("/api/guest-consignors")
@RequiredArgsConstructor
@PreAuthorize("hasRole('SHOP_OWNER')")
public class GuestConsignorController {

    private final GuestConsignorService service;

    /**
     * Create a new guest consignor.
     */
    @PostMapping
    public ResponseEntity<GuestConsignor> create(
            @Valid @RequestBody GuestConsignorRequest request,
            @AuthenticationPrincipal User currentUser) {
        GuestConsignor created = service.create(request, currentUser);
        return ResponseEntity.ok(created);
    }

    /**
     * Get all guest consignors for the current shop owner.
     */
    @GetMapping
    public ResponseEntity<List<GuestConsignor>> getAll(@AuthenticationPrincipal User currentUser) {
        List<GuestConsignor> list = service.getByManager(currentUser);
        return ResponseEntity.ok(list);
    }

    /**
     * Get a single guest consignor by ID.
     */
    @GetMapping("/{id}")
    public ResponseEntity<GuestConsignor> getById(
            @PathVariable Long id,
            @AuthenticationPrincipal User currentUser) {
        GuestConsignor guestConsignor = service.getById(id, currentUser);
        return ResponseEntity.ok(guestConsignor);
    }

    /**
     * Search guest consignors by phone or name.
     */
    @GetMapping("/search")
    public ResponseEntity<List<GuestConsignor>> search(
            @RequestParam(required = false) String phone,
            @RequestParam(required = false) String name,
            @AuthenticationPrincipal User currentUser) {
        if (phone != null && !phone.isBlank()) {
            return ResponseEntity.ok(service.searchByPhone(phone, currentUser));
        } else if (name != null && !name.isBlank()) {
            return ResponseEntity.ok(service.searchByName(name, currentUser));
        }
        return ResponseEntity.ok(service.getByManager(currentUser));
    }

    /**
     * Update a guest consignor.
     */
    @PutMapping("/{id}")
    public ResponseEntity<GuestConsignor> update(
            @PathVariable Long id,
            @Valid @RequestBody GuestConsignorRequest request,
            @AuthenticationPrincipal User currentUser) {
        GuestConsignor updated = service.update(id, request, currentUser);
        return ResponseEntity.ok(updated);
    }

    /**
     * Deactivate (soft delete) a guest consignor.
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @PathVariable Long id,
            @AuthenticationPrincipal User currentUser) {
        service.deactivate(id, currentUser);
        return ResponseEntity.noContent().build();
    }
}
