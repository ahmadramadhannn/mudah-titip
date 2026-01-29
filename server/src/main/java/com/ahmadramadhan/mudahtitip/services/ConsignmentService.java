package com.ahmadramadhan.mudahtitip.services;

import com.ahmadramadhan.mudahtitip.dto.ConsignmentRequest;
import com.ahmadramadhan.mudahtitip.entities.Consignment;
import com.ahmadramadhan.mudahtitip.entities.ConsignmentStatus;
import com.ahmadramadhan.mudahtitip.entities.Product;
import com.ahmadramadhan.mudahtitip.entities.Shop;
import com.ahmadramadhan.mudahtitip.entities.User;
import com.ahmadramadhan.mudahtitip.repositories.ConsignmentRepository;
import com.ahmadramadhan.mudahtitip.repositories.ProductRepository;
import com.ahmadramadhan.mudahtitip.repositories.ShopRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

/**
 * Service handling consignment (titipan) operations.
 */
@Service
@RequiredArgsConstructor
public class ConsignmentService {

    private final ConsignmentRepository consignmentRepository;
    private final ProductRepository productRepository;
    private final ShopRepository shopRepository;

    /**
     * Create a new consignment.
     * Can be initiated by either consignor (product owner) or shop owner.
     */
    @Transactional
    public Consignment createConsignment(ConsignmentRequest request, User currentUser) {
        Product product = productRepository.findById(request.getProductId())
                .orElseThrow(() -> new IllegalArgumentException("Produk tidak ditemukan"));

        Shop shop = shopRepository.findById(request.getShopId())
                .orElseThrow(() -> new IllegalArgumentException("Toko tidak ditemukan"));

        // Calculate expiry date if not provided
        LocalDate expiryDate = request.getExpiryDate();
        if (expiryDate == null && product.getShelfLifeDays() != null && request.getProductionDate() != null) {
            expiryDate = request.getProductionDate().plusDays(product.getShelfLifeDays());
        }

        Consignment consignment = Consignment.builder()
                .product(product)
                .shop(shop)
                .initialQuantity(request.getQuantity())
                .currentQuantity(request.getQuantity())
                .sellingPrice(request.getSellingPrice())
                .commissionPercent(request.getCommissionPercent())
                .productionDate(request.getProductionDate())
                .expiryDate(expiryDate)
                .status(ConsignmentStatus.ACTIVE)
                .notes(request.getNotes())
                .build();

        return consignmentRepository.save(consignment);
    }

    /**
     * Get all consignments for a shop.
     */
    public List<Consignment> getConsignmentsByShop(Long shopId) {
        return consignmentRepository.findByShopId(shopId);
    }

    /**
     * Get all consignments for a shop filtered by status.
     */
    public List<Consignment> getConsignmentsByShopAndStatus(Long shopId, ConsignmentStatus status) {
        return consignmentRepository.findByShopIdAndStatus(shopId, status);
    }

    /**
     * Get all consignments for a consignor (product owner).
     */
    public List<Consignment> getConsignmentsByOwner(Long ownerId) {
        return consignmentRepository.findByProductOwnerId(ownerId);
    }

    /**
     * Get active consignments for a shop, ordered by expiry date.
     */
    public List<Consignment> getActiveConsignmentsForShop(Long shopId) {
        return consignmentRepository.findByShopIdAndStatusOrderByExpiryDateAsc(shopId, ConsignmentStatus.ACTIVE);
    }

    /**
     * Get consignments expiring within the given number of days.
     */
    public List<Consignment> getExpiringSoon(int withinDays) {
        LocalDate today = LocalDate.now();
        LocalDate threshold = today.plusDays(withinDays);
        return consignmentRepository.findExpiringSoon(today, threshold);
    }

    /**
     * Get a single consignment by ID.
     */
    public Consignment getById(Long id) {
        return consignmentRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Titipan tidak ditemukan"));
    }

    /**
     * Update consignment status (e.g., mark as expired, returned, completed).
     */
    @Transactional
    public Consignment updateStatus(Long id, ConsignmentStatus newStatus) {
        Consignment consignment = getById(id);
        consignment.setStatus(newStatus);
        return consignmentRepository.save(consignment);
    }

    /**
     * Reduce stock quantity when items are sold.
     * Called internally by SaleService.
     */
    @Transactional
    public void reduceStock(Long consignmentId, int quantity) {
        Consignment consignment = getById(consignmentId);

        if (consignment.getCurrentQuantity() < quantity) {
            throw new IllegalArgumentException("Stok tidak mencukupi");
        }

        consignment.setCurrentQuantity(consignment.getCurrentQuantity() - quantity);

        // Auto-complete if stock is depleted
        if (consignment.getCurrentQuantity() == 0) {
            consignment.setStatus(ConsignmentStatus.COMPLETED);
        }

        consignmentRepository.save(consignment);
    }
}
