package com.ahmadramadhan.mudahtitip.notification;

import com.ahmadramadhan.mudahtitip.auth.User;
import com.ahmadramadhan.mudahtitip.auth.UserRepository;
import com.ahmadramadhan.mudahtitip.auth.UserRole;
import com.ahmadramadhan.mudahtitip.consignment.Consignment;
import com.ahmadramadhan.mudahtitip.consignment.ConsignmentRepository;
import com.ahmadramadhan.mudahtitip.product.Product;
import com.ahmadramadhan.mudahtitip.product.ProductRepository;
import com.ahmadramadhan.mudahtitip.shop.Shop;
import com.ahmadramadhan.mudahtitip.shop.ShopRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.util.List;

/**
 * Seeds dummy notification data for testing purposes.
 * Only runs in dev profile.
 * Creates notifications based on actual products and consignments.
 */
@Component
@Profile("dev")
@Order(100) // Run after user seeder
@RequiredArgsConstructor
@Slf4j
public class NotificationSeeder implements CommandLineRunner {

        private final NotificationRepository notificationRepository;
        private final UserRepository userRepository;
        private final ProductRepository productRepository;
        private final ConsignmentRepository consignmentRepository;
        private final ShopRepository shopRepository;

        @Override
        public void run(String... args) {
                // Skip if notifications already exist
                if (notificationRepository.count() > 0) {
                        log.info("Notifications already seeded, skipping...");
                        return;
                }

                List<User> users = userRepository.findAll();
                if (users.isEmpty()) {
                        log.warn("No users found, cannot seed notifications");
                        return;
                }

                log.info("Seeding unique notifications for {} users...", users.size());

                for (User user : users) {
                        seedNotificationsForUser(user);
                }

                log.info("Seeded {} notifications", notificationRepository.count());
        }

        private void seedNotificationsForUser(User user) {
                if (user.getRole() == UserRole.CONSIGNOR) {
                        seedConsignorNotifications(user);
                } else if (user.getRole() == UserRole.SHOP_OWNER) {
                        seedShopOwnerNotifications(user);
                }
                // Admin users get no notifications in this seed
        }

        private void seedConsignorNotifications(User consignor) {
                // Get actual products owned by this consignor
                List<Product> products = productRepository.findByOwnerId(consignor.getId());

                if (products.isEmpty()) {
                        log.debug("No products found for consignor {}, skipping notifications", consignor.getName());
                        return;
                }

                // Get actual consignments for this consignor's products
                List<Consignment> consignments = consignmentRepository
                                .findByProductOwnerIdOrderByCreatedAtDesc(consignor.getId());

                int notifCount = 0;

                // Create notifications based on actual products
                for (Product product : products) {
                        if (notifCount >= 4)
                                break; // Limit notifications per user

                        // Find consignment for this product if exists
                        Consignment consignment = consignments.stream()
                                        .filter(c -> c.getProduct().getId().equals(product.getId()))
                                        .findFirst()
                                        .orElse(null);

                        if (consignment != null) {
                                // Stock notification based on actual consignment
                                int qty = consignment.getCurrentQuantity();
                                String shopName = consignment.getShop().getName();

                                if (qty > 0 && qty <= 5) {
                                        notificationRepository.save(Notification.builder()
                                                        .recipient(consignor)
                                                        .type(NotificationType.STOCK_LOW)
                                                        .title("Stok " + product.getName() + " Menipis")
                                                        .message("Stok " + product.getName() + " di " + shopName
                                                                        + " tinggal " + qty + " unit")
                                                        .referenceId(consignment.getId())
                                                        .referenceType("CONSIGNMENT")
                                                        .read(false)
                                                        .build());
                                        notifCount++;
                                }

                                // Sale notification
                                int sold = consignment.getInitialQuantity() - consignment.getCurrentQuantity();
                                if (sold > 0) {
                                        notificationRepository.save(Notification.builder()
                                                        .recipient(consignor)
                                                        .type(NotificationType.SALE_RECORDED)
                                                        .title("Penjualan " + product.getName())
                                                        .message(sold + " " + product.getName() + " terjual di "
                                                                        + shopName)
                                                        .referenceId(consignment.getId())
                                                        .referenceType("SALE")
                                                        .read(notifCount % 2 == 0)
                                                        .build());
                                        notifCount++;
                                }
                        } else {
                                // Product without consignment - general product notification
                                notificationRepository.save(Notification.builder()
                                                .recipient(consignor)
                                                .type(NotificationType.AGREEMENT_PROPOSED)
                                                .title("Produk Siap Dititipkan")
                                                .message("Produk " + product.getName()
                                                                + " belum memiliki perjanjian aktif")
                                                .referenceId(product.getId())
                                                .referenceType("PRODUCT")
                                                .read(false)
                                                .build());
                                notifCount++;
                        }
                }

                // If still need more notifications, add generic ones
                if (notifCount == 0 && !products.isEmpty()) {
                        Product firstProduct = products.get(0);
                        notificationRepository.save(Notification.builder()
                                        .recipient(consignor)
                                        .type(NotificationType.STOCK_LOW)
                                        .title("Cek Stok " + firstProduct.getName())
                                        .message("Pastikan stok " + firstProduct.getName() + " Anda mencukupi")
                                        .referenceId(firstProduct.getId())
                                        .referenceType("PRODUCT")
                                        .read(false)
                                        .build());
                }
        }

