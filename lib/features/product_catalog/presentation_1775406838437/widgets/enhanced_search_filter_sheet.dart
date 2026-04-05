import 'package:flutter/material.dart';
import '../../../shared/widgets/premium_glassmorphic_theme.dart';

class SearchFilterSheet extends StatefulWidget {
  final List<Category> categories;
  final List<Manufacturer> manufacturers;
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onFiltersChanged;

  const SearchFilterSheet({
    Key? key,
    required this.categories,
    required this.manufacturers,
    required this.currentFilters,
    required this.onFiltersChanged,
  }) : super(key: key);

  @override
  State<SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends State<SearchFilterSheet> {
  late Map<String, dynamic> _filters;
  late String _selectedCategory;
  late String _selectedManufacturer;
  late double _minPrice;
  late double _maxPrice;
  late bool _inStockOnly;
  late bool _hasDiscountOnly;

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.currentFilters);
    _selectedCategory = _filters['category'] ?? 'All';
    _selectedManufacturer = _filters['manufacturer'] ?? 'All';
    _minPrice = (_filters['minPrice'] ?? 0.0).toDouble();
    _maxPrice = (_filters['maxPrice'] ?? 10000.0).toDouble();
    _inStockOnly = _filters['inStockOnly'] ?? false;
    _hasDiscountOnly = _filters['hasDiscountOnly'] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return PremiumGlassmorphicTheme.glassModal(
          padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingLg),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.filter_list, color: PremiumGlassmorphicTheme.indigo500),
                  const SizedBox(width: PremiumGlassmorphicTheme.spacingSm),
                  const Text(
                    'Filters',
                    style: TextStyle(
                      color: PremiumGlassmorphicTheme.textPrimary,
                      fontSize: PremiumGlassmorphicTheme.fontSizeXl,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text(
                      'Clear All',
                      style: TextStyle(color: PremiumGlassmorphicTheme.indigo500),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: PremiumGlassmorphicTheme.textSecondary,
                  ),
                ],
              ),
              
              const SizedBox(height: PremiumGlassmorphicTheme.spacingMd),
              
              // Filter Options
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Filter
                      _buildSectionHeader('Category'),
                      _buildCategoryFilter(),
                      
                      const SizedBox(height: PremiumGlassmorphicTheme.spacingLg),
                      
                      // Manufacturer Filter
                      _buildSectionHeader('Manufacturer'),
                      _buildManufacturerFilter(),
                      
                      const SizedBox(height: PremiumGlassmorphicTheme.spacingLg),
                      
                      // Price Range Filter
                      _buildSectionHeader('Price Range'),
                      _buildPriceRangeFilter(),
                      
                      const SizedBox(height: PremiumGlassmorphicTheme.spacingLg),
                      
                      // Stock Filter
                      _buildSectionHeader('Availability'),
                      _buildStockFilter(),
                      
                      const SizedBox(height: PremiumGlassmorphicTheme.spacingLg),
                      
                      // Discount Filter
                      _buildSectionHeader('Special Offers'),
                      _buildDiscountFilter(),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: PremiumGlassmorphicTheme.spacingMd),
              
              // Apply Button
              SizedBox(
                width: double.infinity,
                child: PremiumGlassmorphicTheme.glassButton(
                  onPressed: _applyFilters,
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PremiumGlassmorphicTheme.spacingMd),
      child: Text(
        title,
        style: const TextStyle(
          color: PremiumGlassmorphicTheme.textPrimary,
          fontSize: PremiumGlassmorphicTheme.fontSizeLg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Wrap(
      spacing: PremiumGlassmorphicTheme.spacingSm,
      runSpacing: PremiumGlassmorphicTheme.spacingSm,
      children: [
        _buildFilterChip('All', _selectedCategory == 'All'),
        ...widget.categories.map((category) => 
          _buildFilterChip(category.name, _selectedCategory == category.name)),
      ],
    );
  }

  Widget _buildManufacturerFilter() {
    return Wrap(
      spacing: PremiumGlassmorphicTheme.spacingSm,
      runSpacing: PremiumGlassmorphicTheme.spacingSm,
      children: [
        _buildFilterChip('All', _selectedManufacturer == 'All'),
        ...widget.manufacturers.map((manufacturer) => 
          _buildFilterChip(manufacturer.name, _selectedManufacturer == manufacturer.name)),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return PremiumGlassmorphicTheme.glassChip(
      label: label,
      selected: isSelected,
      onTap: () {
        setState(() {
          if (label == 'All') {
            _selectedCategory = 'All';
            _selectedManufacturer = 'All';
          } else {
            // Determine if this is a category or manufacturer
            final isCategory = widget.categories.any((c) => c.name == label);
            if (isCategory) {
              _selectedCategory = label;
            } else {
              _selectedManufacturer = label;
            }
          }
        });
      },
    );
  }

  Widget _buildPriceRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Price Range Slider
        RangeSlider(
          values: RangeValues(_minPrice, _maxPrice),
          min: 0,
          max: 10000,
          divisions: 100,
          activeColor: PremiumGlassmorphicTheme.indigo500,
          inactiveColor: PremiumGlassmorphicTheme.borderMedium,
          onChanged: (values) {
            setState(() {
              _minPrice = values.start;
              _maxPrice = values.end;
            });
          },
        ),
        
        // Price Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'NPR ${_minPrice.toInt()}',
              style: const TextStyle(
                color: PremiumGlassmorphicTheme.textSecondary,
                fontSize: PremiumGlassmorphicTheme.fontSizeSm,
              ),
            ),
            Text(
              'NPR ${_maxPrice.toInt()}',
              style: const TextStyle(
                color: PremiumGlassmorphicTheme.textSecondary,
                fontSize: PremiumGlassmorphicTheme.fontSizeSm,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStockFilter() {
    return Column(
      children: [
        PremiumGlassmorphicTheme.glassListItem(
          title: 'In Stock Only',
          subtitle: 'Show only products that are currently available',
          leadingIcon: Icons.inventory,
          onTap: () {
            setState(() {
              _inStockOnly = !_inStockOnly;
            });
          },
          trailing: Switch(
            value: _inStockOnly,
            onChanged: (value) {
              setState(() {
                _inStockOnly = value;
              });
            },
            activeColor: PremiumGlassmorphicTheme.indigo500,
          ),
        ),
      ],
    );
  }

  Widget _buildDiscountFilter() {
    return Column(
      children: [
        PremiumGlassmorphicTheme.glassListItem(
          title: 'Has Discount',
          subtitle: 'Show only products with special offers',
          leadingIcon: Icons.local_offer,
          onTap: () {
            setState(() {
              _hasDiscountOnly = !_hasDiscountOnly;
            });
          },
          trailing: Switch(
            value: _hasDiscountOnly,
            onChanged: (value) {
              setState(() {
                _hasDiscountOnly = value;
              });
            },
            activeColor: PremiumGlassmorphicTheme.indigo500,
          ),
        ),
      ],
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = 'All';
      _selectedManufacturer = 'All';
      _minPrice = 0.0;
      _maxPrice = 10000.0;
      _inStockOnly = false;
      _hasDiscountOnly = false;
      _filters.clear();
    });
  }

  void _applyFilters() {
    _filters.clear();
    
    if (_selectedCategory != 'All') {
      _filters['category'] = _selectedCategory;
    }
    
    if (_selectedManufacturer != 'All') {
      _filters['manufacturer'] = _selectedManufacturer;
    }
    
    if (_minPrice > 0) {
      _filters['minPrice'] = _minPrice;
    }
    
    if (_maxPrice < 10000) {
      _filters['maxPrice'] = _maxPrice;
    }
    
    if (_inStockOnly) {
      _filters['inStockOnly'] = true;
    }
    
    if (_hasDiscountOnly) {
      _filters['hasDiscountOnly'] = true;
    }
    
    widget.onFiltersChanged(_filters);
    Navigator.of(context).pop();
  }
}

// Mock classes for demonstration
class Category {
  final String name;
  final int productCount;
  
  Category({required this.name, required this.productCount});
}

class Manufacturer {
  final String name;
  final int productCount;
  
  Manufacturer({required this.name, required this.productCount});
}
