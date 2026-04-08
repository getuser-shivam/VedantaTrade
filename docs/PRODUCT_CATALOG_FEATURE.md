# Product Catalog Feature Documentation

## Overview

The Product Catalog feature provides a robust and user-friendly interface for browsing, searching, filtering, and managing pharmaceutical products in the VedantaTrade application. This comprehensive feature enables customers to explore products with intuitive navigation and powerful search capabilities.

## Table of Contents

- [Architecture](#architecture)
- [Features](#features)
- [Data Models](#data-models)
- [Components](#components)
- [Usage](#usage)
- [API Integration](#api-integration)
- [Testing](#testing)
- [Future Enhancements](#future-enhancements)

---

## Architecture

The Product Catalog follows Clean Architecture principles with clear separation of concerns:

```
lib/features/product_catalog/
├── data/
│   ├── models/
│   │   └── product_model.dart          # Data transfer objects
│   ├── repositories/
│   │   ├── product_catalog_repository_impl.dart
│   │   └── product_repository_impl.dart
│   └── services/
│       ├── product_catalog_service.dart
│       └── product_service.dart
├── domain/
│   ├── models/
│   │   ├── product_entity.dart          # Core domain entity
│   │   ├── product_category.dart        # Category entity
│   │   └── product_filter.dart         # Filter configuration
│   └── repositories/
│       ├── product_catalog_repository.dart
│       └── product_repository.dart
└── presentation/
    ├── providers/
    │   ├── enhanced_product_catalog_provider.dart
    │   └── product_catalog_provider.dart
    ├── screens/
    │   ├── enhanced_product_catalog_screen.dart
    │   ├── product_catalog_screen.dart
    │   └── product_detail_screen.dart
    └── widgets/
        ├── category_chips.dart
        ├── smart_search_bar.dart
        ├── advanced_filter_panel.dart
        ├── enhanced_product_grid.dart
        ├── enhanced_product_card.dart
        └── product_detail_sheet.dart
```

---

## Features

### 1. Product Browsing

- **Grid View**: Visual product display with images and key information
- **List View**: Detailed product list with comprehensive information
- **Responsive Design**: Optimized layouts for mobile, tablet, and desktop
- **Pagination**: Efficient loading of large product catalogs

### 2. Advanced Search

- **Smart Search Bar**: AI-powered search with autocomplete
- **Voice Search**: Voice input for hands-free searching
- **Barcode Scanning**: Scan product barcodes for quick lookup
- **Search Suggestions**: Intelligent suggestions based on history and popularity
- **Recent Searches**: Quick access to previously searched terms

### 3. Filtering System

#### Category Filters
- Predefined categories (Medicines, Medical Devices, Consumables, Equipment, Supplements)
- Custom category selection
- Category chips with product counts

#### Price Range
- Minimum and maximum price sliders
- Real-time price filtering
- Currency support (NPR default)

#### Stock Filters
- In-stock only filter
- Low stock alerts
- Out-of-stock indicators
- Stock quantity range

#### Quick Filters
- On Sale products
- Featured products
- Prescription-required items
- Expiring soon products

#### Attribute Filters
- Brand selection
- Manufacturer selection
- Tag filtering
- Dosage form filtering

### 4. Sorting Options

- Name (A-Z / Z-A)
- Price (Low to High / High to Low)
- Stock Quantity (Low to High / High to Low)
- Newest First
- Recently Updated
- Most Popular (Rating-based)

### 5. Product Details

- **Product Information**: Name, description, manufacturer, brand
- **Pricing**: Price, discounts, tax calculations
- **Inventory**: Stock quantity, batch number, expiry date
- **Specifications**: Dosage form, strength, ingredients
- **Images**: Multiple product images with gallery view
- **Regulatory**: Prescription requirements, regulatory status
- **Reviews**: Customer ratings and reviews

### 6. User Actions

- **Favorites**: Add/remove products from favorites
- **Comparison**: Compare up to 4 products side-by-side
- **Quick View**: Product preview without leaving catalog
- **Add to Cart**: Direct cart integration
- **Share**: Share product information

---

## Data Models

### Product Entity

```dart
class Product extends Equatable {
  final String id;
  final String name;
  final String description;
  final String category;
  final String manufacturer;
  final String sku;
  final double price;
  final String currency;
  final int stockQuantity;
  final int minOrderQuantity;
  final String unit;
  final List<String> images;
  final List<String> tags;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? batchNumber;
  final DateTime? expiryDate;
  final String? storageConditions;
  final String? dosageForm;
  final String? strength;
  final String? prescriptionRequired;
  final Map<String, dynamic> specifications;
  final double? discountPrice;
  final String? discountType;
  final DateTime? discountValidUntil;
}
```

### Product Category

```dart
class ProductCategory extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final String? imageUrl;
  final int productCount;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### Product Filter

```dart
class ProductFilter extends Equatable {
  final String? searchQuery;
  final ProductCategory? category;
  final double? minPrice;
  final double? maxPrice;
  final bool? inStock;
  final bool? hasDiscount;
  final bool? prescriptionRequired;
  final String? manufacturer;
  final List<String>? tags;
  final ProductSortOption sortBy;
  final bool? expiringSoon;
  final String? unit;
}
```

---

## Components

### EnhancedProductCatalogScreen

The main screen for product browsing with responsive layouts for mobile, tablet, and desktop.

**Key Features:**
- Responsive layout adaptation
- Animated filter panel
- Floating action button for quick filter access
- Scroll-aware FAB visibility
- Results summary with active filter chips

**Usage:**
```dart
EnhancedProductCatalogScreen()
```

### SmartSearchBar

Advanced search bar with voice recognition, barcode scanning, and intelligent suggestions.

**Key Features:**
- Voice search integration
- Barcode scanning support
- Search suggestions with history
- Animated suggestion panel
- Recent searches management

**Usage:**
```dart
SmartSearchBar(
  onSearch: (query) => provider.searchProducts(query),
  onSuggestionSelected: (suggestion) => provider.searchProducts(suggestion),
  enableVoiceSearch: true,
  enableBarcodeSearch: true,
  placeholder: 'Search medicines, brands, categories...',
)
```

### AdvancedFilterPanel

Comprehensive filter panel with all filtering options organized in sections.

**Key Features:**
- Sort options selection
- Price range slider
- Stock quantity range
- Category chips
- Brand and manufacturer filters
- Tag filtering
- Quick filter checkboxes
- Responsive design

**Usage:**
```dart
AdvancedFilterPanel(
  initialFilters: provider.filter,
  onFiltersChanged: (filters) => provider.updateFilters(filters),
  onClose: () => setState(() => _isFilterPanelOpen = false),
)
```

### CategoryChips

Horizontal or vertical category selection chips with product counts.

**Key Features:**
- Horizontal/vertical layout options
- Scrollable category list
- Product count badges
- Icon support
- Selection animation

**Usage:**
```dart
CategoryChips(
  categories: provider.categories,
  selectedCategory: provider.selectedCategory?.name,
  onCategorySelected: (category) => provider.selectCategory(category),
  isVertical: false,
  scrollable: true,
)
```

### EnhancedProductGrid

Product grid supporting both grid and list view modes with pagination.

**Key Features:**
- Grid/List view toggle
- Responsive grid columns
- Pagination support
- Loading states
- Empty state handling

**Usage:**
```dart
EnhancedProductGrid(
  products: provider.products,
  viewMode: provider.viewMode,
  isLoading: provider.isLoadingMore,
  hasMore: provider.hasMore,
  onLoadMore: provider.loadMoreProducts,
  onProductTap: (product) => _onProductTap(product),
)
```

### EnhancedProductCard

Product card with comprehensive information display and actions.

**Key Features:**
- Product image with loading states
- Price display with discounts
- Stock status indicators
- Favorite toggle
- Compare button
- Quick view action
- Add to cart button

### ProductDetailSheet

Bottom sheet for quick product preview without full navigation.

**Key Features:**
- Smooth slide-up animation
- Product images gallery
- Detailed information display
- Action buttons (Add to Cart, Favorite, Share)
- Dismissible with drag gesture

---

## Usage

### Basic Setup

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedanta_trade/features/product_catalog/presentation/screens/enhanced_product_catalog_screen.dart';
import 'package:vedanta_trade/features/product_catalog/presentation/providers/enhanced_product_catalog_provider.dart';

class ProductCatalogPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EnhancedProductCatalogProvider()..initialize(),
      child: const EnhancedProductCatalogScreen(),
    );
  }
}
```

### Navigation Integration

```dart
// In your router configuration
GoRoute(
  path: '/catalog',
  builder: (context, state) => ChangeNotifierProvider(
    create: (_) => EnhancedProductCatalogProvider()..initialize(),
    child: const EnhancedProductCatalogScreen(),
  ),
)
```

### Custom Filtering

```dart
final provider = context.read<EnhancedProductCatalogProvider>();

// Set price range
provider.updateFilters(
  provider.filter.copyWith(
    minPrice: 100.0,
    maxPrice: 1000.0,
  ),
);

// Filter by category
provider.selectCategory('Medicines');

// Search products
provider.searchProducts('Paracetamol');

// Clear all filters
provider.clearFilters();
```

### Product Actions

```dart
final provider = context.read<EnhancedProductCatalogProvider>();

// Toggle favorite
provider.toggleFavorite(product);

// Toggle comparison
provider.toggleComparison(product);

// Check if favorite
if (provider.isFavorite(product)) {
  // Product is in favorites
}

// Get comparison products
final comparisonProducts = provider.comparisonProducts;
```

---

## API Integration

### Service Layer

The product catalog uses a service layer for API integration:

```dart
class ProductCatalogService {
  Future<List<Product>> loadRegisteredProducts({
    String? category,
    String? token,
    int page = 1,
  }) async {
    // API call implementation
  }

  Future<List<ProductCategory>> loadCategories() async {
    // API call implementation
  }
}
```

### Data Loading

Products are loaded with pagination support:

```dart
// Initial load
await provider.loadProducts();

// Load more (pagination)
await provider.loadMoreProducts();

// Refresh data
await provider.refresh();
```

### Error Handling

The provider includes error handling:

```dart
final provider = context.watch<EnhancedProductCatalogProvider>();

if (provider.hasError) {
  return ErrorWidget(
    errorMessage: provider.errorMessage,
    onRetry: () => provider.refresh(),
  );
}
```

---

## Testing

### Unit Tests

Test individual components and logic:

```dart
test('Product filter should apply search query', () {
  final filter = ProductFilter(searchQuery: 'test');
  expect(filter.searchQuery, 'test');
});

test('Product should calculate effective price with discount', () {
  final product = Product(
    price: 100.0,
    discountPrice: 80.0,
    // ... other fields
  );
  expect(product.effectivePrice, 80.0);
});
```

### Widget Tests

Test UI components:

```dart
testWidgets('SmartSearchBar should show suggestions', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SmartSearchBar(
          onSearch: (query) {},
          enableSuggestions: true,
        ),
      ),
    ),
  );

  // Test search functionality
});
```

### Integration Tests

Test complete user flows:

```dart
testWidgets('Product catalog should filter by category', (tester) async {
  // Test complete filtering flow
});
```

---

## Future Enhancements

### Planned Features

1. **AI-Powered Recommendations**
   - Personalized product suggestions
   - Related products based on browsing history
   - Smart search with natural language processing

2. **Enhanced Comparison**
   - Side-by-side product comparison view
   - Feature comparison matrix
   - Price comparison across suppliers

3. **Advanced Analytics**
   - Product popularity tracking
   - Search analytics
   - User behavior insights

4. **Offline Support**
   - Caching product data
   - Offline browsing capability
   - Sync when online

5. **Multi-Language Support**
   - Localization for different regions
   - Multi-language product descriptions
   - Currency conversion

6. **AR/VR Integration**
   - 3D product visualization
   - AR product preview
   - Virtual product demonstrations

### Performance Optimizations

1. **Lazy Loading**
   - Image lazy loading
   - Progressive product loading
   - Virtual scrolling for large lists

2. **Caching Strategy**
   - Product data caching
   - Image caching
   - Search result caching

3. **State Management**
   - Optimized state updates
   - Selective widget rebuilds
   - Memory-efficient filtering

---

## Best Practices

### Performance

- Use pagination for large catalogs
- Implement image caching
- Debounce search queries
- Optimize filter operations

### User Experience

- Provide loading indicators
- Show empty states
- Enable quick actions
- Support keyboard shortcuts (desktop)

### Code Quality

- Follow Clean Architecture
- Use proper dependency injection
- Write comprehensive tests
- Document public APIs

---

## Troubleshooting

### Common Issues

**Issue: Products not loading**
- Check API connectivity
- Verify authentication token
- Check error messages in provider

**Issue: Filters not working**
- Ensure filter state is properly updated
- Check filter application logic
- Verify data model compatibility

**Issue: Search suggestions not showing**
- Check suggestion generation logic
- Verify product data completeness
- Ensure search query is not empty

---

## Support

For issues or questions:
- Check the troubleshooting section
- Review API documentation
- Contact development team
- Submit GitHub issues

---

**Last Updated**: April 8, 2026
**Version**: 3.9.0-alpha
