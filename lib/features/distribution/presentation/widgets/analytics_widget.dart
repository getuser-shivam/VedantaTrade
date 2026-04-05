import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AnalyticsWidget extends StatelessWidget {
  final Map<String, dynamic> analytics;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRefresh;

  const AnalyticsWidget({
    Key? key,
    required this.analytics,
    required this.isLoading,
    this.error,
    this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: onRefresh,
            tooltip: 'Refresh Analytics',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _exportAnalytics(context),
            tooltip: 'Export Analytics',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? _buildErrorState()
              : _buildAnalyticsContent(context),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            error!,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRefresh,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview Cards
          _buildOverviewCards(context),
          const SizedBox(height: 24),
          // Charts Section
          _buildChartsSection(context),
          const SizedBox(height: 24),
          // Detailed Metrics
          _buildDetailedMetrics(context),
        ],
      ),
    );
  }

  Widget _buildOverviewCards(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: _getCrossAxisCount(context),
          childAspectRatio: 1.5,
          children: [
            _buildOverviewCard(
              'Total Distributions',
              '${analytics['totalDistributions'] ?? 0}',
              Icons.local_shipping,
              Colors.blue,
            ),
            _buildOverviewCard(
              'Active Orders',
              '${analytics['activeOrders'] ?? 0}',
              Icons.shopping_cart,
              Colors.green,
            ),
            _buildOverviewCard(
              'Low Stock Items',
              '${analytics['lowStockItems'] ?? 0}',
              Icons.warning,
              Colors.orange,
            ),
            _buildOverviewCard(
              'Total Revenue',
              'NPR ${((analytics['totalRevenue'] ?? 0) as double).toStringAsFixed(0)}',
              Icons.attach_money,
              Colors.purple,
            ),
            _buildOverviewCard(
              'Active Campaigns',
              '${analytics['activeCampaigns'] ?? 0}',
              Icons.campaign,
              Colors.indigo,
            ),
            _buildOverviewCard(
              'Conversion Rate',
              '${((analytics['conversionRate'] ?? 0) as double).toStringAsFixed(1)}%',
              Icons.trending_up,
              Colors.teal,
            ),
            _buildOverviewCard(
              'Avg. Delivery Time',
              '${((analytics['averageDeliveryTime'] ?? 0) as double).toStringAsFixed(1)} days',
              Icons.access_time,
              Colors.red,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverviewCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Performance Charts',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // Sales Chart
        _buildSalesChart(context),
        const SizedBox(height: 24),
        // Distribution Chart
        _buildDistributionChart(context),
        const SizedBox(height: 24),
        // Campaign Performance Chart
        _buildCampaignChart(context),
      ],
    );
  }

  Widget _buildSalesChart(BuildContext context) {
    final salesData = _getSalesData();
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sales Trend (Last 7 Days)',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  majorGridLines: const MajorGridLines(width: 0),
                  labelPlacement: LabelPlacement.outside,
                  labelStyle: const TextStyle(fontSize: 10),
                ),
                primaryYAxis: NumericAxis(
                  majorGridLines: const MajorGridLines(width: 0),
                  labelFormat: NumberFormat.decimalPattern('##0'),
                  labelStyle: const TextStyle(fontSize: 10),
                ),
                series: <CartesianSeries<ChartData, String>>[
                  SplineSeries<ChartData, String>>(
                    dataSource: salesData,
                    xValueMapper: (ChartData data, _) => data.x,
                    yValueMapper: (ChartData data, _) => data.y,
                    color: Theme.of(context).primaryColor,
                    width: 2,
                    markerSettings: const MarkerSettings(
                      isVisible: true,
                      height: 4,
                      width: 4,
                    ),
                  ),
                ],
                tooltipBehavior: TooltipBehavior(enable: true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionChart(BuildContext context) {
    final distributionData = _getDistributionData();
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Distribution by Status',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: SfCircularChart(
                dataSource: distributionData,
                xValueMapper: (ChartData data, _) => data.x,
                yValueMapper: (ChartData data, _) => data.y,
                pointColorMapper: (ChartData data, _) => data.color,
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  labelPosition: ChartDataLabelPosition.outside,
                  textStyle: TextStyle(fontSize: 12),
                ),
                enableTooltip: true,
                legend: Legend(
                  isVisible: true,
                  overflowMode: LegendItemOverflowMode.wrap,
                  position: LegendPosition.bottom,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignChart(BuildContext context) {
    final campaignData = _getCampaignData();
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Campaign Performance',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  majorGridLines: const MajorGridLines(width: 0),
                  labelPlacement: LabelPlacement.outside,
                  labelStyle: const TextStyle(fontSize: 10),
                ),
                primaryYAxis: NumericAxis(
                  majorGridLines: const MajorGridLines(width: 0),
                  labelFormat: NumberFormat.decimalPattern('##0'),
                  labelStyle: const TextStyle(fontSize: 10),
                ),
                series: <CartesianSeries<ChartData, String>>[
                  ColumnSeries<ChartData, String>>(
                    dataSource: campaignData,
                    xValueMapper: (ChartData data, _) => data.x,
                    yValueMapper: (ChartData data, _) => data.y,
                    color: Theme.of(context).primaryColor,
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                      textStyle: TextStyle(fontSize: 10),
                    ),
                    enableTooltip: true,
                  ),
                ],
                tooltipBehavior: TooltipBehavior(enable: true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedMetrics(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detailed Metrics',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // Top Products
        _buildTopProductsSection(),
        const SizedBox(height: 24),
        // Recent Activities
        _buildRecentActivitiesSection(),
        const SizedBox(height: 24),
        // Performance Indicators
        _buildPerformanceIndicatorsSection(),
      ],
    );
  }

  Widget _buildTopProductsSection() {
    final topProducts = analytics['topProducts'] as List<dynamic>? ?? [];
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Selling Products',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ...topProducts.take(5).map((product) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      product['name'] as String,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                      'NPR ${(product['revenue'] as double).toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitiesSection() {
    final activities = analytics['recentActivities'] as List<dynamic>? ?? [];
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activities',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ...activities.take(5).map((activity) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(
                    _getActivityIcon(activity['type'] as String),
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity['description'] as String,
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          activity['timestamp'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceIndicatorsSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Indicators',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildPerformanceIndicator(
              'Inventory Turnover',
              '${(analytics['inventoryTurnover'] ?? 0)} times/month',
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildPerformanceIndicator(
              'Order Fulfillment Rate',
              '${((analytics['orderFulfillmentRate'] ?? 0) as double).toStringAsFixed(1)}%',
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildPerformanceIndicator(
              'Customer Satisfaction',
              '${(analytics['customerSatisfaction'] ?? 0)}%',
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildPerformanceIndicator(
              'Campaign ROI',
              '${(analytics['campaignROI'] ?? 0)}%',
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceIndicator(String title, String value, Color color) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) return 4;
    if (screenWidth > 800) return 3;
    if (screenWidth > 600) return 2;
    return 1;
  }

  List<ChartData> _getSalesData() {
    final salesData = analytics['salesData'] as List<dynamic>? ?? [];
    return salesData.map((data) => ChartData(
      x: data['date'] as String,
      y: data['amount'] as double,
      color: Theme.of(context).primaryColor,
    )).toList();
  }

  List<ChartData> _getDistributionData() {
    final distributionData = analytics['distributionData'] as List<dynamic>? ?? [];
    return distributionData.map((data) => ChartData(
      x: data['status'] as String,
      y: data['count'] as double,
      color: _getDistributionColor(data['status'] as String),
    )).toList();
  }

  List<ChartData> _getCampaignData() {
    final campaignData = analytics['campaignData'] as List<dynamic>? ?? [];
    return campaignData.map((data) => ChartData(
      x: data['name'] as String,
      y: data['performance'] as double,
      color: Theme.of(context).primaryColor,
    )).toList();
  }

  Color _getDistributionColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'in_transit':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'order_created':
        return Icons.shopping_cart;
      case 'distribution_created':
        return Icons.local_shipping;
      case 'campaign_launched':
        return Icons.campaign;
      case 'inventory_adjusted':
        return Icons.inventory;
      case 'payment_received':
        return Icons.payment;
      default:
        return Icons.info;
    }
  }

  void _exportAnalytics(BuildContext context) {
    // Implementation for exporting analytics data
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Analytics export feature coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

class ChartData {
  final String x;
  final double y;
  final Color color;

  ChartData({
    required this.x,
    required this.y,
    required this.color,
  });
}
