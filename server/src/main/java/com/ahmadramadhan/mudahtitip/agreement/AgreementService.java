package com.ahmadramadhan.mudahtitip.agreement;

import com.ahmadramadhan.mudahtitip.agreement.dto.AgreementRequest;
import com.ahmadramadhan.mudahtitip.agreement.dto.SettlementResult;
import com.ahmadramadhan.mudahtitip.auth.User;
import com.ahmadramadhan.mudahtitip.common.MessageService;
import com.ahmadramadhan.mudahtitip.consignment.Consignment;
import com.ahmadramadhan.mudahtitip.consignment.ConsignmentRepository;
import com.ahmadramadhan.mudahtitip.notification.NotificationService;
import com.ahmadramadhan.mudahtitip.sale.SaleRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

/**
 * Service handling agreement negotiation and settlement calculation.
 */
@Service
@RequiredArgsConstructor
public class AgreementService {

    private final AgreementRepository agreementRepository;
    private final ConsignmentRepository consignmentRepository;
    private final SaleRepository saleRepository;
    private final MessageService messageService;
    private final NotificationService notificationService;

    /**
     * Propose a new agreement for a consignment.
     * Either shop owner or consignor can propose.
     */
    @Transactional
    public Agreement propose(AgreementRequest request, User currentUser) {
        Consignment consignment = consignmentRepository.findById(request.getConsignmentId())
                .orElseThrow(() -> new IllegalArgumentException(messageService.getMessage("consignment.not.found")));

        // Check if there's already an accepted agreement
        if (agreementRepository.findByConsignmentIdAndStatus(
                consignment.getId(), AgreementStatus.ACCEPTED).isPresent()) {
            throw new IllegalStateException(messageService.getMessage("agreement.exists"));
        }

        Agreement agreement = buildAgreement(request, consignment, currentUser, null);
        agreement.setStatus(AgreementStatus.PROPOSED);

        agreement = agreementRepository.save(agreement);
        notificationService.notifyAgreementProposed(agreement);
        return agreement;
    }

    /**
     * Counter an existing agreement proposal.
     */
    @Transactional
    public Agreement counter(Long agreementId, AgreementRequest request, User currentUser) {
        Agreement previous = agreementRepository.findById(agreementId)
                .orElseThrow(() -> new IllegalArgumentException(messageService.getMessage("agreement.not.found")));

        if (previous.getStatus() != AgreementStatus.PROPOSED &&
                previous.getStatus() != AgreementStatus.COUNTER) {
            throw new IllegalStateException(
                    messageService.getMessage("agreement.counter.invalid.status", previous.getStatus()));
        }

        // Mark previous as countered
        previous.setStatus(AgreementStatus.COUNTER);
        agreementRepository.save(previous);

        // Create new counter proposal
        Agreement counter = buildAgreement(request, previous.getConsignment(), currentUser, previous);
        counter.setStatus(AgreementStatus.PROPOSED);

        counter = agreementRepository.save(counter);
        notificationService.notifyAgreementCountered(counter, previous);
        return counter;
    }

    /**
     * Accept an agreement proposal.
     */
    @Transactional
    public Agreement accept(Long agreementId, User currentUser, String message) {
        Agreement agreement = agreementRepository.findById(agreementId)
                .orElseThrow(() -> new IllegalArgumentException(messageService.getMessage("agreement.not.found")));

        if (agreement.getStatus() != AgreementStatus.PROPOSED) {
            throw new IllegalStateException(messageService.getMessage("agreement.accept.pending.only"));
        }

        // Can't accept your own proposal
        if (agreement.getProposedBy().getId().equals(currentUser.getId())) {
            throw new IllegalArgumentException(messageService.getMessage("agreement.accept.self.denied"));
        }

        agreement.setStatus(AgreementStatus.ACCEPTED);
        agreement.setResponseMessage(message);

        agreement = agreementRepository.save(agreement);
        notificationService.notifyAgreementAccepted(agreement);
        return agreement;
    }

    /**
     * Reject an agreement proposal.
     */
    @Transactional
    public Agreement reject(Long agreementId, User currentUser, String reason) {
        Agreement agreement = agreementRepository.findById(agreementId)
                .orElseThrow(() -> new IllegalArgumentException(messageService.getMessage("agreement.not.found")));

        if (agreement.getStatus() != AgreementStatus.PROPOSED) {
            throw new IllegalStateException(messageService.getMessage("agreement.reject.pending.only"));
        }

        if (agreement.getProposedBy().getId().equals(currentUser.getId())) {
            throw new IllegalArgumentException(messageService.getMessage("agreement.reject.self.denied"));
        }

        agreement.setStatus(AgreementStatus.REJECTED);
        agreement.setResponseMessage(reason);

        agreement = agreementRepository.save(agreement);
        notificationService.notifyAgreementRejected(agreement);
        return agreement;
    }

