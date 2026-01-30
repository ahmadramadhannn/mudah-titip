import 'user_role.dart';

/// Login request DTO.
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

/// Register request DTO with optional shop details.
class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final String? phone;
  final UserRole role;
  // Shop details (required if role is SHOP_OWNER)
  final String? shopName;
  final String? shopAddress;
  final String? shopPhone;
  final String? shopDescription;

  const RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    required this.role,
    this.shopName,
    this.shopAddress,
    this.shopPhone,
    this.shopDescription,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'name': name,
      'email': email,
      'password': password,
      'role': role.value,
    };

    if (phone != null) json['phone'] = phone;
    if (shopName != null) json['shopName'] = shopName;
    if (shopAddress != null) json['shopAddress'] = shopAddress;
    if (shopPhone != null) json['shopPhone'] = shopPhone;
    if (shopDescription != null) json['shopDescription'] = shopDescription;

    return json;
  }
}
