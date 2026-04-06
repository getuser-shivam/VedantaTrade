import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:vedanta_trade/features/cart/domain/models/cart_item.dart';
import 'package:vedanta_trade/features/product_catalog/domain/models/product.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  double _totalAmount = 0.0;

  List<CartItem> get items => _items;
  double get totalAmount => _totalAmount;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  CartProvider() {
    _loadCart();
  }

  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = prefs.getString('cart');
      
      if (cartData != null) {
        final List<dynamic> decoded = json.decode(cartData);
        _items = decoded.map((item) => CartItem.fromJson(item)).toList();
        _calculateTotal();
        notifyListeners();
      }
    } catch (e) {
      
    }
  }

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = json.encode(_items.map((item) => item.toJson()).toList());
      await prefs.setString('cart', cartData);
    } catch (e) {
      
    }
  }

  void addToCart(Product product, {int quantity = 1}) {
    final existingItemIndex = _items.indexWhere(
      (item) => item.productId == product.id,
    );

    if (existingItemIndex != -1) {
      _items[existingItemIndex] = _items[existingItemIndex].copyWith(
        quantity: _items[existingItemIndex].quantity + quantity,
      );
    } else {
      final cartItem = CartItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: product.id,
        productName: product.name,
        productForm: product.form,
        price: product.price,
        imageUrl: product.imageUrl,
        quantity: quantity,
      );
      _items.add(cartItem);
    }

    _calculateTotal();
    _saveCart();
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }

    final existingItemIndex = _items.indexWhere(
      (item) => item.productId == productId,
    );

    if (existingItemIndex != -1) {
      _items[existingItemIndex] = _items[existingItemIndex].copyWith(
        quantity: quantity,
      );
      _calculateTotal();
      _saveCart();
      notifyListeners();
    }
  }

  void removeFromCart(String productId) {
    _items.removeWhere((item) => item.productId == productId);
    _calculateTotal();
    _saveCart();
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _totalAmount = 0.0;
    _saveCart();
    notifyListeners();
  }

  void _calculateTotal() {
    _totalAmount = _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  bool isInCart(String productId) {
    return _items.any((item) => item.productId == productId);
  }

  CartItem? getItemByProductId(String productId) {
    try {
      return _items.firstWhere((item) => item.productId == productId);
    } catch (e) {
      return null;
    }
  }
}
