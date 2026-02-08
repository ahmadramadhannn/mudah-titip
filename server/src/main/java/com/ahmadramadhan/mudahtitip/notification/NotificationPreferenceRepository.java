package com.ahmadramadhan.mudahtitip.notification;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Repository for NotificationPreference entity.
 */
@Repository
public interface NotificationPreferenceRepository extends JpaRepository<NotificationPreference, Long> {

    /**
     * Find preferences by user ID.
     */
    Optional<NotificationPreference> findByUserId(Long userId);

    /**
     * Check if preferences exist for a user.
     */
    boolean existsByUserId(Long userId);
}
