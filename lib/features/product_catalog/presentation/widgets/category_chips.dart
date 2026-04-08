import 'package:flutter/material.dart';
import '../../domain/models/product_category.dart';

/// CategoryChips Widget
/// Displays product categories as selectable chips
class CategoryChips extends StatefulWidget {
  final List<ProductCategory> categories;
  final String? selectedCategory;
  final Function(String?) onCategorySelected;
  final bool isVertical;
  final bool scrollable;
  final EdgeInsets? padding;

  const CategoryChips({
    Key? key,
    required this.categories,
    this.selectedCategory,
    required this.onCategorySelected,
    this.isVertical = false,
    this.scrollable = true,
    this.padding,
  }) : super(key: key);

  @override
  State<CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips> {
  late ScrollController _scrollController;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _selectedCategory = widget.selectedCategory;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CategoryChips oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCategory != oldWidget.selectedCategory) {
      setState(() {
        _selectedCategory = widget.selectedCategory;
      });
    }
  }

  void _selectCategory(String? categoryName) {
    setState(() {
      _selectedCategory = categoryName;
    });
    widget.onCategorySelected(categoryName);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Add "All" option at the beginning
    final allCategories = [
      const ProductCategory(
        id: 'all',
        name: 'All',
        productCount: 0,
        createdAt: null,
        updatedAt: null,
      ),
      ...widget.categories,
    ];

    if (widget.isVertical) {
      return _buildVerticalLayout(theme, allCategories);
    } else {
      return _buildHorizontalLayout(theme, allCategories);
    }
  }

  Widget _buildHorizontalLayout(ThemeData theme, List<ProductCategory> categories) {
    final chips = categories.map((category) {
      final isSelected = _selectedCategory == category.name;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: _buildCategoryChip(theme, category, isSelected),
      );
    }).toList();

    return Container(
      padding: widget.padding ?? const EdgeInsets.symmetric(vertical: 8),
      child: widget.scrollable
          ? SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: Row(children: chips),
            )
          : Row(children: chips),
    );
  }

  Widget _buildVerticalLayout(ThemeData theme, List<ProductCategory> categories) {
    return Container(
      padding: widget.padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: categories.map((category) {
          final isSelected = _selectedCategory == category.name;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildCategoryChip(theme, category, isSelected, isVertical: true),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryChip(
    ThemeData theme,
    ProductCategory category,
    bool isSelected, {
    bool isVertical = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected
            ? theme.primaryColor.withOpacity(0.1)
            : theme.cardColor,
        borderRadius: BorderRadius.circular(isVertical ? 8 : 20),
        border: Border.all(
          color: isSelected
              ? theme.primaryColor.withOpacity(0.3)
              : theme.dividerColor.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: InkWell(
        onTap: () => _selectCategory(category.name),
        borderRadius: BorderRadius.circular(isVertical ? 8 : 20),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isVertical ? 12 : 16,
            vertical: isVertical ? 8 : 10,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (category.icon != null) ...[
                Icon(
                  _getIconForCategory(category.icon!),
                  size: 18,
                  color: isSelected
                      ? theme.primaryColor
                      : theme.iconTheme.color?.withOpacity(0.7),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                category.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? theme.primaryColor
                      : theme.textTheme.bodyMedium?.color,
                ),
              ),
              if (category.productCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.primaryColor.withOpacity(0.2)
                        : theme.dividerColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${category.productCount}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? theme.primaryColor
                          : theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForCategory(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'medicines':
      case 'medicine':
        return Icons.medication;
      case 'medical_devices':
      case 'devices':
        return Icons.devices;
      case 'consumables':
      case 'consumable':
        return Icons.shopping_cart;
      case 'equipment':
        return Icons.build;
      case 'supplements':
      case 'supplement':
        return Icons.vitamins;
      case 'prenatal_care':
      case 'prenatal':
        return Icons.pregnant_woman;
      case 'omega_supplements':
      case 'omega':
        return Icons.water_drop;
      case 'womens_health':
      case 'women':
        return Icons.woman;
      case 'iron_supplements':
      case 'iron':
        return Icons.bloodtype;
      case 'urinary_health':
      case 'urinary':
        return Icons.water;
      case 'fertility_support':
      case 'fertility':
        return Icons.child_care;
      case 'mens_health':
      case 'men':
        return Icons.man;
      case 'bone_health':
      case 'bone':
        return Icons.accessibility;
      case 'calcium_supplements':
      case 'calcium':
        return Icons.science;
      default:
        return Icons.category;
    }
  }
}
