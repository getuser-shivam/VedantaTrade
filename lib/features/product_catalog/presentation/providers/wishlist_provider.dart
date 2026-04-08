import 'package:flutter/foundation.dart';
import '../../domain/entities/wishlist_entity.dart';
import '../../data/models/product_model.dart';
import '../../data/services/wishlist_service.dart';
import '../providers/product_catalog_provider.dart';

/// Wishlist Provider
/// Manages wishlist state and operations
class WishlistProvider extends ChangeNotifier {
  final WishlistService _wishlistService = WishlistService();

  // State
  List<WishlistEntity> _wishlists = [];
  WishlistEntity? _currentWishlist;
  List<WishlistAlertEntity> _alerts = [];
  
  // Loading states
  bool _isLoading = false;
  bool _isCreatingWishlist = false;
  bool _isAddingProduct = false;
  
  // Error state
  String? _errorMessage;

  // Getters
  List<WishlistEntity> get wishlists => _wishlists;
  WishlistEntity? get currentWishlist => _currentWishlist;
  List<WishlistAlertEntity> get alerts => _alerts;
  bool get isLoading => _isLoading;
  bool get isCreatingWishlist => _isCreatingWishlist;
  bool get isAddingProduct => _isAddingProduct;
  String? get errorMessage => _errorMessage;
  
  WishlistEntity? get defaultWishlist => 
      _wishlists.firstWhere((w) => w.isDefault, orElse: () => _wishlists.firstOrNull);
  
  int get totalWishlistCount => _wishlists.fold(0, (sum, w) => sum + w.productCount);

  // Initialize
  Future<void> initialize() async {
    await loadWishlists();
    await loadAlerts();
    
    // Set default wishlist as current
    if (defaultWishlist != null) {
      _currentWishlist = defaultWishlist;
      notifyListeners();
    }
  }

  // Load wishlists
  Future<void> loadWishlists() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _wishlists = await _wishlistService.getWishlists();
    } catch (e) {
      _errorMessage = 'Failed to load wishlists: $e';
      debugPrint('Error loading wishlists: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create new wishlist
  Future<void> createWishlist(String name, {String? description}) async {
    _isCreatingWishlist = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final wishlist = WishlistEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        description: description,
        productIds: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _wishlistService.saveWishlist(wishlist);
      await loadWishlists();
      
      // Set as current if it's the first one
      if (_wishlists.length == 1) {
        _currentWishlist = wishlist;
      }
    } catch (e) {
      _errorMessage = 'Failed to create wishlist: $e';
      debugPrint('Error creating wishlist: $e');
    } finally {
      _isCreatingWishlist = false;
      notifyListeners();
    }
  }

  // Update wishlist
  Future<void> updateWishlist(WishlistEntity wishlist) async {
    try {
      await _wishlistService.saveWishlist(wishlist);
      await loadWishlists();
      
      if (_currentWishlist?.id == wishlist.id) {
        _currentWishlist = wishlist;
      }
    } catch (e) {
      _errorMessage = 'Failed to update wishlist: $e';
      debugPrint('Error updating wishlist: $e');
    }
  }

  // Delete wishlist
  Future<void> deleteWishlist(String wishlistId) async {
    try {
      await _wishlistService.deleteWishlist(wishlistId);
      await loadWishlists();
      
      if (_currentWishlist?.id == wishlistId) {
        _currentWishlist = defaultWishlist;
      }
    } catch (e) {
      _errorMessage = 'Failed to delete wishlist: $e';
      debugPrint('Error deleting wishlist: $e');
    }
  }

  // Set current wishlist
  void setCurrentWishlist(WishlistEntity wishlist) {
    _currentWishlist = wishlist;
    notifyListeners();
  }

  // Add product to current wishlist
  Future<void> addProductToWishlist(Product product) async {
    if (_currentWishlist == null) return;
    
    _isAddingProduct = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedWishlist = _currentWishlist!.addProduct(product.id);
      await _wishlistService.saveWishlist(updatedWishlist);
      _currentWishlist = updatedWishlist;
      await loadWishlists();
    } catch (e) {
      _errorMessage = 'Failed to add product: $e';
      debugPrint('Error adding product: $e');
    } finally {
      _isAddingProduct = false;
      notifyListeners();
    }
  }

  // Remove product from current wishlist
  Future<void> removeProductFromWishlist(String productId) async {
    if (_currentWishlist == null) return;

    try {
      final updatedWishlist = _currentWishlist!.removeProduct(productId);
      await _wishlistService.saveWishlist(updatedWishlist);
      _currentWishlist = updatedWishlist;
      await loadWishlists();
    } catch (e) {
      _errorMessage = 'Failed to remove product: $e';
      debugPrint('Error removing product: $e');
    }
  }

  // Check if product is in current wishlist
  bool isProductInWishlist(String productId) {
    return _currentWishlist?.containsProduct(productId) ?? false;
  }

  // Check if product is in any wishlist
  bool isProductInAnyWishlist(String productId) {
    return _wishlists.any((w) => w.containsProduct(productId));
  }

  // Load alerts
  Future<void> loadAlerts() async {
    try {
      _alerts = await _wishlistService.getAlerts();
    } catch (e) {
      debugPrint('Error loading alerts: $e');
    }
  }

  // Create alert
  Future<void> createAlert(WishlistAlertEntity alert) async {
    try {
      await _wishlistService.saveAlert(alert);
      await loadAlerts();
    } catch (e) {
      _errorMessage = 'Failed to create alert: $e';
      debugPrint('Error creating alert: $e');
    }
  }

  // Delete alert
  Future<void> deleteAlert(String alertId) async {
    try {
      await _wishlistService.deleteAlert(alertId);
      await loadAlerts();
    } catch (e) {
      _errorMessage = 'Failed to delete alert: $e';
      debugPrint('Error deleting alert: $e');
    }
  }

  // Toggle product in current wishlist
  Future<void> toggleProductInWishlist(Product product) async {
    if (_currentWishlist == null) {
      // Create default wishlist if none exists
      await createWishlist('My Wishlist');
    }

    if (isProductInWishlist(product.id)) {
      await removeProductFromWishlist(product.id);
    } else {
      await addProductToWishlist(product);
    }
  }

  // Get products for current wishlist
  Future<List<Product>> getWishlistProducts() async {
    if (_currentWishlist == null) return [];
    
    try {
      return await _wishlistService.getWishlistProducts(_currentWishlist!.productIds);
    } catch (e) {
      debugPrint('Error loading wishlist products: $e');
      return [];
    }
  }

  // Share wishlist
  Future<void> shareWishlist(String wishlistId, String email) async {
    try {
      final wishlist = _wishlists.firstWhere((w) => w.id == wishlistId);
      final updatedWishlist = wishlist.copyWith(
        isShared: true,
        sharedWith: email,
      );
      await updateWishlist(updatedWishlist);
    } catch (e) {
      _errorMessage = 'Failed to share wishlist: $e';
      debugPrint('Error sharing wishlist: $e');
    }
  }

  // Reset error
  void resetError() {
    _errorMessage = null;
    notifyListeners();
  }
}
