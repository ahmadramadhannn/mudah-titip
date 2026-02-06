package com.ahmadramadhan.mudahtitip.sale;

import com.ahmadramadhan.mudahtitip.common.MessageService;
import com.ahmadramadhan.mudahtitip.consignment.Consignment;
import com.ahmadramadhan.mudahtitip.consignment.ConsignmentService;
import com.ahmadramadhan.mudahtitip.notification.NotificationService;
import com.ahmadramadhan.mudahtitip.sale.dto.SaleRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.List;

/**
 * Service handling sale operations with automatic commission calculation.
 */
@Service
@RequiredArgsConstructor
public class SaleService {

    private final SaleRepository saleRepository;
    private final ConsignmentService consignmentService;
    private final MessageService messageService;
    private final NotificationService notificationService;

    /**
     * Record a sale for a consignment.
     * Automatically calculates:
     * - Total amount (quantity * selling price)
     * - Shop commission (total * commission percent / 100)
     * - Consignor earning (total - commission)
     */
    @Transactional
    public Sale recordSale(SaleRequest request) {
        Consignment consignment = consignmentService.getById(request.getConsignmentId());

        // Validate stock availability
        if (consignment.getCurrentQuantity() < request.getQuantity()) {
            throw new IllegalArgumentException(
                    messageService.getMessage("consignment.stock.insufficient.detail",
                            consignment.getCurrentQuantity(), request.getQuantity()));
        }

        // Calculate amounts
        BigDecimal quantity = BigDecimal.valueOf(request.getQuantity());
        BigDecimal totalAmount = consignment.getSellingPrice().multiply(quantity);

        BigDecimal commissionRate = consignment.getCommissionPercent()
                .divide(BigDecimal.valueOf(100), 4, RoundingMode.HALF_UP);
        BigDecimal shopCommission = totalAmount.multiply(commissionRate)
                .setScale(2, RoundingMode.HALF_UP);
        BigDecimal consignorEarning = totalAmount.subtract(shopCommission);

        // Create sale record
        Sale sale = Sale.builder()
                .consignment(consignment)
                .quantitySold(request.getQuantity())
                .totalAmount(totalAmount)
                .shopCommission(shopCommission)
                .consignorEarning(consignorEarning)
                .soldAt(LocalDateTime.now())
                .notes(request.getNotes())
                .build();

        sale = saleRepository.save(sale);

        // Reduce stock
        consignmentService.reduceStock(consignment.getId(), request.getQuantity());

        // Notify consignor about the sale
        notificationService.notifySaleRecorded(sale);

        return sale;
    }

    /**
     * Get all sales for a shop.
     */
    public List<Sale> getSalesByShop(Long shopId) {
        return saleRepository.findByConsignmentShopId(shopId);
    }

    /**
     * Get all sales for a consignor.
     */
    public List<Sale> getSalesByOwner(Long ownerId) {
        return saleRepository.findByConsignmentProductOwnerId(ownerId);
    }

    /**
     * Get sales for a shop within a date range.
     */
    public List<Sale> getSalesByShopAndDateRange(Long shopId, LocalDateTime start, LocalDateTime end) {
        return saleRepository.findByConsignmentShopIdAndSoldAtBetween(shopId, start, end);
    }

    /**
     * Get sales for a consignor within a date range.
     */
    public List<Sale> getSalesByOwnerAndDateRange(Long ownerId, LocalDateTime start, LocalDateTime end) {
        return saleRepository.findByConsignmentProductOwnerIdAndSoldAtBetween(ownerId, start, end);
    }

    /**
     * Get total shop commission for a shop within a date range.
     */
    public BigDecimal getTotalShopCommission(Long shopId, LocalDateTime start, LocalDateTime end) {
        return saleRepository.sumShopCommissionByShopAndDateRange(shopId, start, end);
    }

    /**
     * Get total consignor earnings within a date range.
     */
    public BigDecimal getTotalConsignorEarnings(Long ownerId, LocalDateTime start, LocalDateTime end) {
        return saleRepository.sumConsignorEarningByOwnerAndDateRange(ownerId, start, end);
    }
}
