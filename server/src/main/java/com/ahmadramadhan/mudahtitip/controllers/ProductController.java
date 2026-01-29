package com.ahmadramadhan.mudahtitip.controllers;

import com.ahmadramadhan.mudahtitip.dto.ProductRequest;
import com.ahmadramadhan.mudahtitip.entities.Product;
import com.ahmadramadhan.mudahtitip.entities.User;
import com.ahmadramadhan.mudahtitip.services.ProductService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * REST controller for product management.
 * Only consignors can create/update their own products.
 */
@RestController
@RequestMapping("/api/products")
@RequiredArgsConstructor
public class ProductController {

    private final ProductService productService;

    @PostMapping
    @PreAuthorize("hasRole('CONSIGNOR')")
    public ResponseEntity<Product> createProduct(
            @Valid @RequestBody ProductRequest request,
            @AuthenticationPrincipal User currentUser) {
        Product product = Product.builder()
                .name(request.getName())
                .description(request.getDescription())
                .category(request.getCategory())
                .shelfLifeDays(request.getShelfLifeDays())
                .basePrice(request.getBasePrice())
                .imageUrl(request.getImageUrl())
                .build();

        Product created = productService.createProduct(product, currentUser);
        return ResponseEntity.ok(created);
    }

    @GetMapping("/my")
    @PreAuthorize("hasRole('CONSIGNOR')")
    public ResponseEntity<List<Product>> getMyProducts(@AuthenticationPrincipal User currentUser) {
        List<Product> products = productService.getActiveProductsByOwner(currentUser.getId());
        return ResponseEntity.ok(products);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Product> getProduct(@PathVariable Long id) {
        Product product = productService.getById(id);
        return ResponseEntity.ok(product);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('CONSIGNOR')")
    public ResponseEntity<Product> updateProduct(
            @PathVariable Long id,
            @Valid @RequestBody ProductRequest request,
            @AuthenticationPrincipal User currentUser) {
        Product updates = Product.builder()
                .name(request.getName())
                .description(request.getDescription())
                .category(request.getCategory())
                .shelfLifeDays(request.getShelfLifeDays())
                .basePrice(request.getBasePrice())
                .imageUrl(request.getImageUrl())
                .build();

        Product updated = productService.updateProduct(id, updates, currentUser);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('CONSIGNOR')")
    public ResponseEntity<Void> deleteProduct(
            @PathVariable Long id,
            @AuthenticationPrincipal User currentUser) {
        productService.deactivateProduct(id, currentUser);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/search")
    public ResponseEntity<List<Product>> searchProducts(@RequestParam String name) {
        List<Product> products = productService.searchByName(name);
        return ResponseEntity.ok(products);
    }
}
