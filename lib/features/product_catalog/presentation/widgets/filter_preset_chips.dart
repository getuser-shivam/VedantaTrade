import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/filter_preset_entity.dart';
import '../../domain/entities/system_filter_presets.dart';
import '../providers/enhanced_filter_provider.dart';
import 'package:provider/provider.dart';

/// Filter Preset Chips
/// Quick access to pre-defined filter combinations
class FilterPresetChips extends StatelessWidget {
  final bool isVertical;
  final bool showSystemPresets;
  final bool showCustomPresets;

  const FilterPresetChips({
    Key? key,
    this.isVertical = false,
    this.showSystemPresets = true,
    this.showCustomPresets = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<EnhancedFilterProvider>();

    final systemPresets = showSystemPresets
        ? SystemFilterPresets.presets
        : <FilterPresetEntity>[];
    
    final customPresets = showCustomPresets
        ? provider.presets.where((p) => !p.isSystemPreset).toList()
        : <FilterPresetEntity>[];

    final allPresets = [...systemPresets, ...customPresets];

    if (allPresets.isEmpty) {
      return const SizedBox.shrink();
    }

    if (isVertical) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: allPresets.map((preset) => _buildPresetChip(
          context,
          preset,
          provider,
          theme,
          isVertical: true,
        )).toList(),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: allPresets.map((preset) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _buildPresetChip(
            context,
            preset,
            provider,
            theme,
            isVertical: false,
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildPresetChip(
    BuildContext context,
    FilterPresetEntity preset,
    EnhancedFilterProvider provider,
    ThemeData theme, {
    required bool isVertical,
  }) {
    final isSelected = provider.matchesPreset(preset);

    if (isVertical) {
      return _buildVerticalPresetChip(
        context,
        preset,
        provider,
        theme,
        isSelected,
      );
    }

    return _buildHorizontalPresetChip(
      context,
      preset,
      provider,
      theme,
      isSelected,
    );
  }

  Widget _buildHorizontalPresetChip(
    BuildContext context,
    FilterPresetEntity preset,
    EnhancedFilterProvider provider,
    ThemeData theme,
    bool isSelected,
  ) {
    return FilterChip(
      avatar: Icon(
        preset.icon,
        size: 18,
        color: isSelected
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.primary,
      ),
      label: Text(
        preset.name,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        HapticFeedback.lightImpact();
        if (selected) {
          provider.applyPreset(preset);
        }
      },
      selectedColor: theme.colorScheme.primary,
      checkmarkColor: theme.colorScheme.onPrimary,
      backgroundColor: theme.colorScheme.surfaceVariant,
      labelStyle: TextStyle(
        color: isSelected
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildVerticalPresetChip(
    BuildContext context,
    FilterPresetEntity preset,
    EnhancedFilterProvider provider,
    ThemeData theme,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        provider.applyPreset(preset);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              preset.icon,
              size: 18,
              color: isSelected
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurface,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                preset.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                size: 18,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
