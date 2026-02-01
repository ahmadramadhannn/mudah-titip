package com.ahmadramadhan.mudahtitip.sale;

import com.ahmadramadhan.mudahtitip.auth.User;
import com.ahmadramadhan.mudahtitip.auth.UserRole;
import com.ahmadramadhan.mudahtitip.sale.dto.SaleRequest;
import com.ahmadramadhan.mudahtitip.shop.ShopRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import com.ahmadramadhan.mudahtitip.common.config.ApiV1Controller;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * REST controller for sale operations.
 */
@ApiV1Controller
@RequestMapping("/api/v1/sales")
@RequiredArgsConstructor
public class SaleController {

    private final SaleService saleService;
    private final ShopRepository shopRepository;

    /**
     * Record a new sale. Only shop owners can record sales.
     */
    @PostMapping
    @PreAuthorize("hasRole('SHOP_OWNER')")
    public ResponseEntity<Sale> recordSale(@RequestBody SaleRequest request) {
        Sale sale = saleService.recordSale(request);
        return ResponseEntity.ok(sale);
    }

    /**
     * Get sales for current user.
     * Shop owners see sales at their shop.
     * Consignors see sales of their products.
     */
    @GetMapping("/my")
    public ResponseEntity<List<Sale>> getMySales(
            @AuthenticationPrincipal User currentUser,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        LocalDateTime start = startDate != null ? startDate.atStartOfDay()
                : LocalDate.now().minusMonths(1).atStartOfDay();
        LocalDateTime end = endDate != null ? endDate.atTime(LocalTime.MAX) : LocalDate.now().atTime(LocalTime.MAX);

        if (currentUser.getRole() == UserRole.SHOP_OWNER) {
            Long shopId = shopRepository.findByOwner(currentUser)
                    .map(shop -> shop.getId())
                    .orElseThrow(() -> new IllegalStateException("Toko tidak ditemukan"));

            return ResponseEntity.ok(saleService.getSalesByShopAndDateRange(shopId, start, end));
        } else {
            return ResponseEntity.ok(saleService.getSalesByOwnerAndDateRange(currentUser.getId(), start, end));
        }
    }

    /**
     * Get earnings summary for current user.
     */
    @GetMapping("/summary")
    public ResponseEntity<Map<String, Object>> getEarningsSummary(
            @AuthenticationPrincipal User currentUser,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        LocalDateTime start = startDate != null ? startDate.atStartOfDay()
                : LocalDate.now().minusMonths(1).atStartOfDay();
        LocalDateTime end = endDate != null ? endDate.atTime(LocalTime.MAX) : LocalDate.now().atTime(LocalTime.MAX);

        Map<String, Object> summary = new HashMap<>();

        if (currentUser.getRole() == UserRole.SHOP_OWNER) {
            Long shopId = shopRepository.findByOwner(currentUser)
                    .map(shop -> shop.getId())
                    .orElseThrow(() -> new IllegalStateException("Toko tidak ditemukan"));

            BigDecimal totalCommission = saleService.getTotalShopCommission(shopId, start, end);
            List<Sale> sales = saleService.getSalesByShopAndDateRange(shopId, start, end);

            summary.put("totalEarnings", totalCommission);
            summary.put("totalSales", sales.size());
            summary.put("totalItemsSold", sales.stream().mapToInt(Sale::getQuantitySold).sum());
        } else {
            BigDecimal totalEarnings = saleService.getTotalConsignorEarnings(currentUser.getId(), start, end);
            List<Sale> sales = saleService.getSalesByOwnerAndDateRange(currentUser.getId(), start, end);

            summary.put("totalEarnings", totalEarnings);
            summary.put("totalSales", sales.size());
            summary.put("totalItemsSold", sales.stream().mapToInt(Sale::getQuantitySold).sum());
        }

        summary.put("startDate", start.toLocalDate());
        summary.put("endDate", end.toLocalDate());

        return ResponseEntity.ok(summary);
    }
}
