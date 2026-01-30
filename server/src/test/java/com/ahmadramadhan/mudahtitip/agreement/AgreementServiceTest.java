package com.ahmadramadhan.mudahtitip.agreement;

import com.ahmadramadhan.mudahtitip.agreement.dto.AgreementRequest;
import com.ahmadramadhan.mudahtitip.agreement.dto.SettlementResult;
import com.ahmadramadhan.mudahtitip.auth.User;
import com.ahmadramadhan.mudahtitip.auth.UserRole;
import com.ahmadramadhan.mudahtitip.consignment.Consignment;
import com.ahmadramadhan.mudahtitip.consignment.ConsignmentRepository;
import com.ahmadramadhan.mudahtitip.product.Product;
import com.ahmadramadhan.mudahtitip.sale.SaleRepository;
import com.ahmadramadhan.mudahtitip.shop.Shop;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.Optional;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * Unit tests for AgreementService.
 * Tests the agreement negotiation workflow and settlement calculations.
 */
@ExtendWith(MockitoExtension.class)
class AgreementServiceTest {

    @Mock
    private AgreementRepository agreementRepository;

    @Mock
    private ConsignmentRepository consignmentRepository;

    @Mock
    private SaleRepository saleRepository;

    @InjectMocks
    private AgreementService agreementService;

    private User consignor;
    private User shopOwner;
    private Shop shop;
    private Product product;
    private Consignment consignment;

    @BeforeEach
    void setUp() {
        consignor = User.builder()
                .name("Consignor Test")
                .email("consignor@test.com")
                .role(UserRole.CONSIGNOR)
                .build();
        consignor.setId(1L);

        shopOwner = User.builder()
                .name("Shop Owner Test")
                .email("shop@test.com")
                .role(UserRole.SHOP_OWNER)
                .build();
        shopOwner.setId(2L);

        shop = Shop.builder()
                .name("Test Shop")
                .owner(shopOwner)
                .build();
        shop.setId(1L);

        product = Product.builder()
                .name("Test Product")
                .basePrice(new BigDecimal("10000"))
                .owner(consignor)
                .build();
        product.setId(1L);

        consignment = Consignment.builder()
                .product(product)
                .shop(shop)
                .initialQuantity(100)
                .currentQuantity(50) // 50 sold
                .sellingPrice(new BigDecimal("12000"))
                .commissionPercent(new BigDecimal("10"))
                .build();
        consignment.setId(1L);
    }

    @Nested
    @DisplayName("Propose Agreement")
    class ProposeTests {

        @Test
        @DisplayName("should create new agreement with PROPOSED status")
        void propose_createsNewAgreement() {
            // given
            AgreementRequest request = AgreementRequest.builder()
                    .consignmentId(1L)
                    .commissionType(CommissionType.PERCENTAGE)
                    .commissionValue(new BigDecimal("15"))
                    .build();

            when(consignmentRepository.findById(1L)).thenReturn(Optional.of(consignment));
            when(agreementRepository.findByConsignmentIdAndStatus(1L, AgreementStatus.ACCEPTED))
                    .thenReturn(Optional.empty());
            when(agreementRepository.save(any(Agreement.class)))
                    .thenAnswer(inv -> inv.getArgument(0));

            // when
            Agreement result = agreementService.propose(request, consignor);

            // then
            assertThat(result.getStatus()).isEqualTo(AgreementStatus.PROPOSED);
            assertThat(result.getCommissionType()).isEqualTo(CommissionType.PERCENTAGE);
            assertThat(result.getCommissionValue()).isEqualByComparingTo("15");
            assertThat(result.getProposedBy()).isEqualTo(consignor);
            verify(agreementRepository).save(any(Agreement.class));
        }

        @Test
        @DisplayName("should fail when accepted agreement already exists")
        void propose_failsWhenAlreadyAccepted() {
            // given
            AgreementRequest request = AgreementRequest.builder()
                    .consignmentId(1L)
                    .commissionType(CommissionType.PERCENTAGE)
                    .commissionValue(new BigDecimal("15"))
                    .build();

            Agreement existingAgreement = Agreement.builder()
                    .status(AgreementStatus.ACCEPTED)
                    .build();

            when(consignmentRepository.findById(1L)).thenReturn(Optional.of(consignment));
            when(agreementRepository.findByConsignmentIdAndStatus(1L, AgreementStatus.ACCEPTED))
                    .thenReturn(Optional.of(existingAgreement));

            // when/then
            assertThatThrownBy(() -> agreementService.propose(request, consignor))
                    .isInstanceOf(IllegalStateException.class)
                    .hasMessageContaining("Sudah ada kesepakatan");
        }
    }

