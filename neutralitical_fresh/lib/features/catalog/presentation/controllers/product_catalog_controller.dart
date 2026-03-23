import 'package:flutter/foundation.dart';

import '../../data/services/product_catalog_service.dart';
import '../../data/services/product_media_library_service.dart';
import '../../domain/models/product.dart';
import '../../domain/models/product_media.dart';

class ProductCatalogController extends ChangeNotifier {
  ProductCatalogController({
    required ProductCatalogService productCatalogService,
    required ProductMediaLibraryService productMediaLibraryService,
  }) : _productCatalogService = productCatalogService,
       _productMediaLibraryService = productMediaLibraryService;

  final ProductCatalogService _productCatalogService;
  final ProductMediaLibraryService _productMediaLibraryService;

  bool _isLoading = false;
  String? _errorMessage;
  String _query = '';
  String _selectedCategory = 'All';
  List<Product> _products = const [];
  Map<String, List<ProductMedia>> _uploadedMediaByProductId =
      const <String, List<ProductMedia>>{};
  String? _busyProductId;
  String? _lastStatusMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Product> get products => List.unmodifiable(_products);
  String get selectedCategory => _selectedCategory;
  String get query => _query;
  bool get supportsUploads => _productMediaLibraryService.supportsUploads;
  String? get busyProductId => _busyProductId;
  bool get hasActiveFilters =>
      _query.trim().isNotEmpty || _selectedCategory != 'All';

  int get uploadedMediaCount => _uploadedMediaByProductId.values.fold<int>(
    0,
    (total, items) => total + items.length,
  );

  int get productsWithMediaCount =>
      _products.where((product) => mediaFor(product).isNotEmpty).length;

  List<Product> get featuredProducts {
    final featured = _products.where((product) => product.featured).toList();
    if (featured.isNotEmpty) {
      return featured;
    }
    return _products.take(3).toList();
  }

  List<String> get categories {
    final names = _products.map((product) => product.category).toSet().toList()
      ..sort();
    return ['All', ...names];
  }

  List<Product> get visibleProducts {
    final normalizedQuery = _query.trim().toLowerCase();

    return _products.where((product) {
      final matchesCategory =
          _selectedCategory == 'All' || product.category == _selectedCategory;
      final matchesQuery =
          normalizedQuery.isEmpty ||
          product.name.toLowerCase().contains(normalizedQuery) ||
          product.category.toLowerCase().contains(normalizedQuery) ||
          product.form.toLowerCase().contains(normalizedQuery) ||
          product.description.toLowerCase().contains(normalizedQuery) ||
          product.ingredients.any(
            (ingredient) => ingredient.toLowerCase().contains(normalizedQuery),
          );

      return matchesCategory && matchesQuery;
    }).toList();
  }

  List<ProductMedia> mediaFor(Product product) {
    final merged = [
      ...product.media,
      ...(_uploadedMediaByProductId[product.id] ?? const <ProductMedia>[]),
    ];
    merged.sort((left, right) {
      if (left.isPrimary != right.isPrimary) {
        return left.isPrimary ? -1 : 1;
      }
      if (left.isUploaded != right.isUploaded) {
        return left.isUploaded ? 1 : -1;
      }
      return left.title.compareTo(right.title);
    });
    return merged;
  }

  ProductMedia? primaryVisualFor(Product product) {
    final visuals = mediaFor(product).where((media) => media.isImage).toList();
    if (visuals.isEmpty) {
      return null;
    }

    return visuals.first;
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait<dynamic>([
        _productCatalogService.loadRegisteredProducts(),
        _productMediaLibraryService.loadUploadedMedia(),
      ]);
      final loadedProducts = results[0] as List<Product>;
      final uploadedMedia = results[1] as Map<String, List<ProductMedia>>;
      _products = [...loadedProducts]
        ..sort((left, right) {
          if (left.featured != right.featured) {
            return right.featured ? 1 : -1;
          }
          return left.name.compareTo(right.name);
        });
      _uploadedMediaByProductId = uploadedMedia;
    } catch (_) {
      _errorMessage =
          'Unable to load registered products right now. Pull to retry.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setQuery(String value) {
    if (_query == value) {
      return;
    }

    _query = value;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    if (_selectedCategory == category) {
      return;
    }

    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> addMedia(Product product) async {
    if (_busyProductId == product.id) {
      return;
    }

    _busyProductId = product.id;
    _lastStatusMessage = null;
    notifyListeners();

    try {
      final uploaded = await _productMediaLibraryService.addMedia(
        productId: product.id,
      );
      if (uploaded.isEmpty) {
        _lastStatusMessage = 'No media files were selected.';
      } else {
        _uploadedMediaByProductId = {
          ..._uploadedMediaByProductId,
          product.id: uploaded,
        };
        _lastStatusMessage =
            '${uploaded.length} uploaded item${uploaded.length == 1 ? '' : 's'} now attached to ${product.name}.';
      }
    } on UnsupportedError catch (error) {
      _lastStatusMessage =
          error.message?.toString() ?? 'Uploads are unavailable.';
    } catch (_) {
      _lastStatusMessage =
          'Unable to store media right now. Try another file or retry.';
    } finally {
      _busyProductId = null;
      notifyListeners();
    }
  }

  Future<void> removeUploadedMedia(Product product, ProductMedia media) async {
    if (_busyProductId == product.id || !media.isUploaded) {
      return;
    }

    _busyProductId = product.id;
    _lastStatusMessage = null;
    notifyListeners();

    try {
      await _productMediaLibraryService.removeMedia(
        productId: product.id,
        media: media,
      );
      final updated = [
        ...(_uploadedMediaByProductId[product.id] ?? const <ProductMedia>[]),
      ];
      updated.removeWhere((item) => item.id == media.id);
      _uploadedMediaByProductId = {..._uploadedMediaByProductId};
      if (updated.isEmpty) {
        _uploadedMediaByProductId.remove(product.id);
      } else {
        _uploadedMediaByProductId[product.id] = updated;
      }
      _lastStatusMessage = 'Removed ${media.title} from ${product.name}.';
    } catch (_) {
      _lastStatusMessage = 'Unable to remove this media item right now.';
    } finally {
      _busyProductId = null;
      notifyListeners();
    }
  }

  String? takeStatusMessage() {
    final value = _lastStatusMessage;
    _lastStatusMessage = null;
    return value;
  }
}
