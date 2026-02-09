package com.ahmadramadhan.mudahtitip.product;

import com.ahmadramadhan.mudahtitip.auth.User;
import com.ahmadramadhan.mudahtitip.auth.UserRole;
import com.ahmadramadhan.mudahtitip.common.MessageService;
import com.ahmadramadhan.mudahtitip.consignor.GuestConsignor;
import com.ahmadramadhan.mudahtitip.consignor.GuestConsignorRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * Service handling product operations for consignors.
 */
@Service
@RequiredArgsConstructor
public class ProductService {

    private final ProductRepository productRepository;
    private final GuestConsignorRepository guestConsignorRepository;
    private final MessageService messageService;

    /**
     * Create a new product for a registered consignor.
     */
    @Transactional
    public Product createProduct(Product product, User owner) {
        product.setOwner(owner);
        product.setGuestOwner(null);
        product.setIsActive(true);
        return productRepository.save(product);
    }

    /**
     * Create a new product for a guest consignor.
     * Only shop owners can do this.
     */
    @Transactional
    public Product createProductForGuest(Product product, Long guestConsignorId, User shopOwner) {
        if (shopOwner.getRole() != UserRole.SHOP_OWNER) {
            throw new IllegalStateException(messageService.getMessage("product.owner.required"));
        }

        GuestConsignor guestConsignor = guestConsignorRepository.findByIdAndManagedBy(guestConsignorId, shopOwner)
                .filter(GuestConsignor::getIsActive)
                .orElseThrow(() -> new IllegalArgumentException(messageService.getMessage("consignor.not.found")));

        product.setOwner(null);
        product.setGuestOwner(guestConsignor);
        product.setIsActive(true);
        return productRepository.save(product);
    }

    /**
     * Get all products owned by a registered consignor.
     */
    public List<Product> getProductsByOwner(Long ownerId) {
        return productRepository.findByOwnerId(ownerId);
    }

    /**
     * Get active products owned by a registered consignor.
     */
    public List<Product> getActiveProductsByOwner(Long ownerId) {
        return productRepository.findByOwnerIdAndIsActiveTrue(ownerId);
    }

    /**
     * Get products for a guest consignor.
     */
    public List<Product> getProductsByGuestOwner(Long guestOwnerId) {
        return productRepository.findByGuestOwnerIdAndIsActiveTrue(guestOwnerId);
    }

    /**
     * Get a single product by ID.
     */
    public Product getById(Long id) {
        return productRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException(messageService.getMessage("product.not.found")));
    }

    /**
     * Update a product.
     */
    @Transactional
    public Product updateProduct(Long id, Product updates, User currentUser) {
        Product product = getById(id);

        // Verify ownership (user owner or managed guest owner)
        if (!canUserEditProduct(product, currentUser)) {
            throw new IllegalArgumentException(messageService.getMessage("product.access.denied"));
        }

        if (updates.getName() != null)
            product.setName(updates.getName());
        if (updates.getDescription() != null)
            product.setDescription(updates.getDescription());
        if (updates.getCategory() != null)
            product.setCategory(updates.getCategory());
        if (updates.getShelfLifeDays() != null)
            product.setShelfLifeDays(updates.getShelfLifeDays());
        if (updates.getBasePrice() != null)
            product.setBasePrice(updates.getBasePrice());
        if (updates.getImageUrl() != null)
            product.setImageUrl(updates.getImageUrl());

        return productRepository.save(product);
    }

    /**
     * Deactivate a product (soft delete).
     */
    @Transactional
    public void deactivateProduct(Long id, User currentUser) {
        Product product = getById(id);

        if (!canUserEditProduct(product, currentUser)) {
            throw new IllegalArgumentException(messageService.getMessage("product.access.denied"));
        }

        product.setIsActive(false);
        productRepository.save(product);
    }

    /**
     * Search products by name.
     */
    public List<Product> searchByName(String name) {
        return productRepository.findByNameContainingIgnoreCase(name);
    }

    /**
     * Get all available products for shop owners to browse.
     * Returns all active products.
     */
    public List<Product> getAvailableForShopOwner(String category) {
        List<Product> products = productRepository.findByIsActiveTrue();

        // Filter by category if provided
        if (category != null && !category.isBlank()) {
            return products.stream()
                    .filter(p -> category.equals(p.getCategory()))
                    .toList();
        }

        return products;
    }

    /**
     * Check if user can edit a product.
     * User can edit if they own it directly, or if they manage the guest owner.
     */
    private boolean canUserEditProduct(Product product, User user) {
        // Direct owner check
        if (product.getOwner() != null && product.getOwner().getId().equals(user.getId())) {
            return true;
        }

        // Guest owner check (shop owner manages the guest)
        if (product.getGuestOwner() != null && user.getRole() == UserRole.SHOP_OWNER) {
            return product.getGuestOwner().getManagedBy().getId().equals(user.getId());
        }

        return false;
    }
}
