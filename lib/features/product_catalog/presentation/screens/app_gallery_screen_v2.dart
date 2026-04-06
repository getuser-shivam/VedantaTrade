import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/widgets/glassmorphic_background.dart';
import '../../../../shared/widgets/glassmorphic_widgets.dart';
import '../../../../app/theme/app_theme.dart';
import '../providers/gallery_provider.dart';
import '../widgets/glassmorphic_gallery_widgets.dart';

class AppGalleryScreenV2 extends StatefulWidget {
  const AppGalleryScreenV2({Key? key}) : super(key: key);

  @override
  _AppGalleryScreenV2State createState() => _AppGalleryScreenV2State();
}

class _AppGalleryScreenV2State extends State<AppGalleryScreenV2>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _activeTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() => _activeTab = _tabController.index);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GalleryProvider>(context, listen: false).loadGalleryData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: GlassmorphicBackground(
        child: Column(
          children: [
            _buildCustomAppBar(context),
            _buildPremiumTabs(context),
            Expanded(
              child: Consumer<GalleryProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: LoadingAnimation());
                  }

                  if (provider.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const ErrorAnimation(size: 80),
                          const SizedBox(height: 16),
                          Text(
                            provider.errorMessage ?? 'Failed to load gallery',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 24),
                          GlassmorphicButton(
                            text: 'Retry',
                            onPressed: () => provider.loadGalleryData(),
                            width: 120,
                          ),
                        ],
                      ),
                    );
                  }

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildFeaturedTab(context, provider),
                      _buildGridTab(context, provider),
                      _buildCompareTab(context, provider),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'App Gallery',
                style: AppTheme.darkTheme.appBarTheme.titleTextStyle,
              ),
              const Text(
                'Showcasing UI Transformation',
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          GlassmorphicCard(
            padding: const EdgeInsets.all(8),
            borderRadius: BorderRadius.circular(12),
            child: const Icon(Icons.auto_fix_high_rounded, color: AppTheme.secondary, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumTabs(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.glassBorderLight, width: 1),
      ),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white38,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        tabs: const [
          Tab(text: 'Featured'),
          Tab(text: 'All Versions'),
          Tab(text: 'History'),
        ],
      ),
    );
  }

  Widget _buildFeaturedTab(BuildContext context, GalleryProvider provider) {
    return Column(
      children: [
        const SizedBox(height: 20),
        SizedBox(
          height: 380,
          child: GlassmorphicGalleryCarousel(
            versions: provider.featuredVersions,
            onVersionSelected: (v) => _showVersionDialog(context, v),
          ),
        ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              const Icon(Icons.stars_rounded, color: AppTheme.warning, size: 20),
              const SizedBox(width: 8),
              Text(
                'Latest Milestone',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        if (provider.versions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: GlassmorphicCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.rocket_launch_rounded, color: AppTheme.success, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Version ${provider.versions.first.version}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          provider.versions.first.description,
                          style: const TextStyle(color: Colors.white38, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  GlassmorphicButton(
                    text: 'Explore',
                    onPressed: () => _showVersionDialog(context, provider.versions.first),
                    width: 80,
                    height: 32,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGridTab(BuildContext context, GalleryProvider provider) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: provider.versions.length,
      itemBuilder: (context, i) => GlassmorphicVersionCard(
        version: provider.versions[i],
        onTap: () => _showVersionDialog(context, provider.versions[i]),
      ),
    );
  }

  Widget _buildCompareTab(BuildContext context, GalleryProvider provider) {
    if (provider.versions.length < 2) {
      return const Center(child: Text('Not enough version history', style: TextStyle(color: Colors.white38)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: provider.versions.length - 1,
      itemBuilder: (context, i) {
        final current = provider.versions[i];
        final previous = provider.versions[i + 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Evolution: v${previous.version} → v${current.version}',
                style: const TextStyle(color: AppTheme.secondary, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 240,
                child: GlassmorphicCard(
                  padding: EdgeInsets.zero,
                  child: GlassmorphicComparisonTool(v1: previous, v2: current),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showVersionDialog(BuildContext context, AppVersion version) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassmorphicCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.info_outline_rounded, color: AppTheme.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Version ${version.version}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Text(
                          version.releaseDate,
                          style: const TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white24),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Key Enhancements',
                style: TextStyle(color: AppTheme.secondary, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 12),
              ...version.changelog.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.arrow_right_rounded, color: AppTheme.primary, size: 20),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GlassmorphicButton(
                      text: 'Close',
                      onPressed: () => Navigator.pop(context),
                      backgroundColor: Colors.white.withOpacity(0.05),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
