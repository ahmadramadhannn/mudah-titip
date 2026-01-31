import 'package:bloc_test/bloc_test.dart';
import 'package:client/core/error/failures.dart';
import 'package:client/features/agreement/data/models/agreement.dart';
import 'package:client/features/agreement/data/models/agreement_request.dart';
import 'package:client/features/agreement/data/models/agreement_status.dart';
import 'package:client/features/agreement/data/models/agreement_user.dart';
import 'package:client/features/agreement/data/models/commission_type.dart';
import 'package:client/features/agreement/data/models/settlement_result.dart';
import 'package:client/features/agreement/data/repositories/agreement_repository.dart';
import 'package:client/features/agreement/presentation/bloc/agreement_bloc.dart';
import 'package:client/features/dashboard/data/models/consignment.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAgreementRepository extends Mock implements AgreementRepository {}

void main() {
  late AgreementBloc bloc;
  late MockAgreementRepository mockRepository;

  setUp(() {
    mockRepository = MockAgreementRepository();
    bloc = AgreementBloc(mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  // Test fixtures
  final testProduct = ConsignmentProduct(
    id: 1,
    name: 'Test Product',
    category: 'Test Category',
    basePrice: 10000,
    imageUrl: null,
  );

  final testShop = ConsignmentShop(
    id: 1,
    name: 'Test Shop',
    address: 'Test Address',
  );

  final testConsignment = AgreementConsignment(
    id: 1,
    product: testProduct,
    shop: testShop,
    initialQuantity: 100,
    currentQuantity: 80,
    sellingPrice: 15000,
    status: ConsignmentStatus.active,
  );

  final testUser = AgreementUser(
    id: 1,
    name: 'Test User',
    email: 'test@example.com',
    role: 'CONSIGNOR',
  );

  final testAgreement = Agreement(
    id: 1,
    consignment: testConsignment,
    proposedBy: testUser,
    status: AgreementStatus.proposed,
    commissionType: CommissionType.percentage,
    commissionValue: 10,
    createdAt: DateTime.now(),
  );

  final testRequest = AgreementRequest(
    consignmentId: 1,
    commissionType: CommissionType.percentage,
    commissionValue: 10,
  );

  final testSettlement = SettlementResult(
    consignmentId: 1,
    productName: 'Test Product',
    shopName: 'Test Shop',
    consignorName: 'Test User',
    initialQuantity: 100,
    soldQuantity: 80,
    remainingQuantity: 20,
    soldPercentage: 80.0,
    totalSalesAmount: 1200000,
    shopCommission: 120000,
    bonusAmount: 0,
    totalShopEarning: 120000,
    consignorEarning: 1080000,
    commissionBreakdown: '10% per item',
    bonusApplied: false,
  );

  group('AgreementBloc', () {
    test('initial state is AgreementInitial', () {
      expect(bloc.state, const AgreementInitial());
    });

    group('LoadPendingAgreements', () {
      blocTest<AgreementBloc, AgreementState>(
        'emits [Loading, Loaded] when successful',
        build: () {
          when(
            () => mockRepository.getPendingAgreements(),
          ).thenAnswer((_) async => [testAgreement]);
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadPendingAgreements()),
        expect: () => [
          const AgreementLoading(),
          isA<AgreementsLoaded>().having(
            (s) => s.agreements.length,
            'agreements count',
            1,
          ),
        ],
        verify: (_) {
          verify(() => mockRepository.getPendingAgreements()).called(1);
        },
      );

      blocTest<AgreementBloc, AgreementState>(
        'emits [Loading, Error] when fails',
        build: () {
          when(
            () => mockRepository.getPendingAgreements(),
          ).thenThrow(const ServerFailure('Server error'));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadPendingAgreements()),
        expect: () => [
          const AgreementLoading(),
          const AgreementError('Server error'),
        ],
      );
    });

    group('ProposeAgreement', () {
      blocTest<AgreementBloc, AgreementState>(
        'emits [ActionInProgress, ActionSuccess] when successful',
        build: () {
          when(
            () => mockRepository.propose(testRequest),
          ).thenAnswer((_) async => testAgreement);
          return bloc;
        },
        act: (bloc) => bloc.add(ProposeAgreement(testRequest)),
        expect: () => [
          const AgreementActionInProgress(),
          isA<AgreementActionSuccess>(),
        ],
        verify: (_) {
          verify(() => mockRepository.propose(testRequest)).called(1);
        },
      );

      blocTest<AgreementBloc, AgreementState>(
        'emits [ActionInProgress, Error] when fails',
        build: () {
          when(
            () => mockRepository.propose(testRequest),
          ).thenThrow(const ValidationFailure('Invalid data'));
          return bloc;
        },
        act: (bloc) => bloc.add(ProposeAgreement(testRequest)),
        expect: () => [
          const AgreementActionInProgress(),
          const AgreementError('Invalid data'),
        ],
      );
    });

    group('AcceptAgreement', () {
      final acceptedAgreement = Agreement(
        id: 1,
        consignment: testConsignment,
        proposedBy: testUser,
        status: AgreementStatus.accepted,
        commissionType: CommissionType.percentage,
        commissionValue: 10,
        createdAt: DateTime.now(),
      );

      blocTest<AgreementBloc, AgreementState>(
        'emits [ActionInProgress, ActionSuccess] when successful',
        build: () {
          when(
            () => mockRepository.accept(1, message: null),
          ).thenAnswer((_) async => acceptedAgreement);
          return bloc;
        },
        act: (bloc) => bloc.add(const AcceptAgreement(agreementId: 1)),
        expect: () => [
          const AgreementActionInProgress(),
          isA<AgreementActionSuccess>().having(
            (s) => s.agreement.isAccepted,
            'isAccepted',
            true,
          ),
        ],
      );
    });

    group('RejectAgreement', () {
      final rejectedAgreement = Agreement(
        id: 1,
        consignment: testConsignment,
        proposedBy: testUser,
        status: AgreementStatus.rejected,
        commissionType: CommissionType.percentage,
        commissionValue: 10,
        responseMessage: 'Not acceptable',
        createdAt: DateTime.now(),
      );

      blocTest<AgreementBloc, AgreementState>(
        'emits [ActionInProgress, ActionSuccess] when successful',
        build: () {
          when(
            () => mockRepository.reject(1, reason: 'Not acceptable'),
          ).thenAnswer((_) async => rejectedAgreement);
          return bloc;
        },
        act: (bloc) => bloc.add(
          const RejectAgreement(agreementId: 1, reason: 'Not acceptable'),
        ),
        expect: () => [
          const AgreementActionInProgress(),
          isA<AgreementActionSuccess>().having(
            (s) => s.agreement.isRejected,
            'isRejected',
            true,
          ),
        ],
      );
    });

    group('LoadSettlement', () {
      blocTest<AgreementBloc, AgreementState>(
        'emits [Loading, SettlementLoaded] when successful',
        build: () {
          when(
            () => mockRepository.getSettlement(1),
          ).thenAnswer((_) async => testSettlement);
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadSettlement(1)),
        expect: () => [
          const AgreementLoading(),
          isA<SettlementLoaded>().having(
            (s) => s.settlement.consignmentId,
            'consignmentId',
            1,
          ),
        ],
      );
    });
  });
}
