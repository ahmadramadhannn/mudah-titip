package com.ahmadramadhan.mudahtitip.consignor;

import com.ahmadramadhan.mudahtitip.auth.User;
import com.ahmadramadhan.mudahtitip.auth.UserRole;
import com.ahmadramadhan.mudahtitip.consignor.dto.GuestConsignorRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * Service for managing guest consignors.
 */
@Service
@RequiredArgsConstructor
public class GuestConsignorService {

    private final GuestConsignorRepository repository;

    /**
     * Create a new guest consignor.
     */
    @Transactional
    public GuestConsignor create(GuestConsignorRequest request, User shopOwner) {
        validateShopOwner(shopOwner);

        // Check if phone already exists for this manager
        if (repository.existsByManagedByAndPhoneAndIsActiveTrue(shopOwner, request.getPhone())) {
            throw new IllegalArgumentException("Penitip dengan nomor telepon ini sudah terdaftar");
        }

        GuestConsignor guestConsignor = GuestConsignor.builder()
                .name(request.getName())
                .phone(request.getPhone())
                .address(request.getAddress())
                .notes(request.getNotes())
                .managedBy(shopOwner)
                .isActive(true)
                .build();

        return repository.save(guestConsignor);
    }

    /**
     * Update an existing guest consignor.
     */
    @Transactional
    public GuestConsignor update(Long id, GuestConsignorRequest request, User shopOwner) {
        validateShopOwner(shopOwner);

        GuestConsignor existing = repository.findByIdAndManagedBy(id, shopOwner)
                .orElseThrow(() -> new IllegalArgumentException("Penitip tidak ditemukan"));

        // Check if new phone conflicts with another guest consignor
        if (!existing.getPhone().equals(request.getPhone())) {
            if (repository.existsByManagedByAndPhoneAndIsActiveTrue(shopOwner, request.getPhone())) {
                throw new IllegalArgumentException("Penitip dengan nomor telepon ini sudah terdaftar");
            }
        }

        existing.setName(request.getName());
        existing.setPhone(request.getPhone());
        existing.setAddress(request.getAddress());
        existing.setNotes(request.getNotes());

        return repository.save(existing);
    }

    /**
     * Get guest consignor by ID (only if managed by the requesting user).
     */
    public GuestConsignor getById(Long id, User shopOwner) {
        validateShopOwner(shopOwner);

        return repository.findByIdAndManagedBy(id, shopOwner)
                .filter(GuestConsignor::getIsActive)
                .orElseThrow(() -> new IllegalArgumentException("Penitip tidak ditemukan"));
    }

    /**
     * Get all guest consignors managed by the user.
     */
    public List<GuestConsignor> getByManager(User shopOwner) {
        validateShopOwner(shopOwner);
        return repository.findByManagedByAndIsActiveTrue(shopOwner);
    }

    /**
     * Search by phone number.
     */
    public List<GuestConsignor> searchByPhone(String phone, User shopOwner) {
        validateShopOwner(shopOwner);
        return repository.findByManagedByAndPhoneContainingAndIsActiveTrue(shopOwner, phone);
    }

    /**
     * Search by name.
     */
    public List<GuestConsignor> searchByName(String name, User shopOwner) {
        validateShopOwner(shopOwner);
        return repository.findByManagedByAndNameContainingIgnoreCaseAndIsActiveTrue(shopOwner, name);
    }

    /**
     * Deactivate (soft delete) a guest consignor.
     */
    @Transactional
    public void deactivate(Long id, User shopOwner) {
        validateShopOwner(shopOwner);

        GuestConsignor existing = repository.findByIdAndManagedBy(id, shopOwner)
                .orElseThrow(() -> new IllegalArgumentException("Penitip tidak ditemukan"));

        existing.setIsActive(false);
        repository.save(existing);
    }

    private void validateShopOwner(User user) {
        if (user.getRole() != UserRole.SHOP_OWNER) {
            throw new IllegalStateException("Hanya pemilik toko yang dapat mengelola penitip");
        }
    }
}
