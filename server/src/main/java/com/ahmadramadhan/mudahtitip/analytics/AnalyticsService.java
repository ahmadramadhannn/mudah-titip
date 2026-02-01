package com.ahmadramadhan.mudahtitip.analytics;

import com.ahmadramadhan.mudahtitip.analytics.dto.EarningsBreakdownDTO;
import com.ahmadramadhan.mudahtitip.analytics.dto.TopProductDTO;
import com.ahmadramadhan.mudahtitip.analytics.dto.TrendDataDTO;
import com.ahmadramadhan.mudahtitip.sale.Sale;
import com.ahmadramadhan.mudahtitip.sale.SaleRepository;
import com.ahmadramadhan.mudahtitip.shop.Shop;
import com.ahmadramadhan.mudahtitip.shop.ShopRepository;
import com.ahmadramadhan.mudahtitip.auth.User;
import com.ahmadramadhan.mudahtitip.auth.UserRole;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Service for generating analytics data.
 */
@Service
@RequiredArgsConstructor
public class AnalyticsService {

    private final SaleRepository saleRepository;
    private final ShopRepository shopRepository;

    /**
     * Get daily sales trend for the user.
     */
    public List<TrendDataDTO> getDailySalesTrend(User user, LocalDate startDate, LocalDate endDate) {
        List<Sale> sales = getSalesForUser(user, startDate, endDate);

        // Group sales by date
        Map<LocalDate, List<Sale>> salesByDate = sales.stream()
                .collect(Collectors.groupingBy(
                        sale -> sale.getSoldAt().toLocalDate(),
                        TreeMap::new,
                        Collectors.toList()));

        // Generate trend data for each day in range
        List<TrendDataDTO> trends = new ArrayList<>();
        LocalDate current = startDate;
        while (!current.isAfter(endDate)) {
            List<Sale> daySales = salesByDate.getOrDefault(current, Collections.emptyList());

            BigDecimal totalAmount = daySales.stream()
                    .map(Sale::getTotalAmount)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);

            BigDecimal earnings = getEarningsForSales(user, daySales);

            int itemsSold = daySales.stream()
                    .mapToInt(Sale::getQuantitySold)
                    .sum();

            trends.add(TrendDataDTO.builder()
                    .date(current)
                    .salesCount(daySales.size())
                    .itemsSold(itemsSold)
                    .totalAmount(totalAmount)
                    .earnings(earnings)
                    .build());

            current = current.plusDays(1);
        }

        return trends;
    }

    /**
     * Get top performing products.
     */
    public List<TopProductDTO> getTopProducts(User user, int limit, LocalDate startDate, LocalDate endDate) {
        List<Sale> sales = getSalesForUser(user, startDate, endDate);

        // Group by product and aggregate
        Map<Long, List<Sale>> salesByProduct = sales.stream()
                .collect(Collectors.groupingBy(
                        sale -> sale.getConsignment().getProduct().getId()));

        boolean isShopOwner = user.getRole() == UserRole.SHOP_OWNER;

        List<TopProductDTO> topProducts = salesByProduct.entrySet().stream()
                .map(entry -> {
                    List<Sale> productSales = entry.getValue();
                    Sale firstSale = productSales.get(0);

                    int totalSold = productSales.stream()
                            .mapToInt(Sale::getQuantitySold)
                            .sum();

                    BigDecimal totalRevenue = productSales.stream()
                            .map(Sale::getTotalAmount)
                            .reduce(BigDecimal.ZERO, BigDecimal::add);

                    BigDecimal totalEarnings = productSales.stream()
                            .map(s -> isShopOwner ? s.getShopCommission() : s.getConsignorEarning())
                            .reduce(BigDecimal.ZERO, BigDecimal::add);

                    return TopProductDTO.builder()
                            .productId(entry.getKey())
                            .productName(firstSale.getConsignment().getProduct().getName())
                            .category(firstSale.getConsignment().getProduct().getCategory())
                            .totalSold(totalSold)
                            .totalRevenue(totalRevenue)
                            .totalEarnings(totalEarnings)
                            .build();
                })
                .sorted(Comparator.comparing(TopProductDTO::getTotalEarnings).reversed())
                .limit(limit)
                .toList();

        return topProducts;
    }

    /**
     * Get earnings breakdown by product.
     */
    public List<EarningsBreakdownDTO> getEarningsBreakdown(User user, LocalDate startDate, LocalDate endDate) {
        List<Sale> sales = getSalesForUser(user, startDate, endDate);
        boolean isShopOwner = user.getRole() == UserRole.SHOP_OWNER;

        // Calculate total earnings
        BigDecimal totalEarnings = sales.stream()
                .map(s -> isShopOwner ? s.getShopCommission() : s.getConsignorEarning())
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        if (totalEarnings.compareTo(BigDecimal.ZERO) == 0) {
            return Collections.emptyList();
        }

        // Group by product
        Map<Long, List<Sale>> salesByProduct = sales.stream()
                .collect(Collectors.groupingBy(
                        sale -> sale.getConsignment().getProduct().getId()));

        return salesByProduct.entrySet().stream()
                .map(entry -> {
                    List<Sale> productSales = entry.getValue();
                    Sale firstSale = productSales.get(0);

                    BigDecimal productEarnings = productSales.stream()
                            .map(s -> isShopOwner ? s.getShopCommission() : s.getConsignorEarning())
                            .reduce(BigDecimal.ZERO, BigDecimal::add);

                    double percentage = productEarnings
                            .divide(totalEarnings, 4, RoundingMode.HALF_UP)
                            .multiply(BigDecimal.valueOf(100))
                            .doubleValue();

                    return EarningsBreakdownDTO.builder()
                            .productId(entry.getKey())
                            .productName(firstSale.getConsignment().getProduct().getName())
                            .category(firstSale.getConsignment().getProduct().getCategory())
                            .earnings(productEarnings)
                            .percentage(percentage)
                            .build();
                })
                .sorted(Comparator.comparing(EarningsBreakdownDTO::getEarnings).reversed())
                .toList();
    }

    private List<Sale> getSalesForUser(User user, LocalDate startDate, LocalDate endDate) {
        LocalDateTime start = startDate.atStartOfDay();
        LocalDateTime end = endDate.atTime(LocalTime.MAX);

        if (user.getRole() == UserRole.SHOP_OWNER) {
            Long shopId = shopRepository.findByOwner(user)
                    .map(Shop::getId)
                    .orElseThrow(() -> new IllegalStateException("Toko tidak ditemukan"));
            return saleRepository.findByConsignmentShopIdAndSoldAtBetween(shopId, start, end);
        } else {
            return saleRepository.findByConsignmentProductOwnerIdAndSoldAtBetween(user.getId(), start, end);
        }
    }

    private BigDecimal getEarningsForSales(User user, List<Sale> sales) {
        boolean isShopOwner = user.getRole() == UserRole.SHOP_OWNER;
        return sales.stream()
                .map(s -> isShopOwner ? s.getShopCommission() : s.getConsignorEarning())
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }
}
