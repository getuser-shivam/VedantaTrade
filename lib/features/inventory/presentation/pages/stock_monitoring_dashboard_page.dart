import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../providers/stock_monitoring_provider.dart';
import '../widgets/stock_alert_card.dart';
import '../widgets/stock_level_chart.dart';
import '../widgets/stock_statistics_widget.dart';
import '../widgets/monitoring_config_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/theme/app_theme.dart';

/// Stock Monitoring Dashboard Page
/// Real-time stock level monitoring with alerts
class StockMonitoringDashboardPage extends StatefulWidget {
  const StockMonitoringDashboardPage({Key? key}) : super(key: key);

  @override
  _StockMonitoringDashboardPageState createState() => _StockMonitoringDashboardPageState();
}

class _StockMonitoringDashboardPageState extends State<StockMonitoringDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _refreshTimer;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
    
    // Start auto-refresh
    _startAutoRefresh();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }
  
  void _loadInitialData() {
    final provider = StockMonitoringProvider.of(context);
    provider.loadActiveAlerts();
    provider.loadStockStatistics();
    provider.loadMonitoringConfigs();
  }
  
  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _refreshData();
    });
  }
  
  void _refreshData() {
    final provider = StockMonitoringProvider.of(context);
    provider.refreshActiveAlerts();
    provider.refreshStatistics();
  }
  
  void _onSearchChanged(String query) {
    final provider = StockMonitoringProvider.of(context);
    provider.filterAlerts(query);
  }
  
  void _onTabChanged() {
    setState(() {});
  }
  
  void _onRefresh() {
    _refreshData();
  }
  
  void _onAcknowledgeAlert(String alertId) {
    final provider = StockMonitoringProvider.of(context);
    provider.acknowledgeAlert(alertId);
  }
  
  void _onResolveAlert(String alertId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resolve Alert'),
        content: TextField(
          decoration: const InputDecoration(
            labelText: 'Resolution Notes',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            // Store resolution notes
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final provider = StockMonitoringProvider.of(context);
              provider.resolveAlert(alertId, 'Resolution notes');
            },
            child: const Text('Resolve'),
          ),
        ],
      ),
    );
  }
  
  void _onConfigureMonitoring() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => MonitoringConfigWidget(
        onSave: (config) {
          final provider = StockMonitoringProvider.of(context);
          provider.updateMonitoringConfig(config);
        },
      ),
    );
  }
  
  void _onExportAlerts() {
    final provider = StockMonitoringProvider.of(context);
    provider.exportAlerts();
  }
  
  void _onBulkAction(String action) {
    final provider = StockMonitoringProvider.of(context);
    final selectedAlerts = provider.selectedAlerts;
    
    if (selectedAlerts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select alerts to perform bulk action')),
      );
      return;
    }
    
    switch (action) {
      case 'acknowledge':
        provider.acknowledgeMultipleAlerts(selectedAlerts);
        break;
      case 'resolve':
        _showBulkResolveDialog(selectedAlerts);
        break;
      case 'delete':
        _showBulkDeleteDialog(selectedAlerts);
        break;
      case 'export':
        provider.exportSelectedAlerts(selectedAlerts);
        break;
    }
  }
  
  void _showBulkResolveDialog(List<String> alertIds) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Resolve ${alertIds.length} Alerts'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add resolution notes for all selected alerts:'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Resolution Notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) {
                // Store resolution notes
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final provider = StockMonitoringProvider.of(context);
              provider.resolveMultipleAlerts(alertIds, 'Bulk resolution');
            },
            child: const Text('Resolve All'),
          ),
        ],
      ),
    );
  }
  
  void _showBulkDeleteDialog(List<String> alertIds) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${alertIds.length} Alerts'),
        content: Text('Are you sure you want to delete ${alertIds.length} alert(s)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final provider = StockMonitoringProvider.of(context);
              provider.deleteMultipleAlerts(alertIds);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Monitoring'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _onRefresh,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _onConfigureMonitoring,
            tooltip: 'Configure Monitoring',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _onExportAlerts,
            tooltip: 'Export Alerts',
          ),
          PopupMenuButton<String>(
            onSelected: _onBulkAction,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'acknowledge', child: Text('Acknowledge Selected')),
              const PopupMenuItem(value: 'resolve', child: Text('Resolve Selected')),
              const PopupMenuItem(value: 'delete', child: Text('Delete Selected')),
              const PopupMenuItem(value: 'export', child: Text('Export Selected')),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Alerts', icon: Icon(Icons.notifications)),
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Analytics', icon: Icon(Icons.analytics)),
            Tab(text: 'Settings', icon: Icon(Icons.settings)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search alerts...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAlertsTab(),
                _buildOverviewTab(),
                _buildAnalyticsTab(),
                _buildSettingsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onConfigureMonitoring,
        child: const Icon(Icons.add),
        tooltip: 'Configure Monitoring',
      ),
    );
  }
  
  Widget _buildAlertsTab() {
    return Consumer<StockMonitoringProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const LoadingWidget();
        }
        
        if (provider.error != null) {
          return AppErrorWidget(
            message: provider.error!,
            onRetry: _onRefresh,
          );
        }
        
        final alerts = provider.filteredAlerts;
        
        if (alerts.isEmpty) {
          return EmptyStateWidget(
            title: 'No Active Alerts',
            subtitle: 'All stock levels are within normal parameters',
            action: _onConfigureMonitoring,
            actionText: 'Configure Monitoring',
          );
        }
        
        return RefreshIndicator(
          onRefresh: () async => _onRefresh(),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return StockAlertCard(
                alert: alert,
                onTap: () {
                  // Navigate to alert details
                },
                onAcknowledge: () => _onAcknowledgeAlert(alert.id),
                onResolve: () => _onResolveAlert(alert.id),
                isSelected: provider.selectedAlerts.contains(alert.id),
                onSelected: (selected) {
                  provider.toggleAlertSelection(alert.id);
                },
              );
            },
          ),
        );
      },
    );
  }
  
  Widget _buildOverviewTab() {
    return Consumer<StockMonitoringProvider>(
      builder: (context, provider, child) {
        final statistics = provider.statistics;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary cards
              StockStatisticsWidget(statistics: statistics),
              
              const SizedBox(height: 20),
              
              // Recent alerts chart
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Alerts Trend',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: StockLevelChart(
                          data: provider.recentAlerts,
                          title: 'Alerts Over Time',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Critical alerts
              if (provider.criticalAlerts.isNotEmpty) ...[
                Card(
                  color: Colors.red.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.warning, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(
                              'Critical Alerts',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...provider.criticalAlerts.take(5).map((alert) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  alert.message,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              TextButton(
                                onPressed: () => _onResolveAlert(alert.id),
                                child: const Text('Resolve'),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildAnalyticsTab() {
    return Consumer<StockMonitoringProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Alert distribution by type
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alert Distribution by Type',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 250,
                        child: StockLevelChart(
                          data: provider.alertsByType,
                          title: 'Alerts by Type',
                          chartType: 'pie',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Alert distribution by severity
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alert Distribution by Severity',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 250,
                        child: StockLevelChart(
                          data: provider.alertsBySeverity,
                          title: 'Alerts by Severity',
                          chartType: 'bar',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Top products with alerts
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Products with Most Alerts',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      ...provider.topAlertProducts.take(10).map((product) => ListTile(
                        leading: CircleAvatar(
                          child: Text('${product.alertCount}'),
                          backgroundColor: _getSeverityColor(product.severity),
                        ),
                        title: Text(product.productName),
                        subtitle: Text('${product.warehouseName} • ${product.alertCount} alerts'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Navigate to product details
                        },
                      )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildSettingsTab() {
    return Consumer<StockMonitoringProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Monitoring settings
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monitoring Settings',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Enable Low Stock Alerts'),
                        subtitle: const Text('Get notified when stock falls below minimum'),
                        value: provider.monitoringSettings.enableLowStockAlerts,
                        onChanged: (value) {
                          provider.updateMonitoringSettings(
                            provider.monitoringSettings.copyWith(
                              enableLowStockAlerts: value,
                            ),
                          );
                        },
                      ),
                      SwitchListTile(
                        title: const Text('Enable Overstock Alerts'),
                        subtitle: const Text('Get notified when stock exceeds maximum'),
                        value: provider.monitoringSettings.enableOverstockAlerts,
                        onChanged: (value) {
                          provider.updateMonitoringSettings(
                            provider.monitoringSettings.copyWith(
                              enableOverstockAlerts: value,
                            ),
                          );
                        },
                      ),
                      SwitchListTile(
                        title: const Text('Enable Expiry Alerts'),
                        subtitle: const Text('Get notified before products expire'),
                        value: provider.monitoringSettings.enableExpiryAlerts,
                        onChanged: (value) {
                          provider.updateMonitoringSettings(
                            provider.monitoringSettings.copyWith(
                              enableExpiryAlerts: value,
                            ),
                          );
                        },
                      ),
                      SwitchListTile(
                        title: const Text('Enable Movement Alerts'),
                        subtitle: const Text('Get notified of unusual stock movements'),
                        value: provider.monitoringSettings.enableMovementAlerts,
                        onChanged: (value) {
                          provider.updateMonitoringSettings(
                            provider.monitoringSettings.copyWith(
                              enableMovementAlerts: value,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Notification settings
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notification Settings',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: const Text('Alert Frequency'),
                        subtitle: Text(provider.monitoringSettings.alertFrequency),
                        trailing: DropdownButton<String>(
                          value: provider.monitoringSettings.alertFrequency,
                          items: const [
                            DropdownMenuItem(value: 'immediate', child: Text('Immediate')),
                            DropdownMenuItem(value: 'hourly', child: Text('Hourly')),
                            DropdownMenuItem(value: 'daily', child: Text('Daily')),
                            DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              provider.updateMonitoringSettings(
                                provider.monitoringSettings.copyWith(
                                  alertFrequency: value,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Notification Emails',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...provider.monitoringSettings.notificationEmails.map((email) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Expanded(child: Text(email)),
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                provider.removeNotificationEmail(email);
                              },
                            ),
                          ],
                        ),
                      )),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          _showAddEmailDialog();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Email'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _showAddEmailDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Notification Email'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Email Address',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context);
                final provider = StockMonitoringProvider.of(context);
                provider.addNotificationEmail(controller.text);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
  
  Color _getSeverityColor(StockAlertSeverity severity) {
    switch (severity) {
      case StockAlertSeverity.critical:
        return Colors.red;
      case StockAlertSeverity.high:
        return Colors.orange;
      case StockAlertSeverity.medium:
        return Colors.yellow;
      case StockAlertSeverity.low:
        return Colors.blue;
      case StockAlertSeverity.info:
        return Colors.grey;
    }
  }
}
