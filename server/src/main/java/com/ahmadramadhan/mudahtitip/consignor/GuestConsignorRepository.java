package com.ahmadramadhan.mudahtitip.consignor;

import com.ahmadramadhan.mudahtitip.auth.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Repository for GuestConsignor entity.
 */
@Repository
public interface GuestConsignorRepository extends JpaRepository<GuestConsignor, Long> {

    /**
     * Find all guest consignors managed by a specific user.
     */
    List<GuestConsignor> findByManagedByAndIsActiveTrue(User managedBy);

    /**
     * Find guest consignor by ID and managed by user.
     */
    Optional<GuestConsignor> findByIdAndManagedBy(Long id, User managedBy);

    /**
     * Search guest consignors by phone for a specific manager.
     */
    List<GuestConsignor> findByManagedByAndPhoneContainingAndIsActiveTrue(User managedBy, String phone);

    /**
     * Search guest consignors by name for a specific manager.
     */
    List<GuestConsignor> findByManagedByAndNameContainingIgnoreCaseAndIsActiveTrue(User managedBy, String name);

    /**
     * Check if phone already exists for this manager.
     */
    boolean existsByManagedByAndPhoneAndIsActiveTrue(User managedBy, String phone);
}
