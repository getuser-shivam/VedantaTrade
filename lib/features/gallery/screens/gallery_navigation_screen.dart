import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_gallery_screen.dart';
import 'gallery_stats_provider.dart';

class GalleryNavigationScreen extends StatefulWidget {
  const GalleryNavigationScreen({Key? key}) : super(key: key);

  @override
  State<GalleryNavigationScreen> createState() => _GalleryNavigationScreenState();
}

class _GalleryNavigationScreenState extends State<GalleryNavigationScreen> {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GalleryStatsProvider(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text('Gallery Navigation'),
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          actions: [
            Consumer<GalleryStatsProvider>(
              builder: (context, provider, child) {
                return IconButton(
                  icon: const Icon(Icons.analytics),
                  onPressed: () => _showStatsDialog(context, provider.stats),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            _buildQuickStats(context),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: 3,
                itemBuilder: (context, index) {
                  switch (index) {
                    case 0:
                      return _buildGalleryOverview(context);
                    case 1:
                      return _buildVersionHistory(context);
                    case 2:
                      return _buildInteractiveFeatures(context);
                    default:
                      return Container();
                  }
                },
              ),
            ),
            _buildBottomNavigation(context),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Consumer<GalleryStatsProvider>(
      builder: (context, provider, child) {
        final stats = provider.stats;
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
                'Gallery Statistics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Views',
                      stats.totalViews.toString(),
                      Icons.visibility,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Unique Users',
                      stats.uniqueUsers.toString(),
                      Icons.people,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Avg Session',
                      '${stats.avgSessionDuration}s',
                      Icons.timer,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Most Viewed',
                      stats.mostViewedVersion,
                      Icons.star,
                      Colors.purple,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
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
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryOverview(BuildContext context) {
    return Consumer<GalleryStatsProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gallery Overview',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Explore the evolution of VedantaTrade through different versions and features.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildFeatureCard(
                      'Interactive Carousel',
                      'Browse versions with auto-play',
                      Icons.slideshow,
                      Colors.blue,
                      () => _navigateToGallery(context, 0),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFeatureCard(
                      'Grid View',
                      'All versions at a glance',
                      Icons.grid_view,
                      Colors.green,
                      () => _navigateToGallery(context, 1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildFeatureCard(
                      'Compare Versions',
                      'Side-by-side comparison',
                      Icons.compare,
                      Colors.orange,
                      () => _navigateToGallery(context, 2),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFeatureCard(
                      'Version Details',
                      'In-depth information',
                      Icons.info,
                      Colors.purple,
                      () => _showVersionDetails(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVersionHistory(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Version History',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Track the evolution of VedantaTrade through different versions.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: 10, // Sample data
              itemBuilder: (context, index) {
                return _buildVersionHistoryItem(context, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionHistoryItem(BuildContext context, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            'v${index + 1}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text('Version ${index + 1}.0'),
        subtitle: Text('Released on 2026-04-${(index + 1).toString().padLeft(2, '0')}'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => _showVersionDetails(context),
      ),
    );
  }

  Widget _buildInteractiveFeatures(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Interactive Features',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Discover advanced features and tools for exploring the app gallery.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildInteractiveFeatureCard(
                'Search & Filter',
                'Find versions quickly',
                Icons.search,
                Colors.blue,
                () => _showSearchDialog(context),
              ),
              _buildInteractiveFeatureCard(
                'Statistics',
                'Detailed analytics',
                Icons.analytics,
                Colors.green,
                () => _showDetailedStats(context),
              ),
              _buildInteractiveFeatureCard(
                'Export Data',
                'Download gallery info',
                Icons.download,
                Colors.orange,
                () => _exportGalleryData(context),
              ),
              _buildInteractiveFeatureCard(
                'Share Gallery',
                'Share with others',
                Icons.share,
                Colors.purple,
                () => _shareGallery(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveFeatureCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavButton(
            'Overview',
            Icons.dashboard,
            0,
            () => _pageController.animateToPage(0),
          ),
          _buildNavButton(
            'History',
            Icons.history,
            1,
            () => _pageController.animateToPage(1),
          ),
          _buildNavButton(
            'Features',
            Icons.widgets,
            2,
            () => _pageController.animateToPage(2),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(String label, IconData icon, int index, VoidCallback onTap) {
    return Consumer<GalleryStatsProvider>(
      builder: (context, provider, child) {
        final isSelected = _pageController.hasClients && _pageController.page?.round() == index;
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToGallery(BuildContext context, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AppGalleryScreen(),
      ),
    );
  }

  void _showVersionDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Version Details'),
        content: const Text('Detailed version information will be shown here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showStatsDialog(BuildContext context, GalleryStats stats) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gallery Statistics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Views: ${stats.totalViews}'),
            Text('Unique Users: ${stats.uniqueUsers}'),
            Text('Avg Session: ${stats.avgSessionDuration}s'),
            Text('Most Viewed: ${stats.mostViewedVersion}'),
            Text('Last Updated: ${stats.lastUpdated.toString().split(' ')[0]}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Versions'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Search versions...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showDetailedStats(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detailed Statistics'),
        content: const Text('Detailed analytics and metrics will be shown here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _exportGalleryData(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gallery data exported successfully')),
    );
  }

  void _shareGallery(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gallery shared successfully')),
    );
  }
}
