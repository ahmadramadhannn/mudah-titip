class CreateProductRequest {
  final String name;
  final String? description;
  final double price;
  final int stock;
  final String? imageUrl;

  CreateProductRequest({
    required this.name,
    this.description,
    required this.price,
    required this.stock,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'image_url': imageUrl,
    };
  }
}

class UpdateProductRequest {
  final String? name;
  final String? description;
  final double? price;
  final int? stock;
  final String? imageUrl;

  UpdateProductRequest({
    this.name,
    this.description,
    this.price,
    this.stock,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (description != null) map['description'] = description;
    if (price != null) map['price'] = price;
    if (stock != null) map['stock'] = stock;
    if (imageUrl != null) map['image_url'] = imageUrl;
    return map;
  }
}
