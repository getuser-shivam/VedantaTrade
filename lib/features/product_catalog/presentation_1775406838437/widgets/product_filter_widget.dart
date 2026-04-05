import 'package:flutter/material.dart';

/// Product Filter Widget
class ProductFilterWidget extends StatefulWidget {
  final List<String> categories;
  final List<String> manufacturers;
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onFilterChanged;

  const ProductFilterWidget({
    Key? key,
    required this.categories,
    required this.manufacturers,
    required this.currentFilters,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  State<ProductFilterWidget> createState() => _ProductFilterWidgetState();
}

class _ProductFilterWidgetState extends State<ProductFilterWidget> {
  String? _selectedCategory;
  String? _selectedManufacturer;
  RangeValues? _priceRange;
  bool _inStockOnly = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.currentFilters['category'];
    _selectedManufacturer = widget.currentFilters['manufacturer'];
    
    if (widget.currentFilters['priceRange'] != null) {
      final range = widget.currentFilters['priceRange'] as Map<String, dynamic>;
      _priceRange = RangeValues(
        start: range['min'] as double,
        end: range['max'] as double,
      );
    }
    
    _inStockOnly = widget.currentFilters['inStock'] as bool? ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category filter
          _buildCategoryFilter(),
          
          const SizedBox(height: 16),
          
          // Manufacturer filter
          _buildManufacturerFilter(),
          
          const SizedBox(height: 16),
          
          // Price range filter
          _buildPriceRangeFilter(),
          
          const SizedBox(height: 16),
          
          // Stock filter
          _buildStockFilter(),
          
          const SizedBox(height: 24),
          
          // Apply filters button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Apply Filters'),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Clear filters button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _clearFilters,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.blue),
                foregroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Clear Filters'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: _selectedCategory,
            hint: const Text('All Categories'),
            isExpanded: true,
            items: ['All Categories', ...widget.categories].map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildManufacturerFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Manufacturer',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: _selectedManufacturer,
            hint: const Text('All Manufacturers'),
            isExpanded: true,
            items: ['All Manufacturers', ...widget.manufacturers].map((manufacturer) {
              return DropdownMenuItem(
                value: manufacturer,
                child: Text(manufacturer),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedManufacturer = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Range',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        RangeSlider(
          values: _priceRange,
          min: 0,
          max: 10000,
          divisions: 100,
          labels: RangeLabels(
            divide: 100,
          ),
          onChanged: (values) {
            setState(() {
              _priceRange = values;
            });
          },
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'NPR ${_priceRange?.start.toStringAsFixed(0) ?? '0'}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'NPR ${_priceRange?.end.toStringAsFixed(0) ?? '10000'}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStockFilter() {
    return Row(
      children: [
        Checkbox(
          value: _inStockOnly,
          onChanged: (value) {
            setState(() {
              _inStockOnly = value!;
            });
          },
        ),
        const SizedBox(width: 8),
        const Text('In Stock Only'),
      ],
    );
  }

  void _applyFilters() {
    final filters = <String, dynamic>{};
    
    if (_selectedCategory != null) {
      filters['category'] = _selectedCategory;
    }
    
    if (_selectedManufacturer != null) {
      filters['manufacturer'] = _selectedManufacturer;
    }
    
    if (_priceRange != null) {
      filters['priceRange'] = {
        'min': _priceRange!.start,
        'max': _priceRange!.end,
      };
    }
    
    filters['inStock'] = _inStockOnly;
    
    widget.onFilterChanged(filters);
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedManufacturer = null;
      _priceRange = null;
      _inStockOnly = false;
    });
    
    widget.onFilterChanged({});
  }
}
