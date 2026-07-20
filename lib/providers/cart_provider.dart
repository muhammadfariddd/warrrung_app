import 'package:flutter/foundation.dart';
import 'package:warrrung_app/data/models/cart_item_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _items = [];
  Map<String, dynamic>? _selectedVoucher;

  List<CartItemModel> get items => _items;
  Map<String, dynamic>? get selectedVoucher => _selectedVoucher;

  /// Applies a voucher to the cart
  void applyVoucher(Map<String, dynamic>? voucher) {
    _selectedVoucher = voucher;
    notifyListeners();
  }

  /// Removes the currently selected voucher
  void removeVoucher() {
    _selectedVoucher = null;
    notifyListeners();
  }

  /// Calculates the exact discount amount from the applied voucher
  double get voucherDiscountAmount {
    if (_selectedVoucher == null || _items.isEmpty) return 0.0;

    final String vId = _selectedVoucher!['id'] as String? ?? '';
    final double subtotal = totalPrice;

    double discount = 0.0;
    if (vId == 'v_banner3' || vId == 'v_diskon20k') {
      discount = 20000.0;
    } else if (vId == 'v_diskon30') {
      discount = subtotal * 0.30;
      if (discount > 30000) discount = 30000.0;
    } else if (vId == 'v_ongkir') {
      discount = 10000.0;
    } else if (vId == 'v_cashback') {
      discount = subtotal * 0.20;
      if (discount > 25000) discount = 25000.0;
    } else if (vId == 'v_checkin7') {
      discount = subtotal * 0.10;
    } else if (vId == 'v_checkin14') {
      discount = subtotal * 0.15;
    } else {
      final num? numAmt = _selectedVoucher!['discountAmount'] as num?;
      discount = (numAmt != null) ? numAmt.toDouble() : 20000.0;
    }

    return discount > subtotal ? subtotal : discount;
  }

  /// Returns the sum of final prices for all items in the cart
  double get totalPrice {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  /// Returns the sum of original prices (strike prices) for all items in the cart
  double get totalStrikePrice {
    return _items.fold(0.0, (sum, item) => sum + item.totalStrikePrice);
  }

  /// Returns the total discount amount saved in this cart (item savings + voucher savings)
  double get totalDiscount {
    final double itemSavings = totalStrikePrice - totalPrice;
    final double savings = (itemSavings > 0 ? itemSavings : 0.0) + voucherDiscountAmount;
    return savings;
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
    if (_items.isEmpty) {
      _selectedVoucher = null;
    }
    notifyListeners();
  }

  /// Clears the entire cart
  void clearCart() {
    _items.clear();
    _selectedVoucher = null;
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
