import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class VersionComparisonScreen extends StatefulWidget {
  const VersionComparisonScreen({Key? key}) : super(key: key);

  @override
  State<VersionComparisonScreen> createState() => _VersionComparisonScreenState();
}

class _VersionComparisonScreenState extends State<VersionComparisonScreen> {
  String? _version1;
  String? _version2;
  bool _showFeatureComparison = true;
  bool _showScreenshotComparison = false;

  final List<String> _availableVersions = [
    '3.2.1-alpha',
    '3.2.0-alpha',
    '3.1.0-alpha',
    '3.0.0-alpha',
  ];

  final Map<String, Map<String, dynamic>> _versionData = {
    '3.2.1-alpha': {
      'title': 'Comprehensive CI/CD Pipeline',
      'features': [
        'Complete CI/CD workflow with quality gates',
        'Automated testing suite with coverage reporting',
        'Multi-platform deployment automation',
        'Security vulnerability scanning',
        'Performance monitoring and optimization',
        'Release management with semantic versioning',
        'Environment management (staging/production)',
        'Health checks and monitoring',
        'Documentation updates and version management',
      ],
      'screenshot': 'assets/screenshots/v3.2.1-alpha.png',
      'releaseDate': '2026-04-03',
      'builds': 7,
      'tests': 15,
      'coverage': 85,
      'performance': 92,
      'security': 98,
    },
    '3.2.0-alpha': {
      'title': 'Production Hardening',
      'features': [
        'Production deployment automation',
        'Health checks and monitoring',
        'Performance optimization',
        'Security enhancements',
        'Documentation updates',
      ],
      'screenshot': 'assets/screenshots/v3.2.0-alpha.png',
      'releaseDate': '2026-04-03',
      'builds': 5,
      'tests': 12,
      'coverage': 82,
      'performance': 88,
      'security': 95,
    },
    '3.1.0-alpha': {
      'title': 'Feature Complete',
      'features': [
        '6-role architecture implementation',
        'Geospatial field force tracking',
        'Product catalog with search',
        'Distribution management',
        'VAT compliance system',
      ],
      'screenshot': 'assets/screenshots/v3.1.0-alpha.png',
      'releaseDate': '2026-04-02',
      'builds': 4,
      'tests': 10,
      'coverage': 78,
      'performance': 85,
      'security': 90,
    },
    '3.0.0-alpha': {
      'title': 'Initial Release',
      'features': [
        'Basic 6-role system',
        'Product catalog',
        'Order management',
        'Authentication system',
      ],
      'screenshot': 'assets/screenshots/v3.0.0-alpha.png',
      'releaseDate': '2026-04-01',
      'builds': 2,
      'tests': 6,
      'coverage': 70,
      'performance': 80,
      'security': 85,
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Version Comparison'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showComparisonInfo(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildVersionSelectors(context),
          Expanded(
            child: _buildComparisonContent(context),
          ),
          _buildComparisonToggle(context),
        ],
      ),
    );
  }

  Widget _buildVersionSelectors(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Versions to Compare',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildVersionDropdown(
                  context,
                  'Version 1',
                  _version1,
                  (version) => setState(() => _version1 = version),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildVersionDropdown(
                  context,
                  'Version 2',
                  _version2,
                  (version) => setState(() => _version2 = version),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVersionDropdown(
    BuildContext context,
    String label,
    String? selectedVersion,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedVersion,
              isExpanded: true,
              hint: Text(
                'Select version',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              items: _availableVersions.map((version) {
                return DropdownMenuItem<String>(
                  value: version,
                  child: Text(
                    version,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonContent(BuildContext context) {
    if (_version1 == null || _version2 == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.compare,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Select two versions to compare',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Choose versions from the dropdowns above',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    final data1 = _versionData[_version1!];
    final data2 = _versionData[_version2!];

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            indicatorColor: Theme.of(context).colorScheme.primary,
            labelColor: Theme.of(context).colorScheme.onSurface,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            tabs: const [
              Tab(
                icon: Icon(Icons.list),
                text: 'Features',
              ),
              Tab(
                icon: Icon(Icons.image),
                text: 'Screenshots',
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildFeatureComparison(context, data1, data2),
                _buildScreenshotComparison(context, data1, data2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureComparison(
    BuildContext context,
    Map<String, dynamic> data1,
    Map<String, dynamic> data2,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildComparisonHeader(context, data1, data2),
          const SizedBox(height: 20),
          _buildFeatureComparisonTable(context, data1, data2),
          const SizedBox(height: 20),
          _buildMetricsComparison(context, data1, data2),
        ],
      ),
    );
  }

  Widget _buildComparisonHeader(
    BuildContext context,
    Map<String, dynamic> data1,
    Map<String, dynamic> data2,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildVersionHeader(context, data1, true),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildVersionHeader(context, data2, false),
        ),
      ],
    );
  }

  Widget _buildVersionHeader(
    BuildContext context,
    Map<String, dynamic> data,
    bool isFirst,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isFirst
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Theme.of(context).colorScheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFirst
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.secondary,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isFirst ? 'Version 1' : 'Version 2',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isFirst
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data['version'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data['title'],
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data['releaseDate'],
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureComparisonTable(
    BuildContext context,
    Map<String, dynamic> data1,
    Map<String, dynamic> data2,
  ) {
    final features1 = List<String>.from(data1['features'] ?? []);
    final features2 = List<String>.from(data2['features'] ?? []);
    final allFeatures = {...features1, ...features2}.toList();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Text(
              'Feature Comparison',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          ...allFeatures.map((feature) {
            final hasInV1 = features1.contains(feature);
            final hasInV2 = features2.contains(feature);

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          hasInV1 ? Icons.check_circle : Icons.cancel,
                          color: hasInV1 ? Colors.green : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature,
                            style: TextStyle(
                              fontSize: 12,
                              color: hasInV1
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          hasInV2 ? Icons.check_circle : Icons.cancel,
                          color: hasInV2 ? Colors.green : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature,
                            style: TextStyle(
                              fontSize: 12,
                              color: hasInV2
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMetricsComparison(
    BuildContext context,
    Map<String, dynamic> data1,
    Map<String, dynamic> data2,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Text(
              'Metrics Comparison',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _buildMetricRow('Builds', data1['builds'], data2['builds']),
                _buildMetricRow('Tests', data1['tests'], data2['tests']),
                _buildMetricRow('Coverage', '${data1['coverage']}%', '${data2['coverage']}%'),
                _buildMetricRow('Performance', '${data1['performance']}%', '${data2['performance']}%'),
                _buildMetricRow('Security', '${data1['security']}%', '${data2['security']}%'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value1, String value2) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value1,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value2,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenshotComparison(
    BuildContext context,
    Map<String, dynamic> data1,
    Map<String, dynamic> data2,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildComparisonHeader(context, data1, data2),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildScreenshotCard(context, data1, true),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildScreenshotCard(context, data2, false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScreenshotCard(
    BuildContext context,
    Map<String, dynamic> data,
    bool isFirst,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFirst
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.secondary,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isFirst
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            ),
            child: Text(
              isFirst ? 'Version 1' : 'Version 2',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isFirst
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
              child: Image.asset(
                data['screenshot'],
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonToggle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Comparison Mode',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 16),
          Row(
            children: [
              _buildToggleButton('Features', _showFeatureComparison, () {
                setState(() {
                  _showFeatureComparison = true;
                  _showScreenshotComparison = false;
                });
              }),
              const SizedBox(width: 8),
              _buildToggleButton('Screenshots', _showScreenshotComparison, () {
                setState(() {
                  _showFeatureComparison = false;
                  _showScreenshotComparison = true;
                });
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _showComparisonInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Version Comparison'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Compare different versions of VedantaTrade to understand the evolution and improvements.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 12),
            Text(
              'Features:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('• Side-by-side feature comparison', style: TextStyle(fontSize: 12)),
            Text('• Visual screenshot comparison', style: TextStyle(fontSize: 12)),
            Text('• Metrics and performance data', style: TextStyle(fontSize: 12)),
            Text('• Release date tracking', style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
