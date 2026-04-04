import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';

class SearchFilterBar extends StatefulWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final String selectedCategory;
  final String sortBy;
  final bool showInStockOnly;
  final bool showExpiringSoonOnly;
  final List<ProductCategory> categories;
  final Function(String) onSearchChanged;
  final Function(String) onCategoryChanged;
  final Function(String) onSortChanged;
  final Function() onInStockToggle;
  final Function() onExpiringSoonToggle;
  final Function() onClearFilters;

  const SearchFilterBar({
    Key? key,
    required this.searchController,
    required this.searchQuery,
    required this.selectedCategory,
    required this.sortBy,
    required this.showInStockOnly,
    required this.showExpiringSoonOnly,
    required this.categories,
    required this.onSearchChanged,
    required this.onCategoryChanged,
    required this.onSortChanged,
    required this.onInStockToggle,
    required this.onExpiringSoonToggle,
    required this.onClearFilters,
  }) : super(key: key);

  @override
  State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  bool _showFilters = false;
  final List<String> _sortOptions = [
    'name',
    'price',
    'rating',
    'stock',
    'expiry',
    'manufacturer',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products by name, generic name, or manufacturer...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: widget.searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                widget.searchController.clear();
                                widget.onSearchChanged('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    onChanged: widget.onSearchChanged,
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showFilters = !_showFilters;
                    });
                  },
                  icon: Icon(
                    _showFilters ? Icons.filter_list_off : Icons.filter_list,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
          
          // Filters section
          if (_showFilters) _buildFiltersSection(),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Category filter
              FilterChip(
                label: Text(widget.selectedCategory.isEmpty ? 'All Categories' : widget.selectedCategory),
                selected: widget.selectedCategory.isNotEmpty,
                onSelected: (selected) {
                  if (selected) {
                    _showCategoryDialog();
                  } else {
                    widget.onCategoryChanged('');
                  }
                },
                avatar: widget.selectedCategory.isNotEmpty 
                    ? const Icon(Icons.category, size: 16) 
                    : null,
              ),
              
              // Sort by filter
              FilterChip(
                label: Text('Sort: ${_getSortDisplayName(widget.sortBy)}'),
                selected: true,
                onSelected: (_) => _showSortDialog(),
                avatar: const Icon(Icons.sort, size: 16),
              ),
              
              // In stock filter
              FilterChip(
                label: const Text('In Stock Only'),
                selected: widget.showInStockOnly,
                onSelected: (_) => widget.onInStockToggle(),
                avatar: Icon(
                  Icons.inventory_2,
                  size: 16,
                  color: widget.showInStockOnly ? Colors.white : null,
                ),
              ),
              
              // Expiring soon filter
              FilterChip(
                label: const Text('Expiring Soon'),
                selected: widget.showExpiringSoonOnly,
                onSelected: (_) => widget.onExpiringSoonToggle(),
                avatar: Icon(
                  Icons.schedule,
                  size: 16,
                  color: widget.showExpiringSoonOnly ? Colors.white : null,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Clear filters button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters Applied: ${_getAppliedFiltersCount()}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              TextButton.icon(
                onPressed: widget.onClearFilters,
                icon: const Icon(Icons.clear_all, size: 16),
                label: const Text('Clear All'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Category'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: widget.categories.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return ListTile(
                  title: const Text('All Categories'),
                  leading: const Icon(Icons.category),
                  onTap: () {
                    Navigator.of(context).pop();
                    widget.onCategoryChanged('');
                  },
                );
              }
              
              final category = widget.categories[index - 1];
              return ListTile(
                title: Text(category.name),
                subtitle: Text('${category.productCount} products'),
                leading: Icon(
                  _getCategoryIcon(category.name),
                  color: Theme.of(context).colorScheme.primary,
                ),
                trailing: Text(
                  category.productCount.toString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onCategoryChanged(category.name);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort By'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _sortOptions.map((option) {
            return RadioListTile<String>(
              title: Text(_getSortDisplayName(option)),
              value: option,
              groupValue: widget.sortBy,
              onChanged: (value) {
                Navigator.of(context).pop();
                widget.onSortChanged(value!);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getSortDisplayName(String sortBy) {
    switch (sortBy) {
      case 'name':
        return 'Name';
      case 'price':
        return 'Price';
      case 'rating':
        return 'Rating';
      case 'stock':
        return 'Stock';
      case 'expiry':
        return 'Expiry Date';
      case 'manufacturer':
        return 'Manufacturer';
      default:
        return sortBy;
    }
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'analgesics':
        return Icons.healing;
      case 'antibiotics':
        return Icons.medication;
      case 'gastrointestinal':
        return Icons.stomach;
      case 'respiratory':
        return Icons.lungs;
      case 'antidiabetic':
        return Icons.monitor_heart;
      case 'cardiovascular':
        return Icons.favorite;
      case 'dermatological':
        return Icons.face;
      case 'vitamins':
        return Icons.energy_savings_leaf;
      case 'vaccines':
        return Icons.vaccines;
      case 'oncology':
        return Icons.biotech;
      default:
        return Icons.medication;
    }
  }

  int _getAppliedFiltersCount() {
    int count = 0;
    if (widget.selectedCategory.isNotEmpty) count++;
    if (widget.showInStockOnly) count++;
    if (widget.showExpiringSoonOnly) count++;
    if (widget.searchQuery.isNotEmpty) count++;
    return count;
  }
}

class QuickFilterChips extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const QuickFilterChips({
    Key? key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildChip('All', '', context);
          }
          
          final category = categories[index - 1];
          return _buildChip(category, category, context);
        },
      ),
    );
  }

  Widget _buildChip(String label, String value, BuildContext context) {
    final isSelected = selectedCategory == value;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            onCategorySelected(value);
          }
        },
        backgroundColor: isSelected 
            ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
            : Colors.grey.shade200,
        selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        checkmarkColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
