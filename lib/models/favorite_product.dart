class FavoriteProduct {
  final String id;
  final String name;
  final String? brand;
  final String? imageUrl;
  final Map<String, dynamic> nutriments;
  final String source; // 'openfood' or 'barcode'
  final DateTime addedAt;

  FavoriteProduct({
    required this.id,
    required this.name,
    this.brand,
    this.imageUrl,
    required this.nutriments,
    required this.source,
    required this.addedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'imageUrl': imageUrl,
      'nutriments': nutriments,
      'source': source,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory FavoriteProduct.fromJson(Map<String, dynamic> json) {
    return FavoriteProduct(
      id: json['id'],
      name: json['name'],
      brand: json['brand'],
      imageUrl: json['imageUrl'],
      nutriments: Map<String, dynamic>.from(json['nutriments']),
      source: json['source'],
      addedAt: DateTime.parse(json['addedAt']),
    );
  }

  factory FavoriteProduct.fromOpenFoodProduct(Map<String, dynamic> product) {
    return FavoriteProduct(
      id: product['code'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: product['product_name'] ?? 'Unknown Product',
      brand: product['brands'],
      imageUrl: product['image_url'],
      nutriments: product['nutriments'] ?? {},
      source: 'openfood',
      addedAt: DateTime.now(),
    );
  }
}