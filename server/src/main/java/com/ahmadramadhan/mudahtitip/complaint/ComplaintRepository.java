package com.ahmadramadhan.mudahtitip.complaint;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Repository for Complaint entity operations.
 */
@Repository
public interface ComplaintRepository extends JpaRepository<Complaint, Long> {

    /**
     * Find all complaints for products owned by a specific consignor.
     */
    @Query("SELECT c FROM Complaint c WHERE c.consignment.product.owner.id = ?1 ORDER BY c.createdAt DESC")
    List<Complaint> findByConsignorIdOrderByCreatedAtDesc(Long consignorId);

    /**
     * Find all complaints filed by a specific shop owner.
     */
    List<Complaint> findByReporterIdOrderByCreatedAtDesc(Long reporterId);

    /**
     * Find complaints for a specific consignment.
     */
    List<Complaint> findByConsignmentIdOrderByCreatedAtDesc(Long consignmentId);

    /**
     * Count unresolved complaints for a consignor.
     */
    @Query("SELECT COUNT(c) FROM Complaint c WHERE c.consignment.product.owner.id = ?1 AND c.status = 'OPEN'")
    long countOpenComplaintsByConsignorId(Long consignorId);
}
