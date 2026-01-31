import 'package:equatable/equatable.dart';

/// Request DTO for creating/updating a guest consignor.
class GuestConsignorRequest extends Equatable {
  final String name;
  final String phone;
  final String? address;
  final String? notes;

  const GuestConsignorRequest({
    required this.name,
    required this.phone,
    this.address,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      if (address != null && address!.isNotEmpty) 'address': address,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }

  @override
  List<Object?> get props => [name, phone, address, notes];
}
