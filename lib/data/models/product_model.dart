import 'package:warrrung_app/services/pocketbase_service.dart';

/// Dart model representation of the `products` collection in PocketBase.
class ProductModel {
  final String id;
  final String outletId;
  final String categoryId;
  final String name;
  final String description;
  final double price;
  final double? strikePrice;
  final String image;
  final bool isAvailable;

  ProductModel({
    required this.id,
    required this.outletId,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    this.strikePrice,
    required this.image,
    required this.isAvailable,
  });

  /// Factory constructor to create a [ProductModel] from a JSON map (PocketBase Record fields).
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // PocketBase handles numbers dynamically as double or int, so safe parsing is required.
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    double? parseOptionalDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    return ProductModel(
      id: json['id'] as String? ?? '',
      outletId: json['outlet_id'] as String? ?? '',
      categoryId: json['category_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: parseDouble(json['price']),
      strikePrice: parseOptionalDouble(json['strike_price']),
      image: json['image'] as String? ?? '',
      isAvailable: json['is_available'] as bool? ?? false,
    );
  }

  /// Converts the [ProductModel] instance back into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'outlet_id': outletId,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'price': price,
      'strike_price': strikePrice,
      'image': image,
      'is_available': isAvailable,
    };
  }

  /// Helper getter that returns the fully qualified URL for the product image,
  /// conforming to PocketBase files API:
  /// `http://<your-pb-url>/api/files/<collectionId_or_name>/<recordId>/<filename>`
  String get imageUrl {
    if (image.isEmpty) return '';
    return '${PocketBaseService.baseUrl}/api/files/products/$id/$image';
  }
}
