import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/widgets/premium_glassmorphic_theme.dart';
import '../../data/services/distribution_management_service.dart';
import '../providers/distribution_provider.dart';

class DistributionMetricsWidget extends StatefulWidget {
  const DistributionMetricsWidget({Key? key}) : super(key: key);

  @override
  State<DistributionMetricsWidget> createState() => _DistributionMetricsWidgetState();
}

class _DistributionMetricsWidgetState extends State<DistributionMetricsWidget> {
  late DistributionManagementService _distributionService;

  @override
  void initState() {
    super.initState();
    _distributionService = DistributionManagementService();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DistributionMetrics>(
      stream: _distributionService.metricsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        }

        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        }

        final metrics = snapshot.data ?? DistributionMetrics();
        
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withOpacity(0.05),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    color: PremiumGlassmorphicTheme.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Distribution Metrics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: PremiumGlassmorphicTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Key Metrics Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.4,
                children: [
                  _buildMetricCard(
                    'Total Products',
                    metrics.totalProducts.toString(),
                    Icons.inventory_2_outlined,
                    PremiumGlassmorphicTheme.primaryColor,
                    null,
                  ),
                  _buildMetricCard(
                    'Low Stock Items',
                    metrics.lowStockItems.toString(),
                    Icons.warning_outlined,
                    Colors.orange,
                    metrics.lowStockItems > 0 ? 'Alert' : null,
                  ),
                  _buildMetricCard(
                    'Out of Stock',
                    metrics.outOfStockItems.toString(),
                    Icons.error_outline,
                    Colors.red,
                    metrics.outOfStockItems > 0 ? 'Critical' : null,
                  ),
                  _buildMetricCard(
                    'Today\'s Sales',
                    metrics.todaySales.toString(),
                    Icons.trending_up_outlined,
                    PremiumGlassmorphicTheme.successColor,
                    null,
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Revenue and Orders
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: PremiumGlassmorphicTheme.primaryColor.withOpacity(0.1),
                  border: Border.all(
                    color: PremiumGlassmorphicTheme.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Performance Overview',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: PremiumGlassmorphicTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPerformanceItem(
                            'Total Revenue',
                            'NPR ${metrics.totalSalesValue.toStringAsFixed(2)}',
                            Icons.attach_money_outlined,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildPerformanceItem(
                            'Pending Orders',
                            metrics.pendingOrders.toString(),
                            Icons.pending_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPerformanceItem(
                            'Avg Order Value',
                            'NPR ${metrics.averageOrderValue.toStringAsFixed(2)}',
                            Icons.receipt_outlined,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildPerformanceItem(
                            'Critical Alerts',
                            metrics.criticalAlerts.toString(),
                            Icons.crisis_alert_outlined,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Health Status
              _buildHealthStatus(metrics),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, String? badge) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              if (badge != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: PremiumGlassmorphicTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: PremiumGlassmorphicTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: PremiumGlassmorphicTheme.primaryColor,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: PremiumGlassmorphicTheme.textSecondary,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: PremiumGlassmorphicTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHealthStatus(DistributionMetrics metrics) {
    final healthScore = metrics.inventoryHealth;
    final status = metrics.overallStatus;
    final statusColor = _getStatusColor(status);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: statusColor.withOpacity(0.1),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.health_and_safety_outlined,
                color: statusColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'System Health',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: PremiumGlassmorphicTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Health Score Bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: healthScore / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Health Score: ${healthScore.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
              Text(
                'Status: $status',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'good':
        return Colors.green;
      case 'caution':
        return Colors.orange;
      case 'warning':
        return Colors.orange;
      case 'critical':
        return Colors.red;
      default:
        return PremiumGlassmorphicTheme.primaryColor;
    }
  }

  Widget _buildLoadingWidget() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: PremiumGlassmorphicTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Distribution Metrics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: PremiumGlassmorphicTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                PremiumGlassmorphicTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.red.withOpacity(0.1),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Error Loading Metrics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            error,
            style: TextStyle(
              fontSize: 14,
              color: Colors.red.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
