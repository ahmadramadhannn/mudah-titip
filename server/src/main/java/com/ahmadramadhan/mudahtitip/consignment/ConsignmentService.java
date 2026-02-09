package com.ahmadramadhan.mudahtitip.consignment;

import com.ahmadramadhan.mudahtitip.agreement.AgreementRepository;
import com.ahmadramadhan.mudahtitip.agreement.AgreementStatus;
import com.ahmadramadhan.mudahtitip.auth.User;
import com.ahmadramadhan.mudahtitip.auth.UserRole;
import com.ahmadramadhan.mudahtitip.common.MessageService;
import com.ahmadramadhan.mudahtitip.consignment.dto.ConsignmentRequest;
import com.ahmadramadhan.mudahtitip.product.Product;
import com.ahmadramadhan.mudahtitip.product.ProductRepository;
import com.ahmadramadhan.mudahtitip.shop.Shop;
import com.ahmadramadhan.mudahtitip.shop.ShopRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

/**
 * Service handling consignment operations.
 */
@Service
@RequiredArgsConstructor
public class ConsignmentService {

    private final ConsignmentRepository consignmentRepository;
    private final ProductRepository productRepository;
    private final ShopRepository shopRepository;
    private final MessageService messageService;
    private final AgreementRepository agreementRepository;

    /**
     * Create a new consignment.
     * Consignors: creates ACTIVE consignment for their own products
     * Shop owners: creates PENDING consignment for products they want to sell
     */
    @Transactional
    public Consignment createConsignment(ConsignmentRequest request, User currentUser) {
        if (currentUser.getRole() == UserRole.SHOP_OWNER) {
            return createConsignmentByShopOwner(request, currentUser);
        } else if (currentUser.getRole() == UserRole.CONSIGNOR) {
            return createConsignmentByConsignor(request, currentUser);
        } else {
            throw new IllegalArgumentException(messageService.getMessage("consignment.role.invalid"));
        }
    }

    /**
     * Create consignment initiated by consignor (original flow).
     */
    @Transactional
    private Consignment createConsignmentByConsignor(ConsignmentRequest request, User consignor) {
        Product product = productRepository.findById(request.getProductId())
                .orElseThrow(() -> new IllegalArgumentException(messageService.getMessage("product.not.found")));

        // Verify product ownership
        if (!product.getOwner().getId().equals(consignor.getId())) {
            throw new IllegalArgumentException(messageService.getMessage("product.access.denied"));
        }

        Shop shop = shopRepository.findById(request.getShopId())
                .orElseThrow(() -> new IllegalArgumentException(messageService.getMessage("shop.not.found")));

        LocalDate expiryDate = calculateExpiryDate(product, request);

        Consignment consignment = Consignment.builder()
                .product(product)
                .shop(shop)
                .initialQuantity(request.getQuantity())
                .currentQuantity(request.getQuantity())
                .sellingPrice(request.getSellingPrice())
                .commissionPercent(request.getCommissionPercent() != null ? request.getCommissionPercent()
                        : java.math.BigDecimal.ZERO)
                .consignmentDate(request.getConsignmentDate() != null ? request.getConsignmentDate() : LocalDate.now())
                .expiryDate(expiryDate)
                .status(ConsignmentStatus.ACTIVE)
                .notes(request.getNotes())
                .build();

        return consignmentRepository.save(consignment);
    }

    /**
     * Create consignment initiated by shop owner (new flow).
     * Creates PENDING consignment that becomes ACTIVE when agreement is accepted.
     */
    @Transactional
    private Consignment createConsignmentByShopOwner(ConsignmentRequest request, User shopOwner) {
        Product product = productRepository.findById(request.getProductId())
                .orElseThrow(() -> new IllegalArgumentException(messageService.getMessage("product.not.found")));

        // Get shop owner's shop
        Shop shop = shopOwner.getShop();
        if (shop == null) {
            throw new IllegalStateException(messageService.getMessage("shop.not.found"));
        }

        LocalDate expiryDate = calculateExpiryDate(product, request);

        Consignment consignment = Consignment.builder()
                .product(product)
                .shop(shop)
                .initialQuantity(request.getQuantity())
                .currentQuantity(request.getQuantity())
                .sellingPrice(request.getSellingPrice())
                .commissionPercent(request.getCommissionPercent() != null ? request.getCommissionPercent()
                        : java.math.BigDecimal.ZERO)
                .consignmentDate(LocalDate.now())
                .expiryDate(expiryDate)
                .status(ConsignmentStatus.PENDING) // PENDING until agreement accepted
                .notes(request.getNotes())
                .build();

        return consignmentRepository.save(consignment);
    }

