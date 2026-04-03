import 'package:flutter/material.dart';
import 'app_gallery_screen.dart';
import 'gallery_navigation_screen.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({Key? key}) : super(key: key);

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('VedantaTrade Gallery'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showGalleryInfo(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelColor: Theme.of(context).colorScheme.onSurface,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          tabs: const [
            Tab(
              icon: Icon(Icons.slideshow),
              text: 'App Gallery',
            ),
            Tab(
              icon: Icon(Icons.dashboard),
              text: 'Navigation',
            ),
          ],
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: TabBarView(
          controller: _tabController,
          children: const [
            AppGalleryScreen(),
            GalleryNavigationScreen(),
          ],
        ),
      ),
    );
  }

  void _showGalleryInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About VedantaTrade Gallery'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to the VedantaTrade Gallery!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'This gallery showcases the evolution of VedantaTrade app through different versions, featuring:',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFeatureItem('• Interactive carousel with auto-play'),
                _buildFeatureItem('• Grid view for all versions'),
                _buildFeatureItem('• Side-by-side version comparison'),
                _buildFeatureItem('• Detailed version information'),
                _buildFeatureItem('• Interactive screenshots'),
                _buildFeatureItem('• Version history tracking'),
                _buildFeatureItem('• Search and filtering capabilities'),
                _buildFeatureItem('• Statistics and analytics'),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Explore how VedantaTrade has evolved from initial release to the current enterprise-grade platform.',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
