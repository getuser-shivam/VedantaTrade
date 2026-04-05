import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_theme.dart';
import '../../domain/entities/product_entity.dart';

class SortOptionsWidget extends StatelessWidget {
  final int currentSortOption;
  final Function(int) onSortOptionChanged;

  const SortOptionsWidget({
    Key? key,
    required this.currentSortOption,
    required this.onSortOptionChanged,
  }) : super(key: key);

  static const List<String> sortOptions = [
    'Name (A-Z)',
    'Name (Z-A)',
    'Price (Low to High)',
    'Price (High to Low)',
    'Stock Quantity',
    'Newest First',
    'Oldest First',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.glassColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(
          color: AppTheme.glassBorderColor,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.glassBorderColor,
                  width: 1,
                ),
              ),
            ),
            child: Text(
              'Sort Products',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textPrimaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          // Sort options
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortOptions.length,
            separatorBuilder: (context, index) => Divider(
              color: AppTheme.glassBorderColor,
              height: 1,
            ),
            itemBuilder: (context, index) {
              final isSelected = index == currentSortOption;
              return ListTile(
                leading: Icon(
                  _getSortIcon(index),
                  color: isSelected 
                      ? AppTheme.primaryColor
                      : AppTheme.textSecondaryColor,
                  size: 20,
                ),
                title: Text(
                  sortOptions[index],
                  style: TextStyle(
                    color: isSelected 
                        ? AppTheme.primaryColor
                        : AppTheme.textPrimaryColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                trailing: isSelected
                    ? Icon(
                        Icons.check,
                        color: AppTheme.primaryColor,
                        size: 20,
                      )
                    : null,
                onTap: () => onSortOptionChanged(index),
                selected: isSelected,
                selectedTileColor: AppTheme.primaryColor.withOpacity(0.1),
              );
            },
          ),
          
          // Close button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: EnhancedGlassmorphicButton(
              text: 'Close',
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSortIcon(int index) {
    switch (index) {
      case 0:
      case 1:
        return Icons.sort_by_alpha;
      case 2:
      case 3:
        return Icons.attach_money;
      case 4:
        return Icons.inventory;
      case 5:
        return Icons.new_releases;
      case 6:
        return Icons.history;
      default:
        return Icons.sort;
    }
  }
}
