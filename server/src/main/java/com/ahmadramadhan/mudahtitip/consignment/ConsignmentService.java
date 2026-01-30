package com.ahmadramadhan.mudahtitip.consignment;

import com.ahmadramadhan.mudahtitip.auth.User;
import com.ahmadramadhan.mudahtitip.auth.UserRole;
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

    /**
     * Create a new consignment.
     */
    @Transactional
    public Consignment createConsignment(ConsignmentRequest request, User currentUser) {
        Product product = productRepository.findById(request.getProductId())
                .orElseThrow(() -> new IllegalArgumentException("Produk tidak ditemukan"));

        // Verify product ownership
        if (!product.getOwner().getId().equals(currentUser.getId())) {
            throw new IllegalArgumentException("Anda tidak memiliki akses ke produk ini");
        }

        Shop shop = shopRepository.findById(request.getShopId())
                .orElseThrow(() -> new IllegalArgumentException("Toko tidak ditemukan"));

        // Calculate expiry date if not provided
        LocalDate expiryDate = request.getExpiryDate();
        if (expiryDate == null && product.getShelfLifeDays() != null) {
            LocalDate startDate = request.getConsignmentDate() != null
                    ? request.getConsignmentDate()
                    : LocalDate.now();
            expiryDate = startDate.plusDays(product.getShelfLifeDays());
        }

        Consignment consignment = Consignment.builder()
                .product(product)
                .shop(shop)
                .initialQuantity(request.getQuantity())
                .currentQuantity(request.getQuantity())
                .sellingPrice(request.getSellingPrice())
                .commissionPercent(request.getCommissionPercent())
                .consignmentDate(request.getConsignmentDate() != null ? request.getConsignmentDate() : LocalDate.now())
                .expiryDate(expiryDate)
                .status(ConsignmentStatus.ACTIVE)
                .notes(request.getNotes())
                .build();

        return consignmentRepository.save(consignment);
    }

    /**
     * Get consignment by ID.
     */
    public Consignment getById(Long id) {
        return consignmentRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Titipan tidak ditemukan"));
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
            throw new IllegalArgumentException("Anda tidak memiliki akses ke titipan ini");
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
            throw new IllegalArgumentException("Stok tidak mencukupi");
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
}
