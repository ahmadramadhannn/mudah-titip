import 'package:equatable/equatable.dart';

/// Guest consignor model - consignor managed by shop owner without app account.
class GuestConsignor extends Equatable {
  final int id;
  final String name;
  final String phone;
  final String? address;
  final String? notes;
  final int managedById;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const GuestConsignor({
    required this.id,
    required this.name,
    required this.phone,
    this.address,
    this.notes,
    required this.managedById,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GuestConsignor.fromJson(Map<String, dynamic> json) {
    return GuestConsignor(
      id: json['id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String?,
      notes: json['notes'] as String?,
      managedById: json['managedBy']?['id'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'notes': notes,
      'isActive': isActive,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    phone,
    address,
    notes,
    managedById,
    isActive,
    createdAt,
    updatedAt,
  ];
}
