import 'package:equatable/equatable.dart';

/// Request model for creating a consignment.
class ConsignmentRequest extends Equatable {
  final int productId;
  final int shopId;
  final int quantity;
  final double sellingPrice;
  final double commissionPercent;
  final DateTime? consignmentDate;
  final DateTime? expiryDate;
  final String? notes;

  const ConsignmentRequest({
    required this.productId,
    required this.shopId,
    required this.quantity,
    required this.sellingPrice,
    this.commissionPercent = 0.0, // Default to 0 for shop owner flow
    this.consignmentDate,
    this.expiryDate,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'shopId': shopId,
      'quantity': quantity,
      'sellingPrice': sellingPrice,
      'commissionPercent': commissionPercent,
      if (consignmentDate != null)
        'consignmentDate': consignmentDate!.toIso8601String().split('T')[0],
      if (expiryDate != null)
        'expiryDate': expiryDate!.toIso8601String().split('T')[0],
      if (notes != null) 'notes': notes,
    };
  }

  @override
  List<Object?> get props => [
    productId,
    shopId,
    quantity,
    sellingPrice,
    commissionPercent,
    consignmentDate,
    expiryDate,
    notes,
  ];
}
