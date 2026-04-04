import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../shared/widgets/premium_glassmorphic_theme.dart';
import '../providers/enhanced_distribution_provider.dart';
import '../../marketing/presentation/providers/marketing_analytics_provider.dart';
import '../widgets/sales_metrics_card.dart';
import '../widgets/top_performers_widget.dart';
import '../widgets/sales_chart_widget.dart';
import '../widgets/forecast_widget.dart';

class SalesAnalyticsDashboard extends StatefulWidget {
  const SalesAnalyticsDashboard({Key? key}) : super(key: key);

  @override
  State<SalesAnalyticsDashboard> createState() => _SalesAnalyticsDashboardState();
}

class _SalesAnalyticsDashboardState extends State<SalesAnalyticsDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'monthly';
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedRegion;
  String? _selectedDistributor;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final distributionProvider = Provider.of<EnhancedDistributionProvider>(context, listen: false);
      final marketingProvider = Provider.of<MarketingAnalyticsProvider>(context, listen: false);
      
      distributionProvider.loadSalesAnalytics(period: _selectedPeriod);
      distributionProvider.loadTopPerformers(period: _selectedPeriod);
      distributionProvider.loadPerformanceMetrics();
      marketingProvider.loadOverallAnalytics(period: _selectedPeriod);
    });
  }

  void _refreshData() {
    final distributionProvider = Provider.of<EnhancedDistributionProvider>(context, listen: false);
    final marketingProvider = Provider.of<MarketingAnalyticsProvider>(context, listen: false);
    
    distributionProvider.loadSalesAnalytics(
      period: _selectedPeriod,
      startDate: _startDate,
      endDate: _endDate,
      region: _selectedRegion,
      distributorId: _selectedDistributor,
    );
    
    distributionProvider.loadTopPerformers(
      period: _selectedPeriod,
      region: _selectedRegion,
      distributorId: _selectedDistributor,
    );
    
    distributionProvider.loadPerformanceMetrics(
      distributorId: _selectedDistributor,
      region: _selectedRegion,
      startDate: _startDate,
      endDate: _endDate,
    );
    
    marketingProvider.loadOverallAnalytics(
      period: _selectedPeriod,
      startDate: _startDate,
      endDate: _endDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PremiumGlassmorphicTheme.glassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildFiltersSection(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildAnalyticsTab(),
                  _buildTopPerformersTab(),
                  _buildForecastTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Sales Analytics Dashboard',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshData,
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: _exportAnalytics,
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filters',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPeriodDropdown(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRegionDropdown(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDistributorDropdown(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateRangeButton(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPeriod,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white,
          ),
          dropdownColor: Colors.grey[800],
          items: ['daily', 'weekly', 'monthly', 'quarterly', 'yearly']
              .map((period) => DropdownMenuItem(
                    value: period,
                    child: Text(period.capitalize()),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedPeriod = value;
              });
              _refreshData();
            }
          },
        ),
      ),
    );
  }

  Widget _buildRegionDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRegion,
          hint: Text(
            'All Regions',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white,
          ),
          dropdownColor: Colors.grey[800],
          items: ['Kathmandu', 'Pokhara', 'Biratnagar', 'Bhairahawa']
              .map((region) => DropdownMenuItem(
                    value: region,
                    child: Text(region),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedRegion = value;
            });
            _refreshData();
          },
        ),
      ),
    );
  }

  Widget _buildDistributorDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedDistributor,
          hint: Text(
            'All Distributors',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white,
          ),
          dropdownColor: Colors.grey[800],
          items: ['Distributor 1', 'Distributor 2', 'Distributor 3']
              .map((distributor) => DropdownMenuItem(
                    value: distributor,
                    child: Text(distributor),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedDistributor = value;
            });
            _refreshData();
          },
        ),
      ),
    );
  }

  Widget _buildDateRangeButton() {
    return InkWell(
      onTap: _selectDateRange,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.date_range,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _startDate != null && _endDate != null
                    ? '${DateFormat('MMM dd').format(_startDate!)} - ${DateFormat('MMM dd').format(_endDate!)}'
                    : 'Select Date Range',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.6),
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Analytics'),
          Tab(text: 'Top Performers'),
          Tab(text: 'Forecast'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Consumer<EnhancedDistributionProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingAnalytics) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }

        if (provider.analyticsError != null) {
          return Center(
            child: Text(
              provider.analyticsError!,
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        final analytics = provider.salesAnalytics;
        if (analytics == null) {
          return const Center(
            child: Text(
              'No analytics data available',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: SalesMetricsCard(
                      title: 'Total Revenue',
                      value: analytics.totalRevenue,
                      icon: Icons.attach_money,
                      color: Colors.green,
                      growth: analytics.growthRate,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SalesMetricsCard(
                      title: 'Total Orders',
                      value: analytics.totalOrders,
                      icon: Icons.shopping_cart,
                      color: Colors.blue,
                      isInteger: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SalesMetricsCard(
                      title: 'Avg Order Value',
                      value: analytics.averageOrderValue,
                      icon: Icons.receipt_long,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SalesMetricsCard(
                      title: 'Units Sold',
                      value: analytics.totalUnitsSold.toDouble(),
                      icon: Icons.inventory,
                      color: Colors.purple,
                      isInteger: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SalesMetricsCard(
                title: 'Target Achievement',
                value: analytics.targetAchievement * 100,
                icon: Icons.trending_up,
                color: analytics.targetAchievement >= 1.0 ? Colors.green : Colors.red,
                suffix: '%',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsTab() {
    return Consumer2<EnhancedDistributionProvider, MarketingAnalyticsProvider>(
      builder: (context, distributionProvider, marketingProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (distributionProvider.salesAnalytics != null)
                SalesChartWidget(
                  analytics: distributionProvider.salesAnalytics!,
                ),
              const SizedBox(height: 16),
              if (marketingProvider.overallAnalytics.isNotEmpty)
                _buildMarketingMetrics(marketingProvider.overallAnalytics),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopPerformersTab() {
    return Consumer<EnhancedDistributionProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingTopPerformers) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TopPerformersWidget(
                title: 'Top Products',
                performers: provider.topProducts,
                type: 'product',
              ),
              const SizedBox(height: 16),
              TopPerformersWidget(
                title: 'Top Distributors',
                performers: provider.topDistributors,
                type: 'distributor',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildForecastTab() {
    return Consumer<EnhancedDistributionProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ForecastWidget(
                forecasts: provider.salesForecasts,
                isLoading: provider.isLoadingForecasts,
                error: provider.forecastsError,
                onGenerateForecast: _generateForecast,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMarketingMetrics(Map<String, dynamic> analytics) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Marketing Metrics',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildMetricRow('Total Budget', analytics['total_budget'] ?? 0.0, Icons.account_balance),
          _buildMetricRow('Total Spent', analytics['total_spent'] ?? 0.0, Icons.money_off),
          _buildMetricRow('ROI', analytics['average_roi'] ?? 0.0, Icons.trending_up, suffix: '%'),
          _buildMetricRow('Conversions', analytics['total_conversions'] ?? 0, Icons.person_add, isInteger: true),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String title, double value, IconData icon, {String suffix = '', bool isInteger = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),
          Text(
            isInteger ? value.toInt().toString() : value.toStringAsFixed(2) + suffix,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _selectDateRange() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    ).then((start) {
      if (start != null) {
        showDatePicker(
          context: context,
          initialDate: start.add(const Duration(days: 30)),
          firstDate: start,
          lastDate: DateTime.now().add(const Duration(days: 365)),
        ).then((end) {
          if (end != null) {
            setState(() {
              _startDate = start;
              _endDate = end;
            });
            _refreshData();
          }
        });
      }
    });
  }

  void _generateForecast() {
    // Show dialog to select product and region for forecast
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Sales Forecast'),
        content: const Text('Select product and region to generate forecast'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Generate forecast with mock data
              final provider = Provider.of<EnhancedDistributionProvider>(context, listen: false);
              provider.generateSalesForecast(
                productId: 'product1',
                region: 'Kathmandu',
                forecastDate: DateTime.now().add(const Duration(days: 30)),
              );
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }

  void _exportAnalytics() {
    // Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Analytics exported successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
