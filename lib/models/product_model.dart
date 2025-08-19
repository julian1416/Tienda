// lib/models/product_model.dart
class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final double? originalPrice; // El '?' significa que puede ser nulo
  final String? description; // Descripción opcional

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    this.originalPrice,
    required this.description,
  });

  factory Product.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Product(
      id: documentId,
      name: data['name'] ?? '',
      price: (data['price'] as num).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      rating: (data['rating'] as num).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      originalPrice: data['originalPrice'] != null ? (data['originalPrice'] as num).toDouble() : null,
      description: data['description'] ?? 'No hay descrpción disponible',
    );
  }
}