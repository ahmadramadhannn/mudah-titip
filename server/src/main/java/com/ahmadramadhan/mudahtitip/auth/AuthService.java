package com.ahmadramadhan.mudahtitip.auth;

import com.ahmadramadhan.mudahtitip.auth.dto.AuthResponse;
import com.ahmadramadhan.mudahtitip.auth.dto.LoginRequest;
import com.ahmadramadhan.mudahtitip.auth.dto.ProfileResponse;
import com.ahmadramadhan.mudahtitip.auth.dto.RegisterRequest;
import com.ahmadramadhan.mudahtitip.auth.dto.UpdateEmailRequest;
import com.ahmadramadhan.mudahtitip.auth.dto.UpdatePasswordRequest;
import com.ahmadramadhan.mudahtitip.auth.dto.UpdateProfileRequest;
import com.ahmadramadhan.mudahtitip.common.security.JwtUtil;
import com.ahmadramadhan.mudahtitip.shop.Shop;
import com.ahmadramadhan.mudahtitip.shop.ShopRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Service handling user authentication (registration and login).
 */
@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final ShopRepository shopRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    /**
     * Register a new user. If role is SHOP_OWNER, also creates a shop.
     */
    @Transactional
    public AuthResponse register(RegisterRequest request) {
        // Check if email already exists
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new IllegalArgumentException("Email sudah terdaftar");
        }

        // Validate shop details for shop owners
        if (request.getRole() == UserRole.SHOP_OWNER) {
            if (request.getShopName() == null || request.getShopName().isBlank()) {
                throw new IllegalArgumentException("Nama toko wajib diisi untuk pemilik toko");
            }
        }

        // Create user
        User user = User.builder()
                .name(request.getName())
                .email(request.getEmail())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .phone(request.getPhone())
                .role(request.getRole())
                .build();

        user = userRepository.save(user);

        Long shopId = null;

        // Create shop if user is shop owner
        if (request.getRole() == UserRole.SHOP_OWNER) {
            Shop shop = Shop.builder()
                    .name(request.getShopName())
                    .address(request.getShopAddress())
                    .phone(request.getShopPhone())
                    .description(request.getShopDescription())
                    .owner(user)
                    .isActive(true)
                    .build();

            shop = shopRepository.save(shop);
            shopId = shop.getId();
        }

        // Generate JWT token
        String token = jwtUtil.generateToken(user.getEmail(), user.getId(), user.getRole().name());

        return AuthResponse.builder()
                .token(token)
                .tokenType("Bearer")
                .userId(user.getId())
                .name(user.getName())
                .email(user.getEmail())
                .role(user.getRole())
                .shopId(shopId)
                .build();
    }

    /**
     * Authenticate user and return JWT token.
     */
    public AuthResponse login(LoginRequest request) {
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new IllegalArgumentException("Email atau password salah"));

        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw new IllegalArgumentException("Email atau password salah");
        }

        Long shopId = null;
        if (user.getRole() == UserRole.SHOP_OWNER) {
            shopId = shopRepository.findByOwner(user)
                    .map(Shop::getId)
                    .orElse(null);
        }

        String token = jwtUtil.generateToken(user.getEmail(), user.getId(), user.getRole().name());

        return AuthResponse.builder()
                .token(token)
                .tokenType("Bearer")
                .userId(user.getId())
                .name(user.getName())
                .email(user.getEmail())
                .role(user.getRole())
                .shopId(shopId)
                .build();
    }

    /**
     * Get user profile by ID.
     */
    public ProfileResponse getProfile(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User tidak ditemukan"));
        return ProfileResponse.fromUser(user);
    }

    /**
     * Update user profile (name and/or phone).
     */
    @Transactional
    public ProfileResponse updateProfile(Long userId, UpdateProfileRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User tidak ditemukan"));

        if (request.getName() != null && !request.getName().isBlank()) {
            user.setName(request.getName());
        }
        if (request.getPhone() != null) {
            user.setPhone(request.getPhone().isBlank() ? null : request.getPhone());
        }

        user = userRepository.save(user);
        return ProfileResponse.fromUser(user);
    }

    /**
     * Update user email with password verification.
     */
    @Transactional
    public ProfileResponse updateEmail(Long userId, UpdateEmailRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User tidak ditemukan"));

        // Verify current password
        if (!passwordEncoder.matches(request.getCurrentPassword(), user.getPasswordHash())) {
            throw new IllegalArgumentException("Password saat ini salah");
        }

        // Check if new email is already taken
        if (!user.getEmail().equals(request.getNewEmail())
                && userRepository.existsByEmail(request.getNewEmail())) {
            throw new IllegalArgumentException("Email sudah digunakan");
        }

        user.setEmail(request.getNewEmail());
        user = userRepository.save(user);
        return ProfileResponse.fromUser(user);
    }

    /**
     * Update user password with current password verification.
     */
    @Transactional
    public void updatePassword(Long userId, UpdatePasswordRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User tidak ditemukan"));

        // Verify current password
        if (!passwordEncoder.matches(request.getCurrentPassword(), user.getPasswordHash())) {
            throw new IllegalArgumentException("Password saat ini salah");
        }

        user.setPasswordHash(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);
    }
}
