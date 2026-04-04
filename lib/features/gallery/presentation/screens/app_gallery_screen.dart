import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../shared/widgets/common/enhanced_glassmorphic_theme.dart';
import '../../../shared/widgets/common/enhanced_navigation_widget.dart';
import '../providers/gallery_provider.dart';
import '../widgets/gallery_carousel.dart';
import '../widgets/version_comparison.dart';
import '../widgets/gallery_statistics.dart';

class AppGalleryScreen extends StatefulWidget {
  const AppGalleryScreen({Key? key}) : super(key: key);

  @override
  State<AppGalleryScreen> createState() => _AppGalleryScreenState();
}

class _AppGalleryScreenState extends State<AppGalleryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCarouselTab(),
                  _buildGridTab(),
                  _buildCompareTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
        ),
      child: Row(
        children: [
          Icon(
            Icons.photo_library_outlined,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VedantaTrade Gallery',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Evolution of Nepal\'s Premier Pharmaceutical Distribution Platform',
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

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.grey[600],
        unselectedLabelColor: Colors.grey[400],
        indicatorColor: Colors.blue[600],
        indicatorWeight: 3,
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(
            icon: Icon(Icons.slideshow),
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

  Widget _buildCarouselTab() {
    return Consumer<GalleryProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            _buildSearchBar(provider),
            _buildFilterBar(provider),
            Expanded(
              child: GalleryCarousel(
                versions: provider.versions,
                onVersionSelected: (version) {
                  // Navigate to version details
                },
              ),
            ),
          ),
            _buildStatistics(provider),
          ],
        );
      },
    );
  }

  Widget _buildGridTab() {
    return Consumer<GalleryProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            _buildSearchBar(provider),
            _buildFilterBar(provider),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: provider.filteredVersions.length,
                itemBuilder: (context, index) {
                  final version = provider.filteredVersions[index];
                  return _buildVersionCard(version);
                },
              ),
            ),
          ),
            _buildStatistics(provider),
          ],
        );
      },
    );
  }

  Widget _buildCompareTab() {
    return Consumer<GalleryProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            _buildCompareSelector(provider),
            Expanded(
              child: provider.selectedVersions.length == 2
                  ? VersionComparison(
                      version1: provider.selectedVersions[0],
                      version2: provider.selectedVersions[1],
                    )
                  : _buildComparePrompt(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar(GalleryProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      child: GlassmorphicContainer(
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search versions...',
            prefixIcon: const Icon(Icons.search),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(16.0),
          ),
          onChanged: (query) {
            provider.searchVersions(query);
          },
        ),
      ),
    );
  }

  Widget _buildFilterBar(GalleryProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: GlassmorphicButton(
              text: 'All Versions',
              onPressed: () => provider.setFilter('all'),
              isActive: provider.currentFilter == 'all',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GlassmorphicButton(
              text: 'Major Updates',
              onPressed: () => provider.setFilter('major'),
              isActive: provider.currentFilter == 'major',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GlassmorphicButton(
              text: 'UI Changes',
              onPressed: () => provider.setFilter('ui'),
              isActive: provider.currentFilter == 'ui',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionCard(AppVersion version) {
    return GestureDetector(
      onTap: () {
        // Navigate to version details
      },
      child: GlassmorphicCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
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
            ),
            const SizedBox(height: 12),
            Text(
              version.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              version.date,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: version.features
                  .take(3)
                  .map((feature) => Chip(
                        label: Text(
                          feature,
                          style: const TextStyle(fontSize: 10),
                        ),
                        backgroundColor: Colors.blue[100],
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompareSelector(GalleryProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select two versions to compare:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildVersionSelector(
                  'Version 1',
                  provider.selectedVersions.isNotEmpty
                      ? provider.selectedVersions[0].name
                      : 'Select...',
                  () => _showVersionSelector(provider, 0),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildVersionSelector(
                  'Version 2',
                  provider.selectedVersions.length > 1
                      ? provider.selectedVersions[1].name
                      : 'Select...',
                  () => _showVersionSelector(provider, 1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVersionSelector(String label, String selectedVersion, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.compare_arrows, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                selectedVersion,
                style: TextStyle(
                  color: selectedVersion != 'Select...' ? Colors.blue[600] : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparePrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.compare,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Select two versions to compare',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose versions from the grid view to see side-by-side comparison',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(GalleryProvider provider) {
    return GalleryStatistics(
      totalVersions: provider.versions.length,
      filteredVersions: provider.filteredVersions.length,
      majorUpdates: provider.versions.where((v) => v.isMajor).length,
      uiChanges: provider.versions.where((v) => v.hasUIChanges).length,
    );
  }

  void _showVersionSelector(GalleryProvider provider, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 400,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Text(
                    'Select Version',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: provider.versions.length,
                itemBuilder: (context, index) {
                  final version = provider.versions[index];
                  return ListTile(
                    title: Text(version.name),
                    subtitle: Text(version.date),
                    trailing: version.isMajor
                        ? Chip(
                            label: const Text('Major'),
                            backgroundColor: Colors.green[100],
                          )
                        : null,
                    onTap: () {
                      provider.selectVersionForComparison(version, index);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppVersion {
  final String name;
  final String date;
  final String description;
  final String screenshotUrl;
  final List<String> features;
  final bool isMajor;
  final bool hasUIChanges;
  final List<String> changelog;

  AppVersion({
    required this.name,
    required this.date,
    required this.description,
    required this.screenshotUrl,
    required this.features,
    this.isMajor = false,
    this.hasUIChanges = false,
    required this.changelog,
  });
}
