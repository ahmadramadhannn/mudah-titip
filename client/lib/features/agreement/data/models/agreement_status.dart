/// Status of an agreement negotiation.
enum AgreementStatus {
  /// Initial proposal, waiting for response.
  proposed('PROPOSED'),

  /// Counter-offer made, waiting for response.
  counter('COUNTER'),

  /// Agreement accepted by both parties.
  accepted('ACCEPTED'),

  /// Agreement rejected, no deal.
  rejected('REJECTED');

  final String value;
  const AgreementStatus(this.value);

  /// Get display name in Indonesian.
  String get displayName => switch (this) {
    AgreementStatus.proposed => 'Menunggu Respons',
    AgreementStatus.counter => 'Penawaran Balik',
    AgreementStatus.accepted => 'Disetujui',
    AgreementStatus.rejected => 'Ditolak',
  };

  /// Parse from backend string value.
  static AgreementStatus fromString(String value) {
    return AgreementStatus.values.firstWhere(
      (s) => s.value == value.toUpperCase(),
      orElse: () => AgreementStatus.proposed,
    );
  }
}
