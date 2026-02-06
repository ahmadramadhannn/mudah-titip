package com.ahmadramadhan.mudahtitip.common.seeder;

import com.ahmadramadhan.mudahtitip.agreement.Agreement;
import com.ahmadramadhan.mudahtitip.agreement.AgreementRepository;
import com.ahmadramadhan.mudahtitip.agreement.AgreementStatus;
import com.ahmadramadhan.mudahtitip.agreement.CommissionType;
import com.ahmadramadhan.mudahtitip.auth.User;
import com.ahmadramadhan.mudahtitip.auth.UserRepository;
import com.ahmadramadhan.mudahtitip.auth.UserRole;
import com.ahmadramadhan.mudahtitip.consignment.Consignment;
import com.ahmadramadhan.mudahtitip.consignment.ConsignmentRepository;
import com.ahmadramadhan.mudahtitip.consignment.ConsignmentStatus;
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
import java.time.LocalDate;
import java.util.List;

@Component
@RequiredArgsConstructor
@Slf4j
public class DataSeeder implements CommandLineRunner {

        private final UserRepository userRepository;
        private final ShopRepository shopRepository;
        private final GuestConsignorRepository guestConsignorRepository;
        private final ProductRepository productRepository;
        private final ConsignmentRepository consignmentRepository;
        private final AgreementRepository agreementRepository;
        private final PasswordEncoder passwordEncoder;

        @Override
        public void run(String... args) throws Exception {
                log.info("Starting data seeding...");

                // ============================================================
                // 1. EXISTING DATA: Original Shop Owner (Ahmad Owner)
                // ============================================================
                User shopOwner = userRepository.findByEmail("owner@example.com").orElse(null);
                Shop tokoBerkahJaya = null;
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

                        tokoBerkahJaya = Shop.builder()
                                        .name("Toko Berkah Jaya")
                                        .address("Jl. Raya Bogor No. 123, Jakarta Timur")
                                        .phone("021-87654321")
                                        .description("Toko kelontong modern yang menyediakan berbagai kebutuhan sehari-hari dan menerima titipan produk UMKM.")
                                        .owner(shopOwner)
                                        .isActive(true)
                                        .build();
                        tokoBerkahJaya = shopRepository.save(tokoBerkahJaya);
                        log.info("Created Shop: {}", tokoBerkahJaya.getName());

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
                        tokoBerkahJaya = shopRepository.findByOwner(shopOwner).orElse(null);
                }

                // ============================================================
                // 2. EXISTING DATA: Original Consignor (Siti Consignor)
                // ============================================================
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

                // ============================================================
                // 3. NEW DATA: Jubaidah, Ibu Yus, Ibu Euce, Pak Rudi
                // ============================================================
                seedAgreementScenarios(shopOwner, tokoBerkahJaya);

                // ============================================================
                // 4. ADMIN ACCOUNT: Super Admin for platform management
                // ============================================================
                User admin = userRepository.findByEmail("admin@mudahtitip.com").orElse(null);
                if (admin == null) {
                        admin = User.builder()
                                        .name("Super Admin")
                                        .email("admin@mudahtitip.com")
                                        .passwordHash(passwordEncoder.encode("admin123"))
                                        .phone("081234567999")
                                        .role(UserRole.SUPER_ADMIN)
                                        .build();
                        userRepository.save(admin);
                        log.info("Created Super Admin: {}", admin.getEmail());
                } else {
                        log.info("Super Admin already exists. Skipping admin creation.");
                }

