package com.ahmadramadhan.mudahtitip.notification;

import com.ahmadramadhan.mudahtitip.auth.User;
import com.ahmadramadhan.mudahtitip.auth.UserRepository;
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
 */
@Component
@Profile("dev")
@Order(100) // Run after user seeder
@RequiredArgsConstructor
@Slf4j
public class NotificationSeeder implements CommandLineRunner {

    private final NotificationRepository notificationRepository;
    private final UserRepository userRepository;

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

        log.info("Seeding dummy notifications for {} users...", users.size());

        for (User user : users) {
            seedNotificationsForUser(user);
        }

        log.info("Seeded {} notifications", notificationRepository.count());
    }

    private void seedNotificationsForUser(User user) {
        // Stock notifications
        notificationRepository.save(Notification.builder()
                .recipient(user)
                .type(NotificationType.STOCK_LOW)
                .title("Stok Menipis")
                .message("Stok Kopi Arabica di Toko Berkah tinggal 3 unit")
                .referenceId(1L)
                .referenceType("CONSIGNMENT")
                .read(false)
                .build());

        notificationRepository.save(Notification.builder()
                .recipient(user)
                .type(NotificationType.STOCK_OUT)
                .title("Stok Habis")
                .message("Stok Teh Hijau Organik di Toko Mandiri sudah habis!")
                .referenceId(2L)
                .referenceType("CONSIGNMENT")
                .read(false)
                .build());

        // Agreement notifications
        notificationRepository.save(Notification.builder()
                .recipient(user)
                .type(NotificationType.AGREEMENT_PROPOSED)
                .title("Permintaan Perjanjian Baru")
                .message("Toko Sejahtera mengajukan perjanjian untuk Madu Hutan Asli")
                .referenceId(1L)
                .referenceType("AGREEMENT")
                .read(false)
                .build());

        notificationRepository.save(Notification.builder()
                .recipient(user)
                .type(NotificationType.AGREEMENT_ACCEPTED)
                .title("Perjanjian Diterima")
                .message("Perjanjian untuk Keripik Tempe telah diterima!")
                .referenceId(2L)
                .referenceType("AGREEMENT")
                .read(true)
                .build());

        // Sale notifications
        notificationRepository.save(Notification.builder()
                .recipient(user)
                .type(NotificationType.SALE_RECORDED)
                .title("Penjualan Tercatat")
                .message("5 Sambal Bu Rudy terjual di Toko Makmur")
                .referenceId(1L)
                .referenceType("SALE")
                .read(true)
                .build());

        // Consignment notifications
        notificationRepository.save(Notification.builder()
                .recipient(user)
                .type(NotificationType.CONSIGNMENT_EXPIRING)
                .title("Konsinyasi Akan Berakhir")
                .message("Konsinyasi Brownies Coklat di Mini Market akan berakhir dalam 7 hari")
                .referenceId(3L)
                .referenceType("CONSIGNMENT")
                .read(false)
                .build());

        notificationRepository.save(Notification.builder()
                .recipient(user)
                .type(NotificationType.CONSIGNMENT_COMPLETED)
                .title("Konsinyasi Selesai")
                .message("Semua Kue Nastar di Warung Tegal telah terjual!")
                .referenceId(4L)
                .referenceType("CONSIGNMENT")
                .read(false)
                .build());
    }
}
