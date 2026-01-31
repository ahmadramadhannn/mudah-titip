package com.ahmadramadhan.mudahtitip.auth;

import com.ahmadramadhan.mudahtitip.auth.dto.ProfileResponse;
import com.ahmadramadhan.mudahtitip.auth.dto.UpdateEmailRequest;
import com.ahmadramadhan.mudahtitip.auth.dto.UpdatePasswordRequest;
import com.ahmadramadhan.mudahtitip.auth.dto.UpdateProfileRequest;
import com.ahmadramadhan.mudahtitip.common.security.JwtUtil;
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

import java.time.LocalDateTime;
import java.util.Optional;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * Unit tests for AuthService profile management methods.
 */
@ExtendWith(MockitoExtension.class)
class ProfileServiceTest {

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

    private static final String ENCODED_PASSWORD = "encoded-password-hash";
    private static final Long USER_ID = 1L;

    private User testUser;

    @BeforeEach
    void setUp() {
        testUser = User.builder()
                .name("Test User")
                .email("test@example.com")
                .passwordHash(ENCODED_PASSWORD)
                .phone("081234567890")
                .role(UserRole.CONSIGNOR)
                .build();
        testUser.setId(USER_ID);
        testUser.setCreatedAt(LocalDateTime.now());
        testUser.setUpdatedAt(LocalDateTime.now());
    }

    @Nested
    @DisplayName("Get Profile")
    class GetProfileTests {

        @Test
        @DisplayName("should return user profile when user exists")
        void getProfile_success() {
            // given
            when(userRepository.findById(USER_ID)).thenReturn(Optional.of(testUser));

            // when
            ProfileResponse response = authService.getProfile(USER_ID);

            // then
            assertThat(response.getId()).isEqualTo(USER_ID);
            assertThat(response.getName()).isEqualTo("Test User");
            assertThat(response.getEmail()).isEqualTo("test@example.com");
            assertThat(response.getPhone()).isEqualTo("081234567890");
            assertThat(response.getRole()).isEqualTo(UserRole.CONSIGNOR);
        }

        @Test
        @DisplayName("should throw exception when user not found")
        void getProfile_userNotFound_fails() {
            // given
            when(userRepository.findById(USER_ID)).thenReturn(Optional.empty());

            // when/then
            assertThatThrownBy(() -> authService.getProfile(USER_ID))
                    .isInstanceOf(IllegalArgumentException.class)
                    .hasMessageContaining("User tidak ditemukan");
        }
    }

    @Nested
    @DisplayName("Update Profile")
    class UpdateProfileTests {

        @Test
        @DisplayName("should update name successfully")
        void updateProfile_name_success() {
            // given
            UpdateProfileRequest request = UpdateProfileRequest.builder()
                    .name("New Name")
                    .build();

            when(userRepository.findById(USER_ID)).thenReturn(Optional.of(testUser));
            when(userRepository.save(any(User.class))).thenAnswer(inv -> inv.getArgument(0));

            // when
            ProfileResponse response = authService.updateProfile(USER_ID, request);

            // then
            assertThat(response.getName()).isEqualTo("New Name");
            verify(userRepository).save(argThat(user -> user.getName().equals("New Name")));
        }

        @Test
        @DisplayName("should update phone successfully")
        void updateProfile_phone_success() {
            // given
            UpdateProfileRequest request = UpdateProfileRequest.builder()
                    .phone("089876543210")
                    .build();

            when(userRepository.findById(USER_ID)).thenReturn(Optional.of(testUser));
            when(userRepository.save(any(User.class))).thenAnswer(inv -> inv.getArgument(0));

            // when
            ProfileResponse response = authService.updateProfile(USER_ID, request);

            // then
            assertThat(response.getPhone()).isEqualTo("089876543210");
        }

        @Test
        @DisplayName("should clear phone when empty string provided")
        void updateProfile_clearPhone_success() {
            // given
            UpdateProfileRequest request = UpdateProfileRequest.builder()
                    .phone("")
                    .build();

            when(userRepository.findById(USER_ID)).thenReturn(Optional.of(testUser));
            when(userRepository.save(any(User.class))).thenAnswer(inv -> inv.getArgument(0));

            // when
            ProfileResponse response = authService.updateProfile(USER_ID, request);

            // then
            assertThat(response.getPhone()).isNull();
        }
    }