                log.info("Data seeding completed successfully.");
        }

        /**
         * Seeds the agreement scenarios as per user request:
         * - Jubaidah (consignor) with 3 products
         * - Ibu Yus (Warung Madura) - Jubaidah proposes, Ibu Yus decides
         * - Ibu Euce (Euce Warung) - Ibu Euce proposes, Jubaidah decides
         * - Pak Rudi (consignor) with counter-offer chain to Toko Berkah Jaya
         */
        private void seedAgreementScenarios(User existingShopOwner, Shop existingShop) {
                // Check if already seeded
                if (userRepository.findByEmail("jubaidah@example.com").isPresent()) {
                        log.info("Agreement scenarios already seeded. Skipping.");
                        return;
                }

                log.info("Seeding agreement scenarios...");

                // -------------------------------------------------------
                // 3.1 Create Users
                // -------------------------------------------------------
                User jubaidah = userRepository.save(User.builder()
                                .name("Jubaidah")
                                .email("jubaidah@example.com")
                                .passwordHash(passwordEncoder.encode("password123"))
                                .phone("081234500001")
                                .role(UserRole.CONSIGNOR)
                                .build());
                log.info("Created Consignor: {}", jubaidah.getName());

                User ibuYus = userRepository.save(User.builder()
                                .name("Ibu Yus")
                                .email("ibuyus@example.com")
                                .passwordHash(passwordEncoder.encode("password123"))
                                .phone("081234500002")
                                .role(UserRole.SHOP_OWNER)
                                .build());
                log.info("Created Shop Owner: {}", ibuYus.getName());

                User ibuEuce = userRepository.save(User.builder()
                                .name("Ibu Euce")
                                .email("ibueuce@example.com")
                                .passwordHash(passwordEncoder.encode("password123"))
                                .phone("081234500003")
                                .role(UserRole.SHOP_OWNER)
                                .build());
                log.info("Created Shop Owner: {}", ibuEuce.getName());

                User pakRudi = userRepository.save(User.builder()
                                .name("Pak Rudi")
                                .email("pakrudi@example.com")
                                .passwordHash(passwordEncoder.encode("password123"))
                                .phone("081234500004")
                                .role(UserRole.CONSIGNOR)
                                .build());
                log.info("Created Consignor: {}", pakRudi.getName());

                // -------------------------------------------------------
                // 3.2 Create Shops
                // -------------------------------------------------------
                Shop warungMadura = shopRepository.save(Shop.builder()
                                .name("Warung Madura")
                                .address("Jl. Raya Madura No. 45, Surabaya")
                                .phone("021-11111111")
                                .description("Warung kelontong tradisional khas Madura dengan layanan 24 jam.")
                                .owner(ibuYus)
                                .isActive(true)
                                .build());
                log.info("Created Shop: {}", warungMadura.getName());

                Shop euceWarung = shopRepository.save(Shop.builder()
                                .name("Euce Warung")
                                .address("Jl. Raya Euce No. 88, Bandung")
                                .phone("021-22222222")
                                .description("Warung modern dengan produk titipan dari UMKM lokal.")
                                .owner(ibuEuce)
                                .isActive(true)
                                .build());
                log.info("Created Shop: {}", euceWarung.getName());

                // -------------------------------------------------------
                // 3.3 Create Jubaidah's Products
                // -------------------------------------------------------
                Product risoles = productRepository.save(Product.builder()
                                .name("Mayonaise Risoles")
                                .description("Risoles isi mayonaise homemade, cocok untuk sarapan")
                                .category("Makanan Ringan")
                                .basePrice(new BigDecimal("3000.00"))
                                .shelfLifeDays(3)
                                .imageUrl("https://placehold.co/600x400/FFA500/FFFFFF/png?text=Risoles")
                                .owner(jubaidah)
                                .isActive(true)
                                .build());

                Product lontong = productRepository.save(Product.builder()
                                .name("Lontong")
                                .description("Lontong sayur siap saji, praktis dan lezat")
                                .category("Makanan Berat")
                                .basePrice(new BigDecimal("2500.00"))
                                .shelfLifeDays(2)
                                .imageUrl("https://placehold.co/600x400/8B4513/FFFFFF/png?text=Lontong")
                                .owner(jubaidah)
                                .isActive(true)
                                .build());

                Product kueTradisional = productRepository.save(Product.builder()
                                .name("Kue Tradisional")
                                .description("Kue tradisional campur: onde-onde, klepon, getuk")
                                .category("Kue Basah")
                                .basePrice(new BigDecimal("5000.00"))
                                .shelfLifeDays(2)
                                .imageUrl("https://placehold.co/600x400/228B22/FFFFFF/png?text=Kue+Tradisional")
                                .owner(jubaidah)
                                .isActive(true)
                                .build());
                log.info("Created 3 products for Jubaidah");

                // -------------------------------------------------------
                // 3.4 Create Pak Rudi's Products (for complex scenario)
                // -------------------------------------------------------
                Product chargerHP = productRepository.save(Product.builder()
                                .name("Charger HP Universal")
                                .description("Charger handphone dengan kabel 1.5m, kompatibel semua merek")
                                .category("Elektronik")
                                .basePrice(new BigDecimal("25000.00"))
                                .shelfLifeDays(365)
                                .imageUrl("https://placehold.co/600x400/000080/FFFFFF/png?text=Charger+HP")
                                .owner(pakRudi)
                                .isActive(true)
                                .build());

                Product earphone = productRepository.save(Product.builder()
                                .name("Earphone Stereo")
                                .description("Earphone stereo dengan bass mantap, cocok untuk musik")
                                .category("Elektronik")
                                .basePrice(new BigDecimal("15000.00"))
                                .shelfLifeDays(365)
                                .imageUrl("https://placehold.co/600x400/800080/FFFFFF/png?text=Earphone")
                                .owner(pakRudi)
                                .isActive(true)
                                .build());
                log.info("Created 2 products for Pak Rudi");

                // -------------------------------------------------------
                // 3.5 Create Consignments + Agreements
                // -------------------------------------------------------

                // ================== SCENARIO A ==================
                // Jubaidah → Warung Madura (Ibu Yus)
                // Jubaidah proposes the agreement, Ibu Yus can accept/reject
                // ================================================

                Consignment risolesAtMadura = consignmentRepository.save(Consignment.builder()
                                .product(risoles)
                                .shop(warungMadura)
                                .initialQuantity(25)
                                .currentQuantity(25)
                                .sellingPrice(new BigDecimal("3500.00"))
                                .commissionPercent(new BigDecimal("10.00"))
                                .consignmentDate(LocalDate.now())
                                .expiryDate(LocalDate.now().plusDays(3))
                                .status(ConsignmentStatus.ACTIVE)
                                .notes("Titipan risoles batch pertama")
                                .build());

                Consignment lontongAtMadura = consignmentRepository.save(Consignment.builder()
                                .product(lontong)
                                .shop(warungMadura)
                                .initialQuantity(20)
                                .currentQuantity(20)
                                .sellingPrice(new BigDecimal("3000.00"))
                                .commissionPercent(new BigDecimal("10.00"))
                                .consignmentDate(LocalDate.now())
                                .expiryDate(LocalDate.now().plusDays(2))
                                .status(ConsignmentStatus.ACTIVE)
                                .notes("Titipan lontong pagi")
                                .build());

                Consignment kueAtMadura = consignmentRepository.save(Consignment.builder()
                                .product(kueTradisional)
                                .shop(warungMadura)
                                .initialQuantity(10)
                                .currentQuantity(10)
                                .sellingPrice(new BigDecimal("6000.00"))
                                .commissionPercent(new BigDecimal("10.00"))
                                .consignmentDate(LocalDate.now())
                                .expiryDate(LocalDate.now().plusDays(2))
                                .status(ConsignmentStatus.ACTIVE)
                                .notes("Titipan kue tradisional")
                                .build());

                log.info("Created 3 consignments for Jubaidah →  Warung Madura");

                // Agreement: Jubaidah proposes to Ibu Yus (PENDING - waiting for Ibu Yus)
                agreementRepository.save(Agreement.builder()
                                .consignment(risolesAtMadura)
                                .proposedBy(jubaidah)
                                .status(AgreementStatus.PROPOSED)
                                .commissionType(CommissionType.PERCENTAGE)
                                .commissionValue(new BigDecimal("10.00"))
                                .termsNote("Komisi 10% dari setiap penjualan risoles")
                                .build());

                agreementRepository.save(Agreement.builder()
                                .consignment(lontongAtMadura)
                                .proposedBy(jubaidah)
                                .status(AgreementStatus.PROPOSED)
                                .commissionType(CommissionType.PERCENTAGE)
                                .commissionValue(new BigDecimal("10.00"))
                                .termsNote("Komisi 10% dari setiap penjualan lontong")
                                .build());

                // One already ACCEPTED for variety
                agreementRepository.save(Agreement.builder()
                                .consignment(kueAtMadura)
                                .proposedBy(jubaidah)
                                .status(AgreementStatus.ACCEPTED)
                                .commissionType(CommissionType.PERCENTAGE)
                                .commissionValue(new BigDecimal("10.00"))
                                .termsNote("Komisi 10% dari setiap penjualan kue")
                                .responseMessage("Setuju, silahkan titip!")
                                .build());

                log.info("Created agreements: Jubaidah → Ibu Yus (2 PROPOSED, 1 ACCEPTED)");

                // ================== SCENARIO B ==================
                // Jubaidah → Euce Warung (Ibu Euce)
                // Ibu Euce proposes the agreement, Jubaidah can accept/reject
                // ================================================

                Consignment risolesAtEuce = consignmentRepository.save(Consignment.builder()
                                .product(risoles)
                                .shop(euceWarung)
                                .initialQuantity(25)
                                .currentQuantity(25)
                                .sellingPrice(new BigDecimal("4000.00"))
                                .commissionPercent(new BigDecimal("15.00"))
                                .consignmentDate(LocalDate.now())
                                .expiryDate(LocalDate.now().plusDays(3))
                                .status(ConsignmentStatus.ACTIVE)
                                .notes("Titipan risoles di Euce Warung")
                                .build());

                Consignment lontongAtEuce = consignmentRepository.save(Consignment.builder()
                                .product(lontong)
                                .shop(euceWarung)
                                .initialQuantity(20)
                                .currentQuantity(20)
                                .sellingPrice(new BigDecimal("3500.00"))
                                .commissionPercent(new BigDecimal("12.00"))
                                .consignmentDate(LocalDate.now())
                                .expiryDate(LocalDate.now().plusDays(2))
                                .status(ConsignmentStatus.ACTIVE)
                                .notes("Titipan lontong di Euce")
                                .build());

                Consignment kueAtEuce = consignmentRepository.save(Consignment.builder()
                                .product(kueTradisional)
                                .shop(euceWarung)
                                .initialQuantity(10)
                                .currentQuantity(10)
                                .sellingPrice(new BigDecimal("7000.00"))
                                .commissionPercent(new BigDecimal("15.00"))
                                .consignmentDate(LocalDate.now())
                                .expiryDate(LocalDate.now().plusDays(2))
                                .status(ConsignmentStatus.ACTIVE)
                                .notes("Titipan kue di Euce Warung")
                                .build());

                log.info("Created 3 consignments for Jubaidah → Euce Warung");

                // Agreement: Ibu Euce proposes to Jubaidah (PENDING - waiting for Jubaidah)
                agreementRepository.save(Agreement.builder()
                                .consignment(risolesAtEuce)
                                .proposedBy(ibuEuce) // Shop owner proposes!
                                .status(AgreementStatus.PROPOSED)
                                .commissionType(CommissionType.TIERED_BONUS)
                                .commissionValue(new BigDecimal("12.00"))
                                .bonusThresholdPercent(80)
                                .bonusAmount(new BigDecimal("10000.00"))
                                .termsNote("Komisi 12% + bonus Rp10.000 jika terjual >80%")
                                .build());

                agreementRepository.save(Agreement.builder()
                                .consignment(lontongAtEuce)
                                .proposedBy(ibuEuce)
                                .status(AgreementStatus.PROPOSED)
                                .commissionType(CommissionType.FIXED_PER_ITEM)
                                .commissionValue(new BigDecimal("500.00"))
                                .termsNote("Komisi Rp500 per lontong terjual")
                                .build());

                // One ACCEPTED for variety
                agreementRepository.save(Agreement.builder()
                                .consignment(kueAtEuce)
                                .proposedBy(ibuEuce)
                                .status(AgreementStatus.ACCEPTED)
                                .commissionType(CommissionType.PERCENTAGE)
                                .commissionValue(new BigDecimal("15.00"))
                                .termsNote("Komisi 15% dari penjualan kue")
                                .responseMessage("Deal! Silahkan titipkan kuenya.")
                                .build());

                log.info("Created agreements: Ibu Euce → Jubaidah (2 PROPOSED, 1 ACCEPTED)");

                // ================== SCENARIO C ==================
                // Complex: Pak Rudi → Toko Berkah Jaya (Ahmad Owner)
                // Counter-offer negotiation chain
                // ================================================

                if (existingShop != null) {
                        Consignment chargerConsignment = consignmentRepository.save(Consignment.builder()
                                        .product(chargerHP)
                                        .shop(existingShop)
                                        .initialQuantity(50)
                                        .currentQuantity(50)
                                        .sellingPrice(new BigDecimal("35000.00"))
                                        .commissionPercent(new BigDecimal("20.00"))
                                        .consignmentDate(LocalDate.now().minusDays(3))
                                        .expiryDate(LocalDate.now().plusDays(60))
                                        .status(ConsignmentStatus.ACTIVE)
                                        .notes("Titipan charger HP batch pertama")
                                        .build());

                        Consignment earphoneConsignment = consignmentRepository.save(Consignment.builder()
                                        .product(earphone)
                                        .shop(existingShop)
                                        .initialQuantity(30)
                                        .currentQuantity(28) // 2 already sold
                                        .sellingPrice(new BigDecimal("20000.00"))
                                        .commissionPercent(new BigDecimal("25.00"))
                                        .consignmentDate(LocalDate.now().minusDays(7))
                                        .expiryDate(LocalDate.now().plusDays(90))
                                        .status(ConsignmentStatus.ACTIVE)
                                        .notes("Titipan earphone untuk display")
                                        .build());

                        log.info("Created 2 consignments for Pak Rudi → Toko Berkah Jaya");

                        // Initial proposal - REJECTED
                        Agreement initialProposal = agreementRepository.save(Agreement.builder()
                                        .consignment(chargerConsignment)
                                        .proposedBy(pakRudi)
                                        .status(AgreementStatus.REJECTED)
                                        .commissionType(CommissionType.FIXED_PER_ITEM)
                                        .commissionValue(new BigDecimal("5000.00"))
                                        .termsNote("Komisi Rp5.000 per charger terjual")
                                        .responseMessage("Terlalu rendah, minta minimal Rp7.500 per item")
                                        .build());

                        // Counter-offer from shop owner - ACCEPTED
                        agreementRepository.save(Agreement.builder()
                                        .consignment(chargerConsignment)
                                        .proposedBy(existingShopOwner)
                                        .previousVersion(initialProposal) // Link to previous
                                        .status(AgreementStatus.ACCEPTED)
                                        .commissionType(CommissionType.FIXED_PER_ITEM)
                                        .commissionValue(new BigDecimal("7000.00"))
                                        .termsNote("Komisi Rp7.000 per charger - deal final")
                                        .responseMessage("Setuju dengan Rp7.000 per item")
                                        .build());

                        // Earphone: direct accepted with tiered bonus
                        agreementRepository.save(Agreement.builder()
                                        .consignment(earphoneConsignment)
                                        .proposedBy(pakRudi)
                                        .status(AgreementStatus.ACCEPTED)
                                        .commissionType(CommissionType.TIERED_BONUS)
                                        .commissionValue(new BigDecimal("15.00"))
                                        .bonusThresholdPercent(90)
                                        .bonusAmount(new BigDecimal("50000.00"))
                                        .termsNote("Komisi 15% + bonus Rp50.000 jika terjual >90%")
                                        .responseMessage("Deal! Semangat jualan!")
                                        .build());

                        log.info("Created agreements: Pak Rudi → Ahmad Owner (REJECTED → COUNTER → ACCEPTED chain)");
                }

                log.info("Agreement scenarios seeding completed.");
        }
}
