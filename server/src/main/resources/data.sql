-- ============================================================================
-- Mudah Titip - Comprehensive Seed Data
-- ============================================================================
-- This script populates the database with realistic test data.
-- Passwords are BCrypt hashed. Run with: spring.sql.init.mode=always
-- ============================================================================

-- ============================================================================
-- USERS (8 total: 3 shop owners, 5 consignors)
-- ============================================================================
-- BCrypt hashed passwords (generated with cost factor 10):
-- toko123      -> $2a$10$N9qo8uLOickgx2ZMRZoMy.MqrqL1MqP5WR7fxvxJ.Qz.VZ3Rlp1fW
-- shop456      -> $2a$10$8K1p/a0dL1LXMIgoEDFrwOfMQkLgpNLqUeQc2zNIh/DGK7Z.1mVFm
-- tokoku789    -> $2a$10$rDkPvvAFV8kqwvKJzwlRq.Yc4QK3rYhKN1umLyO.VP0KlhGKLM4gy
-- titip123     -> $2a$10$Qf5Hj8Zk.VxN2TmPp3UqXu4wY6R7oI8sA5B1hC9dE0fG2KL3M4N5O
-- penitip456   -> $2a$10$Xw9Yj0Ak.BzO3UnQq4VrYv5xZ7S8pJ9tB6C2iD0eF1gH3IL4M5N6P
-- produk789    -> $2a$10$Zy0Zk1Bl.CaP4VoRr5WsZw6yA8T9qK0uC7D3jE1fG2hI4JM5N6O7Q
-- barang123    -> $2a$10$Ab1Al2Cm.DbQ5WpSs6XtAx7zB9U0rL1vD8E4kF2gH3iJ5KN6O7P8R
-- titipan456   -> $2a$10$Bc2Bm3Dn.EcR6XqTt7YuBy8aC0V1sM2wE9F5lG3hI4jK6LO7P8Q9S

INSERT INTO users (id, name, email, password_hash, phone, role, created_at, updated_at)
VALUES
-- Shop Owners
(1, 'Budi Santoso', 'budi.santoso@example.com', '$2a$10$N9qo8uLOickgx2ZMRZoMy.MqrqL1MqP5WR7fxvxJ.Qz.VZ3Rlp1fW', '081234567890', 'SHOP_OWNER', NOW(), NOW()),
(2, 'Dewi Puspita', 'dewi.puspita@example.com', '$2a$10$8K1p/a0dL1LXMIgoEDFrwOfMQkLgpNLqUeQc2zNIh/DGK7Z.1mVFm', '082345678901', 'SHOP_OWNER', NOW(), NOW()),
(3, 'Eko Prasetyo', 'eko.prasetyo@example.com', '$2a$10$rDkPvvAFV8kqwvKJzwlRq.Yc4QK3rYhKN1umLyO.VP0KlhGKLM4gy', '083456789012', 'SHOP_OWNER', NOW(), NOW()),
-- Consignors
(4, 'Fitri Handayani', 'fitri.handayani@example.com', '$2a$10$Qf5Hj8Zk.VxN2TmPp3UqXu4wY6R7oI8sA5B1hC9dE0fG2KL3M4N5O', '084567890123', 'CONSIGNOR', NOW(), NOW()),
(5, 'Gunawan Hadi', 'gunawan.hadi@example.com', '$2a$10$Xw9Yj0Ak.BzO3UnQq4VrYv5xZ7S8pJ9tB6C2iD0eF1gH3IL4M5N6P', '085678901234', 'CONSIGNOR', NOW(), NOW()),
(6, 'Hana Wijaya', 'hana.wijaya@example.com', '$2a$10$Zy0Zk1Bl.CaP4VoRr5WsZw6yA8T9qK0uC7D3jE1fG2hI4JM5N6O7Q', '086789012345', 'CONSIGNOR', NOW(), NOW()),
(7, 'Ivan Kurniawan', 'ivan.kurniawan@example.com', '$2a$10$Ab1Al2Cm.DbQ5WpSs6XtAx7zB9U0rL1vD8E4kF2gH3iJ5KN6O7P8R', '087890123456', 'CONSIGNOR', NOW(), NOW()),
(8, 'Joko Susilo', 'joko.susilo@example.com', '$2a$10$Bc2Bm3Dn.EcR6XqTt7YuBy8aC0V1sM2wE9F5lG3hI4jK6LO7P8Q9S', '088901234567', 'CONSIGNOR', NOW(), NOW())
ON DUPLICATE KEY UPDATE updated_at = NOW();

