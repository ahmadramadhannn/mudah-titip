package com.ahmadramadhan.mudahtitip.product;

import com.ahmadramadhan.mudahtitip.auth.User;
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

    /**
     * Create a new product for a consignor.
     */
    @Transactional
    public Product createProduct(Product product, User owner) {
        product.setOwner(owner);
        product.setIsActive(true);
        return productRepository.save(product);
    }

    /**
     * Get all products owned by a consignor.
     */
    public List<Product> getProductsByOwner(Long ownerId) {
        return productRepository.findByOwnerId(ownerId);
    }

    /**
     * Get active products owned by a consignor.
     */
    public List<Product> getActiveProductsByOwner(Long ownerId) {
        return productRepository.findByOwnerIdAndIsActiveTrue(ownerId);
    }

    /**
     * Get a single product by ID.
     */
    public Product getById(Long id) {
        return productRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Produk tidak ditemukan"));
    }

    /**
     * Update a product.
     */
    @Transactional
    public Product updateProduct(Long id, Product updates, User currentUser) {
        Product product = getById(id);

        // Verify ownership
        if (!product.getOwner().getId().equals(currentUser.getId())) {
            throw new IllegalArgumentException("Anda tidak memiliki akses ke produk ini");
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

        if (!product.getOwner().getId().equals(currentUser.getId())) {
            throw new IllegalArgumentException("Anda tidak memiliki akses ke produk ini");
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
}
