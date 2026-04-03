import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../widgets/gallery_carousel.dart';
import '../widgets/version_card.dart';
import '../widgets/gallery_filter.dart';
import '../providers/gallery_provider.dart';

class AppGalleryScreen extends StatefulWidget {
  const AppGalleryScreen({Key? key}) : super(key: key);

  @override
  _AppGalleryScreenState createState() => _AppGalleryScreenState();
}

class _AppGalleryScreenState extends State<AppGalleryScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _tabController = TabController(length: 3, vsync: this);
    _animationController.forward();

    // Initialize gallery data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GalleryProvider>().loadGalleryData();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: _buildAppBar(theme),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildTabBar(theme),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCarouselView(theme),
                  _buildGridView(theme),
                  _buildComparisonView(theme),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      title: Row(
        children: [
          Icon(
            Icons.photo_library_outlined,
            color: theme.colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            'App Gallery',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(
            Icons.search,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => _showSearch(context),
        ),
        IconButton(
          icon: Icon(
            Icons.filter_list,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => _showFilter(context),
        ),
      ],
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
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
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.7),
        tabs: const [
          Tab(
            icon: Icon(Icons.view_carousel),
            text: 'Carousel',
          ),
          Tab(
            icon: Icon(Icons.grid_view),
            text: 'Grid View',
          ),
          Tab(
            icon: Icon(Icons.compare),
            text: 'Compare',
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselView(ThemeData theme) {
    return Consumer<GalleryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.hasError) {
          return _buildErrorWidget(provider.errorMessage);
        }

        return Column(
          children: [
            // Featured Carousel
            Container(
              height: 300,
              margin: const EdgeInsets.all(16),
              child: GalleryCarousel(
                versions: provider.featuredVersions,
                onVersionSelected: (version) => _showVersionDetails(version),
              ),
            ),
            
            // Version List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: provider.versions.length,
                itemBuilder: (context, index) {
                  final version = provider.versions[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: VersionCard(
                      version: version,
                      onTap: () => _showVersionDetails(version),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGridView(ThemeData theme) {
    return Consumer<GalleryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: provider.versions.length,
          itemBuilder: (context, index) {
            final version = provider.versions[index];
            return VersionCard(
              version: version,
              isCompact: true,
              onTap: () => _showVersionDetails(version),
            );
          },
        );
      },
    );
  }

  Widget _buildComparisonView(ThemeData theme) {
    return Consumer<GalleryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.versions.length < 2) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.compare,
                  size: 64,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'Need at least 2 versions to compare',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Version Selection
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildVersionSelector(
                      theme,
                      'Version 1',
                      provider.selectedVersion1,
                      (version) => provider.selectVersion1(version),
                      provider.versions,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildVersionSelector(
                      theme,
                      'Version 2',
                      provider.selectedVersion2,
                      (version) => provider.selectVersion2(version),
                      provider.versions,
                    ),
                  ),
                ],
              ),
            ),
            
            // Comparison Content
            if (provider.selectedVersion1 != null && provider.selectedVersion2 != null)
              Expanded(
                child: _buildComparisonContent(theme, provider),
              ),
          ],
        );
      },
    );
  }

  Widget _buildVersionSelector(
    ThemeData theme,
    String label,
    AppVersion? selectedVersion,
    Function(AppVersion) onSelected,
    List<AppVersion> versions,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<AppVersion>(
            value: selectedVersion,
            isExpanded: true,
            hint: Text(
              'Select version',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            items: versions.map((version) {
              return DropdownMenuItem<AppVersion>(
                value: version,
                child: Text(
                  'v${version.version}',
                  style: theme.textTheme.bodyMedium,
                ),
              );
            }).toList(),
            onChanged: (version) {
              if (version != null) {
                onSelected(version);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonContent(ThemeData theme, GalleryProvider provider) {
    final version1 = provider.selectedVersion1!;
    final version2 = provider.selectedVersion2!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Side-by-side comparison
          Row(
            children: [
              Expanded(
                child: _buildComparisonSide(
                  theme,
                  'v${version1.version}',
                  version1.screenshots.isNotEmpty ? version1.screenshots.first : null,
                  version1.features,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildComparisonSide(
                  theme,
                  'v${version2.version}',
                  version2.screenshots.isNotEmpty ? version2.screenshots.first : null,
                  version2.features,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Feature comparison table
          _buildFeatureComparisonTable(theme, version1, version2),
        ],
      ),
    );
  }

  Widget _buildComparisonSide(
    ThemeData theme,
    String versionTitle,
    String? screenshot,
    List<String> features,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          versionTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        if (screenshot != null)
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: theme.colorScheme.surface,
              image: DecorationImage(
                image: AssetImage(screenshot),
                fit: BoxFit.cover,
              ),
            ),
          ),
        const SizedBox(height: 12),
        ...features.map((feature) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                size: 16,
                color: AppTheme.successColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  feature,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildFeatureComparisonTable(
    ThemeData theme,
    AppVersion version1,
    AppVersion version2,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Feature Comparison',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                  ),
                  children: [
                    _buildTableCell(
                      theme,
                      'Feature',
                      isHeader: true,
                    ),
                    _buildTableCell(
                      theme,
                      'v${version1.version}',
                      isHeader: true,
                    ),
                    _buildTableCell(
                      theme,
                      'v${version2.version}',
                      isHeader: true,
                    ),
                  ],
                ),
                ..._getComparisonFeatures(version1, version2).map((comparison) {
                  return TableRow(
                    children: [
                      _buildTableCell(theme, comparison.feature),
                      _buildTableCell(
                        theme,
                        comparison.hasVersion1 ? '✓' : '✗',
                        color: comparison.hasVersion1 ? AppTheme.successColor : AppTheme.errorColor,
                      ),
                      _buildTableCell(
                        theme,
                        comparison.hasVersion2 ? '✓' : '✗',
                        color: comparison.hasVersion2 ? AppTheme.successColor : AppTheme.errorColor,
                      ),
                    ],
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCell(
    ThemeData theme,
    String text, {
    bool isHeader = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: isHeader
            ? theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              )
            : theme.textTheme.bodySmall?.copyWith(
                color: color,
              ),
        textAlign: TextAlign.center,
      ),
    );
  }

  List<FeatureComparison> _getComparisonFeatures(
    AppVersion version1,
    AppVersion version2,
  ) {
    final allFeatures = <String>{...version1.features, ...version2.features}.toList();
    
    return allFeatures.map((feature) {
      return FeatureComparison(
        feature: feature,
        hasVersion1: version1.features.contains(feature),
        hasVersion2: version2.features.contains(feature),
      );
    }).toList();
  }

  Widget _buildErrorWidget(String? error) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error ?? 'Failed to load gallery data',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Retry',
              onPressed: () => context.read<GalleryProvider>().loadGalleryData(),
              type: CustomButtonType.primary,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => _showAddVersion(context),
      icon: const Icon(Icons.add),
      label: const Text('Add Version'),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
    );
  }

  void _showVersionDetails(AppVersion version) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VersionDetailScreen(version: version),
      ),
    );
  }

  void _showSearch(BuildContext context) {
    // Show search functionality
  }

  void _showFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => GalleryFilter(),
    );
  }

  void _showAddVersion(BuildContext context) {
    // Show add version dialog
  }
}

class VersionDetailScreen extends StatelessWidget {
  final AppVersion version;

  const VersionDetailScreen({
    Key? key,
    required this.version,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Version ${version.version}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Version header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Version ${version.version}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    version.releaseDate,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    version.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Screenshots
            Text(
              'Screenshots',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: version.screenshots.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 300,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: theme.colorScheme.surface,
                      image: DecorationImage(
                        image: AssetImage(version.screenshots[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Features
            Text(
              'Features',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...version.features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppTheme.successColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )),
            
            const SizedBox(height: 24),
            
            // Changelog
            Text(
              'Changelog',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...version.changelog.map((change) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '• $change',
                style: theme.textTheme.bodyMedium,
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class FeatureComparison {
  final String feature;
  final bool hasVersion1;
  final bool hasVersion2;

  FeatureComparison({
    required this.feature,
    required this.hasVersion1,
    required this.hasVersion2,
  });
}
