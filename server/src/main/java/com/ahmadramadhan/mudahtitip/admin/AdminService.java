package com.ahmadramadhan.mudahtitip.admin;

import com.ahmadramadhan.mudahtitip.admin.dto.*;
import com.ahmadramadhan.mudahtitip.auth.User;
import com.ahmadramadhan.mudahtitip.auth.UserRepository;
import com.ahmadramadhan.mudahtitip.auth.UserRole;
import com.ahmadramadhan.mudahtitip.auth.UserStatus;
import com.ahmadramadhan.mudahtitip.consignment.ConsignmentRepository;
import com.ahmadramadhan.mudahtitip.consignment.ConsignmentStatus;
import com.ahmadramadhan.mudahtitip.product.ProductRepository;
import com.ahmadramadhan.mudahtitip.shop.Shop;
import com.ahmadramadhan.mudahtitip.shop.ShopRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Service for admin operations.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class AdminService {

    private final UserRepository userRepository;
    private final ShopRepository shopRepository;
    private final ProductRepository productRepository;
    private final ConsignmentRepository consignmentRepository;

    // ============================================================
    // User Management
    // ============================================================

    /**
     * Get all users with optional filtering.
     */
    public Page<UserAdminDto> getAllUsers(UserRole role, String status, Pageable pageable) {
        List<User> users;

        if (role != null && status != null) {
            UserStatus userStatus = UserStatus.valueOf(status.toUpperCase());
            users = userRepository.findAll().stream()
                    .filter(u -> u.getRole() == role && u.getStatus() == userStatus)
                    .collect(Collectors.toList());
        } else if (role != null) {
            users = userRepository.findAll().stream()
                    .filter(u -> u.getRole() == role)
                    .collect(Collectors.toList());
        } else if (status != null) {
            UserStatus userStatus = UserStatus.valueOf(status.toUpperCase());
            users = userRepository.findAll().stream()
                    .filter(u -> u.getStatus() == userStatus)
                    .collect(Collectors.toList());
        } else {
            users = userRepository.findAll();
        }

        List<UserAdminDto> dtos = users.stream()
                .map(this::mapToUserAdminDto)
                .collect(Collectors.toList());

        int start = (int) pageable.getOffset();
        int end = Math.min((start + pageable.getPageSize()), dtos.size());

        return new PageImpl<>(dtos.subList(start, end), pageable, dtos.size());
    }

    /**
     * Get detailed user information.
     */
    public UserAdminDto getUserDetails(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        return mapToUserAdminDto(user);
    }

    /**
     * Suspend a user account.
     */
    @Transactional
    public void suspendUser(Long userId, String reason) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        user.setStatus(UserStatus.SUSPENDED);
        user.setSuspensionReason(reason);
        userRepository.save(user);

        log.info("User {} suspended. Reason: {}", user.getEmail(), reason);
    }

    /**
     * Activate a suspended user account.
     */
    @Transactional
    public void activateUser(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        user.setStatus(UserStatus.ACTIVE);
        user.setSuspensionReason(null);
        userRepository.save(user);

        log.info("User {} activated", user.getEmail());
    }

    /**
     * Ban a user account permanently.
     */
    @Transactional
    public void banUser(Long userId, String reason) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        user.setStatus(UserStatus.BANNED);
        user.setSuspensionReason(reason);
        userRepository.save(user);

        log.info("User {} banned. Reason: {}", user.getEmail(), reason);
    }

    // ============================================================
    // Shop Management
    // ============================================================

    /**
     * Get all shops with optional filtering.
     */
    public Page<ShopAdminDto> getAllShops(Boolean verified, Pageable pageable) {
        List<Shop> shops;

        if (verified != null) {
            shops = shopRepository.findAll().stream()
                    .filter(s -> s.getIsVerified().equals(verified))
                    .collect(Collectors.toList());
        } else {
            shops = shopRepository.findAll();
        }

        List<ShopAdminDto> dtos = shops.stream()
                .map(this::mapToShopAdminDto)
                .collect(Collectors.toList());

        int start = (int) pageable.getOffset();
        int end = Math.min((start + pageable.getPageSize()), dtos.size());

        return new PageImpl<>(dtos.subList(start, end), pageable, dtos.size());
    }

    /**
     * Get shops pending verification.
     */
    public List<ShopAdminDto> getPendingVerifications() {
        return shopRepository.findAll().stream()
                .filter(shop -> !shop.getIsVerified())
                .map(this::mapToShopAdminDto)
                .collect(Collectors.toList());
    }

    /**
     * Verify a shop.
     */
    @Transactional
    public void verifyShop(Long shopId, String message) {
        Shop shop = shopRepository.findById(shopId)
                .orElseThrow(() -> new RuntimeException("Shop not found"));

        shop.setIsVerified(true);
        shop.setVerificationMessage(message);
        shop.setVerifiedAt(LocalDateTime.now());
        shopRepository.save(shop);

        log.info("Shop {} verified", shop.getName());
    }

    /**
     * Reject a shop verification.
     */
    @Transactional
    public void rejectShop(Long shopId, String message) {
        Shop shop = shopRepository.findById(shopId)
                .orElseThrow(() -> new RuntimeException("Shop not found"));

        shop.setIsVerified(false);
        shop.setVerificationMessage(message);
        shopRepository.save(shop);

        log.info("Shop {} verification rejected", shop.getName());
    }

    // ============================================================
    // Analytics
    // ============================================================

    /**
     * Get platform-wide metrics.
     */
    public PlatformMetricsDto getPlatformMetrics() {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime sevenDaysAgo = now.minusDays(7);
        LocalDateTime monthStart = now.withDayOfMonth(1).withHour(0).withMinute(0).withSecond(0);

        // User metrics
        long totalUsers = userRepository.count();
        long totalShopOwners = userRepository.findAll().stream()
                .filter(u -> u.getRole() == UserRole.SHOP_OWNER)
                .count();
        long totalConsignors = userRepository.findAll().stream()
                .filter(u -> u.getRole() == UserRole.CONSIGNOR)
                .count();
        long activeUsersLast7Days = userRepository.findAll().stream()
                .filter(u -> u.getLastLoginAt() != null && u.getLastLoginAt().isAfter(sevenDaysAgo))
                .count();
        long newUsersThisMonth = userRepository.findAll().stream()
                .filter(u -> u.getCreatedAt().isAfter(monthStart))
                .count();

        // Shop metrics
        long totalShops = shopRepository.count();
        long activeShops = shopRepository.findAll().stream()
                .filter(Shop::getIsActive)
                .count();
        long pendingVerifications = shopRepository.findAll().stream()
                .filter(s -> !s.getIsVerified())
                .count();

        // Product metrics
        long totalProducts = productRepository.count();
        long activeProducts = productRepository.findAll().stream()
                .filter(p -> p.getIsActive())
                .count();

        // Consignment metrics
        long totalConsignments = consignmentRepository.count();
        long activeConsignments = consignmentRepository.findAll().stream()
                .filter(c -> c.getStatus() == ConsignmentStatus.ACTIVE)
                .count();
        long expiringConsignments = consignmentRepository.findAll().stream()
                .filter(c -> c.getStatus() == ConsignmentStatus.ACTIVE
                        && c.getExpiryDate() != null
                        && c.getExpiryDate().isBefore(LocalDate.now().plusDays(7)))
                .count();

        // Financial metrics (placeholder - will be calculated from sales)
        BigDecimal totalGMV = BigDecimal.ZERO;
        BigDecimal monthlyGMV = BigDecimal.ZERO;
        BigDecimal platformRevenue = BigDecimal.ZERO;
        long totalTransactions = 0L;

        // Growth metrics (placeholder)
        double userGrowthRate = 0.0;
        double revenueGrowthRate = 0.0;

        return PlatformMetricsDto.builder()
                .totalUsers(totalUsers)
                .totalShopOwners(totalShopOwners)
                .totalConsignors(totalConsignors)
                .activeUsersLast7Days(activeUsersLast7Days)
                .newUsersThisMonth(newUsersThisMonth)
                .totalShops(totalShops)
                .activeShops(activeShops)
                .pendingVerifications(pendingVerifications)
                .totalProducts(totalProducts)
                .activeProducts(activeProducts)
                .totalConsignments(totalConsignments)
                .activeConsignments(activeConsignments)
                .expiringConsignments(expiringConsignments)
                .totalGMV(totalGMV)
                .monthlyGMV(monthlyGMV)
                .platformRevenue(platformRevenue)
                .totalTransactions(totalTransactions)
                .userGrowthRate(userGrowthRate)
                .revenueGrowthRate(revenueGrowthRate)
                .build();
    }

    // ============================================================
    // Helper Methods
    // ============================================================

    private UserAdminDto mapToUserAdminDto(User user) {
        // Calculate statistics
        long totalProducts = productRepository.findAll().stream()
                .filter(p -> p.getOwner() != null && p.getOwner().getId().equals(user.getId()))
                .count();

        long totalConsignments = consignmentRepository.findAll().stream()
                .filter(c -> c.getProduct() != null
                        && c.getProduct().getOwner() != null
                        && c.getProduct().getOwner().getId().equals(user.getId()))
                .count();

        return UserAdminDto.builder()
                .id(user.getId())
                .name(user.getName())
                .email(user.getEmail())
                .phone(user.getPhone())
                .role(user.getRole())
                .status(user.getStatus().name())
                .createdAt(user.getCreatedAt())
                .lastLoginAt(user.getLastLoginAt())
                .totalProducts(totalProducts)
                .totalConsignments(totalConsignments)
                .totalSales(0L) // Placeholder
                .totalRevenue(0.0) // Placeholder
                .averageRating(null) // Placeholder
                .build();
    }

    private ShopAdminDto mapToShopAdminDto(Shop shop) {
        long totalProducts = consignmentRepository.findAll().stream()
                .filter(c -> c.getShop() != null && c.getShop().getId().equals(shop.getId()))
                .map(c -> c.getProduct())
                .distinct()
                .count();

        long totalConsignments = consignmentRepository.findAll().stream()
                .filter(c -> c.getShop() != null && c.getShop().getId().equals(shop.getId()))
                .count();

        return ShopAdminDto.builder()
                .id(shop.getId())
                .name(shop.getName())
                .address(shop.getAddress())
                .phone(shop.getPhone())
                .description(shop.getDescription())
                .ownerName(shop.getOwner().getName())
                .ownerEmail(shop.getOwner().getEmail())
                .isActive(shop.getIsActive())
                .isVerified(shop.getIsVerified())
                .createdAt(shop.getCreatedAt())
                .totalProducts(totalProducts)
                .totalConsignments(totalConsignments)
                .totalSales(0L) // Placeholder
                .totalRevenue(0.0) // Placeholder
                .averageRating(null) // Placeholder
                .build();
    }
}
