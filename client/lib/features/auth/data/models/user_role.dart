/// User roles matching backend UserRole enum.
enum UserRole {
  consignor('CONSIGNOR'),
  shopOwner('SHOP_OWNER');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.consignor,
    );
  }

  String get displayName {
    switch (this) {
      case UserRole.consignor:
        return 'Penitip';
      case UserRole.shopOwner:
        return 'Pemilik Toko';
    }
  }
}
