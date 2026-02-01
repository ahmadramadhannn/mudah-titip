package com.ahmadramadhan.mudahtitip.analytics;

import com.ahmadramadhan.mudahtitip.analytics.dto.EarningsBreakdownDTO;
import com.ahmadramadhan.mudahtitip.analytics.dto.TopProductDTO;
import com.ahmadramadhan.mudahtitip.analytics.dto.TrendDataDTO;
import com.ahmadramadhan.mudahtitip.auth.User;
import com.ahmadramadhan.mudahtitip.common.config.ApiV1Controller;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

/**
 * Controller for analytics endpoints.
 */
@ApiV1Controller
@RequestMapping("/api/v1/analytics")
@RequiredArgsConstructor
public class AnalyticsController {

    private final AnalyticsService analyticsService;

    /**
     * Get daily sales/earnings trend.
     */
    @GetMapping("/trends")
    public ResponseEntity<List<TrendDataDTO>> getTrends(
            @AuthenticationPrincipal User currentUser,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {

        LocalDate start = startDate != null ? startDate : LocalDate.now().minusDays(30);
        LocalDate end = endDate != null ? endDate : LocalDate.now();

        List<TrendDataDTO> trends = analyticsService.getDailySalesTrend(currentUser, start, end);
        return ResponseEntity.ok(trends);
    }

    /**
     * Get top performing products.
     */
    @GetMapping("/top-products")
    public ResponseEntity<List<TopProductDTO>> getTopProducts(
            @AuthenticationPrincipal User currentUser,
            @RequestParam(defaultValue = "5") int limit,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {

        LocalDate start = startDate != null ? startDate : LocalDate.now().minusDays(30);
        LocalDate end = endDate != null ? endDate : LocalDate.now();

        List<TopProductDTO> topProducts = analyticsService.getTopProducts(currentUser, limit, start, end);
        return ResponseEntity.ok(topProducts);
    }

    /**
     * Get earnings breakdown by product.
     */
    @GetMapping("/breakdown")
    public ResponseEntity<List<EarningsBreakdownDTO>> getBreakdown(
            @AuthenticationPrincipal User currentUser,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {

        LocalDate start = startDate != null ? startDate : LocalDate.now().minusDays(30);
        LocalDate end = endDate != null ? endDate : LocalDate.now();

        List<EarningsBreakdownDTO> breakdown = analyticsService.getEarningsBreakdown(currentUser, start, end);
        return ResponseEntity.ok(breakdown);
    }
}
