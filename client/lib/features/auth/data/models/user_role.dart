/// User roles matching backend UserRole enum.
enum UserRole {
  consignor('CONSIGNOR'),
  shopOwner('SHOP_OWNER'),
  superAdmin('SUPER_ADMIN'),
  moderator('MODERATOR'),
  financeAdmin('FINANCE_ADMIN');

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
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.moderator:
        return 'Moderator';
      case UserRole.financeAdmin:
        return 'Finance Admin';
    }
  }
}