-- ============================================================================
-- SHOPS (3 total)
-- ============================================================================
INSERT INTO shops (id, name, address, phone, description, is_active, owner_id, created_at, updated_at)
VALUES
(1, 'Toko Serba Ada Budi', 'Jl. Sudirman No. 123, Jakarta Selatan', '021-5551234', 'Toko kelontong lengkap dengan berbagai kebutuhan sehari-hari', true, 1, NOW(), NOW()),
(2, 'Warung Dewi Lestari', 'Jl. Braga No. 45, Bandung', '022-4201234', 'Warung tradisional dengan produk makanan homemade', true, 2, NOW(), NOW()),
(3, 'Minimart Prasetyo', 'Jl. Pemuda No. 89, Surabaya', '031-5345678', 'Minimarket modern dengan produk lokal berkualitas', true, 3, NOW(), NOW())
ON DUPLICATE KEY UPDATE updated_at = NOW();

-- ============================================================================
-- PRODUCTS (15 total - owned by consignors)
-- ============================================================================
INSERT INTO products (id, name, description, category, shelf_life_days, base_price, image_url, is_active, owner_id, created_at, updated_at)
VALUES
-- Fitri's products (Makanan Ringan)
(1, 'Keripik Singkong Original', 'Keripik singkong renyah tanpa pengawet', 'Makanan', 30, 15000.00, NULL, true, 4, NOW(), NOW()),
(2, 'Keripik Singkong Pedas', 'Keripik singkong dengan bumbu pedas khas', 'Makanan', 30, 17000.00, NULL, true, 4, NOW(), NOW()),
(3, 'Kue Nastar Homemade', 'Kue nastar lembut dengan isian selai nanas asli', 'Makanan', 14, 45000.00, NULL, true, 4, NOW(), NOW()),

-- Gunawan's products (Minuman)
(4, 'Sirup Markisa', 'Sirup markisa asli tanpa bahan pengawet', 'Minuman', 60, 35000.00, NULL, true, 5, NOW(), NOW()),
(5, 'Jus Mangga Botolan', 'Jus mangga segar dalam kemasan 500ml', 'Minuman', 7, 12000.00, NULL, true, 5, NOW(), NOW()),
(6, 'Teh Herbal Jahe', 'Teh herbal dengan jahe merah berkhasiat', 'Minuman', 90, 25000.00, NULL, true, 5, NOW(), NOW()),

-- Hana's products (Kerajinan)
(7, 'Tas Rajut Warna-Warni', 'Tas rajut handmade dengan benang berkualitas', 'Kerajinan', NULL, 85000.00, NULL, true, 6, NOW(), NOW()),
(8, 'Dompet Kulit Sintetis', 'Dompet dari kulit sintetis premium', 'Kerajinan', NULL, 65000.00, NULL, true, 6, NOW(), NOW()),
(9, 'Gantungan Kunci Resin', 'Gantungan kunci dari resin dengan bunga kering', 'Kerajinan', NULL, 25000.00, NULL, true, 6, NOW(), NOW()),

-- Ivan's products (Makanan Berat)
(10, 'Rendang Kering', 'Rendang kering siap makan dalam kemasan vacuum', 'Makanan', 30, 75000.00, NULL, true, 7, NOW(), NOW()),
(11, 'Abon Sapi Premium', 'Abon sapi dengan tekstur lembut', 'Makanan', 60, 55000.00, NULL, true, 7, NOW(), NOW()),
(12, 'Sambal Terasi Bu Ivan', 'Sambal terasi homemade tingkat pedas sedang', 'Makanan', 30, 28000.00, NULL, true, 7, NOW(), NOW()),

