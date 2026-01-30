package com.ahmadramadhan.mudahtitip.auth;

import com.ahmadramadhan.mudahtitip.auth.dto.AuthResponse;
import com.ahmadramadhan.mudahtitip.auth.dto.LoginRequest;
import com.ahmadramadhan.mudahtitip.auth.dto.RegisterRequest;
import com.ahmadramadhan.mudahtitip.common.security.JwtUtil;
import com.ahmadramadhan.mudahtitip.shop.Shop;
import com.ahmadramadhan.mudahtitip.shop.ShopRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Optional;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * Unit tests for AuthService.
 * Tests user registration and login functionality.
 */
@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private ShopRepository shopRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private JwtUtil jwtUtil;

    @InjectMocks
    private AuthService authService;

    private static final String TEST_TOKEN = "test-jwt-token";
    private static final String ENCODED_PASSWORD = "encoded-password-hash";

    @BeforeEach
    void setUp() {
        lenient().when(passwordEncoder.encode(anyString())).thenReturn(ENCODED_PASSWORD);
        lenient().when(jwtUtil.generateToken(anyString(), anyLong(), anyString())).thenReturn(TEST_TOKEN);
    }

    @Nested
    @DisplayName("Register")
    class RegisterTests {

        @Test
        @DisplayName("should register consignor without creating shop")
        void register_consignor_success() {
            // given
            RegisterRequest request = RegisterRequest.builder()
                    .name("Test Consignor")
                    .email("consignor@test.com")
                    .password("password123")
                    .phone("081234567890")
                    .role(UserRole.CONSIGNOR)
                    .build();

            when(userRepository.existsByEmail("consignor@test.com")).thenReturn(false);
            when(userRepository.save(any(User.class))).thenAnswer(inv -> {
                User user = inv.getArgument(0);
                user.setId(1L);
                return user;
            });

            // when
            AuthResponse response = authService.register(request);

            // then
            assertThat(response.getToken()).isEqualTo(TEST_TOKEN);
            assertThat(response.getRole()).isEqualTo(UserRole.CONSIGNOR);
            assertThat(response.getName()).isEqualTo("Test Consignor");
            assertThat(response.getShopId()).isNull();
            verify(shopRepository, never()).save(any(Shop.class));
        }

        @Test
        @DisplayName("should register shop owner and create shop")
        void register_shopOwner_createsShop() {
            // given
            RegisterRequest request = RegisterRequest.builder()
                    .name("Shop Owner")
                    .email("shop@test.com")
                    .password("password123")
                    .role(UserRole.SHOP_OWNER)
                    .shopName("Toko Baru")
                    .shopAddress("Jl. Test No. 123")
                    .shopPhone("081234567890")
                    .build();

            when(userRepository.existsByEmail("shop@test.com")).thenReturn(false);
            when(userRepository.save(any(User.class))).thenAnswer(inv -> {
                User user = inv.getArgument(0);
                user.setId(1L);
                return user;
            });
            when(shopRepository.save(any(Shop.class))).thenAnswer(inv -> {
                Shop shop = inv.getArgument(0);
                shop.setId(1L);
                return shop;
            });

            // when
            AuthResponse response = authService.register(request);

            // then
            assertThat(response.getRole()).isEqualTo(UserRole.SHOP_OWNER);
            assertThat(response.getShopId()).isEqualTo(1L);
            verify(shopRepository).save(any(Shop.class));
        }

        @Test
        @DisplayName("should fail when email already exists")
        void register_duplicateEmail_fails() {
            // given
            RegisterRequest request = RegisterRequest.builder()
                    .name("Test User")
                    .email("existing@test.com")
                    .password("password123")
                    .role(UserRole.CONSIGNOR)
                    .build();

            when(userRepository.existsByEmail("existing@test.com")).thenReturn(true);

            // when/then
            assertThatThrownBy(() -> authService.register(request))
                    .isInstanceOf(IllegalArgumentException.class)
                    .hasMessageContaining("Email sudah terdaftar");
        }

        @Test
        @DisplayName("should fail when shop owner without shop name")
        void register_shopOwnerWithoutName_fails() {
            // given
            RegisterRequest request = RegisterRequest.builder()
                    .name("Shop Owner")
                    .email("shop@test.com")
                    .password("password123")
                    .role(UserRole.SHOP_OWNER)
                    // shopName is null
                    .build();

            when(userRepository.existsByEmail("shop@test.com")).thenReturn(false);

            // when/then
            assertThatThrownBy(() -> authService.register(request))
                    .isInstanceOf(IllegalArgumentException.class)
                    .hasMessageContaining("Nama toko wajib diisi");
        }
    }

    @Nested
    @DisplayName("Login")
    class LoginTests {

        @Test
        @DisplayName("should return token on successful login")
        void login_success() {
            // given
            User user = User.builder()
                    .name("Test User")
                    .email("user@test.com")
                    .passwordHash(ENCODED_PASSWORD)
                    .role(UserRole.CONSIGNOR)
                    .build();
            user.setId(1L);

            LoginRequest request = LoginRequest.builder()
                    .email("user@test.com")
                    .password("password123")
                    .build();

            when(userRepository.findByEmail("user@test.com")).thenReturn(Optional.of(user));
            when(passwordEncoder.matches("password123", ENCODED_PASSWORD)).thenReturn(true);

            // when
            AuthResponse response = authService.login(request);

            // then
            assertThat(response.getToken()).isEqualTo(TEST_TOKEN);
            assertThat(response.getUserId()).isEqualTo(1L);
            assertThat(response.getName()).isEqualTo("Test User");
        }

        @Test
        @DisplayName("should fail on wrong password")
        void login_wrongPassword_fails() {
            // given
            User user = User.builder()
                    .email("user@test.com")
                    .passwordHash(ENCODED_PASSWORD)
                    .build();
            user.setId(1L);

            LoginRequest request = LoginRequest.builder()
                    .email("user@test.com")
                    .password("wrong-password")
                    .build();

            when(userRepository.findByEmail("user@test.com")).thenReturn(Optional.of(user));
            when(passwordEncoder.matches("wrong-password", ENCODED_PASSWORD)).thenReturn(false);

            // when/then
            assertThatThrownBy(() -> authService.login(request))
                    .isInstanceOf(IllegalArgumentException.class)
                    .hasMessageContaining("Email atau password salah");
        }

        @Test
        @DisplayName("should fail on non-existent email")
        void login_nonExistentEmail_fails() {
            // given
            LoginRequest request = LoginRequest.builder()
                    .email("nonexistent@test.com")
                    .password("password123")
                    .build();

            when(userRepository.findByEmail("nonexistent@test.com")).thenReturn(Optional.empty());

            // when/then
            assertThatThrownBy(() -> authService.login(request))
                    .isInstanceOf(IllegalArgumentException.class)
                    .hasMessageContaining("Email atau password salah");
        }
    }
}
