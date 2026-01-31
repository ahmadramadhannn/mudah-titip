/// Type of commission in an agreement.
enum CommissionType {
  /// Shop gets a percentage of each sale.
  /// commission_value = percentage (e.g., 10 for 10%)
  percentage('PERCENTAGE'),

  /// Shop gets a fixed amount per item sold.
  /// commission_value = amount per item (e.g., 2000 for Rp2.000)
  fixedPerItem('FIXED_PER_ITEM'),

  /// Shop gets a bonus if sales reach a threshold.
  /// bonus_threshold_percent = minimum sold percentage (e.g., 90)
  /// bonus_amount = bonus to pay if threshold met
  tieredBonus('TIERED_BONUS');

  final String value;
  const CommissionType(this.value);

  /// Get display name in Indonesian.
  String get displayName => switch (this) {
    CommissionType.percentage => 'Persentase',
    CommissionType.fixedPerItem => 'Per Item',
    CommissionType.tieredBonus => 'Bonus Bertingkat',
  };

  /// Get description in Indonesian.
  String get description => switch (this) {
    CommissionType.percentage =>
      'Toko mendapat persentase dari setiap penjualan',
    CommissionType.fixedPerItem =>
      'Toko mendapat jumlah tetap per item terjual',
    CommissionType.tieredBonus =>
      'Toko mendapat bonus jika penjualan mencapai target',
  };

  /// Parse from backend string value.
  static CommissionType fromString(String value) {
    return CommissionType.values.firstWhere(
      (t) => t.value == value.toUpperCase(),
      orElse: () => CommissionType.percentage,
    );
  }
}