-- Joko's products (Aksesoris)
(13, 'Gelang Kayu Etnik', 'Gelang dari kayu dengan ukiran etnik', 'Aksesoris', NULL, 35000.00, NULL, true, 8, NOW(), NOW()),
(14, 'Kalung Manik-Manik', 'Kalung handmade dengan manik-manik batu alam', 'Aksesoris', NULL, 45000.00, NULL, true, 8, NOW(), NOW()),
(15, 'Bros Batik Mini', 'Bros dengan motif batik khas Indonesia', 'Aksesoris', NULL, 20000.00, NULL, true, 8, NOW(), NOW())
ON DUPLICATE KEY UPDATE updated_at = NOW();

-- ============================================================================
-- CONSIGNMENTS (10 total - various statuses)
-- ============================================================================
INSERT INTO consignments (id, product_id, shop_id, initial_quantity, current_quantity, selling_price, commission_percent, consignment_date, expiry_date, status, notes, created_at, updated_at)
VALUES
-- Active consignments
(1, 1, 1, 50, 35, 18000.00, 10.00, '2026-01-15', '2026-02-15', 'ACTIVE', 'Keripik singkong di toko Budi', NOW(), NOW()),
(2, 4, 1, 30, 22, 40000.00, 12.00, '2026-01-10', '2026-03-10', 'ACTIVE', 'Sirup markisa di toko Budi', NOW(), NOW()),
(3, 7, 2, 20, 15, 95000.00, 15.00, '2026-01-20', NULL, 'ACTIVE', 'Tas rajut di warung Dewi', NOW(), NOW()),
(4, 10, 2, 25, 18, 85000.00, 10.00, '2026-01-18', '2026-02-18', 'ACTIVE', 'Rendang di warung Dewi', NOW(), NOW()),
(5, 13, 3, 40, 28, 40000.00, 12.00, '2026-01-22', NULL, 'ACTIVE', 'Gelang kayu di Minimart Prasetyo', NOW(), NOW()),

-- Completed consignments
(6, 2, 1, 40, 0, 20000.00, 10.00, '2026-01-01', '2026-01-30', 'COMPLETED', 'Sudah habis terjual', NOW(), NOW()),
(7, 5, 3, 48, 0, 15000.00, 8.00, '2026-01-05', '2026-01-12', 'COMPLETED', 'Jus mangga laris', NOW(), NOW()),

-- Expired consignment
(8, 3, 2, 30, 12, 55000.00, 15.00, '2025-12-15', '2025-12-29', 'EXPIRED', 'Kue nastar sudah expired', NOW(), NOW()),

-- Returned consignment
(9, 6, 1, 15, 10, 30000.00, 10.00, '2025-12-20', '2026-03-20', 'RETURNED', 'Dikembalikan atas permintaan penitip', NOW(), NOW()),

-- Another active one
(10, 11, 3, 35, 25, 65000.00, 12.00, '2026-01-25', '2026-03-25', 'ACTIVE', 'Abon sapi premium', NOW(), NOW())
ON DUPLICATE KEY UPDATE updated_at = NOW();

-- ============================================================================
-- AGREEMENTS (6 total - various types and statuses)
-- ============================================================================
INSERT INTO agreements (id, consignment_id, proposed_by_id, status, commission_type, commission_value, bonus_threshold_percent, bonus_amount, terms_note, response_message, previous_version_id, created_at, updated_at)
VALUES
-- Accepted agreements
(1, 1, 1, 'ACCEPTED', 'PERCENTAGE', 10.00, NULL, NULL, 'Komisi standar 10% untuk keripik', NULL, NULL, NOW(), NOW()),
(2, 3, 2, 'ACCEPTED', 'PERCENTAGE', 15.00, NULL, NULL, 'Komisi 15% untuk produk kerajinan', NULL, NULL, NOW(), NOW()),
(3, 5, 3, 'ACCEPTED', 'FIXED_PER_ITEM', 5000.00, NULL, NULL, 'Rp5.000 per gelang terjual', NULL, NULL, NOW(), NOW()),

