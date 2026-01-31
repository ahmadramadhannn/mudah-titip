import 'commission_type.dart';

/// DTO for proposing or countering an agreement.
class AgreementRequest {
  final int consignmentId;
  final CommissionType commissionType;

  /// For PERCENTAGE: the percentage (e.g., 10 for 10%)
  /// For FIXED_PER_ITEM: amount per item (e.g., 2000)
  final double? commissionValue;

  /// For TIERED_BONUS: minimum sold percentage to trigger bonus
  final int? bonusThresholdPercent;

  /// For TIERED_BONUS: bonus amount when threshold is met
  final double? bonusAmount;

  /// Additional terms or notes.
  final String? termsNote;

  const AgreementRequest({
    required this.consignmentId,
    required this.commissionType,
    this.commissionValue,
    this.bonusThresholdPercent,
    this.bonusAmount,
    this.termsNote,
  });

  Map<String, dynamic> toJson() => {
    'consignmentId': consignmentId,
    'commissionType': commissionType.value,
    if (commissionValue != null) 'commissionValue': commissionValue,
    if (bonusThresholdPercent != null)
      'bonusThresholdPercent': bonusThresholdPercent,
    if (bonusAmount != null) 'bonusAmount': bonusAmount,
    if (termsNote != null) 'termsNote': termsNote,
  };
}

/// Request for accepting an agreement.
class AcceptAgreementRequest {
  final String? message;

  const AcceptAgreementRequest({this.message});

  Map<String, dynamic> toJson() => {if (message != null) 'message': message};
}

/// Request for rejecting an agreement.
class RejectAgreementRequest {
  final String? reason;

  const RejectAgreementRequest({this.reason});

  Map<String, dynamic> toJson() => {if (reason != null) 'reason': reason};
}
