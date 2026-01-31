package com.ahmadramadhan.mudahtitip.auth;

import com.ahmadramadhan.mudahtitip.auth.dto.ProfileResponse;
import com.ahmadramadhan.mudahtitip.auth.dto.UpdateEmailRequest;
import com.ahmadramadhan.mudahtitip.auth.dto.UpdatePasswordRequest;
import com.ahmadramadhan.mudahtitip.auth.dto.UpdateProfileRequest;
import com.ahmadramadhan.mudahtitip.common.security.JwtUtil;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * REST controller for user profile management endpoints.
 */
@RestController
@RequestMapping("/api/profile")
@RequiredArgsConstructor
public class ProfileController {

    private final AuthService authService;
    private final JwtUtil jwtUtil;

    /**
     * Get current user's profile.
     */
    @GetMapping
    public ResponseEntity<ProfileResponse> getProfile(
            @RequestHeader("Authorization") String authHeader) {
        Long userId = extractUserId(authHeader);
        ProfileResponse response = authService.getProfile(userId);
        return ResponseEntity.ok(response);
    }

    /**
     * Update current user's profile (name and/or phone).
     */
    @PutMapping
    public ResponseEntity<ProfileResponse> updateProfile(
            @RequestHeader("Authorization") String authHeader,
            @Valid @RequestBody UpdateProfileRequest request) {
        Long userId = extractUserId(authHeader);
        ProfileResponse response = authService.updateProfile(userId, request);
        return ResponseEntity.ok(response);
    }

    /**
     * Update current user's email (requires password verification).
     */
    @PutMapping("/email")
    public ResponseEntity<ProfileResponse> updateEmail(
            @RequestHeader("Authorization") String authHeader,
            @Valid @RequestBody UpdateEmailRequest request) {
        Long userId = extractUserId(authHeader);
        ProfileResponse response = authService.updateEmail(userId, request);
        return ResponseEntity.ok(response);
    }

    /**
     * Update current user's password (requires current password verification).
     */
    @PutMapping("/password")
    public ResponseEntity<Void> updatePassword(
            @RequestHeader("Authorization") String authHeader,
            @Valid @RequestBody UpdatePasswordRequest request) {
        Long userId = extractUserId(authHeader);
        authService.updatePassword(userId, request);
        return ResponseEntity.ok().build();
    }

    private Long extractUserId(String authHeader) {
        String token = authHeader.replace("Bearer ", "");
        return jwtUtil.extractUserId(token);
    }
}