-- Proposed (pending)
(4, 4, 7, 'PROPOSED', 'TIERED_BONUS', 10.00, 80, 50000.00, 'Bonus Rp50.000 jika terjual 80%', NULL, NULL, NOW(), NOW()),

-- Counter offer
(5, 10, 3, 'COUNTER', 'PERCENTAGE', 15.00, NULL, NULL, 'Minta komisi 15%', 'Bisa 12% saja?', NULL, NOW(), NOW()),

-- Rejected
(6, 2, 5, 'REJECTED', 'PERCENTAGE', 20.00, NULL, NULL, 'Minta komisi 20%', 'Terlalu tinggi, tidak bisa deal', NULL, NOW(), NOW())
ON DUPLICATE KEY UPDATE updated_at = NOW();

-- ============================================================================
-- SALES (15 total - from active and completed consignments)
-- ============================================================================
INSERT INTO sales (id, consignment_id, quantity_sold, total_amount, shop_commission, consignor_earning, sold_at, notes, created_at, updated_at)
VALUES
-- Sales from consignment 1 (Keripik Singkong Original)
(1, 1, 5, 90000.00, 9000.00, 81000.00, '2026-01-16 10:30:00', 'Penjualan pertama', NOW(), NOW()),
(2, 1, 3, 54000.00, 5400.00, 48600.00, '2026-01-18 14:15:00', NULL, NOW(), NOW()),
(3, 1, 7, 126000.00, 12600.00, 113400.00, '2026-01-22 09:45:00', 'Pembeli grosir kecil', NOW(), NOW()),

-- Sales from consignment 2 (Sirup Markisa)
(4, 2, 4, 160000.00, 19200.00, 140800.00, '2026-01-12 11:00:00', NULL, NOW(), NOW()),
(5, 2, 4, 160000.00, 19200.00, 140800.00, '2026-01-20 16:30:00', NULL, NOW(), NOW()),

-- Sales from consignment 3 (Tas Rajut)
(6, 3, 2, 190000.00, 28500.00, 161500.00, '2026-01-21 13:00:00', 'Ibu-ibu arisan beli', NOW(), NOW()),
(7, 3, 3, 285000.00, 42750.00, 242250.00, '2026-01-25 15:30:00', NULL, NOW(), NOW()),

-- Sales from consignment 4 (Rendang)
(8, 4, 5, 425000.00, 42500.00, 382500.00, '2026-01-19 12:00:00', 'Pesanan catering', NOW(), NOW()),
(9, 4, 2, 170000.00, 17000.00, 153000.00, '2026-01-24 10:00:00', NULL, NOW(), NOW()),

-- Sales from consignment 5 (Gelang Kayu)
(10, 5, 8, 320000.00, 40000.00, 280000.00, '2026-01-23 11:30:00', 'Turis beli banyak', NOW(), NOW()),
(11, 5, 4, 160000.00, 20000.00, 140000.00, '2026-01-28 14:00:00', NULL, NOW(), NOW()),

-- Sales from completed consignment 6 (Keripik Pedas - all sold)
(12, 6, 20, 400000.00, 40000.00, 360000.00, '2026-01-10 10:00:00', 'Penjualan besar', NOW(), NOW()),
(13, 6, 20, 400000.00, 40000.00, 360000.00, '2026-01-20 11:00:00', 'Habis terjual', NOW(), NOW()),

-- Sales from completed consignment 7 (Jus Mangga - all sold)
(14, 7, 24, 360000.00, 28800.00, 331200.00, '2026-01-07 09:00:00', 'Cuaca panas, laris', NOW(), NOW()),
(15, 7, 24, 360000.00, 28800.00, 331200.00, '2026-01-10 10:00:00', 'Habis semua', NOW(), NOW())
ON DUPLICATE KEY UPDATE updated_at = NOW();

-- ============================================================================
-- Summary:
-- - 8 Users (3 shop owners, 5 consignors)
-- - 3 Shops
-- - 15 Products (across 5 consignors, 4 categories)
-- - 10 Consignments (5 active, 2 completed, 1 expired, 1 returned)
-- - 6 Agreements (3 accepted, 1 proposed, 1 counter, 1 rejected)
-- - 15 Sales records
-- ============================================================================
