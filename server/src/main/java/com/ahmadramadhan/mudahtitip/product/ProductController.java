package com.ahmadramadhan.mudahtitip.product;

import com.ahmadramadhan.mudahtitip.auth.User;
import com.ahmadramadhan.mudahtitip.product.dto.ProductRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import com.ahmadramadhan.mudahtitip.common.config.ApiV1Controller;

import java.util.List;

/**
 * REST controller for product management.
 * Consignors can create/update their own products.
 * Shop owners can create/update products for their guest consignors.
 */
@ApiV1Controller
@RequestMapping("/api/v1/products")
@RequiredArgsConstructor
public class ProductController {

    private final ProductService productService;

    /**
     * Create a product for the current consignor.
     */
    @PostMapping
    @PreAuthorize("hasRole('CONSIGNOR')")
    public ResponseEntity<Product> createProduct(
            @Valid @RequestBody ProductRequest request,
            @AuthenticationPrincipal User currentUser) {
        Product product = buildProductFromRequest(request);
        Product created = productService.createProduct(product, currentUser);
        return ResponseEntity.ok(created);
    }

    /**
     * Create a product for a guest consignor (shop owner only).
     */
    @PostMapping("/for-guest/{guestConsignorId}")
    @PreAuthorize("hasRole('SHOP_OWNER')")
    public ResponseEntity<Product> createProductForGuest(
            @PathVariable Long guestConsignorId,
            @Valid @RequestBody ProductRequest request,
            @AuthenticationPrincipal User currentUser) {
        Product product = buildProductFromRequest(request);
        Product created = productService.createProductForGuest(product, guestConsignorId, currentUser);
        return ResponseEntity.ok(created);
    }

    /**
     * Get products for the current consignor.
     */
    @GetMapping("/my")
    @PreAuthorize("hasRole('CONSIGNOR')")
    public ResponseEntity<List<Product>> getMyProducts(@AuthenticationPrincipal User currentUser) {
        List<Product> products = productService.getActiveProductsByOwner(currentUser.getId());
        return ResponseEntity.ok(products);
    }

    /**
     * Get products for a guest consignor (shop owner only).
     */
    @GetMapping("/guest/{guestConsignorId}")
    @PreAuthorize("hasRole('SHOP_OWNER')")
    public ResponseEntity<List<Product>> getGuestProducts(@PathVariable Long guestConsignorId) {
        List<Product> products = productService.getProductsByGuestOwner(guestConsignorId);
        return ResponseEntity.ok(products);
    }

    /**
     * Get a single product by ID.
     */
    @GetMapping("/{id}")
    public ResponseEntity<Product> getProduct(@PathVariable Long id) {
        Product product = productService.getById(id);
        return ResponseEntity.ok(product);
    }

    /**
     * Update a product (consignor or shop owner for guest products).
     */
    @PutMapping("/{id}")
    public ResponseEntity<Product> updateProduct(
            @PathVariable Long id,
            @Valid @RequestBody ProductRequest request,
            @AuthenticationPrincipal User currentUser) {
        Product updates = buildProductFromRequest(request);
        Product updated = productService.updateProduct(id, updates, currentUser);
        return ResponseEntity.ok(updated);
    }

    /**
     * Delete (deactivate) a product.
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteProduct(
            @PathVariable Long id,
            @AuthenticationPrincipal User currentUser) {
        productService.deactivateProduct(id, currentUser);
        return ResponseEntity.noContent().build();
    }

    /**
     * Search products by name.
     */
    @GetMapping("/search")
    public ResponseEntity<List<Product>> searchProducts(@RequestParam String name) {
        List<Product> products = productService.searchByName(name);
        return ResponseEntity.ok(products);
    }

    /**
     * Get all available products for shop owners to browse.
     */
    @GetMapping("/available")
    @PreAuthorize("hasRole('SHOP_OWNER')")
    public ResponseEntity<List<Product>> getAvailableProducts(
            @RequestParam(required = false) String category) {
        List<Product> products = productService.getAvailableForShopOwner(category);
        return ResponseEntity.ok(products);
    }

    private Product buildProductFromRequest(ProductRequest request) {
        return Product.builder()
                .name(request.getName())
                .description(request.getDescription())
                .category(request.getCategory())
                .shelfLifeDays(request.getShelfLifeDays())
                .basePrice(request.getBasePrice())
                .stock(request.getStock())
                .imageUrl(request.getImageUrl())
                .build();
    }
}
