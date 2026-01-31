import 'package:equatable/equatable.dart';

import '../../../dashboard/data/models/consignment.dart';
import 'agreement_status.dart';
import 'agreement_user.dart';
import 'commission_type.dart';

/// Agreement model representing negotiated terms between shop owner and consignor.
class Agreement extends Equatable {
  final int id;
  final AgreementConsignment consignment;
  final AgreementUser proposedBy;
  final AgreementStatus status;
  final CommissionType commissionType;

  /// For PERCENTAGE: the percentage value (e.g., 10 for 10%)
  /// For FIXED_PER_ITEM: the amount per item (e.g., 2000 for Rp2.000)
  final double? commissionValue;

  /// For TIERED_BONUS: minimum percentage of items that must be sold
  final int? bonusThresholdPercent;

  /// For TIERED_BONUS: bonus amount if threshold is met
  final double? bonusAmount;

  /// Additional notes or terms for this agreement.
  final String? termsNote;

  /// Message explaining counter-offer or rejection reason.
  final String? responseMessage;

  /// Reference to the previous agreement version in negotiation chain.
  final int? previousVersionId;

  final DateTime createdAt;
  final DateTime? updatedAt;

  const Agreement({
    required this.id,
    required this.consignment,
    required this.proposedBy,
    required this.status,
    required this.commissionType,
    this.commissionValue,
    this.bonusThresholdPercent,
    this.bonusAmount,
    this.termsNote,
    this.responseMessage,
    this.previousVersionId,
    required this.createdAt,
    this.updatedAt,
  });

  factory Agreement.fromJson(Map<String, dynamic> json) {
    return Agreement(
      id: json['id'] as int,
      consignment: AgreementConsignment.fromJson(
        json['consignment'] as Map<String, dynamic>,
      ),
      proposedBy: AgreementUser.fromJson(
        json['proposedBy'] as Map<String, dynamic>,
      ),
      status: AgreementStatus.fromString(json['status'] as String),
      commissionType: CommissionType.fromString(
        json['commissionType'] as String,
      ),
      commissionValue: json['commissionValue'] != null
          ? (json['commissionValue'] as num).toDouble()
          : null,
      bonusThresholdPercent: json['bonusThresholdPercent'] as int?,
      bonusAmount: json['bonusAmount'] != null
          ? (json['bonusAmount'] as num).toDouble()
          : null,
      termsNote: json['termsNote'] as String?,
      responseMessage: json['responseMessage'] as String?,
      previousVersionId: json['previousVersion'] is Map
          ? (json['previousVersion'] as Map)['id'] as int?
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Check if this agreement is pending (waiting for response).
  bool get isPending =>
      status == AgreementStatus.proposed || status == AgreementStatus.counter;

  /// Check if this agreement was accepted.
  bool get isAccepted => status == AgreementStatus.accepted;

  /// Check if this agreement was rejected.
  bool get isRejected => status == AgreementStatus.rejected;

  /// Get formatted commission description.
  String get commissionDescription {
    switch (commissionType) {
      case CommissionType.percentage:
        return '${commissionValue?.toStringAsFixed(0) ?? 0}% per penjualan';
      case CommissionType.fixedPerItem:
        return 'Rp${commissionValue?.toStringAsFixed(0) ?? 0} per item';
      case CommissionType.tieredBonus:
        return 'Bonus Rp${bonusAmount?.toStringAsFixed(0) ?? 0} jika terjual ${bonusThresholdPercent ?? 0}%';
    }
  }

  @override
  List<Object?> get props => [
    id,
    consignment,
    proposedBy,
    status,
    commissionType,
    commissionValue,
    bonusThresholdPercent,
    bonusAmount,
    termsNote,
    responseMessage,
    previousVersionId,
    createdAt,
    updatedAt,
  ];
}

/// Simplified consignment for agreement response.
class AgreementConsignment extends Equatable {
  final int id;
  final ConsignmentProduct product;
  final ConsignmentShop shop;
  final int initialQuantity;
  final int currentQuantity;
  final double sellingPrice;
  final ConsignmentStatus status;

  const AgreementConsignment({
    required this.id,
    required this.product,
    required this.shop,
    required this.initialQuantity,
    required this.currentQuantity,
    required this.sellingPrice,
    required this.status,
  });

  factory AgreementConsignment.fromJson(Map<String, dynamic> json) {
    return AgreementConsignment(
      id: json['id'] as int,
      product: ConsignmentProduct.fromJson(
        json['product'] as Map<String, dynamic>,
      ),
      shop: ConsignmentShop.fromJson(json['shop'] as Map<String, dynamic>),
      initialQuantity: json['initialQuantity'] as int,
      currentQuantity: json['currentQuantity'] as int,
      sellingPrice: (json['sellingPrice'] as num).toDouble(),
      status: ConsignmentStatus.fromString(json['status'] as String),
    );
  }

  @override
  List<Object?> get props => [
    id,
    product,
    shop,
    initialQuantity,
    currentQuantity,
    sellingPrice,
    status,
  ];
}
