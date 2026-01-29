package com.ahmadramadhan.mudahtitip.repositories;

import com.ahmadramadhan.mudahtitip.entities.Sale;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface SaleRepository extends JpaRepository<Sale, Long> {

    List<Sale> findByConsignmentId(Long consignmentId);

    List<Sale> findByConsignmentShopId(Long shopId);

    List<Sale> findByConsignmentProductOwnerId(Long ownerId);

    /**
     * Find sales within a date range for a shop.
     */
    List<Sale> findByConsignmentShopIdAndSoldAtBetween(
            Long shopId,
            LocalDateTime startDate,
            LocalDateTime endDate);

    /**
     * Find sales within a date range for a consignor.
     */
    List<Sale> findByConsignmentProductOwnerIdAndSoldAtBetween(
            Long ownerId,
            LocalDateTime startDate,
            LocalDateTime endDate);

    /**
     * Sum total shop commission for a shop within date range.
     */
    @Query("SELECT COALESCE(SUM(s.shopCommission), 0) FROM Sale s " +
            "WHERE s.consignment.shop.id = :shopId " +
            "AND s.soldAt BETWEEN :startDate AND :endDate")
    BigDecimal sumShopCommissionByShopAndDateRange(
            @Param("shopId") Long shopId,
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate);

    /**
     * Sum total consignor earnings within date range.
     */
    @Query("SELECT COALESCE(SUM(s.consignorEarning), 0) FROM Sale s " +
            "WHERE s.consignment.product.owner.id = :ownerId " +
            "AND s.soldAt BETWEEN :startDate AND :endDate")
    BigDecimal sumConsignorEarningByOwnerAndDateRange(
            @Param("ownerId") Long ownerId,
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate);
}
