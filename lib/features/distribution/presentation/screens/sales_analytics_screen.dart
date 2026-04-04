import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import '../providers/analytics_provider.dart';

class SalesAnalyticsScreen extends StatefulWidget {
  const SalesAnalyticsScreen({Key? key}) : super(key: key);

  @override
  _SalesAnalyticsScreenState createState() => _SalesAnalyticsScreenState();
}

class _SalesAnalyticsScreenState extends State<SalesAnalyticsScreen> {
  String _selectedPeriod = 'Last 30 Days';
  String _selectedMetric = 'Revenue';
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final analyticsProvider = Provider.of<AnalyticsProvider>(context, listen: false);
      await analyticsProvider.loadSalesAnalytics(
        period: _selectedPeriod,
        metric: _selectedMetric,
      );
    } catch (e) {
      setState(() {
        _error = 'Failed to load analytics data';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onPeriodChanged(String period) {
    setState(() {
      _selectedPeriod = period;
    });
    _loadAnalyticsData();
  }

  void _onMetricChanged(String metric) {
    setState(() {
      _selectedMetric = metric;
    });
    _loadAnalyticsData();
  }

  @override
  Widget build(BuildContext context) {
    final analyticsProvider = Provider.of<AnalyticsProvider>(context, listen: false);
    final analyticsData = analyticsProvider.salesAnalytics;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Analytics'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () {
              
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              children: [
                // Period Filter
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedPeriod,
                    decoration: InputDecoration(
                      labelText: 'Time Period',
                      border: OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: [
                      'Last 7 Days',
                      'Last 30 Days',
                      'Last 90 Days',
                      'Last 6 Months',
                      'Last Year',
                      'Custom Range',
                    ].map((period) {
                      return DropdownMenuItem(
                        value: period,
                        child: Text(period),
                      );
                    }).toList(),
                    onChanged: _onPeriodChanged,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Metric Filter
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedMetric,
                    decoration: InputDecoration(
                      labelText: 'Metric',
                      border: OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: [
                      'Revenue',
                      'Sales Quantity',
                      'Profit',
                      'Cost',
                      'ROI',
                      'Conversion Rate',
                    ].map((metric) {
                      return DropdownMenuItem(
                        value: metric,
                        child: Text(metric),
                      );
                    }).toList(),
                    onChanged: _onMetricChanged,
                  ),
                ),
              ],
            ),
          ),
          
          // Loading Indicator
          if (_isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: Colors.blue[800],
                ),
              ),
            ),
          
          // Error Message
          if (_error != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.red[400],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadAnalyticsData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          
          // Analytics Content
          if (!_isLoading && _error == null)
            Expanded(
              child: analyticsData == null
                  ? _buildEmptyState()
                  : _buildAnalyticsContent(analyticsData!),
            ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsContent(Map<String, dynamic> analyticsData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          _buildSummaryCards(analyticsData),
          const SizedBox(height: 24),
          
          // Chart Section
          _buildChartSection(analyticsData),
          const SizedBox(height: 24),
          
          // Detailed Metrics
          _buildDetailedMetrics(analyticsData),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(Map<String, dynamic> analyticsData) {
    final summary = analyticsData['summary'] as Map<String, dynamic>? ?? {};
    
    return Row(
      children: [
        // Revenue Card
        Expanded(
          child: Card(
            color: Colors.green[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.attach_money, color: Colors.green[800], size: 24),
                  const SizedBox(height: 8),
                  Text(
                    'Total Revenue',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${(summary['total_revenue'] ?? 0).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        
        // Sales Quantity Card
        Expanded(
          child: Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.shopping_cart, color: Colors.blue[800], size: 24),
                  const SizedBox(height: 8),
                  Text(
                    'Total Sales',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (summary['total_sales'] ?? 0).toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(width: 16),
        
        // Profit Card
        Expanded(
          child: Card(
            color: Colors.orange[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.trending_up, color: Colors.orange[800], size: 24),
                  const SizedBox(height: 8),
                  Text(
                    'Total Profit',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.orange[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${(summary['total_profit'] ?? 0).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[800],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildChartSection(Map<String, dynamic> analyticsData) {
    final chartData = analyticsData['chart_data'] as List<dynamic>? ?? [];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_selectedMetric} Over Time',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: charts.LineChart(
                [
                  charts.Series<dynamic, String>(
                    id: _selectedMetric,
                    data: chartData,
                    colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
                    domainFn: (data, _) => data['date'],
                    measureFn: (data, _) => data['value'],
                  ),
                ],
                animate: true,
                defaultRenderer: charts.LineRendererConfig(
                  includePoints: true,
                  includeArea: true,
                ),
                primaryMeasureAxis: charts.NumericAxisSpec(
                  renderSpec: charts.GridlineRendererSpec(
                    lineStyle: charts.LineStyleSpec(
                      color: charts.MaterialPalette.gray.shade400,
                    ),
                  ),
                ),
                domainAxis: charts.OrdinalAxisSpec(
                  renderSpec: charts.SmallTickRendererSpec(
                    labelRotation: 45,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedMetrics(Map<String, dynamic> analyticsData) {
    final metrics = analyticsData['detailed_metrics'] as Map<String, dynamic>? ?? {};
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detailed Metrics',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            
            // Top Products
            _buildMetricItem(
              'Top Products',
              Icons.star,
              Colors.blue[800],
              (metrics['top_products'] as List<dynamic>? ?? [])
                  .take(5)
                  .map((product) => '${product['name']}: ${product['sales']}')
                  .join(', '),
            ),
            
            // Top Centers
            _buildMetricItem(
              'Top Centers',
              Icons.location_city,
              Colors.green[800],
              (metrics['top_centers'] as List<dynamic>? ?? [])
                  .take(5)
                  .map((center) => '${center['name']}: ${center['revenue']}')
                  .join(', '),
            ),
            
            // Average Order Value
            _buildMetricItem(
              'Average Order Value',
              Icons.receipt,
              Colors.orange[800],
              '₹${(metrics['avg_order_value'] ?? 0).toStringAsFixed(2)}',
            ),
            
            // Conversion Rate
            _buildMetricItem(
              'Conversion Rate',
              Icons.trending_up,
              Colors.purple[800],
              '${(metrics['conversion_rate'] ?? 0).toStringAsFixed(2)}%',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String title, IconData icon, Color color, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No analytics data available',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a different time period or check back later',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
