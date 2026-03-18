import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/product.dart';

class WishlistProvider extends ChangeNotifier {
  List<String> _wishlistProductIds = [];

  List<String> get wishlistProductIds => _wishlistProductIds;

  WishlistProvider() {
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistData = prefs.getString('wishlist');
      
      if (wishlistData != null) {
        final List<dynamic> decoded = json.decode(wishlistData);
        _wishlistProductIds = decoded.cast<String>();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading wishlist: $e');
    }
  }

  Future<void> _saveWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistData = json.encode(_wishlistProductIds);
      await prefs.setString('wishlist', wishlistData);
    } catch (e) {
      debugPrint('Error saving wishlist: $e');
    }
  }

  bool isInWishlist(String productId) {
    return _wishlistProductIds.contains(productId);
  }

  void addToWishlist(String productId) {
    if (!_wishlistProductIds.contains(productId)) {
      _wishlistProductIds.add(productId);
      _saveWishlist();
      notifyListeners();
    }
  }

  void removeFromWishlist(String productId) {
    _wishlistProductIds.remove(productId);
    _saveWishlist();
    notifyListeners();
  }

  void toggleWishlist(String productId) {
    if (isInWishlist(productId)) {
      removeFromWishlist(productId);
    } else {
      addToWishlist(productId);
    }
  }

  void clearWishlist() {
    _wishlistProductIds.clear();
    _saveWishlist();
    notifyListeners();
  }

  int get itemCount => _wishlistProductIds.length;
}
