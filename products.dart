class Product {
  final int id;
  final String title;
  final double price;
  final double oldPrice;
  final String category;
  final bool hasShipping;
  final int discountPercentage;
  final String imageUrl;
  final int stock;
  final bool isActive;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.oldPrice,
    required this.category,
    required this.hasShipping,
    required this.discountPercentage,
    required this.imageUrl,
    required this.stock,
    required this.isActive,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      title: map['title'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      oldPrice: (map['oldPrice'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      hasShipping: map['hasShipping'] ?? false,
      discountPercentage: map['discountPercentage'] ?? 0,
      imageUrl: map['imageUrl'] ?? '',
      stock: map['stock'] ?? 0,
      isActive: map['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'oldPrice': oldPrice,
      'category': category,
      'hasShipping': hasShipping,
      'discountPercentage': discountPercentage,
      'imageUrl': imageUrl,
      'stock': stock,
      'is_active': isActive,
    };
  }
}
