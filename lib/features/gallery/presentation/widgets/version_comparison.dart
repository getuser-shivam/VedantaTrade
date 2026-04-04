import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../shared/widgets/common/enhanced_glassmorphic_theme.dart';
import '../providers/gallery_provider.dart';

class VersionComparison extends StatefulWidget {
  final AppVersion version1;
  final AppVersion version2;

  const VersionComparison({
    Key? key,
    required this.version1,
    required this.version2,
  }) : super(key: key);

  @override
  State<VersionComparison> createState() => _VersionComparisonState();
}

class _VersionComparisonState extends State<VersionComparison> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildComparisonHeader(),
          const SizedBox(height: 24),
          _buildScreenshotsComparison(),
          const SizedBox(height: 24),
          _buildFeaturesComparison(),
          const SizedBox(height: 24),
          _buildChangelogComparison(),
        ],
      ),
    );
  }

  Widget _buildComparisonHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue[600]!,
            Colors.blue[800]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.compare,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Version Comparison',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${widget.version1.name} vs ${widget.version2.name}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenshotsComparison() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Text(
              'Screenshots',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildVersionScreenshot(
                    widget.version1,
                    'Version 1',
                    Colors.blue[100]!,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildVersionScreenshot(
                    widget.version2,
                    'Version 2',
                    Colors.green[100]!,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionScreenshot(AppVersion version, String title, Color backgroundColor) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  version.name,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  version.date,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 200,
            margin: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: version.screenshotUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: version.screenshotUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.error, color: Colors.grey),
                      ),
                    ),
                  )
                : Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.image, color: Colors.grey),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesComparison() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Text(
              'Features Comparison',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildFeatureComparisonRow('Version', widget.version1.features, widget.version2.features),
                _buildFeatureComparisonRow('Major Update', [widget.version1.isMajor.toString()], [widget.version2.isMajor.toString()]),
                _buildFeatureComparisonRow('UI Changes', [widget.version1.hasUIChanges.toString()], [widget.version2.hasUIChanges.toString()]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureComparisonRow(String label, List<String> version1Features, List<String> version2Features) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildFeatureList(version1Features, Colors.blue[100]!),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFeatureList(version2Features, Colors.green[100]!),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureList(List<String> features, Color backgroundColor) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Text(
              features.length > 5 ? '${features.take(5).join(', ')}...' : features.join(', '),
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangelogComparison() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Text(
              'Changelog',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildChangelogSection('Version 1', widget.version1.changelog, Colors.blue[100]!),
                const SizedBox(height: 16),
                _buildChangelogSection('Version 2', widget.version2.changelog, Colors.green[100]!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangelogSection(String title, List<String> changelog, Color backgroundColor) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: changelog.map((change) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        change,
                        style: const TextStyle(
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