    /**
     * Calculate settlement for a completed consignment.
     */
    public SettlementResult calculateSettlement(Long consignmentId) {
        Consignment consignment = consignmentRepository.findById(consignmentId)
                .orElseThrow(() -> new IllegalArgumentException(messageService.getMessage("consignment.not.found")));

        Agreement agreement = agreementRepository
                .findByConsignmentIdAndStatus(consignmentId, AgreementStatus.ACCEPTED)
                .orElseThrow(() -> new IllegalArgumentException(messageService.getMessage("agreement.no.accepted")));

        int sold = consignment.getInitialQuantity() - consignment.getCurrentQuantity();
        BigDecimal soldPercent = BigDecimal.valueOf(sold)
                .divide(BigDecimal.valueOf(consignment.getInitialQuantity()), 4, RoundingMode.HALF_UP)
                .multiply(BigDecimal.valueOf(100));

        BigDecimal totalSales = consignment.getSellingPrice()
                .multiply(BigDecimal.valueOf(sold));

        BigDecimal shopCommission = calculateCommission(agreement, sold, totalSales);
        BigDecimal bonusAmount = calculateBonus(agreement, soldPercent);
        BigDecimal totalShopEarning = shopCommission.add(bonusAmount);
        BigDecimal consignorEarning = totalSales.subtract(totalShopEarning);

        return SettlementResult.builder()
                .consignmentId(consignmentId)
                .productName(consignment.getProduct().getName())
                .shopName(consignment.getShop().getName())
                .consignorName(consignment.getProduct().getOwner().getName())
                .initialQuantity(consignment.getInitialQuantity())
                .soldQuantity(sold)
                .remainingQuantity(consignment.getCurrentQuantity())
                .soldPercentage(soldPercent.setScale(2, RoundingMode.HALF_UP))
                .totalSalesAmount(totalSales)
                .shopCommission(shopCommission)
                .bonusAmount(bonusAmount)
                .totalShopEarning(totalShopEarning)
                .consignorEarning(consignorEarning)
                .commissionBreakdown(buildCommissionBreakdown(agreement, sold, shopCommission))
                .bonusApplied(bonusAmount.compareTo(BigDecimal.ZERO) > 0)
                .build();
    }

    /**
     * Get pending agreements for a user to respond to.
     */
    public List<Agreement> getPendingAgreements(User user) {
        List<AgreementStatus> pendingStatuses = List.of(AgreementStatus.PROPOSED);

        // Get agreements where user needs to respond (proposed by the other party)
        List<Agreement> shopOwnerPending = agreementRepository
                .findByConsignmentShopOwnerIdAndStatusIn(user.getId(), pendingStatuses);
        List<Agreement> consignorPending = agreementRepository
                .findByConsignmentProductOwnerIdAndStatusIn(user.getId(), pendingStatuses);

        // Filter out agreements proposed by self
        shopOwnerPending.removeIf(a -> a.getProposedBy().getId().equals(user.getId()));
        consignorPending.removeIf(a -> a.getProposedBy().getId().equals(user.getId()));

        shopOwnerPending.addAll(consignorPending);
        return shopOwnerPending;
    }

    private Agreement buildAgreement(AgreementRequest request, Consignment consignment,
            User proposedBy, Agreement previousVersion) {
        return Agreement.builder()
                .consignment(consignment)
                .proposedBy(proposedBy)
                .commissionType(request.getCommissionType())
                .commissionValue(request.getCommissionValue())
                .bonusThresholdPercent(request.getBonusThresholdPercent())
                .bonusAmount(request.getBonusAmount())
                .termsNote(request.getTermsNote())
                .previousVersion(previousVersion)
                .build();
    }

    private BigDecimal calculateCommission(Agreement agreement, int soldQuantity, BigDecimal totalSales) {
        return switch (agreement.getCommissionType()) {
            case PERCENTAGE -> {
                BigDecimal rate = agreement.getCommissionValue()
                        .divide(BigDecimal.valueOf(100), 4, RoundingMode.HALF_UP);
                yield totalSales.multiply(rate).setScale(2, RoundingMode.HALF_UP);
            }
            case FIXED_PER_ITEM -> agreement.getCommissionValue()
                    .multiply(BigDecimal.valueOf(soldQuantity))
                    .setScale(2, RoundingMode.HALF_UP);
            case TIERED_BONUS -> BigDecimal.ZERO; // Commission only from bonus
        };
    }

    private BigDecimal calculateBonus(Agreement agreement, BigDecimal soldPercent) {
        if (agreement.getCommissionType() == CommissionType.TIERED_BONUS ||
                agreement.getBonusThresholdPercent() != null) {

            int threshold = agreement.getBonusThresholdPercent() != null
                    ? agreement.getBonusThresholdPercent()
                    : 0;

            if (soldPercent.compareTo(BigDecimal.valueOf(threshold)) >= 0) {
                return agreement.getBonusAmount() != null
                        ? agreement.getBonusAmount()
                        : BigDecimal.ZERO;
            }
        }
        return BigDecimal.ZERO;
    }

    private String buildCommissionBreakdown(Agreement agreement, int sold, BigDecimal commission) {
        return switch (agreement.getCommissionType()) {
            case PERCENTAGE -> String.format("%.2f%% × Rp%,.0f = Rp%,.0f",
                    agreement.getCommissionValue(),
                    commission.divide(
                            agreement.getCommissionValue().divide(BigDecimal.valueOf(100), 4, RoundingMode.HALF_UP), 2,
                            RoundingMode.HALF_UP),
                    commission);
            case FIXED_PER_ITEM -> String.format("Rp%,.0f × %d item = Rp%,.0f",
                    agreement.getCommissionValue(), sold, commission);
            case TIERED_BONUS -> "Bonus based on sales threshold";
        };
    }
}