        private void seedShopOwnerNotifications(User shopOwner) {
                // Get the shop owned by this user
                Shop shop = shopRepository.findByOwnerId(shopOwner.getId()).orElse(null);

                if (shop == null) {
                        log.debug("No shop found for shop owner {}, skipping notifications", shopOwner.getName());
                        return;
                }

                // Get actual consignments at this shop
                List<Consignment> consignments = consignmentRepository.findByShopIdOrderByCreatedAtDesc(shop.getId());

                int notifCount = 0;

                for (Consignment consignment : consignments) {
                        if (notifCount >= 3)
                                break; // Limit notifications per user

                        Product product = consignment.getProduct();
                        String consignorName = product.getOwner().getName();
                        int qty = consignment.getCurrentQuantity();

                        // Stock notification
                        if (qty > 0 && qty <= 5) {
                                notificationRepository.save(Notification.builder()
                                                .recipient(shopOwner)
                                                .type(NotificationType.STOCK_LOW)
                                                .title("Stok " + product.getName() + " Menipis")
                                                .message("Stok " + product.getName() + " dari " + consignorName
                                                                + " tinggal " + qty + " unit")
                                                .referenceId(consignment.getId())
                                                .referenceType("CONSIGNMENT")
                                                .read(false)
                                                .build());
                                notifCount++;
                        }

                        // Consignment accepted notification
                        notificationRepository.save(Notification.builder()
                                        .recipient(shopOwner)
                                        .type(NotificationType.AGREEMENT_ACCEPTED)
                                        .title("Produk Diterima")
                                        .message(product.getName() + " dari " + consignorName
                                                        + " sudah aktif di toko Anda")
                                        .referenceId(consignment.getId())
                                        .referenceType("CONSIGNMENT")
                                        .read(true)
                                        .build());
                        notifCount++;
                }

                // If no consignments, add generic shop notification
                if (consignments.isEmpty()) {
                        notificationRepository.save(Notification.builder()
                                        .recipient(shopOwner)
                                        .type(NotificationType.AGREEMENT_PROPOSED)
                                        .title("Toko Siap Menerima Produk")
                                        .message("Toko " + shop.getName() + " siap menerima produk konsinyasi")
                                        .referenceId(shop.getId())
                                        .referenceType("SHOP")
                                        .read(false)
                                        .build());
                }
        }
}
