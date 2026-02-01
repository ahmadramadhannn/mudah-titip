package com.ahmadramadhan.mudahtitip.auth;

import com.ahmadramadhan.mudahtitip.auth.dto.AuthResponse;
import com.ahmadramadhan.mudahtitip.auth.dto.LoginRequest;
import com.ahmadramadhan.mudahtitip.auth.dto.RegisterRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

import com.ahmadramadhan.mudahtitip.common.config.ApiV1Controller;

/**
 * REST controller for authentication endpoints.
 */
@ApiV1Controller
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        AuthResponse response = authService.register(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        AuthResponse response = authService.login(request);
        return ResponseEntity.ok(response);
    }
}
