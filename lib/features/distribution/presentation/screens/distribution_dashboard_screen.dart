import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../widgets/dashboard_stats_card.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/recent_activity_widget.dart';
import '../providers/distribution_provider.dart';
import 'distribution_centers_screen.dart';
import 'inventory_management_screen.dart';
import 'marketing_campaigns_screen.dart';
import 'sales_analytics_screen.dart';

class DistributionDashboardScreen extends StatefulWidget {
  const DistributionDashboardScreen({Key? key}) : super(key: key);

  @override
  _DistributionDashboardScreenState createState() => _DistributionDashboardScreenState();
}

class _DistributionDashboardScreenState extends State<DistributionDashboardScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();

    // Initialize data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DistributionProvider>().loadDashboardData();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: _buildAppBar(theme, isSmallScreen),
      body: isSmallScreen ? _buildMobileLayout(theme) : _buildDesktopLayout(theme),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, bool isSmallScreen) {
    if (isSmallScreen) {
      return AppBar(
        title: Text(
          'Distribution Management',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () => _showNotifications(context),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () => _showSearch(context),
          ),
        ],
      );
    }

    return AppBar(
      title: Row(
        children: [
          Icon(
            Icons.warehouse_outlined,
            color: theme.colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            'Distribution Management',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      foregroundColor: theme.colorScheme.onSurface,
      elevation: 0,
      centerTitle: false,
      actions: [
        _buildSearchField(theme),
        const SizedBox(width: 16),
        _buildNotificationButton(theme),
        const SizedBox(width: 16),
        _buildProfileButton(theme),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildSearchField(ThemeData theme) {
    return SizedBox(
      width: 300,
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search centers, inventory, campaigns...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: theme.colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onSubmitted: (value) => _performSearch(value),
      ),
    );
  }

  Widget _buildNotificationButton(ThemeData theme) {
    return Stack(
      children: [
        IconButton(
          icon: Icon(
            Icons.notifications_outlined,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => _showNotifications(context),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileButton(ThemeData theme) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: theme.colorScheme.primary,
      child: Icon(
        Icons.person,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildMobileLayout(ThemeData theme) {
    return Column(
      children: [
        // Stats Cards
        Container(
          height: 180,
          padding: const EdgeInsets.all(16),
          child: Consumer<DistributionProvider>(
            builder: (context, provider, child) {
              return ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  DashboardStatsCard(
                    title: 'Total Centers',
                    value: provider.totalCenters.toString(),
                    icon: Icons.warehouse_outlined,
                    color: AppTheme.primaryColor,
                    trend: '+12%',
                    isPositive: true,
                  ),
                  const SizedBox(width: 12),
                  DashboardStatsCard(
                    title: 'Active Inventory',
                    value: provider.activeInventory.toString(),
                    icon: Icons.inventory_outlined,
                    color: AppTheme.successColor,
                    trend: '+8%',
                    isPositive: true,
                  ),
                  const SizedBox(width: 12),
                  DashboardStatsCard(
                    title: 'Active Campaigns',
                    value: provider.activeCampaigns.toString(),
                    icon: Icons.campaign_outlined,
                    color: AppTheme.secondaryColor,
                    trend: '-2%',
                    isPositive: false,
                  ),
                ],
              );
            },
          ),
        ),
        
        // Quick Actions
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Actions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  QuickActionButton(
                    title: 'Add Center',
                    icon: Icons.add_location_outlined,
                    color: AppTheme.primaryColor,
                    onTap: () => _navigateToAddCenter(),
                  ),
                  QuickActionButton(
                    title: 'Allocate Inventory',
                    icon: Icons.inventory_2_outlined,
                    color: AppTheme.successColor,
                    onTap: () => _navigateToInventoryAllocation(),
                  ),
                  QuickActionButton(
                    title: 'New Campaign',
                    icon: Icons.campaign_outlined,
                    color: AppTheme.secondaryColor,
                    onTap: () => _navigateToNewCampaign(),
                  ),
                  QuickActionButton(
                    title: 'View Reports',
                    icon: Icons.analytics_outlined,
                    color: AppTheme.infoColor,
                    onTap: () => _navigateToReports(),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Recent Activity
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: RecentActivityWidget(),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(ThemeData theme) {
    return Row(
      children: [
        // Enhanced Navigation Rail
        Container(
          width: 280,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor,
                blurRadius: 4,
                offset: const Offset(2, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              // User Profile Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin User',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Distribution Manager',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Navigation Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  children: [
                    _buildNavigationItem(
                      icon: Icons.dashboard_outlined,
                      selectedIcon: Icons.dashboard,
                      label: 'Dashboard',
                      index: 0,
                      theme: theme,
                    ),
                    _buildNavigationItem(
                      icon: Icons.warehouse_outlined,
                      selectedIcon: Icons.warehouse,
                      label: 'Distribution Centers',
                      index: 1,
                      theme: theme,
                    ),
                    _buildNavigationItem(
                      icon: Icons.inventory_outlined,
                      selectedIcon: Icons.inventory,
                      label: 'Inventory Management',
                      index: 2,
                      theme: theme,
                    ),
                    _buildNavigationItem(
                      icon: Icons.route_outlined,
                      selectedIcon: Icons.route,
                      label: 'Route Planning',
                      index: 3,
                      theme: theme,
                    ),
                    _buildNavigationItem(
                      icon: Icons.campaign_outlined,
                      selectedIcon: Icons.campaign,
                      label: 'Marketing Campaigns',
                      index: 4,
                      theme: theme,
                    ),
                    _buildNavigationItem(
                      icon: Icons.analytics_outlined,
                      selectedIcon: Icons.analytics,
                      label: 'Analytics & Reports',
                      index: 5,
                      theme: theme,
                    ),
                  ],
                ),
              ),
              
              // Bottom Actions
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.settings_outlined,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      title: Text(
                        'Settings',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      onTap: () => _navigateToSettings(),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.logout,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      title: Text(
                        'Logout',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      onTap: () => _logout(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Main Content Area
        Expanded(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildSelectedScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
    required ThemeData theme,
  }) {
    final isSelected = _selectedIndex == index;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: isSelected ? theme.colorScheme.primary.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _onNavigationItemTapped(index),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(
                  isSelected ? selectedIcon : icon,
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.7),
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.7),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => _showQuickActions(context),
      icon: const Icon(Icons.add),
      label: const Text('Quick Action'),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
    );
  }

  void _onNavigationItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _animationController.reset();
    _animationController.forward();
  }

  Widget _buildSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return const DistributionCentersScreen();
      case 2:
        return const InventoryManagementScreen();
      case 3:
        return const RouteManagementScreen();
      case 4:
        return const MarketingCampaignsScreen();
      case 5:
        return const DistributionAnalyticsScreen();
      default:
        return const Center(
          child: Text('Screen not found'),
        );
    }
  }

  Widget _buildDashboardContent() {
    return Consumer<DistributionProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const PageLoadingWidget(
            message: 'Loading dashboard data...',
            type: LoadingType.dots,
          );
        }

        if (provider.hasError) {
          return _buildErrorWidget(provider.errorMessage);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Overview
              Row(
                children: [
                  Expanded(
                    child: DashboardStatsCard(
                      title: 'Total Centers',
                      value: provider.totalCenters.toString(),
                      icon: Icons.warehouse_outlined,
                      color: AppTheme.primaryColor,
                      trend: '+12%',
                      isPositive: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DashboardStatsCard(
                      title: 'Active Inventory',
                      value: provider.activeInventory.toString(),
                      icon: Icons.inventory_outlined,
                      color: AppTheme.successColor,
                      trend: '+8%',
                      isPositive: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DashboardStatsCard(
                      title: 'Active Campaigns',
                      value: provider.activeCampaigns.toString(),
                      icon: Icons.campaign_outlined,
                      color: AppTheme.secondaryColor,
                      trend: '-2%',
                      isPositive: false,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DashboardStatsCard(
                      title: 'Total Revenue',
                      value: '\$${provider.totalRevenue.toString()}',
                      icon: Icons.trending_up_outlined,
                      color: AppTheme.infoColor,
                      trend: '+15%',
                      isPositive: true,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Quick Actions and Recent Activity
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildQuickActionsSection(),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: RecentActivityWidget(),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActionsSection() {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                QuickActionButton(
                  title: 'Add Center',
                  icon: Icons.add_location_outlined,
                  color: AppTheme.primaryColor,
                  onTap: () => _navigateToAddCenter(),
                ),
                QuickActionButton(
                  title: 'Allocate Inventory',
                  icon: Icons.inventory_2_outlined,
                  color: AppTheme.successColor,
                  onTap: () => _navigateToInventoryAllocation(),
                ),
                QuickActionButton(
                  title: 'New Campaign',
                  icon: Icons.campaign_outlined,
                  color: AppTheme.secondaryColor,
                  onTap: () => _navigateToNewCampaign(),
                ),
                QuickActionButton(
                  title: 'View Reports',
                  icon: Icons.analytics_outlined,
                  color: AppTheme.infoColor,
                  onTap: () => _navigateToReports(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
              error ?? 'Failed to load dashboard data',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Retry',
              onPressed: () => context.read<DistributionProvider>().loadDashboardData(),
              type: CustomButtonType.primary,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAddCenter() {
    // Navigate to add center screen
  }

  void _navigateToInventoryAllocation() {
    setState(() {
      _selectedIndex = 2;
    });
  }

  void _navigateToNewCampaign() {
    setState(() {
      _selectedIndex = 4;
    });
  }

  void _navigateToReports() {
    setState(() {
      _selectedIndex = 5;
    });
  }

  void _navigateToSettings() {
    // Navigate to settings
  }

  void _logout() {
    // Handle logout
  }

  void _showNotifications(BuildContext context) {
    // Show notifications
  }

  void _showSearch(BuildContext context) {
    // Show search
  }

  void _performSearch(String query) {
    // Perform search
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildQuickActionsBottomSheet(context),
    );
  }

  Widget _buildQuickActionsBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          QuickActionButton(
            title: 'Add Center',
            icon: Icons.add_location_outlined,
            color: AppTheme.primaryColor,
            onTap: () {
              Navigator.pop(context);
              _navigateToAddCenter();
            },
          ),
          const SizedBox(height: 12),
          QuickActionButton(
            title: 'Allocate Inventory',
            icon: Icons.inventory_2_outlined,
            color: AppTheme.successColor,
            onTap: () {
              Navigator.pop(context);
              _navigateToInventoryAllocation();
            },
          ),
          const SizedBox(height: 12),
          QuickActionButton(
            title: 'New Campaign',
            icon: Icons.campaign_outlined,
            color: AppTheme.secondaryColor,
            onTap: () {
              Navigator.pop(context);
              _navigateToNewCampaign();
            },
          ),
          const SizedBox(height: 12),
          QuickActionButton(
            title: 'View Reports',
            icon: Icons.analytics_outlined,
            color: AppTheme.infoColor,
            onTap: () {
              Navigator.pop(context);
              _navigateToReports();
            },
          ),
        ],
      ),
    );
  }
}

// Placeholder screens for navigation
class DistributionCentersScreen extends StatelessWidget {
  const DistributionCentersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Distribution Centers Screen'),
    );
  }
}

class InventoryManagementScreen extends StatelessWidget {
  const InventoryManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Inventory Management Screen'),
    );
  }
}

class RouteManagementScreen extends StatelessWidget {
  const RouteManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Route Management Screen'),
    );
  }
}

class CampaignManagementScreen extends StatelessWidget {
  const CampaignManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Campaign Management Screen'),
    );
  }
}

class DistributionAnalyticsScreen extends StatelessWidget {
  const DistributionAnalyticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Distribution Analytics Screen'),
    );
  }
}