    @Nested
    @DisplayName("Counter Agreement")
    class CounterTests {

        @Test
        @DisplayName("should chain counter agreement to previous")
        void counter_chainsAgreements() {
            // given
            Agreement previous = Agreement.builder()
                    .consignment(consignment)
                    .proposedBy(consignor)
                    .status(AgreementStatus.PROPOSED)
                    .commissionType(CommissionType.PERCENTAGE)
                    .commissionValue(new BigDecimal("10"))
                    .build();
            previous.setId(1L);

            AgreementRequest counterRequest = AgreementRequest.builder()
                    .consignmentId(1L)
                    .commissionType(CommissionType.PERCENTAGE)
                    .commissionValue(new BigDecimal("12"))
                    .build();

            when(agreementRepository.findById(1L)).thenReturn(Optional.of(previous));
            when(agreementRepository.save(any(Agreement.class)))
                    .thenAnswer(inv -> inv.getArgument(0));

            // when
            Agreement result = agreementService.counter(1L, counterRequest, shopOwner);

            // then
            assertThat(result.getStatus()).isEqualTo(AgreementStatus.PROPOSED);
            assertThat(result.getPreviousVersion()).isEqualTo(previous);
            assertThat(result.getProposedBy()).isEqualTo(shopOwner);
            assertThat(previous.getStatus()).isEqualTo(AgreementStatus.COUNTER);
            verify(agreementRepository, times(2)).save(any(Agreement.class));
        }

        @Test
        @DisplayName("should fail when countering rejected agreement")
        void counter_failsOnRejectedStatus() {
            // given
            Agreement rejected = Agreement.builder()
                    .status(AgreementStatus.REJECTED)
                    .build();
            rejected.setId(1L);

            AgreementRequest request = AgreementRequest.builder()
                    .consignmentId(1L)
                    .commissionType(CommissionType.PERCENTAGE)
                    .commissionValue(new BigDecimal("12"))
                    .build();

            when(agreementRepository.findById(1L)).thenReturn(Optional.of(rejected));

            // when/then
            assertThatThrownBy(() -> agreementService.counter(1L, request, shopOwner))
                    .isInstanceOf(IllegalStateException.class)
                    .hasMessageContaining("Tidak bisa counter");
        }
    }

    @Nested
    @DisplayName("Accept Agreement")
    class AcceptTests {

        @Test
        @DisplayName("should update status to ACCEPTED")
        void accept_updatesStatus() {
            // given
            Agreement proposal = Agreement.builder()
                    .proposedBy(consignor)
                    .status(AgreementStatus.PROPOSED)
                    .build();
            proposal.setId(1L);

            when(agreementRepository.findById(1L)).thenReturn(Optional.of(proposal));
            when(agreementRepository.save(any(Agreement.class)))
                    .thenAnswer(inv -> inv.getArgument(0));

            // when
            Agreement result = agreementService.accept(1L, shopOwner, "Setuju!");

            // then
            assertThat(result.getStatus()).isEqualTo(AgreementStatus.ACCEPTED);
            assertThat(result.getResponseMessage()).isEqualTo("Setuju!");
        }

        @Test
        @DisplayName("should fail when accepting own proposal")
        void accept_failsOnOwnProposal() {
            // given
            Agreement proposal = Agreement.builder()
                    .proposedBy(consignor)
                    .status(AgreementStatus.PROPOSED)
                    .build();
            proposal.setId(1L);

            when(agreementRepository.findById(1L)).thenReturn(Optional.of(proposal));

            // when/then
            assertThatThrownBy(() -> agreementService.accept(1L, consignor, null))
                    .isInstanceOf(IllegalArgumentException.class)
                    .hasMessageContaining("Tidak bisa menerima proposal sendiri");
        }
    }

    @Nested
    @DisplayName("Reject Agreement")
    class RejectTests {

        @Test
        @DisplayName("should update status to REJECTED with reason")
        void reject_withReason() {
            // given
            Agreement proposal = Agreement.builder()
                    .proposedBy(consignor)
                    .status(AgreementStatus.PROPOSED)
                    .build();
            proposal.setId(1L);

            when(agreementRepository.findById(1L)).thenReturn(Optional.of(proposal));
            when(agreementRepository.save(any(Agreement.class)))
                    .thenAnswer(inv -> inv.getArgument(0));

            // when
            Agreement result = agreementService.reject(1L, shopOwner, "Komisi terlalu kecil");

            // then
            assertThat(result.getStatus()).isEqualTo(AgreementStatus.REJECTED);
            assertThat(result.getResponseMessage()).isEqualTo("Komisi terlalu kecil");
        }
    }

