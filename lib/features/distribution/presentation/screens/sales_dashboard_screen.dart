import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sales_provider.dart';
import '../widgets/sales_metrics_card.dart';
import '../widgets/sales_chart_widget.dart';
import '../widgets/top_products_widget.dart';
import '../widgets/orders_list_widget.dart';
import '../widgets/revenue_summary_widget.dart';

class SalesDashboardScreen extends StatefulWidget {
  const SalesDashboardScreen({Key? key}) : super(key: key);

  @override
  State<SalesDashboardScreen> createState() => _SalesDashboardScreenState();
}

class _SalesDashboardScreenState extends State<SalesDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'Today';
  String _selectedRegion = 'All Regions';
  DateTimeRange? _dateRange;

  final List<String> _periods = [
    'Today',
    'Yesterday',
    'This Week',
    'Last Week',
    'This Month',
    'Last Month',
    'This Quarter',
    'Last Quarter',
    'This Year',
    'Last Year',
    'Custom Range',
  ];

  final List<String> _regions = [
    'All Regions',
    'Kathmandu',
    'Pokhara',
    'Biratnagar',
    'Birgunj',
    'Bhaktapur',
    'Lalitpur',
    'Dharan',
    'Nepalgunj',
    'Butwal',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SalesProvider>().initializeDashboard(
        period: _selectedPeriod,
        region: _selectedRegion,
        dateRange: _dateRange,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              backgroundColor: Theme.of(context).colorScheme.primary,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Sales Dashboard',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Consumer<SalesProvider>(
                    builder: (context, provider, child) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Revenue',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              'NPR ${provider.totalRevenue.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${provider.totalOrders} orders • ${provider.totalCustomers} customers',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: const [
                  Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
                  Tab(icon: Icon(Icons.trending_up), text: 'Analytics'),
                  Tab(icon: Icon(Icons.inventory), text: 'Products'),
                  Tab(icon: Icon(Icons.list), text: 'Orders'),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: _buildFiltersSection(),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildAnalyticsTab(),
            _buildProductsTab(),
            _buildOrdersTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showExportOptions,
        icon: const Icon(Icons.download),
        label: const Text('Export'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedPeriod,
                  decoration: const InputDecoration(
                    labelText: 'Period',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _periods.map((period) {
                    return DropdownMenuItem(
                      value: period,
                      child: Text(period),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPeriod = value!;
                      if (value != 'Custom Range') {
                        _dateRange = null;
                      }
                    });
                    _refreshData();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedRegion,
                  decoration: const InputDecoration(
                    labelText: 'Region',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _regions.map((region) {
                    return DropdownMenuItem(
                      value: region,
                      child: Text(region),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRegion = value!;
                    });
                    _refreshData();
                  },
                ),
              ),
            ],
          ),
          
          if (_selectedPeriod == 'Custom Range') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectDateRange,
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      _dateRange != null
                          ? '${_dateRange!.start.day}/${_dateRange!.start.month}/${_dateRange!.start.year} - ${_dateRange!.end.day}/${_dateRange!.end.month}/${_dateRange!.end.year}'
                          : 'Select Date Range',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _refreshData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Apply'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Consumer<SalesProvider>(
      builder: (context, provider, child) {
        return RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Key Metrics Cards
                Row(
                  children: [
                    Expanded(
                      child: SalesMetricsCard(
                        title: 'Total Revenue',
                        value: 'NPR ${provider.totalRevenue.toStringAsFixed(2)}',
                        change: provider.revenueChange,
                        changePercentage: provider.revenueChangePercentage,
                        icon: Icons.attach_money,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SalesMetricsCard(
                        title: 'Total Orders',
                        value: provider.totalOrders.toString(),
                        change: provider.ordersChange,
                        changePercentage: provider.ordersChangePercentage,
                        icon: Icons.shopping_cart,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: SalesMetricsCard(
                        title: 'Average Order Value',
                        value: 'NPR ${provider.averageOrderValue.toStringAsFixed(2)}',
                        change: provider.aovChange,
                        changePercentage: provider.aovChangePercentage,
                        icon: Icons.receipt,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SalesMetricsCard(
                        title: 'Total Customers',
                        value: provider.totalCustomers.toString(),
                        change: provider.customersChange,
                        changePercentage: provider.customersChangePercentage,
                        icon: Icons.people,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Revenue Summary
                RevenueSummaryWidget(
                  totalRevenue: provider.totalRevenue,
                  revenueByCategory: provider.revenueByCategory,
                  revenueByChannel: provider.revenueByChannel,
                  revenueByRegion: provider.revenueByRegion,
                ),
                
                const SizedBox(height: 24),
                
                // Sales Chart
                SalesChartWidget(
                  title: 'Sales Trend',
                  data: provider.salesTrendData,
                  period: _selectedPeriod,
                ),
                
                const SizedBox(height: 24),
                
                // Top Products
                TopProductsWidget(
                  products: provider.topSellingProducts,
                  title: 'Top Selling Products',
                ),
                
                const SizedBox(height: 24),
                
                // Recent Orders
                OrdersListWidget(
                  orders: provider.recentOrders.take(5).toList(),
                  title: 'Recent Orders',
                  showViewAll: true,
                ),
                
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsTab() {
    return Consumer<SalesProvider>(
      builder: (context, provider, child) {
        return RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Conversion Metrics
                Row(
                  children: [
                    Expanded(
                      child: SalesMetricsCard(
                        title: 'Conversion Rate',
                        value: '${provider.conversionRate.toStringAsFixed(2)}%',
                        change: provider.conversionRateChange,
                        changePercentage: provider.conversionRateChangePercentage,
                        icon: Icons.trending_up,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SalesMetricsCard(
                        title: 'Customer Retention',
                        value: '${provider.customerRetentionRate.toStringAsFixed(2)}%',
                        change: provider.retentionRateChange,
                        changePercentage: provider.retentionRateChangePercentage,
                        icon: Icons.repeat,
                        color: Colors.indigo,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: SalesMetricsCard(
                        title: 'On-Time Delivery',
                        value: '${provider.onTimeDeliveryRate.toStringAsFixed(2)}%',
                        change: provider.deliveryRateChange,
                        changePercentage: provider.deliveryRateChangePercentage,
                        icon: Icons.local_shipping,
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SalesMetricsCard(
                        title: 'Customer Satisfaction',
                        value: '${provider.customerSatisfactionScore.toStringAsFixed(1)}/5.0',
                        change: provider.satisfactionChange,
                        changePercentage: provider.satisfactionChangePercentage,
                        icon: Icons.sentiment_satisfied,
                        color: Colors.pink,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Analytics Charts
                SalesChartWidget(
                  title: 'Revenue by Category',
                  data: provider.revenueByCategoryData,
                  chartType: 'pie',
                ),
                
                const SizedBox(height: 24),
                
                SalesChartWidget(
                  title: 'Sales by Region',
                  data: provider.salesByRegionData,
                  chartType: 'bar',
                ),
                
                const SizedBox(height: 24),
                
                SalesChartWidget(
                  title: 'Channel Performance',
                  data: provider.channelPerformanceData,
                  chartType: 'line',
                ),
                
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductsTab() {
    return Consumer<SalesProvider>(
      builder: (context, provider, child) {
        return RefreshIndicator(
          onRefresh: _refreshData,
          child: Column(
            children: [
              // Product Performance Header
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.inventory,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Product Performance',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${provider.topSellingProducts.length} products',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Top Products List
              Expanded(
                child: TopProductsWidget(
                  products: provider.topSellingProducts,
                  showDetails: true,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrdersTab() {
    return Consumer<SalesProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            // Orders Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.list,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Recent Orders',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${provider.recentOrders.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Orders List
            Expanded(
              child: OrdersListWidget(
                orders: provider.recentOrders,
                showFilters: true,
              ),
            ),
          ],
        );
      },
    );
  }

  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );

    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
      _refreshData();
    }
  }

  void _refreshData() async {
    await context.read<SalesProvider>().refreshDashboard(
      period: _selectedPeriod,
      region: _selectedRegion,
      dateRange: _dateRange,
    );
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Export Options',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Export as PDF'),
              onTap: () {
                Navigator.pop(context);
                context.read<SalesProvider>().exportReport('pdf');
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Export as Excel'),
              onTap: () {
                Navigator.pop(context);
                context.read<SalesProvider>().exportReport('excel');
              },
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Export as CSV'),
              onTap: () {
                Navigator.pop(context);
                context.read<SalesProvider>().exportReport('csv');
              },
            ),
          ],
        ),
      ),
    );
  }
}
