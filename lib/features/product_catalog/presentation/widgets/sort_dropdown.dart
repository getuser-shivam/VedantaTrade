import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/sort_option_entity.dart';
import '../providers/enhanced_filter_provider.dart';
import 'package:provider/provider.dart';

/// Sort Dropdown
/// Allows users to select sorting options
class SortDropdown extends StatelessWidget {
  const SortDropdown({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<EnhancedFilterProvider>();

    final currentSortOption = _getCurrentSortOption(provider.currentFilter);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SortOptionEntity>(
          value: currentSortOption,
          icon: Icon(Icons.expand_more, color: theme.colorScheme.onSurface),
          style: TextStyle(color: theme.colorScheme.onSurface),
          dropdownColor: theme.colorScheme.surface,
          items: PredefinedSortOptions.options.map((option) {
            return DropdownMenuItem<SortOptionEntity>(
              value: option,
              child: Row(
                children: [
                  Icon(
                    option.icon,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          option.label,
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          option.description,
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (option) {
            if (option != null) {
              HapticFeedback.lightImpact();
              provider.updateFilterField(
                sortBy: option.field,
                sortOrder: option.order,
              );
            }
          },
        ),
      ),
    );
  }

  SortOptionEntity _getCurrentSortOption(ProductFilterEntity filter) {
    if (filter.sortBy != null && filter.sortOrder != null) {
      final option = PredefinedSortOptions.getOptionByFieldAndOrder(
        filter.sortBy!,
        filter.sortOrder!,
      );
      if (option != null) return option;
    }
    return PredefinedSortOptions.defaultOption;
  }
}
