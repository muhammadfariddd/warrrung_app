import 'package:warrrung_app/data/models/product_model.dart';

class CartItemModel {
  final String id;
  final ProductModel product;
  final int quantity;
  final List<String> customizations;
  final String notes;
  final double singleItemPrice;

  CartItemModel({
    required this.id,
    required this.product,
    required this.quantity,
    required this.customizations,
    required this.notes,
    required this.singleItemPrice,
  });

  /// Computes the total price of this item based on single item price and quantity
  double get totalPrice => singleItemPrice * quantity;

  /// Computes the total strike price (original price before discount) of this item based on product's strikePrice or price, plus customization pricing
  double get totalStrikePrice {
    final double baseStrike = product.strikePrice ?? product.price;
    final double customizationAddition = singleItemPrice - product.price;
    return (baseStrike + customizationAddition) * quantity;
  }

  /// Creates a copy of this [CartItemModel] with modified fields
  CartItemModel copyWith({
    String? id,
    ProductModel? product,
    int? quantity,
    List<String>? customizations,
    String? notes,
    double? singleItemPrice,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      customizations: customizations ?? this.customizations,
      notes: notes ?? this.notes,
      singleItemPrice: singleItemPrice ?? this.singleItemPrice,
    );
  }
}
