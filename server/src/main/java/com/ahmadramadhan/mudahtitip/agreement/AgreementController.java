package com.ahmadramadhan.mudahtitip.agreement;

import com.ahmadramadhan.mudahtitip.agreement.dto.AgreementRequest;
import com.ahmadramadhan.mudahtitip.agreement.dto.SettlementResult;
import com.ahmadramadhan.mudahtitip.auth.User;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import com.ahmadramadhan.mudahtitip.common.config.ApiV1Controller;

import java.util.List;
import java.util.Map;

/**
 * REST controller for agreement negotiation.
 */
@ApiV1Controller
@RequestMapping("/api/v1/agreements")
@RequiredArgsConstructor
public class AgreementController {

    private final AgreementService agreementService;

    /**
     * Propose a new agreement for a consignment.
     */
    @PostMapping("/propose")
    public ResponseEntity<Agreement> propose(
            @Valid @RequestBody AgreementRequest request,
            @AuthenticationPrincipal User currentUser) {
        Agreement agreement = agreementService.propose(request, currentUser);
        return ResponseEntity.ok(agreement);
    }

    /**
     * Counter an existing proposal.
     */
    @PostMapping("/{id}/counter")
    public ResponseEntity<Agreement> counter(
            @PathVariable Long id,
            @Valid @RequestBody AgreementRequest request,
            @AuthenticationPrincipal User currentUser) {
        Agreement agreement = agreementService.counter(id, request, currentUser);
        return ResponseEntity.ok(agreement);
    }

    /**
     * Accept a proposal.
     */
    @PostMapping("/{id}/accept")
    public ResponseEntity<Agreement> accept(
            @PathVariable Long id,
            @RequestBody(required = false) Map<String, String> body,
            @AuthenticationPrincipal User currentUser) {
        String message = body != null ? body.get("message") : null;
        Agreement agreement = agreementService.accept(id, currentUser, message);
        return ResponseEntity.ok(agreement);
    }

    /**
     * Reject a proposal.
     */
    @PostMapping("/{id}/reject")
    public ResponseEntity<Agreement> reject(
            @PathVariable Long id,
            @RequestBody(required = false) Map<String, String> body,
            @AuthenticationPrincipal User currentUser) {
        String reason = body != null ? body.get("reason") : null;
        Agreement agreement = agreementService.reject(id, currentUser, reason);
        return ResponseEntity.ok(agreement);
    }

    /**
     * Get pending agreements for current user to respond to.
     */
    @GetMapping("/pending")
    public ResponseEntity<List<Agreement>> getPending(@AuthenticationPrincipal User currentUser) {
        List<Agreement> pending = agreementService.getPendingAgreements(currentUser);
        return ResponseEntity.ok(pending);
    }

    /**
     * Calculate settlement for a consignment.
     */
    @GetMapping("/settlement/{consignmentId}")
    public ResponseEntity<SettlementResult> getSettlement(@PathVariable Long consignmentId) {
        SettlementResult result = agreementService.calculateSettlement(consignmentId);
        return ResponseEntity.ok(result);
    }
}
