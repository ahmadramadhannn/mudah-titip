/// DTO for creating a product.
class CreateProductRequest {
  final String name;
  final String? description;
  final String? category;
  final int? shelfLifeDays;
  final double basePrice;
  final String? imageUrl;

  const CreateProductRequest({
    required this.name,
    this.description,
    this.category,
    this.shelfLifeDays,
    required this.basePrice,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'name': name, 'basePrice': basePrice};

    if (description != null) json['description'] = description;
    if (category != null) json['category'] = category;
    if (shelfLifeDays != null) json['shelfLifeDays'] = shelfLifeDays;
    if (imageUrl != null) json['imageUrl'] = imageUrl;

    return json;
  }
}

/// DTO for updating a product.
class UpdateProductRequest {
  final String name;
  final String? description;
  final String? category;
  final int? shelfLifeDays;
  final double basePrice;
  final String? imageUrl;

  const UpdateProductRequest({
    required this.name,
    this.description,
    this.category,
    this.shelfLifeDays,
    required this.basePrice,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'shelfLifeDays': shelfLifeDays,
      'basePrice': basePrice,
      'imageUrl': imageUrl,
    };
  }
}
