import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../app/theme/app_theme.dart';
import '../../shared/widgets/glassmorphic_widgets.dart';
import '../../shared/widgets/enhanced_loading_widget.dart';
import '../../shared/widgets/micro_interactions.dart';

class AppGalleryScreen extends StatefulWidget {
  const AppGalleryScreen({Key? key}) : super(key: key);

  @override
  State<AppGalleryScreen> createState() => _AppGalleryScreenState();
}

class _AppGalleryScreenState extends State<AppGalleryScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  List<Map<String, dynamic>> _versions = [];
  List<Map<String, dynamic>> _filteredVersions = [];
  int _currentVersionIndex = 0;
  bool _isLoading = true;
  bool _isAutoPlaying = false;
  String _searchQuery = '';
  String _selectedFilter = 'all';
  CarouselSliderController? _carouselController;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _loadVersions();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _autoPlayTimer?.cancel();
    _carouselController?.dispose();
    super.dispose();
  }

  Future<void> _loadVersions() async {
    try {
      final String versionsJson = await rootBundle.loadString('assets/data/versions.json');
      final List<dynamic> versionsList = json.decode(versionsJson);
      
      setState(() {
        _versions = versionsList.cast<Map<String, dynamic>>();
        _filteredVersions = List.from(_versions);
        _isLoading = false;
      });
      
      _fadeController.forward();
      _slideController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading versions: $e');
    }
  }

  void _filterVersions() {
    setState(() {
      _filteredVersions = _versions.where((version) {
        final matchesSearch = version['version'].toString().toLowerCase()
            .contains(_searchQuery.toLowerCase()) ||
            version['description'].toString().toLowerCase()
                .contains(_searchQuery.toLowerCase());
        
        if (_selectedFilter == 'all') return matchesSearch;
        if (_selectedFilter == 'featured') return matchesSearch && version['isFeatured'] == true;
        if (_selectedFilter == 'stable') return matchesSearch && version['status'] == 'Stable';
        if (_selectedFilter == 'alpha') return matchesSearch && version['status'] == 'Alpha';
        if (_selectedFilter == 'beta') return matchesSearch && version['status'] == 'Beta';
        
        return matchesSearch;
      }).toList();
    });
  }

  void _toggleAutoPlay() {
    setState(() {
      _isAutoPlaying = !_isAutoPlaying;
    });
    
    if (_isAutoPlaying) {
      _startAutoPlay();
    } else {
      _stopAutoPlay();
    }
  }

  void _startAutoPlay() {
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_filteredVersions.isNotEmpty) {
        setState(() {
          _currentVersionIndex = (_currentVersionIndex + 1) % _filteredVersions.length;
        });
      }
    });
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
  }

  void _onVersionChanged(int index, CarouselPageChangedReason reason) {
    if (reason == CarouselPageChangedReason.manual) {
      setState(() {
        _currentVersionIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: Text(
          'App Gallery',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.surfaceDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isAutoPlaying ? Icons.pause : Icons.play_arrow,
              color: AppTheme.textPrimary,
            ),
            onPressed: _toggleAutoPlay,
          ),
          IconButton(
            icon: Icon(
              Icons.compare_arrows,
              color: AppTheme.textPrimary,
            ),
            onPressed: () => _showComparisonDialog(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: EnhancedLoadingWidget())
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    _buildSearchAndFilterBar(),
                    Expanded(
                      child: _buildGalleryContent(),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: GlassmorphicCard(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search versions...',
                      hintStyle: TextStyle(color: AppTheme.textSecondary),
                      prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(color: AppTheme.textPrimary),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                      _filterVersions();
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GlassmorphicButton(
                text: 'Filter',
                icon: Icons.filter_list,
                onPressed: () => _showFilterDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildFilterChips(),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            isSelected: _selectedFilter == 'all',
            onTap: () {
              setState(() {
                _selectedFilter = 'all';
              });
              _filterVersions();
            },
          ),
          _FilterChip(
            label: 'Featured',
            isSelected: _selectedFilter == 'featured',
            onTap: () {
              setState(() {
                _selectedFilter = 'featured';
              });
              _filterVersions();
            },
          ),
          _FilterChip(
            label: 'Stable',
            isSelected: _selectedFilter == 'stable',
            onTap: () {
              setState(() {
                _selectedFilter = 'stable';
              });
              _filterVersions();
            },
          ),
          _FilterChip(
            label: 'Alpha',
            isSelected: _selectedFilter == 'alpha',
            onTap: () {
              setState(() {
                _selectedFilter = 'alpha';
              });
              _filterVersions();
            },
          ),
          _FilterChip(
            label: 'Beta',
            isSelected: _selectedFilter == 'beta',
            onTap: () {
              setState(() {
                _selectedFilter = 'beta';
              });
              _filterVersions();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryContent() {
    if (_filteredVersions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No versions found',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.primary,
            tabs: const [
              Tab(text: 'Carousel'),
              Tab(text: 'Grid'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildCarouselView(),
                _buildGridView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselView() {
    if (_filteredVersions.isEmpty) return const SizedBox();
    
    return Column(
      children: [
        Expanded(
          child: CarouselSlider.builder(
            itemCount: _filteredVersions.length,
            itemBuilder: (context, index, realIndex) {
              final version = _filteredVersions[index];
              return _buildVersionCard(version, true);
            },
            options: CarouselOptions(
              height: 600,
              viewportFraction: 0.8,
              enlargeCenterPage: true,
              autoPlay: _isAutoPlay,
              autoPlayInterval: const Duration(seconds: 4),
              onPageChanged: _onVersionChanged,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildCarouselIndicators(),
      ],
    );
  }

  Widget _buildCarouselIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _filteredVersions.length,
        (index) => GestureDetector(
          onTap: () {
            setState(() {
              _currentVersionIndex = index;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentVersionIndex == index ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: _currentVersionIndex == index
                  ? AppTheme.primary
                  : AppTheme.textSecondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _filteredVersions.length,
      itemBuilder: (context, index) {
        final version = _filteredVersions[index];
        return _buildVersionCard(version, false);
      },
    );
  }

  Widget _buildVersionCard(Map<String, dynamic> version, bool isCarousel) {
    final screenshots = version['screenshots'] as List<dynamic>? ?? [];
    final features = version['features'] as List<dynamic>? ?? [];
    final isFeatured = version['isFeatured'] as bool? ?? false;
    
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                if (screenshots.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      screenshots[0],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppTheme.surfaceDark,
                          child: Icon(
                            Icons.image_not_supported,
                            color: AppTheme.textSecondary,
                            size: 48,
                          ),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    color: AppTheme.surfaceDark,
                    child: Icon(
                      Icons.phone_android,
                      color: AppTheme.textSecondary,
                      size: 48,
                    ),
                  ),
                if (isFeatured)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'FEATURED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  version['version'] ?? 'Unknown Version',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: isCarousel ? 18 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  version['releaseDate'] ?? '',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    version['description'] ?? '',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: isCarousel ? 14 : 12,
                    ),
                    maxLines: isCarousel ? 3 : 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 8),
                MicroInteractionButton(
                  text: 'View Details',
                  icon: Icons.info_outline,
                  onPressed: () => _showVersionDetails(context, version),
                  animationType: AnimationType.scale,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showVersionDetails(BuildContext context, Map<String, dynamic> version) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          version['version'] ?? 'Unknown Version',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(version['status']),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          version['status'] ?? 'Unknown',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    version['description'] ?? '',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildScreenshotGallery(version),
                  const SizedBox(height: 20),
                  _buildFeaturesList(version),
                  const SizedBox(height: 20),
                  _buildChangelogList(version),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScreenshotGallery(Map<String, dynamic> version) {
    final screenshots = version['screenshots'] as List<dynamic>? ?? [];
    
    if (screenshots.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported,
                color: AppTheme.textSecondary,
                size: 48,
              ),
              const SizedBox(height: 8),
              Text(
                'No screenshots available',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Screenshots',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: screenshots.length,
            itemBuilder: (context, index) {
              return Container(
                width: 300,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderDark),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    screenshots[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppTheme.surfaceDark,
                        child: Icon(
                          Icons.broken_image,
                          color: AppTheme.textSecondary,
                          size: 48,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesList(Map<String, dynamic> version) {
    final features = version['features'] as List<dynamic>? ?? [];
    
    if (features.isEmpty) return const SizedBox();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Features',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...features.map((feature) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: AppTheme.success,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  feature.toString(),
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildChangelogList(Map<String, dynamic> version) {
    final changelog = version['changelog'] as List<dynamic>? ?? [];
    
    if (changelog.isEmpty) return const SizedBox();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Changelog',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...changelog.map((change) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(
                Icons.arrow_right,
                color: AppTheme.primary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  change.toString(),
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Stable':
        return AppTheme.success;
      case 'Alpha':
        return AppTheme.warning;
      case 'Beta':
        return AppTheme.info;
      default:
        return AppTheme.textSecondary;
    }
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: Text(
          'Filter Versions',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _FilterOption(
              title: 'All Versions',
              value: 'all',
              selected: _selectedFilter,
              onTap: () {
                setState(() {
                  _selectedFilter = 'all';
                });
                _filterVersions();
                Navigator.pop(context);
              },
            ),
            _FilterOption(
              title: 'Featured Only',
              value: 'featured',
              selected: _selectedFilter,
              onTap: () {
                setState(() {
                  _selectedFilter = 'featured';
                });
                _filterVersions();
                Navigator.pop(context);
              },
            ),
            _FilterOption(
              title: 'Stable Releases',
              value: 'stable',
              selected: _selectedFilter,
              onTap: () {
                setState(() {
                  _selectedFilter = 'stable';
                });
                _filterVersions();
                Navigator.pop(context);
              },
            ),
            _FilterOption(
              title: 'Alpha Versions',
              value: 'alpha',
              selected: _selectedFilter,
              onTap: () {
                setState(() {
                  _selectedFilter = 'alpha';
                });
                _filterVersions();
                Navigator.pop(context);
              },
            ),
            _FilterOption(
              title: 'Beta Versions',
              value: 'beta',
              selected: _selectedFilter,
              onTap: () {
                setState(() {
                  _selectedFilter = 'beta';
                });
                _filterVersions();
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  void _showComparisonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: Text(
          'Compare Versions',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select two versions to compare their features and screenshots.',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _VersionSelector(
                      title: 'Version 1',
                      versions: _filteredVersions,
                      onSelected: (version) {
                        // TODO: Implement comparison logic
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _VersionSelector(
                      title: 'Version 2',
                      versions: _filteredVersions,
                      onSelected: (version) {
                        // TODO: Implement comparison logic
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement comparison
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Compare'),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.borderDark,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _FilterOption extends StatelessWidget {
  final String title;
  final String value;
  final String selected;
  final VoidCallback onTap;

  const _FilterOption({
    required this.title,
    required this.value,
    required this.selected,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.borderDark,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VersionSelector extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> versions;
  final Function(Map<String, dynamic>) onSelected;

  const _VersionSelector({
    required this.title,
    required this.versions,
    required this.onSelected,
    Key? key,
  }) : super(key: key);

  @override
  State<_VersionSelector> createState() => _VersionSelectorState();
}

class _VersionSelectorState extends State<_VersionSelector> {
  Map<String, dynamic>? _selectedVersion;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.borderDark),
          ),
          child: DropdownButton<Map<String, dynamic>>(
            value: _selectedVersion,
            isExpanded: true,
            dropdownColor: AppTheme.surfaceDark,
            style: TextStyle(color: AppTheme.textPrimary),
            items: widget.versions.map((version) {
              return DropdownMenuItem<Map<String, dynamic>>(
                value: version,
                child: Text(
                  version['version'] ?? 'Unknown',
                  style: TextStyle(color: AppTheme.textPrimary),
                ),
              );
            }).toList(),
            onChanged: (version) {
              setState(() {
                _selectedVersion = version;
              });
              if (version != null) {
                widget.onSelected(version!);
              }
            },
          ),
        ),
      ],
    );
  }
}
