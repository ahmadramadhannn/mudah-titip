package com.ahmadramadhan.mudahtitip.repositories;

import com.ahmadramadhan.mudahtitip.entities.Consignment;
import com.ahmadramadhan.mudahtitip.entities.ConsignmentStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface ConsignmentRepository extends JpaRepository<Consignment, Long> {

    List<Consignment> findByShopId(Long shopId);

    List<Consignment> findByShopIdAndStatus(Long shopId, ConsignmentStatus status);

    List<Consignment> findByProductOwnerId(Long ownerId);

    List<Consignment> findByProductOwnerIdAndStatus(Long ownerId, ConsignmentStatus status);

    /**
     * Find consignments expiring before the given date.
     */
    @Query("SELECT c FROM Consignment c WHERE c.expiryDate <= :date AND c.status = 'ACTIVE'")
    List<Consignment> findExpiringBefore(@Param("date") LocalDate date);

    /**
     * Find consignments expiring within the given number of days.
     */
    @Query("SELECT c FROM Consignment c WHERE c.expiryDate <= :thresholdDate AND c.expiryDate >= :today AND c.status = 'ACTIVE'")
    List<Consignment> findExpiringSoon(
            @Param("today") LocalDate today,
            @Param("thresholdDate") LocalDate thresholdDate);

    /**
     * Find all active consignments for a shop.
     */
    List<Consignment> findByShopIdAndStatusOrderByExpiryDateAsc(Long shopId, ConsignmentStatus status);

    /**
     * Find consignments by product.
     */
    List<Consignment> findByProductId(Long productId);
}