    @Nested
    @DisplayName("Update Email")
    class UpdateEmailTests {

        @Test
        @DisplayName("should update email with correct password")
        void updateEmail_success() {
            // given
            UpdateEmailRequest request = UpdateEmailRequest.builder()
                    .newEmail("newemail@example.com")
                    .currentPassword("correct-password")
                    .build();

            when(userRepository.findById(USER_ID)).thenReturn(Optional.of(testUser));
            when(passwordEncoder.matches("correct-password", ENCODED_PASSWORD)).thenReturn(true);
            when(userRepository.existsByEmail("newemail@example.com")).thenReturn(false);
            when(userRepository.save(any(User.class))).thenAnswer(inv -> inv.getArgument(0));

            // when
            ProfileResponse response = authService.updateEmail(USER_ID, request);

            // then
            assertThat(response.getEmail()).isEqualTo("newemail@example.com");
        }

        @Test
        @DisplayName("should fail with wrong password")
        void updateEmail_wrongPassword_fails() {
            // given
            UpdateEmailRequest request = UpdateEmailRequest.builder()
                    .newEmail("newemail@example.com")
                    .currentPassword("wrong-password")
                    .build();

            when(userRepository.findById(USER_ID)).thenReturn(Optional.of(testUser));
            when(passwordEncoder.matches("wrong-password", ENCODED_PASSWORD)).thenReturn(false);

            // when/then
            assertThatThrownBy(() -> authService.updateEmail(USER_ID, request))
                    .isInstanceOf(IllegalArgumentException.class)
                    .hasMessageContaining("Password saat ini salah");
        }

        @Test
        @DisplayName("should fail when email already exists")
        void updateEmail_emailExists_fails() {
            // given
            UpdateEmailRequest request = UpdateEmailRequest.builder()
                    .newEmail("existing@example.com")
                    .currentPassword("correct-password")
                    .build();

            when(userRepository.findById(USER_ID)).thenReturn(Optional.of(testUser));
            when(passwordEncoder.matches("correct-password", ENCODED_PASSWORD)).thenReturn(true);
            when(userRepository.existsByEmail("existing@example.com")).thenReturn(true);

            // when/then
            assertThatThrownBy(() -> authService.updateEmail(USER_ID, request))
                    .isInstanceOf(IllegalArgumentException.class)
                    .hasMessageContaining("Email sudah digunakan");
        }
    }

    @Nested
    @DisplayName("Update Password")
    class UpdatePasswordTests {

        @Test
        @DisplayName("should update password with correct current password")
        void updatePassword_success() {
            // given
            UpdatePasswordRequest request = UpdatePasswordRequest.builder()
                    .currentPassword("correct-password")
                    .newPassword("newPassword123")
                    .build();

            when(userRepository.findById(USER_ID)).thenReturn(Optional.of(testUser));
            when(passwordEncoder.matches("correct-password", ENCODED_PASSWORD)).thenReturn(true);
            when(passwordEncoder.encode("newPassword123")).thenReturn("new-encoded-hash");

            // when
            authService.updatePassword(USER_ID, request);

            // then
            verify(userRepository).save(argThat(user -> user.getPasswordHash().equals("new-encoded-hash")));
        }

        @Test
        @DisplayName("should fail with wrong current password")
        void updatePassword_wrongPassword_fails() {
            // given
            UpdatePasswordRequest request = UpdatePasswordRequest.builder()
                    .currentPassword("wrong-password")
                    .newPassword("newPassword123")
                    .build();

            when(userRepository.findById(USER_ID)).thenReturn(Optional.of(testUser));
            when(passwordEncoder.matches("wrong-password", ENCODED_PASSWORD)).thenReturn(false);

            // when/then
            assertThatThrownBy(() -> authService.updatePassword(USER_ID, request))
                    .isInstanceOf(IllegalArgumentException.class)
                    .hasMessageContaining("Password saat ini salah");

            verify(userRepository, never()).save(any());
        }
    }
}
