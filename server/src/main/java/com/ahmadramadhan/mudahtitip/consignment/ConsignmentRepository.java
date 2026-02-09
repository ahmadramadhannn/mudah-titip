package com.ahmadramadhan.mudahtitip.consignment;

import com.ahmadramadhan.mudahtitip.auth.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface ConsignmentRepository extends JpaRepository<Consignment, Long> {

        List<Consignment> findByStatus(ConsignmentStatus status);

        List<Consignment> findByShopId(Long shopId);

        List<Consignment> findByShopIdAndStatus(Long shopId, ConsignmentStatus status);

        List<Consignment> findByProductOwnerId(Long ownerId);

        List<Consignment> findByProductOwnerIdAndStatus(Long ownerId, ConsignmentStatus status);

        List<Consignment> findByProductOwnerIdOrderByCreatedAtDesc(Long ownerId);

        List<Consignment> findByShopIdOrderByCreatedAtDesc(Long shopId);

        /**
         * Find consignments expiring before a given date.
         */
        List<Consignment> findByExpiryDateBeforeAndStatus(LocalDate date, ConsignmentStatus status);

        /**
         * Find active consignments expiring soon (within days).
         */
        @Query("SELECT c FROM Consignment c WHERE c.status = 'ACTIVE' " +
                        "AND c.expiryDate BETWEEN :today AND :futureDate")
        List<Consignment> findExpiringSoon(
                        @Param("today") LocalDate today,
                        @Param("futureDate") LocalDate futureDate);

        /**
         * Find all consignments for a shop owner.
         */
        @Query("SELECT c FROM Consignment c WHERE c.shop.owner.id = :ownerId")
        List<Consignment> findByShopOwnerId(@Param("ownerId") Long ownerId);

        /**
         * Find consignments by shop and status.
         */
        @Query("SELECT c FROM Consignment c WHERE c.shop.owner.id = :ownerId AND c.status = :status")
        List<Consignment> findByShopOwnerIdAndStatus(
                        @Param("ownerId") Long ownerId,
                        @Param("status") ConsignmentStatus status);
}
