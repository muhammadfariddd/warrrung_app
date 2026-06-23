import 'package:flutter/foundation.dart';
import 'package:warrrung_app/data/models/cart_item_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => _items;

  /// Returns the sum of final prices for all items in the cart
  double get totalPrice {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  /// Returns the sum of original prices (strike prices) for all items in the cart
  double get totalStrikePrice {
    return _items.fold(0.0, (sum, item) => sum + item.totalStrikePrice);
  }

  /// Returns the total discount amount saved in this cart
  double get totalDiscount {
    final double savings = totalStrikePrice - totalPrice;
    return savings > 0 ? savings : 0.0;
  }

  /// Returns total count of items in the cart
  int get totalItemCount {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Adds an item to the cart. If the product and customizations are identical, increments quantity.
  void addItem(CartItemModel newItem) {
    int existingIndex = -1;
    for (int i = 0; i < _items.length; i++) {
      if (_items[i].product.id == newItem.product.id &&
          _areCustomizationsIdentical(_items[i].customizations, newItem.customizations)) {
        existingIndex = i;
        break;
      }
    }

    if (existingIndex >= 0) {
      // Increment quantity
      final existingItem = _items[existingIndex];
      _items[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + newItem.quantity,
      );
    } else {
      // Add as new item
      _items.add(newItem);
    }
    notifyListeners();
  }

  /// Replaces/updates an existing cart item by ID
  void updateItem(CartItemModel updatedItem) {
    final index = _items.indexWhere((item) => item.id == updatedItem.id);
    if (index >= 0) {
      _items[index] = updatedItem;
      notifyListeners();
    }
  }

  /// Updates quantity of an item. If quantity <= 0, removes it.
  void updateQuantity(String itemId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(itemId);
      return;
    }

    final index = _items.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(quantity: newQuantity);
      notifyListeners();
    }
  }

  /// Removes an item from the cart
  void removeItem(String itemId) {
    _items.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  /// Clears the entire cart
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  /// Helper to check if two lists of customizations contain the same options
  bool _areCustomizationsIdentical(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    // Sort and compare elements
    final sorted1 = List<String>.from(list1)..sort();
    final sorted2 = List<String>.from(list2)..sort();
    for (int i = 0; i < sorted1.length; i++) {
      if (sorted1[i] != sorted2[i]) return false;
    }
    return true;
  }
}
