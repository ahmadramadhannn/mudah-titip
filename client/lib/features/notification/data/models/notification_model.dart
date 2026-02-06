/// Types of notifications that can be sent to users.
enum NotificationType {
  agreementProposed('AGREEMENT_PROPOSED'),
  agreementAccepted('AGREEMENT_ACCEPTED'),
  agreementRejected('AGREEMENT_REJECTED'),
  agreementCountered('AGREEMENT_COUNTERED'),
  saleRecorded('SALE_RECORDED'),
  consignmentExpiring('CONSIGNMENT_EXPIRING'),
  consignmentExpired('CONSIGNMENT_EXPIRED');

  const NotificationType(this.value);
  final String value;

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NotificationType.agreementProposed,
    );
  }
}

/// Notification model representing an in-app notification.
class NotificationModel {
  final int id;
  final NotificationType type;
  final String title;
  final String message;
  final int? referenceId;
  final String? referenceType;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.referenceId,
    this.referenceType,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      type: NotificationType.fromString(json['type'] as String),
      title: json['title'] as String,
      message: json['message'] as String,
      referenceId: json['referenceId'] as int?,
      referenceType: json['referenceType'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.value,
      'title': title,
      'message': message,
      'referenceId': referenceId,
      'referenceType': referenceType,
      'isRead': isRead,
      'readAt': readAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    int? id,
    NotificationType? type,
    String? title,
    String? message,
    int? referenceId,
    String? referenceType,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      referenceId: referenceId ?? this.referenceId,
      referenceType: referenceType ?? this.referenceType,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
