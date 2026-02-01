import 'package:equatable/equatable.dart';

/// Request model for recording a sale.
class SaleRequest extends Equatable {
  final int consignmentId;
  final int quantity;
  final String? notes;

  const SaleRequest({
    required this.consignmentId,
    required this.quantity,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'consignmentId': consignmentId,
      'quantity': quantity,
      if (notes != null) 'notes': notes,
    };
  }

  @override
  List<Object?> get props => [consignmentId, quantity, notes];
}
