import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../providers/gallery_provider.dart';

class GalleryFilter extends StatelessWidget {
  const GalleryFilter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<GalleryProvider>();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Gallery',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Search
          Text(
            'Search',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search by version or description...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              provider.setSearchQuery(value);
            },
          ),
          
          const SizedBox(height: 20),
          
          // Sort by
          Text(
            'Sort By',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: provider.sortBy,
              isExpanded: true,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'version', child: Text('Version (Latest First)')),
                DropdownMenuItem(value: 'date', child: Text('Release Date (Newest First)')),
                DropdownMenuItem(value: 'name', child: Text('Version Name (A-Z)')),
              ],
              onChanged: (value) {
                if (value != null) {
                  provider.setSortBy(value);
                }
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Features filter
          Text(
            'Features',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: provider.allFeatures.map((feature) {
              final isSelected = provider.selectedFeatures.contains(feature);
              return FilterChip(
                label: Text(
                  feature,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  final features = List<String>.from(provider.selectedFeatures);
                  if (selected) {
                    features.add(feature);
                  } else {
                    features.remove(feature);
                  }
                  provider.setSelectedFeatures(features);
                },
                backgroundColor: theme.colorScheme.surface,
                selectedColor: theme.colorScheme.primary,
                checkmarkColor: Colors.white,
              );
            }).toList(),
          ),
          
          const SizedBox(height: 20),
          
          // Filter status
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Showing ${provider.versions.length} of ${provider.versions.length} versions',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Actions
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Clear Filters',
                  onPressed: () {
                    provider.clearFilters();
                    Navigator.pop(context);
                  },
                  type: CustomButtonType.outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'Apply',
                  onPressed: () => Navigator.pop(context),
                  type: CustomButtonType.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GallerySearchBar extends StatelessWidget {
  final String query;
  final Function(String) onChanged;
  final VoidCallback? onClear;

  const GallerySearchBar({
    Key? key,
    required this.query,
    required this.onChanged,
    this.onClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        value: query,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search versions, features, descriptions...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: onClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
      ),
    );
  }
}

class GalleryStatsCard extends StatelessWidget {
  const GalleryStatsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<GalleryProvider>();
    final stats = provider.statistics;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gallery Statistics',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    theme,
                    'Total Versions',
                    '${stats['totalVersions']}',
                    Icons.apps,
                    AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    theme,
                    'Featured',
                    '${stats['featuredVersions']}',
                    Icons.star,
                    AppTheme.warningColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    theme,
                    'Screenshots',
                    '${stats['totalScreenshots']}',
                    Icons.image,
                    AppTheme.successColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    theme,
                    'Features',
                    '${stats['totalFeatures']}',
                    Icons.featured_play_list,
                    AppTheme.infoColor,
                  ),
                ),
              ],
            ),
            if (stats['latestVersion'] != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.new_releases,
                      color: AppTheme.successColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Latest: v${stats['latestVersion']}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.successColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
