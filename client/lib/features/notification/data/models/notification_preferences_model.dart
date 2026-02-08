/// Model for notification preferences.
class NotificationPreferencesModel {
  final bool stockLowEnabled;
  final bool stockOutEnabled;
  final int lowStockThreshold;
  final bool weeklySummaryEnabled;
  final bool agreementUpdatesEnabled;
  final bool salesNotificationsEnabled;
  final bool expiryRemindersEnabled;
  final int expiryReminderDays;
  final bool payoutNotificationsEnabled;

  NotificationPreferencesModel({
    required this.stockLowEnabled,
    required this.stockOutEnabled,
    required this.lowStockThreshold,
    required this.weeklySummaryEnabled,
    required this.agreementUpdatesEnabled,
    required this.salesNotificationsEnabled,
    required this.expiryRemindersEnabled,
    required this.expiryReminderDays,
    required this.payoutNotificationsEnabled,
  });

  factory NotificationPreferencesModel.fromJson(Map<String, dynamic> json) {
    return NotificationPreferencesModel(
      stockLowEnabled: json['stockLowEnabled'] as bool? ?? true,
      stockOutEnabled: json['stockOutEnabled'] as bool? ?? true,
      lowStockThreshold: json['lowStockThreshold'] as int? ?? 5,
      weeklySummaryEnabled: json['weeklySummaryEnabled'] as bool? ?? false,
      agreementUpdatesEnabled: json['agreementUpdatesEnabled'] as bool? ?? true,
      salesNotificationsEnabled:
          json['salesNotificationsEnabled'] as bool? ?? true,
      expiryRemindersEnabled: json['expiryRemindersEnabled'] as bool? ?? true,
      expiryReminderDays: json['expiryReminderDays'] as int? ?? 7,
      payoutNotificationsEnabled:
          json['payoutNotificationsEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stockLowEnabled': stockLowEnabled,
      'stockOutEnabled': stockOutEnabled,
      'lowStockThreshold': lowStockThreshold,
      'weeklySummaryEnabled': weeklySummaryEnabled,
      'agreementUpdatesEnabled': agreementUpdatesEnabled,
      'salesNotificationsEnabled': salesNotificationsEnabled,
      'expiryRemindersEnabled': expiryRemindersEnabled,
      'expiryReminderDays': expiryReminderDays,
      'payoutNotificationsEnabled': payoutNotificationsEnabled,
    };
  }

  NotificationPreferencesModel copyWith({
    bool? stockLowEnabled,
    bool? stockOutEnabled,
    int? lowStockThreshold,
    bool? weeklySummaryEnabled,
    bool? agreementUpdatesEnabled,
    bool? salesNotificationsEnabled,
    bool? expiryRemindersEnabled,
    int? expiryReminderDays,
    bool? payoutNotificationsEnabled,
  }) {
    return NotificationPreferencesModel(
      stockLowEnabled: stockLowEnabled ?? this.stockLowEnabled,
      stockOutEnabled: stockOutEnabled ?? this.stockOutEnabled,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      weeklySummaryEnabled: weeklySummaryEnabled ?? this.weeklySummaryEnabled,
      agreementUpdatesEnabled:
          agreementUpdatesEnabled ?? this.agreementUpdatesEnabled,
      salesNotificationsEnabled:
          salesNotificationsEnabled ?? this.salesNotificationsEnabled,
      expiryRemindersEnabled:
          expiryRemindersEnabled ?? this.expiryRemindersEnabled,
      expiryReminderDays: expiryReminderDays ?? this.expiryReminderDays,
      payoutNotificationsEnabled:
          payoutNotificationsEnabled ?? this.payoutNotificationsEnabled,
    );
  }

  /// Create default preferences.
  factory NotificationPreferencesModel.defaults() {
    return NotificationPreferencesModel(
      stockLowEnabled: true,
      stockOutEnabled: true,
      lowStockThreshold: 5,
      weeklySummaryEnabled: false,
      agreementUpdatesEnabled: true,
      salesNotificationsEnabled: true,
      expiryRemindersEnabled: true,
      expiryReminderDays: 7,
      payoutNotificationsEnabled: true,
    );
  }
}
