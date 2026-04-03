import 'package:flutter/material.dart';
import '../providers/gallery_provider.dart';

class EnhancedVersionComparison extends StatefulWidget {
  const EnhancedVersionComparison({Key? key}) : super(key: key);

  @override
  _EnhancedVersionComparisonState createState() => _EnhancedVersionComparisonState();
}

class _EnhancedVersionComparisonState extends State<EnhancedVersionComparison> {
  @override
  Widget build(BuildContext context) {
    return Consumer<GalleryProvider>(
      builder: (context, galleryProvider, child) {
        final selectedVersions = galleryProvider.selectedVersions;
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Version Comparison'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            elevation: 0,
            actions: [
              if (selectedVersions.length == 2)
                IconButton(
                  onPressed: () => _clearComparison(context),
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear Comparison',
                ),
              IconButton(
                onPressed: () => _exportComparison(context),
                icon: const Icon(Icons.share),
                tooltip: 'Export Comparison',
              ),
            ],
          ),
          body: selectedVersions.length == 2
              ? _buildComparisonView(context, selectedVersions[0], selectedVersions[1])
              : _buildSelectionView(context, galleryProvider),
        );
      },
    );
  }

  Widget _buildSelectionView(BuildContext context, GalleryProvider galleryProvider) {
    return Column(
      children: [
        // Instructions
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Select 2 versions to compare',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Choose versions from the list below to see detailed comparison of features, performance, and changes.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Version selection grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: galleryProvider.versions.length,
            itemBuilder: (context, index) {
              final version = galleryProvider.versions[index];
              final isSelected = galleryProvider.selectedVersions.contains(version);
              
              return GestureDetector(
                onTap: () {
                  galleryProvider.toggleVersionSelection(version);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                        : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Version header
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: Theme.of(context).colorScheme.onPrimary,
                                size: 20,
                              ),
                            if (isSelected) const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                version.version ?? 'Unknown',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Version details
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildComparisonDetail(
                                'Release Date',
                                version.releaseDate ?? 'Unknown',
                                Icons.calendar_today,
                              ),
                              _buildComparisonDetail(
                                'Status',
                                version.status ?? 'Unknown',
                                Icons.info_outline,
                              ),
                              _buildComparisonDetail(
                                'Platform',
                                version.platform ?? 'Unknown',
                                Icons.devices,
                              ),
                              if (version.buildNumber != null)
                                _buildComparisonDetail(
                                  'Build',
                                  version.buildNumber!,
                                  Icons.build,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonView(BuildContext context, dynamic version1, dynamic version2) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comparison header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildVersionHeader(context, version1, 'Version 1'),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                Expanded(
                  child: _buildVersionHeader(context, version2, 'Version 2'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Feature comparison table
          _buildFeatureComparison(context, version1, version2),
          const SizedBox(height: 16),
          
          // Performance comparison
          _buildPerformanceComparison(context, version1, version2),
          const SizedBox(height: 16),
          
          // Changes summary
          _buildChangesSummary(context, version1, version2),
        ],
      ),
    );
  }

  Widget _buildVersionHeader(BuildContext context, dynamic version, String title) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            version.version ?? 'Unknown',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            version.releaseDate ?? '',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureComparison(BuildContext context, dynamic version1, dynamic version2) {
    final features1 = Set<String>.from(version1.features ?? []);
    final features2 = Set<String>.from(version2.features ?? []);
    final allFeatures = features1.union(features2).toList()..sort();
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Feature Comparison',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(),
          
          // Feature comparison rows
          ...allFeatures.map((feature) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        feature,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: features1.contains(feature)
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Icon(
                            features1.contains(feature)
                                ? Icons.check
                                : Icons.close,
                            color: features1.contains(feature)
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: features2.contains(feature)
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Icon(
                            features2.contains(feature)
                                ? Icons.check
                                : Icons.close,
                            color: features2.contains(feature)
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: features1.contains(feature) && features2.contains(feature)
                              ? Theme.of(context).colorScheme.tertiaryContainer
                              : Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            _getFeatureComparisonStatus(features1.contains(feature), features2.contains(feature)),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
        ],
      ),
    );
  }

  Widget _buildPerformanceComparison(BuildContext context, dynamic version1, dynamic version2) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Performance Metrics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(),
          
          // Performance metrics comparison
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildPerformanceRow('Load Time', '2.3s', '2.1s', true),
                _buildPerformanceRow('Memory Usage', '45MB', '38MB', true),
                _buildPerformanceRow('Bundle Size', '12.5MB', '11.2MB', true),
                _buildPerformanceRow('FPS', '58', '60', false),
                _buildPerformanceRow('Crash Rate', '0.1%', '0.05%', true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceRow(String metric, String value1, String value2, bool isBetter) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              metric,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isBetter
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  value1,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isBetter
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isBetter
                    ? Theme.of(context).colorScheme.errorContainer
                    : Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  value2,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isBetter
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          Expanded(
            flex: 2,
            child: Center(
              child: Icon(
                isBetter ? Icons.arrow_upward : Icons.arrow_downward,
                color: isBetter
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangesSummary(BuildContext context, dynamic version1, dynamic version2) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Changes Summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildChangeCategory(
                  'UI Improvements',
                  [
                    'Enhanced navigation system',
                    'Improved color scheme',
                    'Better responsive design',
                  ],
                  [
                    'Added dark mode support',
                    'Improved animations',
                    'Better accessibility',
                  ],
                ),
                _buildChangeCategory(
                  'Performance',
                  [
                    'Optimized loading times',
                    'Reduced memory usage',
                    'Improved FPS',
                  ],
                  [
                    'Faster rendering',
                    'Better resource management',
                    'Improved startup time',
                  ],
                ),
                _buildChangeCategory(
                  'New Features',
                  [
                    'Enhanced search',
                    'Improved filtering',
                    'Better organization',
                  ],
                  [
                    'Advanced analytics',
                    'Real-time updates',
                    'Better user experience',
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeCategory(String title, List<String> version1Changes, List<String> version2Changes) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: version1Changes.map((change) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                change,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: version2Changes.map((change) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.add_circle,
                              size: 16,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                change,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getFeatureComparisonStatus(bool hasV1, bool hasV2) {
    if (hasV1 && hasV2) return 'Both';
    if (hasV1 && !hasV2) return 'V1 Only';
    if (!hasV1 && hasV2) return 'V2 Only';
    return 'Neither';
  }

  void _clearComparison(BuildContext context) {
    final galleryProvider = Provider.of<GalleryProvider>(context, listen: false);
    galleryProvider.clearComparison();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Comparison cleared'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _exportComparison(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Comparison exported'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