    @Nested
    @DisplayName("Calculate Settlement")
    class SettlementTests {

        @Test
        @DisplayName("should calculate percentage commission correctly")
        void calculateSettlement_percentageCommission() {
            // given: 50 out of 100 sold at Rp12.000 with 15% commission
            Agreement agreement = Agreement.builder()
                    .consignment(consignment)
                    .commissionType(CommissionType.PERCENTAGE)
                    .commissionValue(new BigDecimal("15"))
                    .status(AgreementStatus.ACCEPTED)
                    .build();

            when(consignmentRepository.findById(1L)).thenReturn(Optional.of(consignment));
            when(agreementRepository.findByConsignmentIdAndStatus(1L, AgreementStatus.ACCEPTED))
                    .thenReturn(Optional.of(agreement));

            // when
            SettlementResult result = agreementService.calculateSettlement(1L);

            // then
            // Total sales: 50 × 12.000 = 600.000
            // Commission: 15% × 600.000 = 90.000
            assertThat(result.getSoldQuantity()).isEqualTo(50);
            assertThat(result.getTotalSalesAmount()).isEqualByComparingTo("600000");
            assertThat(result.getShopCommission()).isEqualByComparingTo("90000");
            assertThat(result.getConsignorEarning()).isEqualByComparingTo("510000");
        }

        @Test
        @DisplayName("should calculate fixed per item commission correctly")
        void calculateSettlement_fixedPerItem() {
            // given: 50 sold at Rp2.000 fixed per item
            Agreement agreement = Agreement.builder()
                    .consignment(consignment)
                    .commissionType(CommissionType.FIXED_PER_ITEM)
                    .commissionValue(new BigDecimal("2000"))
                    .status(AgreementStatus.ACCEPTED)
                    .build();

            when(consignmentRepository.findById(1L)).thenReturn(Optional.of(consignment));
            when(agreementRepository.findByConsignmentIdAndStatus(1L, AgreementStatus.ACCEPTED))
                    .thenReturn(Optional.of(agreement));

            // when
            SettlementResult result = agreementService.calculateSettlement(1L);

            // then
            // Total sales: 50 × 12.000 = 600.000
            // Commission: 2.000 × 50 = 100.000
            assertThat(result.getShopCommission()).isEqualByComparingTo("100000");
            assertThat(result.getConsignorEarning()).isEqualByComparingTo("500000");
        }

        @Test
        @DisplayName("should apply tiered bonus when threshold met")
        void calculateSettlement_tieredBonus_thresholdMet() {
            // given: 50% sold (50 of 100), threshold 40%, bonus 50.000
            Agreement agreement = Agreement.builder()
                    .consignment(consignment)
                    .commissionType(CommissionType.TIERED_BONUS)
                    .bonusThresholdPercent(40)
                    .bonusAmount(new BigDecimal("50000"))
                    .status(AgreementStatus.ACCEPTED)
                    .build();

            when(consignmentRepository.findById(1L)).thenReturn(Optional.of(consignment));
            when(agreementRepository.findByConsignmentIdAndStatus(1L, AgreementStatus.ACCEPTED))
                    .thenReturn(Optional.of(agreement));

            // when
            SettlementResult result = agreementService.calculateSettlement(1L);

            // then
            // Sold 50% >= 40% threshold, so bonus applies
            assertThat(result.isBonusApplied()).isTrue();
            assertThat(result.getBonusAmount()).isEqualByComparingTo("50000");
            assertThat(result.getTotalShopEarning()).isEqualByComparingTo("50000");
        }

        @Test
        @DisplayName("should not apply bonus when threshold not met")
        void calculateSettlement_tieredBonus_thresholdNotMet() {
            // given: 50% sold but threshold is 60%
            Agreement agreement = Agreement.builder()
                    .consignment(consignment)
                    .commissionType(CommissionType.TIERED_BONUS)
                    .bonusThresholdPercent(60)
                    .bonusAmount(new BigDecimal("50000"))
                    .status(AgreementStatus.ACCEPTED)
                    .build();

            when(consignmentRepository.findById(1L)).thenReturn(Optional.of(consignment));
            when(agreementRepository.findByConsignmentIdAndStatus(1L, AgreementStatus.ACCEPTED))
                    .thenReturn(Optional.of(agreement));

            // when
            SettlementResult result = agreementService.calculateSettlement(1L);

            // then
            // Sold 50% < 60% threshold, no bonus
            assertThat(result.isBonusApplied()).isFalse();
            assertThat(result.getBonusAmount()).isEqualByComparingTo("0");
        }
    }
}
