import 'package:flutter/material.dart';
import '../../../shared/widgets/glassmorphic_widgets.dart';
import '../models/product.dart';

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
  late String? _selectedCategory;
  late String? _selectedManufacturer;
  late String _selectedStockStatus;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.currentFilters['category'];
    _selectedManufacturer = widget.currentFilters['manufacturer'];
    _selectedStockStatus = widget.currentFilters['stock_status'] ?? 'All';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Reset', style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          _buildFilterSection('Category', widget.categories.map((c) => c.name).toList(), _selectedCategory, (val) {
            setState(() => _selectedCategory = val);
          }),
          
          const SizedBox(height: 20),
          
          _buildFilterSection('Manufacturer', widget.manufacturers.map((m) => m.name).toList(), _selectedManufacturer, (val) {
            setState(() => _selectedManufacturer = val);
          }),

          const SizedBox(height: 20),
          
          _buildFilterSection('Stock Status', ['All', 'in_stock', 'low_stock', 'out_of_stock'], _selectedStockStatus, (val) {
            setState(() => _selectedStockStatus = val!);
          }),

          const SizedBox(height: 30),
          
          GlassmorphicButton(
            text: 'Apply Filters',
            onPressed: _applyFilters,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, List<String> options, String? selectedValue, Function(String?) onSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedValue == option;
            return GlassmorphicChip(
              label: option,
              selected: isSelected,
              onTap: () => onSelected(isSelected ? null : option),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedManufacturer = null;
      _selectedStockStatus = 'All';
    });
  }

  void _applyFilters() {
    final filters = <String, dynamic>{};
    if (_selectedCategory != null) filters['category'] = _selectedCategory;
    if (_selectedManufacturer != null) filters['manufacturer'] = _selectedManufacturer;
    if (_selectedStockStatus != 'All') filters['stock_status'] = _selectedStockStatus;
    
    widget.onFiltersChanged(filters);
    Navigator.pop(context);
  }
}
