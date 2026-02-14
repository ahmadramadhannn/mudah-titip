package com.ahmadramadhan.mudahtitip.product.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

/**
 * DTO for creating/updating a product.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProductRequest {

    @NotBlank(message = "Nama produk wajib diisi")
    @Size(min = 2, max = 100, message = "Nama produk harus antara 2-100 karakter")
    private String name;

    @Size(max = 500, message = "Deskripsi maksimal 500 karakter")
    private String description;

    @Size(max = 50, message = "Kategori maksimal 50 karakter")
    private String category;

    @Positive(message = "Masa simpan harus positif")
    private Integer shelfLifeDays;

    @NotNull(message = "Harga dasar wajib diisi")
    @Positive(message = "Harga harus positif")
    private BigDecimal basePrice;

    @NotNull(message = "Stok wajib diisi")
    @PositiveOrZero(message = "Stok tidak boleh negatif")
    private Integer stock;

    private String imageUrl;
}