    /**
     * Calculate expiry date based on product shelf life and consignment date.
     */
    private LocalDate calculateExpiryDate(Product product, ConsignmentRequest request) {
        LocalDate expiryDate = request.getExpiryDate();
        if (expiryDate == null && product.getShelfLifeDays() != null) {
            LocalDate startDate = request.getConsignmentDate() != null
                    ? request.getConsignmentDate()
                    : LocalDate.now();
            expiryDate = startDate.plusDays(product.getShelfLifeDays());
        }
        return expiryDate;
    }

    /**
     * Get consignment by ID.
     */
    public Consignment getById(Long id) {
        return consignmentRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException(messageService.getMessage("consignment.not.found")));
    }

    /**
     * Get consignments for current user based on role.
     */
    public List<Consignment> getConsignmentsForUser(User user, ConsignmentStatus status) {
        if (user.getRole() == UserRole.SHOP_OWNER) {
            if (status != null) {
                return consignmentRepository.findByShopOwnerIdAndStatus(user.getId(), status);
            }
            return consignmentRepository.findByShopOwnerId(user.getId());
        } else {
            if (status != null) {
                return consignmentRepository.findByProductOwnerIdAndStatus(user.getId(), status);
            }
            return consignmentRepository.findByProductOwnerId(user.getId());
        }
    }

    /**
     * Update consignment status.
     */
    @Transactional
    public Consignment updateStatus(Long id, ConsignmentStatus newStatus, User currentUser) {
        Consignment consignment = getById(id);

        // Verify access
        boolean hasAccess = consignment.getProduct().getOwner().getId().equals(currentUser.getId())
                || consignment.getShop().getOwner().getId().equals(currentUser.getId());

        if (!hasAccess) {
            throw new IllegalArgumentException(messageService.getMessage("consignment.access.denied"));
        }

        consignment.setStatus(newStatus);
        return consignmentRepository.save(consignment);
    }

    /**
     * Reduce stock after a sale.
     */
    @Transactional
    public void reduceStock(Long consignmentId, int quantity) {
        Consignment consignment = getById(consignmentId);

        if (consignment.getCurrentQuantity() < quantity) {
            throw new IllegalArgumentException(messageService.getMessage("consignment.stock.insufficient"));
        }

        consignment.setCurrentQuantity(consignment.getCurrentQuantity() - quantity);

        // Auto-complete if all sold
        if (consignment.getCurrentQuantity() == 0) {
            consignment.setStatus(ConsignmentStatus.COMPLETED);
        }

        consignmentRepository.save(consignment);
    }

    /**
     * Find consignments expiring within given days.
     */
    public List<Consignment> findExpiringSoon(int days) {
        LocalDate today = LocalDate.now();
        LocalDate futureDate = today.plusDays(days);
        return consignmentRepository.findExpiringSoon(today, futureDate);
    }

    /**
     * Get consignments without an accepted agreement (eligible for agreement
     * proposal).
     */
    public List<Consignment> getConsignmentsWithoutAgreement(User user) {
        List<Consignment> consignments = getConsignmentsForUser(user, ConsignmentStatus.ACTIVE);
        // Filter to only those without an accepted agreement
        return consignments.stream()
                .filter(c -> !hasAcceptedAgreement(c.getId()))
                .toList();
    }

    private boolean hasAcceptedAgreement(Long consignmentId) {
        return agreementRepository.findByConsignmentIdAndStatus(
                consignmentId, AgreementStatus.ACCEPTED).isPresent();
    }
}
