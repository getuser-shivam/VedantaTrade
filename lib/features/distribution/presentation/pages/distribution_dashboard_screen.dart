import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/distribution_management_provider.dart';
import '../widgets/distribution_card.dart';
import '../widgets/inventory_card.dart';
import '../widgets/order_card.dart';
import '../widgets/campaign_card.dart';
import '../widgets/analytics_widget.dart';

class DistributionDashboardScreen extends StatefulWidget {
  const DistributionDashboardScreen({Key? key}) : super(key: key);

  @override
  State<DistributionDashboardScreen> createState() => _DistributionDashboardScreenState();
}

class _DistributionDashboardScreenState extends State<DistributionDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DistributionManagementProvider _provider;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _provider = DistributionManagementProvider(
      repository: DistributionRepositoryImpl(),
    );
    _provider.initialize();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _provider,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Distribution & Marketing'),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _refreshAll(),
              tooltip: 'Refresh All Data',
            ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showFilters(context),
              tooltip: 'Filter Options',
            ),
            IconButton(
              icon: const Icon(Icons.analytics),
              onPressed: () => _showAnalytics(context),
              tooltip: 'Analytics Dashboard',
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                icon: Icon(Icons.local_shipping),
                text: 'Distributions',
              ),
              Tab(
                icon: Icon(Icons.inventory),
                text: 'Inventory',
              ),
              Tab(
                icon: Icon(Icons.shopping_cart),
                text: 'Orders',
              ),
              Tab(
                icon: Icon(Icons.campaign),
                text: 'Campaigns',
              ),
              Tab(
                icon: Icon(Icons.analytics),
                text: 'Analytics',
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildDistributionsTab(),
            _buildInventoryTab(),
            _buildOrdersTab(),
            _buildCampaignsTab(),
            _buildAnalyticsTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showQuickActions(context),
          child: const Icon(Icons.add),
          tooltip: 'Quick Actions',
        ),
      ),
    );
  }

  Widget _buildDistributionsTab() {
    return Consumer<DistributionManagementProvider>(
      builder: (context, provider) => Column(
        children: [
          // Summary Cards
          _buildDistributionSummary(provider),
          const SizedBox(height: 16),
          // Search and Filter
          _buildSearchAndFilter(provider),
          const SizedBox(height: 16),
          // Distributions List
          Expanded(
            child: _buildDistributionsList(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryTab() {
    return Consumer<DistributionManagementProvider>(
      builder: (context, provider) => Column(
        children: [
          // Summary Cards
          _buildInventorySummary(provider),
          const SizedBox(height: 16),
          // Search and Filter
          _buildInventorySearchAndFilter(provider),
          const SizedBox(height: 16),
          // Inventory List
          Expanded(
            child: _buildInventoryList(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTab() {
    return Consumer<DistributionManagementProvider>(
      builder: (context, provider) => Column(
        children: [
          // Summary Cards
          _buildOrdersSummary(provider),
          const SizedBox(height: 16),
          // Search and Filter
          _buildOrdersSearchAndFilter(provider),
          const SizedBox(height: 16),
          // Orders List
          Expanded(
            child: _buildOrdersList(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignsTab() {
    return Consumer<DistributionManagementProvider>(
      builder: (context, provider) => Column(
        children: [
          // Summary Cards
          _buildCampaignsSummary(provider),
          const SizedBox(height: 16),
          // Search and Filter
          _buildCampaignsSearchAndFilter(provider),
          const SizedBox(height: 16),
          // Campaigns List
          Expanded(
            child: _buildCampaignsList(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return Consumer<DistributionManagementProvider>(
      builder: (context, provider) => AnalyticsWidget(
        analytics: provider.analytics,
        isLoading: provider.isLoadingAnalytics,
        error: provider.analyticsError,
        onRefresh: () => provider.loadAnalytics(),
      ),
    );
  }

  Widget _buildDistributionSummary(DistributionManagementProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Total Distributions',
              '${provider.distributions.length}',
              Icons.local_shipping,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'In Transit',
              '${provider.distributions.where((d) => d.isInTransit).length}',
              Icons.local_shipping_outlined,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Delivered',
              '${provider.distributions.where((d) => d.isDelivered).length}',
              Icons.check_circle,
              Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventorySummary(DistributionManagementProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Total Items',
              '${provider.inventory.length}',
              Icons.inventory,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Low Stock',
              '${provider.inventory.where((i) => i.isLowStock).length}',
              Icons.warning,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Out of Stock',
              '${provider.inventory.where((i) => i.isOutOfStock).length}',
              Icons.error,
              Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersSummary(DistributionManagementProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Total Orders',
              '${provider.orders.length}',
              Icons.shopping_cart,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Processing',
              '${provider.orders.where((o) => o.isProcessing).length}',
              Icons.pending,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Completed',
              '${provider.orders.where((o) => o.isCompleted).length}',
              Icons.check_circle,
              Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignsSummary(DistributionManagementProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Total Campaigns',
              '${provider.campaigns.length}',
              Icons.campaign,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Active',
              '${provider.campaigns.where((c) => c.isActive).length}',
              Icons.play_circle,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Completed',
              '${provider.campaigns.where((c) => c.isCompleted).length}',
              Icons.check_circle,
              Colors.purple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter(DistributionManagementProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) => provider.updateSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Search distributions...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: provider.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => provider.updateSearchQuery(''),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          DropdownButton<String>(
            hint: const Text('Status'),
            value: provider.selectedStatus,
            items: const [
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
              DropdownMenuItem(value: 'inTransit', child: Text('In Transit')),
              DropdownMenuItem(value: 'delivered', child: Text('Delivered')),
              DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
            ],
            onChanged: (value) => provider.updateStatusFilter(value),
          ),
        ],
      ),
    );
  }

  Widget _buildInventorySearchAndFilter(DistributionManagementProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) => provider.updateSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Search inventory...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: provider.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => provider.updateSearchQuery(''),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          DropdownButton<String>(
            hint: const Text('Status'),
            value: provider.selectedStatus,
            items: const [
              DropdownMenuItem(value: 'inStock', child: Text('In Stock')),
              DropdownMenuItem(value: 'lowStock', child: Text('Low Stock')),
              DropdownMenuItem(value: 'outOfStock', child: Text('Out of Stock')),
              DropdownMenuItem(value: 'reserved', child: Text('Reserved')),
            ],
            onChanged: (value) => provider.updateStatusFilter(value),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersSearchAndFilter(DistributionManagementProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) => provider.updateSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Search orders...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: provider.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => provider.updateSearchQuery(''),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          DropdownButton<String>(
            hint: const Text('Status'),
            value: provider.selectedStatus,
            items: const [
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
              DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
              DropdownMenuItem(value: 'processing', child: Text('Processing')),
              DropdownMenuItem(value: 'shipped', child: Text('Shipped')),
              DropdownMenuItem(value: 'delivered', child: Text('Delivered')),
              DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
            ],
            onChanged: (value) => provider.updateStatusFilter(value),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignsSearchAndFilter(DistributionManagementProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) => provider.updateSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Search campaigns...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: provider.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => provider.updateSearchQuery(''),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          DropdownButton<String>(
            hint: const Text('Status'),
            value: provider.selectedStatus,
            items: const [
              DropdownMenuItem(value: 'draft', child: Text('Draft')),
              DropdownMenuItem(value: 'active', child: Text('Active')),
              DropdownMenuItem(value: 'paused', child: Text('Paused')),
              DropdownMenuItem(value: 'completed', child: Text('Completed')),
              DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
            ],
            onChanged: (value) => provider.updateStatusFilter(value),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionsList(DistributionManagementProvider provider) {
    if (provider.isLoadingDistributions) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.distributionsError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              provider.distributionsError!,
              style: const TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.loadDistributions(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (provider.distributions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_shipping_outlined, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              'No distributions found',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.distributions.length,
      itemBuilder: (context, index) {
        final distribution = provider.distributions[index];
        return DistributionCard(
          distribution: distribution,
          onTap: () => _showDistributionDetails(distribution),
          onStatusUpdate: (status) => provider.updateDistributionStatus(distribution.id, status),
        );
      },
    );
  }

  Widget _buildInventoryList(DistributionManagementProvider provider) {
    if (provider.isLoadingInventory) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.inventoryError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              provider.inventoryError!,
              style: const TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.loadInventory(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (provider.inventory.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_outlined, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              'No inventory items found',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.inventory.length,
      itemBuilder: (context, index) {
        final inventory = provider.inventory[index];
        return InventoryCard(
          inventory: inventory,
          onTap: () => _showInventoryDetails(inventory),
          onStockAdjust: (quantity, reason) => provider.adjustStock(inventory.productId, quantity, reason),
        );
      },
    );
  }

  Widget _buildOrdersList(DistributionManagementProvider provider) {
    if (provider.isLoadingOrders) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.ordersError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              provider.ordersError!,
              style: const TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.loadOrders(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (provider.orders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              'No orders found',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.orders.length,
      itemBuilder: (context, index) {
        final order = provider.orders[index];
        return OrderCard(
          order: order,
          onTap: () => _showOrderDetails(order),
          onStatusUpdate: (status) => provider.updateOrderStatus(order.id, status),
        );
      },
    );
  }

  Widget _buildCampaignsList(DistributionManagementProvider provider) {
    if (provider.isLoadingCampaigns) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.campaignsError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              provider.campaignsError!,
              style: const TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.loadCampaigns(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (provider.campaigns.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.campaign_outlined, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              'No campaigns found',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.campaigns.length,
      itemBuilder: (context, index) {
        final campaign = provider.campaigns[index];
        return CampaignCard(
          campaign: campaign,
          onTap: () => _showCampaignDetails(campaign),
          onStatusUpdate: (status) => provider.launchCampaign(campaign.id),
        );
      },
    );
  }

  void _refreshAll() {
    _provider.loadDistributions();
    _provider.loadInventory();
    _provider.loadOrders();
    _provider.loadCampaigns();
    _provider.loadAnalytics();
  }

  void _showFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Filter Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Date Range Filter
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text('Date Range'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showDateRangeFilter(context),
            ),
            // Warehouse Filter
            ListTile(
              leading: const Icon(Icons.warehouse),
              title: const Text('Warehouse'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showWarehouseFilter(context),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _provider.clearFilters(),
                    child: const Text('Clear All Filters'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAnalytics(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AnalyticsScreen(),
      ),
    );
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.local_shipping),
              title: const Text('Create Distribution'),
              onTap: () => _showCreateDistribution(context),
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Adjust Inventory'),
              onTap: () => _showInventoryAdjustment(context),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Create Order'),
              onTap: () => _showCreateOrder(context),
            ),
            ListTile(
              leading: const Icon(Icons.campaign),
              title: const Text('Create Campaign'),
              onTap: () => _showCreateCampaign(context),
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Generate Report'),
              onTap: () => _showReportGeneration(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showDistributionDetails(DistributionEntity distribution) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DistributionDetailScreen(distribution: distribution),
      ),
    );
  }

  void _showInventoryDetails(InventoryEntity inventory) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InventoryDetailScreen(inventory: inventory),
      ),
    );
  }

  void _showOrderDetails(OrderEntity order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailScreen(order: order),
      ),
    );
  }

  void _showCampaignDetails(MarketingCampaignEntity campaign) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CampaignDetailScreen(campaign: campaign),
      ),
    );
  }

  void _showDateRangeFilter(BuildContext context) {
    // Implementation for date range filter
  }

  void _showWarehouseFilter(BuildContext context) {
    // Implementation for warehouse filter
  }

  void _showCreateDistribution(BuildContext context) {
    // Implementation for creating distribution
  }

  void _showInventoryAdjustment(BuildContext context) {
    // Implementation for inventory adjustment
  }

  void _showCreateOrder(BuildContext context) {
    // Implementation for creating order
  }

  void _showCreateCampaign(BuildContext context) {
    // Implementation for creating campaign
  }

  void _showReportGeneration(BuildContext context) {
    // Implementation for report generation
  }
}
