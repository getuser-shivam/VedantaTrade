import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/product_filter_entity.dart';
import '../providers/product_catalog_provider.dart';
import '../../../shared/theme/enhanced_app_theme.dart';
import '../../../shared/widgets/responsive/responsive_layout.dart';

/// Advanced Filter Panel
/// Comprehensive filtering options for product catalog
class AdvancedFilterPanel extends StatefulWidget {
  final ProductFilterEntity? initialFilters;
  final Function(ProductFilterEntity)? onFiltersChanged;
  final Function()? onClose;
  final bool isExpanded;

  const AdvancedFilterPanel({
    Key? key,
    this.initialFilters,
    this.onFiltersChanged,
    this.onClose,
    this.isExpanded = false,
  }) : super(key: key);

  @override
  State<AdvancedFilterPanel> createState() => _AdvancedFilterPanelState();
}

class _AdvancedFilterPanelState extends State<AdvancedFilterPanel>
    with TickerProviderStateMixin {
  late AnimationController _panelController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  ProductFilterEntity _currentFilters = const ProductFilterEntity();
  RangeValues _priceRange = const RangeValues(0, 10000);
  RangeValues _stockRange = const RangeValues(0, 1000);
  List<String> _selectedCategories = [];
  List<String> _selectedBrands = [];
  List<String> _selectedManufacturers = [];
  List<String> _selectedTags = [];
  String _selectedSortOption = 'name';
  bool _inStockOnly = false;
  bool _onSaleOnly = false;
  bool _featuredOnly = false;

  @override
  void initState() {
    super.initState();
    _panelController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _panelController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _panelController,
      curve: Curves.easeOutBack,
    ));

    _currentFilters = widget.initialFilters ?? const ProductFilterEntity();
    _initializeFilters();

    if (widget.isExpanded) {
      _panelController.forward();
    }
  }

  @override
  void dispose() {
    _panelController.dispose();
    super.dispose();
  }

  void _initializeFilters() {
    setState(() {
      _priceRange = RangeValues(
        _currentFilters.minPrice ?? 0,
        _currentFilters.maxPrice ?? 10000,
      );
      _stockRange = RangeValues(
        _currentFilters.minStock ?? 0,
        _currentFilters.maxStock ?? 1000,
      );
      _selectedCategories = List.from(_currentFilters.categories);
      _selectedBrands = List.from(_currentFilters.brands);
      _selectedManufacturers = List.from(_currentFilters.manufacturers);
      _selectedTags = List.from(_currentFilters.tags);
      _selectedSortOption = _currentFilters.sortBy ?? 'name';
      _inStockOnly = _currentFilters.inStockOnly ?? false;
      _onSaleOnly = _currentFilters.onSaleOnly ?? false;
      _featuredOnly = _currentFilters.featuredOnly ?? false;
    });
  }

  void _applyFilters() {
    final updatedFilters = _currentFilters.copyWith(
      categories: _selectedCategories,
      brands: _selectedBrands,
      manufacturers: _selectedManufacturers,
      tags: _selectedTags,
      minPrice: _priceRange.start,
      maxPrice: _priceRange.end,
      minStock: _stockRange.start,
      maxStock: _stockRange.end,
      sortBy: _selectedSortOption,
      inStockOnly: _inStockOnly,
      onSaleOnly: _onSaleOnly,
      featuredOnly: _featuredOnly,
    );

    widget.onFiltersChanged?.call(updatedFilters);
    widget.onClose?.call();
  }

  void _resetFilters() {
    setState(() {
      _priceRange = const RangeValues(0, 10000);
      _stockRange = const RangeValues(0, 1000);
      _selectedCategories = [];
      _selectedBrands = [];
      _selectedManufacturers = [];
      _selectedTags = [];
      _selectedSortOption = 'name';
      _inStockOnly = false;
      _onSaleOnly = false;
      _featuredOnly = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ProductCatalogProvider>();

    return ResponsiveLayout(
      mobile: _buildMobileLayout(theme, provider),
      tablet: _buildTabletLayout(theme, provider),
      desktop: _buildDesktopLayout(theme, provider),
    );
  }

  Widget _buildMobileLayout(ThemeData theme, ProductCatalogProvider provider) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle Bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: theme.dividerColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  'Advanced Filters',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _resetFilters,
                  child: const Text('Reset'),
                ),
                IconButton(
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Filter Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildFilterContent(theme, provider),
            ),
          ),

          // Apply Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border(top: BorderSide(color: theme.dividerColor.withOpacity(0.1))),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(ThemeData theme, ProductCatalogProvider provider) {
    return Container(
      width: 350,
      height: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _resetFilters,
                  child: const Text('Reset'),
                ),
                IconButton(
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Filter Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildFilterContent(theme, provider),
            ),
          ),

          // Apply Button
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Apply Filters'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(ThemeData theme, ProductCatalogProvider provider) {
    return Container(
      width: 400,
      height: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                const Text(
                  'Advanced Filters',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _resetFilters,
                  child: const Text('Reset All'),
                ),
                IconButton(
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Filter Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildFilterContent(theme, provider),
            ),
          ),

          // Apply Button
          Container(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterContent(ThemeData theme, ProductCatalogProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sort Options
        _buildSection(
          title: 'Sort By',
          child: _buildSortOptions(theme),
        ),
        const SizedBox(height: 24),

        // Price Range
        _buildSection(
          title: 'Price Range',
          child: _buildPriceRange(theme),
        ),
        const SizedBox(height: 24),

        // Stock Range
        _buildSection(
          title: 'Stock Quantity',
          child: _buildStockRange(theme),
        ),
        const SizedBox(height: 24),

        // Categories
        if (provider.categories.isNotEmpty)
          _buildSection(
            title: 'Categories',
            child: _buildCategoryChips(theme, provider.categories),
          ),
        if (provider.categories.isNotEmpty) const SizedBox(height: 24),

        // Brands
        if (provider.brands.isNotEmpty)
          _buildSection(
            title: 'Brands',
            child: _buildBrandChips(theme, provider.brands),
          ),
        if (provider.brands.isNotEmpty) const SizedBox(height: 24),

        // Manufacturers
        if (provider.manufacturers.isNotEmpty)
          _buildSection(
            title: 'Manufacturers',
            child: _buildManufacturerChips(theme, provider.manufacturers),
          ),
        if (provider.manufacturers.isNotEmpty) const SizedBox(height: 24),

        // Tags
        if (provider.tags.isNotEmpty)
          _buildSection(
            title: 'Tags',
            child: _buildTagChips(theme, provider.tags),
          ),

        // Quick Filters
        const SizedBox(height: 24),
        _buildSection(
          title: 'Quick Filters',
          child: _buildQuickFilters(theme),
        ),
      ],
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildSortOptions(ThemeData theme) {
    final sortOptions = [
      {'value': 'name', 'label': 'Name (A-Z)'},
      {'value': 'name_desc', 'label': 'Name (Z-A)'},
      {'value': 'price', 'label': 'Price (Low to High)'},
      {'value': 'price_desc', 'label': 'Price (High to Low)'},
      {'value': 'stock', 'label': 'Stock (Low to High)'},
      {'value': 'stock_desc', 'label': 'Stock (High to Low)'},
      {'value': 'created_at', 'label': 'Newest First'},
      {'value': 'updated_at', 'label': 'Recently Updated'},
      {'value': 'popularity', 'label': 'Most Popular'},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: sortOptions.map((option) {
        final isSelected = _selectedSortOption == option['value'];
        return ChoiceChip(
          label: Text(option['label']!),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _selectedSortOption = option['value']!;
              });
            }
          },
          backgroundColor: theme.cardColor,
          selectedColor: theme.primaryColor.withOpacity(0.2),
          labelStyle: TextStyle(
            color: isSelected ? theme.primaryColor : theme.textTheme.bodyMedium?.color,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriceRange(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Rs. ${_priceRange.start.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.primaryColor,
              ),
            ),
            Text(
              'Rs. ${_priceRange.end.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        RangeSlider(
          values: _priceRange,
          min: 0,
          max: 10000,
          divisions: 100,
          activeColor: theme.primaryColor,
          inactiveColor: theme.primaryColor.withOpacity(0.2),
          onChanged: (values) {
            setState(() {
              _priceRange = values;
            });
          },
        ),
      ],
    );
  }

  Widget _buildStockRange(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_stockRange.start.toStringAsFixed(0)} units',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.primaryColor,
              ),
            ),
            Text(
              '${_stockRange.end.toStringAsFixed(0)} units',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        RangeSlider(
          values: _stockRange,
          min: 0,
          max: 1000,
          divisions: 50,
          activeColor: theme.primaryColor,
          inactiveColor: theme.primaryColor.withOpacity(0.2),
          onChanged: (values) {
            setState(() {
              _stockRange = values;
            });
          },
        ),
      ],
    );
  }

  Widget _buildCategoryChips(ThemeData theme, List<String> categories) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((category) {
        final isSelected = _selectedCategories.contains(category);
        return FilterChip(
          label: Text(category),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedCategories.add(category);
              } else {
                _selectedCategories.remove(category);
              }
            });
          },
          backgroundColor: theme.cardColor,
          selectedColor: theme.primaryColor.withOpacity(0.2),
          labelStyle: TextStyle(
            color: isSelected ? theme.primaryColor : theme.textTheme.bodyMedium?.color,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBrandChips(ThemeData theme, List<String> brands) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: brands.map((brand) {
        final isSelected = _selectedBrands.contains(brand);
        return FilterChip(
          label: Text(brand),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedBrands.add(brand);
              } else {
                _selectedBrands.remove(brand);
              }
            });
          },
          backgroundColor: theme.cardColor,
          selectedColor: theme.primaryColor.withOpacity(0.2),
          labelStyle: TextStyle(
            color: isSelected ? theme.primaryColor : theme.textTheme.bodyMedium?.color,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildManufacturerChips(ThemeData theme, List<String> manufacturers) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: manufacturers.map((manufacturer) {
        final isSelected = _selectedManufacturers.contains(manufacturer);
        return FilterChip(
          label: Text(manufacturer),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedManufacturers.add(manufacturer);
              } else {
                _selectedManufacturers.remove(manufacturer);
              }
            });
          },
          backgroundColor: theme.cardColor,
          selectedColor: theme.primaryColor.withOpacity(0.2),
          labelStyle: TextStyle(
            color: isSelected ? theme.primaryColor : theme.textTheme.bodyMedium?.color,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTagChips(ThemeData theme, List<String> tags) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) {
        final isSelected = _selectedTags.contains(tag);
        return FilterChip(
          label: Text(tag),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedTags.add(tag);
              } else {
                _selectedTags.remove(tag);
              }
            });
          },
          backgroundColor: theme.cardColor,
          selectedColor: theme.primaryColor.withOpacity(0.2),
          labelStyle: TextStyle(
            color: isSelected ? theme.primaryColor : theme.textTheme.bodyMedium?.color,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickFilters(ThemeData theme) {
    return Column(
      children: [
        CheckboxListTile(
          title: const Text('In Stock Only'),
          value: _inStockOnly,
          onChanged: (value) {
            setState(() {
              _inStockOnly = value ?? false;
            });
          },
          activeColor: theme.primaryColor,
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          title: const Text('On Sale'),
          value: _onSaleOnly,
          onChanged: (value) {
            setState(() {
              _onSaleOnly = value ?? false;
            });
          },
          activeColor: theme.primaryColor,
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          title: const Text('Featured Products'),
          value: _featuredOnly,
          onChanged: (value) {
            setState(() {
              _featuredOnly = value ?? false;
            });
          },
          activeColor: theme.primaryColor,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
}
