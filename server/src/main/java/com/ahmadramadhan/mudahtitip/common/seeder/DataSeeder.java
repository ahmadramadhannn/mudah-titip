package com.ahmadramadhan.mudahtitip.common.seeder;

import com.ahmadramadhan.mudahtitip.auth.User;
import com.ahmadramadhan.mudahtitip.auth.UserRepository;
import com.ahmadramadhan.mudahtitip.auth.UserRole;
import com.ahmadramadhan.mudahtitip.consignor.GuestConsignor;
import com.ahmadramadhan.mudahtitip.consignor.GuestConsignorRepository;
import com.ahmadramadhan.mudahtitip.product.Product;
import com.ahmadramadhan.mudahtitip.product.ProductRepository;
import com.ahmadramadhan.mudahtitip.shop.Shop;
import com.ahmadramadhan.mudahtitip.shop.ShopRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.util.List;

@Component
@RequiredArgsConstructor
@Slf4j
public class DataSeeder implements CommandLineRunner {

    private final UserRepository userRepository;
    private final ShopRepository shopRepository;
    private final GuestConsignorRepository guestConsignorRepository;
    private final ProductRepository productRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {
        log.info("Starting data seeding...");

        // 1. Check/Create Shop Owner
        User shopOwner = userRepository.findByEmail("owner@example.com").orElse(null);
        if (shopOwner == null) {
            shopOwner = User.builder()
                    .name("Ahmad Owner")
                    .email("owner@example.com")
                    .passwordHash(passwordEncoder.encode("password123"))
                    .phone("081234567890")
                    .role(UserRole.SHOP_OWNER)
                    .build();
            shopOwner = userRepository.save(shopOwner);
            log.info("Created Shop Owner: {}", shopOwner.getEmail());

            // Create Shop for Owner
            Shop shop = Shop.builder()
                    .name("Toko Berkah Jaya")
                    .address("Jl. Raya Bogor No. 123, Jakarta Timur")
                    .phone("021-87654321")
                    .description(
                            "Toko kelontong modern yang menyediakan berbagai kebutuhan sehari-hari dan menerima titipan produk UMKM.")
                    .owner(shopOwner)
                    .isActive(true)
                    .build();
            shopRepository.save(shop);
            log.info("Created Shop: {}", shop.getName());

            // Create Guest Consignor (Managed by Shop Owner)
            GuestConsignor guestConsignor = GuestConsignor.builder()
                    .name("Budi Santoso (Guest)")
                    .phone("085678901234")
                    .address("Kp. Rambutan, Jakarta Timur")
                    .notes("Penitip rutin setiap senin")
                    .managedBy(shopOwner)
                    .isActive(true)
                    .build();
            guestConsignor = guestConsignorRepository.save(guestConsignor);
            log.info("Created Guest Consignor: {}", guestConsignor.getName());

            // Product 3: Guest Consignor
            Product product3 = Product.builder()
                    .name("Sambal Terasi Botol")
                    .description("Sambal terasi rumahan tanpa pengawet.")
                    .category("Bumbu")
                    .basePrice(new BigDecimal("20000.00"))
                    .shelfLifeDays(60)
                    .imageUrl("https://placehold.co/600x400/png?text=Sambal+Terasi")
                    .guestOwner(guestConsignor)
                    .isActive(true)
                    .build();
            productRepository.save(product3);
        } else {
            log.info("Shop Owner already exists. Skipping owner creation.");
        }

        // 2. Check/Create Registered Consignor
        User consignor = userRepository.findByEmail("consignor@example.com").orElse(null);
        if (consignor == null) {
            consignor = User.builder()
                    .name("Siti Consignor")
                    .email("consignor@example.com")
                    .passwordHash(passwordEncoder.encode("password123"))
                    .phone("089876543210")
                    .role(UserRole.CONSIGNOR)
                    .build();
            consignor = userRepository.save(consignor);
            log.info("Created Consignor: {}", consignor.getEmail());

            // Products for Registered Consignor
            Product product1 = Product.builder()
                    .name("Keripik Singkong Pedas")
                    .description("Keripik singkong renyah dengan bumbu balado pedas manis.")
                    .category("Makanan Ringan")
                    .basePrice(new BigDecimal("15000.00"))
                    .shelfLifeDays(30)
                    .imageUrl("https://placehold.co/600x400/png?text=Keripik+Singkong")
                    .owner(consignor)
                    .isActive(true)
                    .build();

            Product product2 = Product.builder()
                    .name("Kue Bolu Kukus")
                    .description("Bolu kukus lembut dengan varian rasa pandan dan coklat.")
                    .category("Kue Basah")
                    .basePrice(new BigDecimal("25000.00"))
                    .shelfLifeDays(3)
                    .imageUrl("https://placehold.co/600x400/png?text=Bolu+Kukus")
                    .owner(consignor)
                    .isActive(true)
                    .build();

            productRepository.saveAll(List.of(product1, product2));
            log.info("Created 2 products for consignor.");
        } else {
            log.info("Consignor already exists. Skipping consignor creation.");
        }

        log.info("Data seeding completed successfully.");
    }
}
