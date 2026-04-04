import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/premium_glassmorphic_theme.dart';
import '../providers/distribution_provider.dart';
import '../widgets/enhanced_distribution_center_card.dart';
import '../widgets/enhanced_campaign_card.dart';
import '../widgets/enhanced_analytics_card.dart';
import '../widgets/enhanced_inventory_transfer_card.dart';

class DistributionManagementScreen extends StatefulWidget {
  const DistributionManagementScreen({Key? key}) : super(key: key);

  @override
  State<DistributionManagementScreen> createState() => _DistributionManagementScreenState();
}

class _DistributionManagementScreenState extends State<DistributionManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;

  bool _isSearching = false;
  String _searchQuery = '';
  Map<String, dynamic> _filters = {};
  String _sortBy = 'name';
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    
    _searchController.addListener(_onSearchChanged);
    
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    if (query != _searchQuery) {
      _searchQuery = query;
      Provider.of<DistributionProvider>(context, listen: false).setSearchQuery(query);
    }
  }

  Future<void> _loadData() async {
    final provider = Provider.of<DistributionProvider>(context, listen: false);
    await Future.wait([
      provider.loadDistributionCenters(),
      provider.loadCampaigns(),
      provider.loadAnalytics(),
      provider.loadInventoryTransfers(),
    ]);
  }

  void _applyFilters(Map<String, dynamic> filters) {
    setState(() {
      _filters = Map<String, dynamic>.from(filters);
    });
    
    final provider = Provider.of<DistributionProvider>(context, listen: false);
    provider.applyFilters(filters);
  }

  void _clearFilters() {
    setState(() {
      _filters.clear();
      _searchController.clear();
      _sortBy = 'name';
      _sortAscending = true;
    });
    
    final provider = Provider.of<DistributionProvider>(context, listen: false);
    provider.clearFilters();
  }

  void _toggleSort() {
    setState(() {
      if (_sortBy == 'name') {
        _sortBy = 'capacity';
      } else if (_sortBy == 'capacity') {
        _sortBy = 'location';
      } else if (_sortBy == 'location') {
        _sortBy = 'status';
      } else {
        _sortBy = 'name';
        _sortAscending = !_sortAscending;
      }
    });
    
    final provider = Provider.of<DistributionProvider>(context, listen: false);
    provider.sortData(_sortBy, _sortAscending);
  }

  @override
  Widget build(BuildContext context) {
    return PremiumGlassmorphicTheme.glassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildSearchBar(),
            _buildFilterOptions(),
            Expanded(
              child: Consumer<DistributionProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading && provider.centers.isEmpty) {
                    return const Center(
                      child: PremiumGlassmorphicTheme.glassLoading(),
                    );
                  }
                  
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCentersGrid(provider.centers),
                      _buildCampaignsList(provider.campaigns),
                      _buildAnalyticsView(provider.analytics),
                      _buildInventoryTransfersList(provider.inventoryTransfers),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showAddOptions,
          label: const Text('Add New'),
          icon: const Icon(Icons.add),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PremiumGlassmorphicTheme.glassAppBar(
      title: 'Distribution Management',
      actions: [
        IconButton(
          onPressed: _toggleSearch,
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          color: PremiumGlassmorphicTheme.textPrimary,
        ),
        IconButton(
          onPressed: _showFilterOptions,
          icon: const Icon(Icons.filter_list),
          color: PremiumGlassmorphicTheme.textPrimary,
        ),
        IconButton(
          onPressed: _exportData,
          icon: const Icon(Icons.download),
          color: PremiumGlassmorphicTheme.textPrimary,
        ),
      ],
      bottom: PremiumGlassmorphicTheme.glassTabBar(
        tabs: ['Centers', 'Campaigns', 'Analytics', 'Transfers'],
        selectedIndex: _tabController.index,
        onTap: (index) => _tabController.animateTo(index),
      ),
    );
  }

  Widget _buildSearchBar() {
    if (!_isSearching) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingMd),
      child: PremiumGlassmorphicTheme.getInputDecoration(
        hintText: 'Search centers, campaigns, or transfers...',
        prefixIcon: Icons.search,
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PremiumGlassmorphicTheme.spacingMd,
        vertical: PremiumGlassmorphicTheme.spacingSm,
      ),
      child: Row(
        children: [
          Text(
            'Sort by:',
            style: const TextStyle(
              color: PremiumGlassmorphicTheme.textSecondary,
              fontSize: PremiumGlassmorphicTheme.fontSizeSm,
            ),
          ),
          const SizedBox(width: PremiumGlassmorphicTheme.spacingSm),
          PremiumGlassmorphicTheme.glassChip(
            label: _sortBy == 'name' 
                ? 'Name ${_sortAscending ? '↑' : '↓'}'
                : _sortBy == 'capacity'
                    ? 'Capacity ${_sortAscending ? '↑' : '↓'}'
                    : _sortBy == 'location'
                        ? 'Location ${_sortAscending ? '↑' : '↓'}'
                        : 'Status ${_sortAscending ? '↑' : '↓'}',
            selected: true,
            onTap: _toggleSort,
          ),
          const Spacer(),
          Text(
            '${Provider.of<DistributionProvider>(context).totalItems} items',
            style: const TextStyle(
              color: PremiumGlassmorphicTheme.textTertiary,
              fontSize: PremiumGlassmorphicTheme.fontSizeSm,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCentersGrid(List<DistributionCenter> centers) {
    return RefreshIndicator(
      onRefresh: () => Provider.of<DistributionProvider>(context, listen: false).refresh(),
      child: GridView.builder(
        padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingMd),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: PremiumGlassmorphicTheme.spacingMd,
          mainAxisSpacing: PremiumGlassmorphicTheme.spacingMd,
        ),
        itemCount: centers.length,
        itemBuilder: (context, index) {
          final center = centers[index];
          return EnhancedDistributionCenterCard(
            center: center,
            onTap: () => _navigateToCenterDetails(center),
            onEdit: () => _editCenter(center),
            onDelete: () => _deleteCenter(center),
          );
        },
      ),
    );
  }

  Widget _buildCampaignsList(List<MarketingCampaign> campaigns) {
    return RefreshIndicator(
      onRefresh: () => Provider.of<DistributionProvider>(context, listen: false).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingMd),
        itemCount: campaigns.length,
        itemBuilder: (context, index) {
          final campaign = campaigns[index];
          return EnhancedCampaignCard(
            campaign: campaign,
            onTap: () => _navigateToCampaignDetails(campaign),
            onEdit: () => _editCampaign(campaign),
            onDelete: () => _deleteCampaign(campaign),
            onToggleStatus: () => _toggleCampaignStatus(campaign),
          );
        },
      ),
    );
  }

  Widget _buildAnalyticsView(Map<String, dynamic> analytics) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Analytics Overview
          _buildAnalyticsOverview(analytics),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingXl),
          
          // Sales Analytics
          _buildSalesAnalytics(analytics),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingXl),
          
          // Performance Metrics
          _buildPerformanceMetrics(analytics),
        ],
      ),
    );
  }

  Widget _buildInventoryTransfersList(List<InventoryTransfer> transfers) {
    return RefreshIndicator(
      onRefresh: () => Provider.of<DistributionProvider>(context, listen: false).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingMd),
        itemCount: transfers.length,
        itemBuilder: (context, index) {
          final transfer = transfers[index];
          return EnhancedInventoryTransferCard(
            transfer: transfer,
            onTap: () => _navigateToTransferDetails(transfer),
            onApprove: () => _approveTransfer(transfer),
            onReject: () => _rejectTransfer(transfer),
          );
        },
      ),
    );
  }

  Widget _buildAnalyticsOverview(Map<String, dynamic> analytics) {
    return PremiumGlassmorphicTheme.glassCard(
      padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Analytics Overview',
            style: TextStyle(
              color: PremiumGlassmorphicTheme.textPrimary,
              fontSize: PremiumGlassmorphicTheme.fontSizeXl,
              fontWeight: FontWeight.w700,
            ),
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingLg),
          
          Row(
            children: [
              Expanded(
                child: _buildAnalyticsCard(
                  'Total Sales',
                  'NPR ${(analytics['totalSales'] ?? 0).toString()}',
                  Icons.trending_up,
                  Colors.green,
                ),
              ),
              const SizedBox(width: PremiumGlassmorphicTheme.spacingMd),
              Expanded(
                child: _buildAnalyticsCard(
                  'Active Campaigns',
                  '${analytics['activeCampaigns'] ?? 0}',
                  Icons.campaign,
                  Colors.blue,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingMd),
          
          Row(
            children: [
              Expanded(
                child: _buildAnalyticsCard(
                  'Conversion Rate',
                  '${(analytics['conversionRate'] ?? 0).toStringAsFixed(1)}%',
                  Icons.show_chart,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: PremiumGlassmorphicTheme.spacingMd),
              Expanded(
                child: _buildAnalyticsCard(
                  'ROI',
                  '${(analytics['roi'] ?? 0).toStringAsFixed(1)}%',
                  Icons.trending_up,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSalesAnalytics(Map<String, dynamic> analytics) {
    final salesData = analytics['salesByProduct'] as Map<String, dynamic>? ?? {};
    
    return PremiumGlassmorphicTheme.glassCard(
      padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sales by Product',
            style: TextStyle(
              color: PremiumGlassmorphicTheme.textPrimary,
              fontSize: PremiumGlassmorphicTheme.fontSizeLg,
              fontWeight: FontWeight.w700,
            ),
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingLg),
          
          // Top Products
          ...salesData.entries.take(5).map((entry) {
            final productName = entry.key;
            final salesData = entry.value as Map<String, dynamic>;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: PremiumGlassmorphicTheme.spacingMd),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      productName,
                      style: const TextStyle(
                        color: PremiumGlassmorphicTheme.textPrimary,
                        fontSize: PremiumGlassmorphicTheme.fontSizeMd,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${salesData['quantity'] ?? 0} units',
                      style: const TextStyle(
                        color: PremiumGlassmorphicTheme.textSecondary,
                        fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'NPR ${(salesData['revenue'] ?? 0).toString()}',
                      style: const TextStyle(
                        color: PremiumGlassmorphicTheme.indigo500,
                        fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                        fontWeight: FontWeight.w700,
                      ),
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

  Widget _buildPerformanceMetrics(Map<String, dynamic> analytics) {
    return PremiumGlassmorphicTheme.glassCard(
      padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Metrics',
            style: TextStyle(
              color: PremiumGlassmorphicTheme.textPrimary,
              fontSize: PremiumGlassmorphicTheme.fontSizeLg,
              fontWeight: FontWeight.w700,
            ),
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingLg),
          
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Avg. Order Time',
                  '${(analytics['avgOrderTime'] ?? 0).toString()} days',
                  Icons.access_time,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: PremiumGlassmorphicTheme.spacingMd),
              Expanded(
                child: _buildMetricCard(
                  'Delivery Rate',
                  '${(analytics['deliveryRate'] ?? 0).toStringAsFixed(1)}%',
                  Icons.local_shipping,
                  Colors.green,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingMd),
          
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Customer Satisfaction',
                  '${(analytics['customerSatisfaction'] ?? 0).toStringAsFixed(1)}/5.0',
                  Icons.sentiment_satisfied,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: PremiumGlassmorphicTheme.spacingMd),
              Expanded(
                child: _buildMetricCard(
                  'Inventory Turnover',
                  '${(analytics['inventoryTurnover'] ?? 0).toStringAsFixed(1)}x',
                  Icons.inventory,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, String value, IconData icon, Color color) {
    return PremiumGlassmorphicTheme.glassCard(
      padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: PremiumGlassmorphicTheme.spacingSm),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: PremiumGlassmorphicTheme.textSecondary,
                    fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: PremiumGlassmorphicTheme.spacingXs),
          Text(
            value,
            style: const TextStyle(
              color: PremiumGlassmorphicTheme.textPrimary,
              fontSize: PremiumGlassmorphicTheme.fontSizeLg,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingMd),
      decoration: BoxDecoration(
        color: PremiumGlassmorphicTheme.surfaceLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(PremiumGlassmorphicTheme.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: PremiumGlassmorphicTheme.spacingXs),
          Text(
            title,
            style: const TextStyle(
              color: PremiumGlassmorphicTheme.textSecondary,
              fontSize: PremiumGlassmorphicTheme.fontSizeXs,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: PremiumGlassmorphicTheme.textPrimary,
              fontSize: PremiumGlassmorphicTheme.fontSizeMd,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchFocusNode.unfocus();
      }
    });
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PremiumGlassmorphicTheme.glassModal(
        padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Filter Options',
              style: TextStyle(
                color: PremiumGlassmorphicTheme.textPrimary,
                fontSize: PremiumGlassmorphicTheme.fontSizeLg,
                fontWeight: FontWeight.w700,
              ),
            ),
            
            const SizedBox(height: PremiumGlassmorphicTheme.spacingLg),
            
            // Filter checkboxes
            PremiumGlassmorphicTheme.glassListItem(
              title: 'Active Centers Only',
              leadingIcon: Icons.location_on,
              onTap: () {
                _applyFilters({'activeOnly': true});
                Navigator.pop(context);
              },
            ),
            
            PremiumGlassmorphicTheme.glassListItem(
              title: 'Active Campaigns Only',
              leadingIcon: Icons.campaign,
              onTap: () {
                _applyFilters({'activeCampaignsOnly': true});
                Navigator.pop(context);
              },
            ),
            
            PremiumGlassmorphicTheme.glassListItem(
              title: 'Pending Transfers Only',
              leadingIcon: Icons.pending_actions,
              onTap: () {
                _applyFilters({'pendingTransfersOnly': true});
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PremiumGlassmorphicTheme.glassModal(
        padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add New',
              style: TextStyle(
                color: PremiumGlassmorphicTheme.textPrimary,
                fontSize: PremiumGlassmorphicTheme.fontSizeLg,
                fontWeight: FontWeight.w700,
              ),
            ),
            
            const SizedBox(height: PremiumGlassmorphicTheme.spacingLg),
            
            PremiumGlassmorphicTheme.glassButton(
              onPressed: () {
                Navigator.pop(context);
                context.push('/distribution/add-center');
              },
              child: const Text('Distribution Center'),
            ),
            
            const SizedBox(height: PremiumGlassmorphicTheme.spacingMd),
            
            PremiumGlassmorphicTheme.glassButton(
              onPressed: () {
                Navigator.pop(context);
                context.push('/distribution/add-campaign');
              },
              child: const Text('Marketing Campaign'),
            ),
            
            const SizedBox(height: PremiumGlassmorphicTheme.spacingMd),
            
            PremiumGlassmorphicTheme.glassButton(
              onPressed: () {
                Navigator.pop(context);
                context.push('/distribution/add-transfer');
              },
              child: const Text('Inventory Transfer'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCenterDetails(DistributionCenter center) {
    context.push('/distribution/center/${center.id}');
  }

  void _editCenter(DistributionCenter center) {
    context.push('/distribution/center/${center.id}/edit');
  }

  void _deleteCenter(DistributionCenter center) {
    _showDeleteConfirmation('Distribution Center', center.name, () {
      Provider.of<DistributionProvider>(context, listen: false).deleteCenter(center.id);
    });
  }

  void _navigateToCampaignDetails(MarketingCampaign campaign) {
    context.push('/distribution/campaign/${campaign.id}');
  }

  void _editCampaign(MarketingCampaign campaign) {
    context.push('/distribution/campaign/${campaign.id}/edit');
  }

  void _deleteCampaign(MarketingCampaign campaign) {
    _showDeleteConfirmation('Marketing Campaign', campaign.name, () {
      Provider.of<DistributionProvider>(context, listen: false).deleteCampaign(campaign.id);
    });
  }

  void _toggleCampaignStatus(MarketingCampaign campaign) {
    Provider.of<DistributionProvider>(context, listen: false).toggleCampaignStatus(campaign.id);
  }

  void _navigateToTransferDetails(InventoryTransfer transfer) {
    context.push('/distribution/transfer/${transfer.id}');
  }

  void _approveTransfer(InventoryTransfer transfer) {
    Provider.of<DistributionProvider>(context, listen: false).approveTransfer(transfer.id);
  }

  void _rejectTransfer(InventoryTransfer transfer) {
    Provider.of<DistributionProvider>(context, listen: false).rejectTransfer(transfer.id);
  }

  void _exportData() {
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Exporting data...'),
        backgroundColor: PremiumGlassmorphicTheme.success,
      ),
    );
  }

  void _showDeleteConfirmation(String itemType, String itemName, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete $itemType'),
        content: Text('Are you sure you want to delete "$itemName"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
