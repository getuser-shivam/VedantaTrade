import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/product_filter_entity.dart';
import '../providers/product_catalog_provider.dart';
import '../../../shared/theme/enhanced_app_theme.dart';
import '../../../shared/widgets/enhanced_text_field.dart';

/// Enhanced Search and Filter Bar
/// Comprehensive search and filtering interface with advanced options
class EnhancedSearchFilterBar extends StatefulWidget {
  final ProductFilterEntity? initialFilters;
  final Function(ProductFilterEntity)? onFiltersChanged;
  final Function(String)? onSearch;
  final bool showAdvancedFilters;
  final bool enableVoiceSearch;
  final bool enableBarcodeSearch;
  final String? placeholder;
  final EdgeInsets? padding;
  final bool expanded;

  const EnhancedSearchFilterBar({
    Key? key,
    this.initialFilters,
    this.onFiltersChanged,
    this.onSearch,
    this.showAdvancedFilters = true,
    this.enableVoiceSearch = false,
    this.enableBarcodeSearch = false,
    this.placeholder,
    this.padding,
    this.expanded = false,
  }) : super(key: key);

  @override
  State<EnhancedSearchFilterBar> createState() => _EnhancedSearchFilterBarState();
}

class _EnhancedSearchFilterBarState extends State<EnhancedSearchFilterBar>
    with TickerProviderStateMixin {
  late TextEditingController _searchController;
  late AnimationController _filterPanelController;
  late AnimationController _searchController;
  late Animation<double> _filterPanelAnimation;
  late Animation<Offset> _searchAnimation;
  
  bool _isFilterPanelOpen = false;
  bool _isSearching = false;
  ProductFilterEntity _currentFilters = const ProductFilterEntity();
  String _lastSearchQuery = '';

  @override
  void initState() {
    super.initState();
    
    _searchController = TextEditingController();
    _filterPanelController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _searchController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _filterPanelAnimation = CurvedAnimation(
      parent: _filterPanelController,
      curve: Curves.easeInOut,
    );

    _searchAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, 0.1),
    ).animate(CurvedAnimation(
      parent: _searchController,
      curve: Curves.easeInOut,
    ));

    _currentFilters = widget.initialFilters ?? const ProductFilterEntity();
    
    if (widget.expanded) {
      _filterPanelController.forward();
      _isFilterPanelOpen = true;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _filterPanelController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleFilterPanel() {
    setState(() {
      _isFilterPanelOpen = !_isFilterPanelOpen;
    });

    if (_isFilterPanelOpen) {
      _filterPanelController.forward();
    } else {
      _filterPanelController.reverse();
    }
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    
    if (query == _lastSearchQuery) return;
    
    setState(() {
      _isSearching = true;
      _lastSearchQuery = query;
    });

    final updatedFilters = _currentFilters.copyWith(searchQuery: query.isEmpty ? null : query);
    _updateFilters(updatedFilters);

    widget.onSearch?.call(query);
    widget.onFiltersChanged?.call(updatedFilters);

    // Simulate search completion
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _lastSearchQuery = '';
    
    final updatedFilters = _currentFilters.copyWith(searchQuery: null);
    _updateFilters(updatedFilters);
    
    widget.onSearch?.call('');
    widget.onFiltersChanged?.call(updatedFilters);
  }

  void _updateFilters(ProductFilterEntity filters) {
    setState(() {
      _currentFilters = filters;
    });
  }

  void _applyFilter(String category, dynamic value) {
    ProductFilterEntity updatedFilters;

    switch (category) {
      case 'categories':
        final categories = List<String>.from(_currentFilters.categories);
        if (categories.contains(value)) {
          categories.remove(value);
        } else {
          categories.add(value);
        }
        updatedFilters = _currentFilters.copyWith(categories: categories);
        break;
      case 'brands':
        final brands = List<String>.from(_currentFilters.brands);
        if (brands.contains(value)) {
          brands.remove(value);
        } else {
          brands.add(value);
        }
        updatedFilters = _currentFilters.copyWith(brands: brands);
        break;
      case 'price':
        updatedFilters = _currentFilters.copyWith(
          minPrice: value['min'],
          maxPrice: value['max'],
        );
        break;
      case 'stock':
        updatedFilters = _currentFilters.copyWith(
          inStockOnly: value,
        );
        break;
      case 'rating':
        updatedFilters = _currentFilters.copyWith(
          minRating: value,
        );
        break;
      case 'sort':
        updatedFilters = _currentFilters.copyWith(
          sortBy: value['field'],
          sortOrder: value['order'],
        );
        break;
      default:
        return;
    }

    _updateFilters(updatedFilters);
    widget.onFiltersChanged?.call(updatedFilters);
  }

  void _clearAllFilters() {
    _updateFilters(const ProductFilterEntity());
    widget.onFiltersChanged?.call(const ProductFilterEntity());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Main Search Bar
        Container(
          padding: widget.padding ?? const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search Input Row
              Row(
                children: [
                  // Search Field
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _searchAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: _searchAnimation.value * MediaQuery.of(context).size.height,
                          child: EnhancedTextField(
                            controller: _searchController,
                            hintText: widget.placeholder ?? 'Search products...',
                            prefixIcon: _isSearching 
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                    ),
                                  )
                                : const Icon(Icons.search),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: _clearSearch,
                                  )
                                : null,
                            onSubmitted: (_) => _performSearch(),
                            onChanged: (value) {
                              if (value.isEmpty) {
                                _clearSearch();
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Filter Button
                  if (widget.showAdvancedFilters)
                    Container(
                      decoration: BoxDecoration(
                        color: _currentFilters.hasActiveFilters 
                            ? theme.primaryColor.withOpacity(0.1)
                            : theme.cardColor,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: _currentFilters.hasActiveFilters 
                              ? theme.primaryColor
                              : theme.dividerColor,
                        ),
                      ),
                      child: Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.tune),
                            onPressed: _toggleFilterPanel,
                            color: _currentFilters.hasActiveFilters 
                                ? theme.primaryColor
                                : null,
                          ),
                          if (_currentFilters.hasActiveFilters)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: theme.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  
                  // Voice Search Button
                  if (widget.enableVoiceSearch)
                    IconButton(
                      icon: const Icon(Icons.mic),
                      onPressed: () {
                        // Implement voice search
                      },
                    ),
                  
                  // Barcode Search Button
                  if (widget.enableBarcodeSearch)
                    IconButton(
                      icon: const Icon(Icons.qr_code_scanner),
                      onPressed: () {
                        // Implement barcode search
                      },
                    ),
                ],
              ),
              
              // Active Filters Chips
              if (_currentFilters.hasActiveFilters)
                Container(
                  margin: const EdgeInsets.only(top: 8.0),
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      // Search Query Chip
                      if (_currentFilters.searchQuery != null && _currentFilters.searchQuery!.isNotEmpty)
                        _buildFilterChip(
                          label: 'Search: ${_currentFilters.searchQuery}',
                          onRemove: () => _clearSearch(),
                        ),
                      
                      // Category Chips
                      ..._currentFilters.categories.map((category) => 
                          _buildFilterChip(
                            label: category,
                            onRemove: () => _applyFilter('categories', category),
                          ),
                        ),
                      
                      // Brand Chips
                      ..._currentFilters.brands.map((brand) => 
                          _buildFilterChip(
                            label: brand,
                            onRemove: () => _applyFilter('brands', brand),
                          ),
                        ),
                      
                      // Price Range Chip
                      if (_currentFilters.hasPriceRange)
                        _buildFilterChip(
                          label: _currentFilters.formattedPriceRange,
                          onRemove: () => _applyFilter('price', {'min': null, 'max': null}),
                        ),
                      
                      // Stock Status Chip
                      if (_currentFilters.inStockOnly == true)
                        _buildFilterChip(
                          label: 'In Stock Only',
                          onRemove: () => _applyFilter('stock', null),
                        ),
                      
                      // Rating Chip
                      if (_currentFilters.minRating != null)
                        _buildFilterChip(
                          label: '${_currentFilters.minRating}+ Stars',
                          onRemove: () => _applyFilter('rating', null),
                        ),
                      
                      // Clear All Chip
                      _buildFilterChip(
                        label: 'Clear All',
                        onRemove: _clearAllFilters,
                        isDestructive: true,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        
        // Advanced Filter Panel
        if (widget.showAdvancedFilters)
          SizeTransition(
            sizeFactor: _filterPanelAnimation,
            child: _buildFilterPanel(theme),
          ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onRemove,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(right: 8.0),
      child: Chip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDestructive 
                ? Colors.white 
                : theme.textTheme.bodySmall?.color,
          ),
        ),
        backgroundColor: isDestructive 
            ? Colors.red 
            : theme.primaryColor.withOpacity(0.1),
        deleteIcon: Icon(
          Icons.close,
          size: 16,
          color: isDestructive 
              ? Colors.white 
              : theme.textTheme.bodySmall?.color,
        ),
        onDeleted: onRemove,
      ),
    );
  }

  Widget _buildFilterPanel(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          top: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Panel Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Advanced Filters',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: _clearAllFilters,
                child: const Text('Clear All'),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Filter Options
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categories
                  _buildFilterSection(
                    title: 'Categories',
                    child: _buildCheckboxList(
                      items: ['Tablets', 'Capsules', 'Syrups', 'Injections', 'Ointments'],
                      selectedItems: _currentFilters.categories,
                      onToggle: (value) => _applyFilter('categories', value),
                    ),
                  ),
                  
                  // Brands
                  _buildFilterSection(
                    title: 'Brands',
                    child: _buildCheckboxList(
                      items: ['Pfizer', 'Johnson & Johnson', 'GlaxoSmithKline', 'Novartis'],
                      selectedItems: _currentFilters.brands,
                      onToggle: (value) => _applyFilter('brands', value),
                    ),
                  ),
                  
                  // Price Range
                  _buildFilterSection(
                    title: 'Price Range',
                    child: _buildPriceRangeSlider(),
                  ),
                  
                  // Stock Status
                  _buildFilterSection(
                    title: 'Stock Status',
                    child: SwitchListTile(
                      title: const Text('In Stock Only'),
                      value: _currentFilters.inStockOnly ?? false,
                      onChanged: (value) => _applyFilter('stock', value),
                    ),
                  ),
                  
                  // Rating
                  _buildFilterSection(
                    title: 'Minimum Rating',
                    child: _buildRatingSelector(),
                  ),
                  
                  // Sort Options
                  _buildFilterSection(
                    title: 'Sort By',
                    child: _buildSortOptions(),
                  ),
                ],
              ),
            ),
          ),
          
          // Apply Button
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _toggleFilterPanel();
                widget.onFiltersChanged?.call(_currentFilters);
              },
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        child,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCheckboxList({
    required List<String> items,
    required List<String> selectedItems,
    required Function(String) onToggle,
  }) {
    return Column(
      children: items.map((item) {
        return CheckboxListTile(
          title: Text(item),
          value: selectedItems.contains(item),
          onChanged: (_) => onToggle(item),
          dense: true,
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }

  Widget _buildPriceRangeSlider() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'NPR ${(_currentFilters.minPrice ?? 0).toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'NPR ${(_currentFilters.maxPrice ?? 10000).toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        RangeSlider(
          values: RangeValues(
            _currentFilters.minPrice ?? 0,
            _currentFilters.maxPrice ?? 10000,
          ),
          min: 0,
          max: 10000,
          divisions: 100,
          onChanged: (values) {
            _applyFilter('price', {
              'min': values.start,
              'max': values.end,
            });
          },
        ),
      ],
    );
  }

  Widget _buildRatingSelector() {
    return Row(
      children: List.generate(5, (index) {
        final rating = index + 1;
        final isSelected = (_currentFilters.minRating ?? 0) >= rating;
        
        return IconButton(
          icon: Icon(
            isSelected ? Icons.star : Icons.star_border,
            color: isSelected ? Colors.amber : null,
          ),
          onPressed: () => _applyFilter('rating', rating.toDouble()),
        );
      }),
    );
  }

  Widget _buildSortOptions() {
    final sortOptions = [
      {'field': 'name', 'order': 'asc', 'label': 'Name A-Z'},
      {'field': 'name', 'order': 'desc', 'label': 'Name Z-A'},
      {'field': 'price', 'order': 'asc', 'label': 'Price Low to High'},
      {'field': 'price', 'order': 'desc', 'label': 'Price High to Low'},
      {'field': 'rating', 'order': 'desc', 'label': 'Highest Rated'},
      {'field': 'createdAt', 'order': 'desc', 'label': 'Newest First'},
    ];

    return Column(
      children: sortOptions.map((option) {
        final isSelected = _currentFilters.sortBy == option['field'] && 
                          _currentFilters.sortOrder == option['order'];
        
        return RadioListTile<String>(
          title: Text(option['label'] as String),
          value: option['field'] as String,
          groupValue: _currentFilters.sortBy,
          onChanged: (_) {
            _applyFilter('sort', {
              'field': option['field'],
              'order': option['order'],
            });
          },
          dense: true,
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }
}
