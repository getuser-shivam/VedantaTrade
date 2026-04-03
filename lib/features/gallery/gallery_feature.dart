import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_gallery_provider.dart';
import '../screens/app_gallery_screen.dart';
import '../screens/gallery_navigation_screen.dart';
import '../screens/version_comparison_screen.dart';
import '../screens/gallery_statistics_screen.dart';
import '../routes/gallery_routes.dart';

class GalleryFeature extends StatelessWidget {
  const GalleryFeature({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppGalleryProvider()..initializeVersions(),
      child: MaterialApp(
        title: 'VedantaTrade Gallery',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
        ),
        initialRoute: GalleryRoutes.galleryOverview,
        routes: {
          GalleryRoutes.galleryOverview: (context) => const GalleryNavigationScreen(),
          GalleryRoutes.appGallery: (context) => const AppGalleryScreen(),
          GalleryRoutes.versionComparison: (context) => const VersionComparisonScreen(),
          GalleryRoutes.galleryStatistics: (context) => const GalleryStatisticsScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == GalleryRoutes.versionDetails) {
            final args = settings.arguments as GalleryRouteArguments;
            return MaterialPageRoute(
              builder: (context) => VersionDetailsScreen(
                version: args.version!,
                versionData: args.versionData,
              ),
            );
          }
          return null;
        },
      ),
    );
  }
}

class VersionDetailsScreen extends StatelessWidget {
  final String version;
  final Map<String, dynamic> versionData;

  const VersionDetailsScreen({
    Key? key,
    required this.version,
    required this.versionData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Version $version'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVersionHeader(context),
            const SizedBox(height: 24),
            _buildFeaturesSection(context),
            const SizedBox(height: 24),
            _buildMetricsSection(context),
            const SizedBox(height: 24),
            _buildScreenshotsSection(context),
            const SizedBox(height: 24),
            _buildChangelogSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            versionData['title'],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Version $version',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            versionData['date'],
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            versionData['description'],
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white90,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    final features = List<String>.from(versionData['features'] ?? []);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Features',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsSection(BuildContext context) {
    final metrics = versionData['metrics'] as Map<String, dynamic>? ?? {};
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Metrics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.5,
              children: [
                _buildMetricItem('Builds', metrics['builds']?.toString() ?? '0', Icons.build),
                _buildMetricItem('Tests', metrics['tests']?.toString() ?? '0', Icons.science),
                _buildMetricItem('Coverage', '${metrics['coverage'] ?? 0}%', Icons.percent),
                _buildMetricItem('Performance', '${metrics['performance'] ?? 0}%', Icons.speed),
                _buildMetricItem('Security', '${metrics['security'] ?? 0}%', Icons.security),
                _buildMetricItem('Quality', '${metrics['quality'] ?? 0}%', Icons.high_quality),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenshotsSection(BuildContext context) {
    final screenshots = List<String>.from(versionData['screenshots'] ?? []);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Screenshots',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (screenshots.isNotEmpty)
              Column(
                children: screenshots.map((screenshot) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      screenshot,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            border: Border.all(color: Theme.of(context).dividerColor),
                            borderRadius: BorderRadius.circular(8),
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
                )).toList(),
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported,
                    size: 40,
                    color: Colors.grey,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChangelogSection(BuildContext context) {
    final changelog = versionData['changelog'] as String? ?? '';
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Changelog',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              changelog.isNotEmpty ? changelog : 'No changelog available.',
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
