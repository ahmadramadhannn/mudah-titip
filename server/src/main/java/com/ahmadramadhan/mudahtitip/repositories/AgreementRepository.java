package com.ahmadramadhan.mudahtitip.repositories;

import com.ahmadramadhan.mudahtitip.entities.Agreement;
import com.ahmadramadhan.mudahtitip.entities.AgreementStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface AgreementRepository extends JpaRepository<Agreement, Long> {

    List<Agreement> findByConsignmentId(Long consignmentId);

    Optional<Agreement> findByConsignmentIdAndStatus(Long consignmentId, AgreementStatus status);

    /**
     * Find the current active (accepted) agreement for a consignment.
     */
    Optional<Agreement> findFirstByConsignmentIdAndStatusOrderByCreatedAtDesc(
            Long consignmentId, AgreementStatus status);

    /**
     * Find pending agreements (proposed or counter) for a user to respond to.
     */
    List<Agreement> findByConsignmentShopOwnerIdAndStatusIn(
            Long shopOwnerId, List<AgreementStatus> statuses);

    List<Agreement> findByConsignmentProductOwnerIdAndStatusIn(
            Long consignorId, List<AgreementStatus> statuses);
}
