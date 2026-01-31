import 'package:equatable/equatable.dart';

/// Shop model matching backend Shop entity.
class Shop extends Equatable {
  final int id;
  final String name;
  final String? address;
  final String? phone;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Shop({
    required this.id,
    required this.name,
    this.address,
    this.phone,
    this.description,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'description': description,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    address,
    phone,
    description,
    isActive,
    createdAt,
    updatedAt,
  ];
}
