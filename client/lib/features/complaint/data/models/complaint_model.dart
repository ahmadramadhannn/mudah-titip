/// Categories of product complaints.
enum ComplaintCategory {
  expired('EXPIRED', 'Kedaluwarsa'),
  damaged('DAMAGED', 'Rusak'),
  qualityIssue('QUALITY_ISSUE', 'Masalah Kualitas'),
  packaging('PACKAGING', 'Kemasan Rusak'),
  other('OTHER', 'Lainnya');

  const ComplaintCategory(this.value, this.displayName);
  final String value;
  final String displayName;

  static ComplaintCategory fromString(String value) {
    return ComplaintCategory.values.firstWhere(
      (c) => c.value == value,
      orElse: () => ComplaintCategory.other,
    );
  }
}

/// Status of a complaint.
enum ComplaintStatus {
  open('OPEN', 'Menunggu'),
  inReview('IN_REVIEW', 'Ditinjau'),
  resolved('RESOLVED', 'Selesai'),
  rejected('REJECTED', 'Ditolak');

  const ComplaintStatus(this.value, this.displayName);
  final String value;
  final String displayName;

  static ComplaintStatus fromString(String value) {
    return ComplaintStatus.values.firstWhere(
      (c) => c.value == value,
      orElse: () => ComplaintStatus.open,
    );
  }
}

/// Model representing a product complaint.
class ComplaintModel {
  final int id;
  final int consignmentId;
  final String productName;
  final String shopName;
  final String reporterName;
  final int reporterId;
  final ComplaintCategory category;
  final String description;
  final List<String> mediaUrls;
  final ComplaintStatus status;
  final String? resolution;
  final DateTime? resolvedAt;
  final String? resolvedByName;
  final DateTime createdAt;

  const ComplaintModel({
    required this.id,
    required this.consignmentId,
    required this.productName,
    required this.shopName,
    required this.reporterName,
    required this.reporterId,
    required this.category,
    required this.description,
    required this.mediaUrls,
    required this.status,
    this.resolution,
    this.resolvedAt,
    this.resolvedByName,
    required this.createdAt,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: json['id'] as int,
      consignmentId: json['consignmentId'] as int,
      productName: json['productName'] as String,
      shopName: json['shopName'] as String,
      reporterName: json['reporterName'] as String,
      reporterId: json['reporterId'] as int,
      category: ComplaintCategory.fromString(json['category'] as String),
      description: json['description'] as String,
      mediaUrls:
          (json['mediaUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      status: ComplaintStatus.fromString(json['status'] as String),
      resolution: json['resolution'] as String?,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'] as String)
          : null,
      resolvedByName: json['resolvedByName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'consignmentId': consignmentId,
      'productName': productName,
      'shopName': shopName,
      'reporterName': reporterName,
      'reporterId': reporterId,
      'category': category.value,
      'description': description,
      'mediaUrls': mediaUrls,
      'status': status.value,
      'resolution': resolution,
      'resolvedAt': resolvedAt?.toIso8601String(),
      'resolvedByName': resolvedByName,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
