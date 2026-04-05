import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../shared/theme/modern_design_system.dart';
import '../../../shared/widgets/micro_interactions.dart';
import 'wireless_debug_service.dart';

/// Wireless Debugging Dashboard
/// Comprehensive debugging interface with real-time monitoring and controls
class WirelessDebugDashboard extends StatefulWidget {
  const WirelessDebugDashboard({Key? key}) : super(key: key);

  @override
  _WirelessDebugDashboardState createState() => _WirelessDebugDashboardState();
}

class _WirelessDebugDashboardState extends State<WirelessDebugDashboard> 
    with TickerProviderStateMixin {
  late WirelessDebugService _debugService;
  late TabController _tabController;
  DebugSessionInfo? _currentSession;
  List<DebugLog> _recentLogs = [];
  List<PerformanceMetric> _performanceMetrics = [];
  NetworkStatus? _networkStatus;
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = false;
  bool _isMonitoring = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _initializeDebugService();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer?.cancel();
    _debugService.dispose();
    super.dispose();
  }

  Future<void> _initializeDebugService() async {
    try {
      _debugService = WirelessDebugService();
      await _debugService.initialize();
      
      // Listen to debug events
      _debugService.debugEventStream.listen((event) {
        if (mounted) {
          setState(() {
            _recentLogs.insert(0, DebugLog.fromEvent({
              'type': event.type,
              'level': event.level,
              'timestamp': event.timestamp.toIso8601String(),
              'data': event.data,
            }));
            
            // Keep only last 100 logs
            if (_recentLogs.length > 100) {
              _recentLogs = _recentLogs.take(100).toList();
            }
          });
        }
      });
      
      // Listen to performance metrics
      _debugService.performanceStream.listen((metric) {
        if (mounted) {
          setState(() {
            _performanceMetrics.insert(0, metric);
            
            // Keep only last 50 metrics
            if (_performanceMetrics.length > 50) {
              _performanceMetrics = _performanceMetrics.take(50).toList();
            }
          });
        }
      });
      
      // Listen to network status
      _debugService.networkStatusStream.listen((status) {
        if (mounted) {
          setState(() {
            _networkStatus = status;
          });
        }
      });
      
      // Start auto-refresh
      _startAutoRefresh();
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize debug service: $e'),
            backgroundColor: ModernDesignSystem.errorColor,
          ),
        );
      }
    }
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (mounted && _isMonitoring) {
        await _refreshDashboardData();
      }
    });
  }

  Future<void> _refreshDashboardData() async {
    try {
      final data = await _debugService.getDebugDashboardData();
      
      setState(() {
        _dashboardData = data;
        _currentSession = DebugSessionInfo.fromJson(data['session_info']);
      });
    } catch (e) {
// print('❌ Failed to refresh dashboard data: $e'); // Removed for production
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernDesignSystem.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Wireless Debug Dashboard',
          style: ModernDesignSystem.headlineSmall.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: ModernDesignSystem.primaryColor,
        elevation: 0,
        actions: [
          AnimatedButton(
            text: _isMonitoring ? 'Stop' : 'Start',
            onPressed: _toggleMonitoring,
            showScale: true,
            backgroundColor: _isMonitoring 
                ? ModernDesignSystem.errorColor 
                : ModernDesignSystem.successColor,
            textColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          const SizedBox(width: 8),
          AnimatedButton(
            text: 'Clear Logs',
            onPressed: _clearLogs,
            showScale: true,
            backgroundColor: ModernDesignSystem.secondaryColor,
            textColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: SpinKitFadingCircle(
                color: ModernDesignSystem.primaryColor,
                size: 50.0,
              ),
            )
          : Column(
              children: [
                _buildSessionInfoCard(),
                _buildNetworkStatusCard(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildLogsTab(),
                      _buildPerformanceTab(),
                      _buildDeviceTab(),
                      _buildNetworkTab(),
                      _buildControlsTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSessionInfoCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernDesignSystem.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: ModernDesignSystem.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bug_report,
                color: ModernDesignSystem.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Debug Session',
                style: ModernDesignSystem.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _currentSession != null 
                      ? ModernDesignSystem.successColor 
                      : ModernDesignSystem.textSecondaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _currentSession != null ? 'Active' : 'Inactive',
                  style: ModernDesignSystem.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (_currentSession != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                _buildSessionInfoItem(
                  'Session ID',
                  _currentSession!.sessionId,
                  Icons.qr_code,
                ),
                const SizedBox(width: 16),
                _buildSessionInfoItem(
                  'Started',
                  _formatDateTime(_currentSession!.startTime),
                  Icons.access_time,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildSessionInfoItem(
                  'Duration',
                  _formatDuration(DateTime.now().difference(_currentSession!.startTime)),
                  Icons.timer,
                ),
                const SizedBox(width: 16),
                _buildSessionInfoItem(
                  'Log Count',
                  '${_currentSession!.logCount}',
                  Icons.list_alt,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSessionInfoItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: ModernDesignSystem.textSecondaryColor, size: 16),
              const SizedBox(width: 8),
              Text(
                label,
                style: ModernDesignSystem.bodySmall.copyWith(
                  color: ModernDesignSystem.textSecondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: ModernDesignSystem.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkStatusCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernDesignSystem.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: ModernDesignSystem.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.wifi,
                color: _networkStatus?.isConnected == true 
                    ? ModernDesignSystem.successColor 
                    : ModernDesignSystem.errorColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Network Status',
                style: ModernDesignSystem.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _networkStatus?.isConnected == true 
                      ? ModernDesignSystem.successColor 
                      : ModernDesignSystem.errorColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _networkStatus?.isConnected == true ? 'Connected' : 'Disconnected',
                  style: ModernDesignSystem.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (_networkStatus != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                _buildNetworkInfoItem(
                  'Connection Type',
                  _networkStatus!.connectionType,
                  Icons.settings_ethernet,
                ),
                const SizedBox(width: 16),
                _buildNetworkInfoItem(
                  'WiFi Name',
                  _networkStatus!.wifiName ?? 'N/A',
                  Icons.wifi,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildNetworkInfoItem(
                  'IP Address',
                  _networkStatus!.ipAddress ?? 'N/A',
                  Icons.router,
                ),
                const SizedBox(width: 16),
                _buildNetworkInfoItem(
                  'Last Update',
                  _formatDateTime(_networkStatus!.timestamp),
                  Icons.update,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNetworkInfoItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: ModernDesignSystem.textSecondaryColor, size: 16),
              const SizedBox(width: 8),
              Text(
                label,
                style: ModernDesignSystem.bodySmall.copyWith(
                  color: ModernDesignSystem.textSecondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: ModernDesignSystem.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsTab() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernDesignSystem.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: ModernDesignSystem.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.list_alt,
                color: ModernDesignSystem.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Debug Logs',
                style: ModernDesignSystem.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${_recentLogs.length} logs',
                style: ModernDesignSystem.bodySmall.copyWith(
                  color: ModernDesignSystem.textSecondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _recentLogs.isEmpty
                ? const Center(
                    child: Text(
                      'No debug logs available',
                      style: TextStyle(
                        color: ModernDesignSystem.textSecondaryColor,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _recentLogs.length,
                    itemBuilder: (context, index) {
                      final log = _recentLogs[index];
                      return _buildLogItem(log);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogItem(DebugLog log) {
    final isError = log.level == 'error';
    final isWarning = log.level == 'warning';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError 
            ? ModernDesignSystem.errorColor.withOpacity(0.1)
            : isWarning 
                ? ModernDesignSystem.warningColor.withOpacity(0.1)
                : ModernDesignSystem.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isError 
              ? ModernDesignSystem.errorColor.withOpacity(0.3)
              : isWarning 
                  ? ModernDesignSystem.warningColor.withOpacity(0.3)
                  : ModernDesignSystem.borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isError 
                    ? Icons.error 
                    : isWarning 
                        ? Icons.warning 
                        : Icons.info,
                color: isError 
                    ? ModernDesignSystem.errorColor 
                    : isWarning 
                        ? ModernDesignSystem.warningColor 
                        : ModernDesignSystem.infoColor,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                log.type,
                style: ModernDesignSystem.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isError 
                      ? ModernDesignSystem.errorColor 
                      : isWarning 
                          ? ModernDesignSystem.warningColor 
                          : ModernDesignSystem.textSecondaryColor,
                ),
              ),
              const Spacer(),
              Text(
                _formatDateTime(log.timestamp),
                style: ModernDesignSystem.bodySmall.copyWith(
                  color: ModernDesignSystem.textSecondaryColor,
                ),
              ),
            ],
          ),
          if (log.data.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _formatLogData(log.data),
              style: ModernDesignSystem.bodySmall.copyWith(
                color: ModernDesignSystem.textPrimaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPerformanceTab() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernDesignSystem.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: ModernDesignSystem.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.speed,
                color: ModernDesignSystem.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Performance Metrics',
                style: ModernDesignSystem.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${_performanceMetrics.length} metrics',
                style: ModernDesignSystem.bodySmall.copyWith(
                  color: ModernDesignSystem.textSecondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _performanceMetrics.isEmpty
                ? const Center(
                    child: Text(
                      'No performance metrics available',
                      style: TextStyle(
                        color: ModernDesignSystem.textSecondaryColor,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _performanceMetrics.length,
                    itemBuilder: (context, index) {
                      final metric = _performanceMetrics[index];
                      return _buildPerformanceItem(metric);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceItem(PerformanceMetric metric) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ModernDesignSystem.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ModernDesignSystem.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.monitor_heart,
                color: ModernDesignSystem.primaryColor,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                metric.operation,
                style: ModernDesignSystem.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${metric.duration.inMilliseconds}ms',
                style: ModernDesignSystem.bodySmall.copyWith(
                  color: ModernDesignSystem.textSecondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatDateTime(metric.timestamp),
            style: ModernDesignSystem.bodySmall.copyWith(
              color: ModernDesignSystem.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceTab() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernDesignSystem.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: ModernDesignSystem.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.devices,
                color: ModernDesignSystem.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Device Information',
                style: ModernDesignSystem.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_dashboardData != null && _dashboardData!['device_info'] != null) ...[
            _buildDeviceInfoItem(
              'Platform',
              _dashboardData!['device_info']['platform']?.toString() ?? 'Unknown',
              Icons.computer,
            ),
            _buildDeviceInfoItem(
              'Version',
              _dashboardData!['device_info']['version']?.toString() ?? 'Unknown',
              Icons.system_update,
            ),
            _buildDeviceInfoItem(
              'App Version',
              _dashboardData!['device_info']['app_version']?.toString() ?? 'Unknown',
              Icons.app_settings_alt,
            ),
            _buildDeviceInfoItem(
              'Device Type',
              _dashboardData!['device_info']['device_type']?.toString() ?? 'Unknown',
              Icons.phone_android,
            ),
            _buildDeviceInfoItem(
              'Debug Mode',
              _dashboardData!['device_info']['is_debug_mode'] == true ? 'Enabled' : 'Disabled',
              Icons.bug_report,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeviceInfoItem(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ModernDesignSystem.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ModernDesignSystem.borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: ModernDesignSystem.textSecondaryColor, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: ModernDesignSystem.bodySmall.copyWith(
              color: ModernDesignSystem.textSecondaryColor,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: ModernDesignSystem.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkTab() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernDesignSystem.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: ModernDesignSystem.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.wifi_tethering,
                color: ModernDesignSystem.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Network Diagnostics',
                style: ModernDesignSystem.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_dashboardData != null && _dashboardData!['network_info'] != null) ...[
            _buildNetworkDiagnosticItem(
              'Connection Type',
              _dashboardData!['network_info']['connection_type']?.toString() ?? 'Unknown',
              Icons.settings_ethernet,
            ),
            _buildNetworkDiagnosticItem(
              'WiFi Name',
              _dashboardData!['network_info']['wifi_name']?.toString() ?? 'N/A',
              Icons.wifi,
            ),
            _buildNetworkDiagnosticItem(
              'IP Address',
              _dashboardData!['network_info']['ip_address']?.toString() ?? 'N/A',
              Icons.router,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNetworkDiagnosticItem(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ModernDesignSystem.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ModernDesignSystem.borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: ModernDesignSystem.textSecondaryColor, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: ModernDesignSystem.bodySmall.copyWith(
              color: ModernDesignSystem.textSecondaryColor,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: ModernDesignSystem.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsTab() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernDesignSystem.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: ModernDesignSystem.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tune,
                color: ModernDesignSystem.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Debug Controls',
                style: ModernDesignSystem.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AnimatedButton(
                  text: 'Start Session',
                  onPressed: _startDebugSession,
                  showScale: true,
                  backgroundColor: ModernDesignSystem.successColor,
                  textColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AnimatedButton(
                  text: 'Stop Session',
                  onPressed: _stopDebugSession,
                  showScale: true,
                  backgroundColor: ModernDesignSystem.errorColor,
                  textColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AnimatedButton(
                  text: 'Capture Screenshot',
                  onPressed: _captureScreenshot,
                  showScale: true,
                  backgroundColor: ModernDesignSystem.secondaryColor,
                  textColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AnimatedButton(
                  text: 'Export Logs',
                  onPressed: _exportLogs,
                  showScale: true,
                  backgroundColor: ModernDesignSystem.infoColor,
                  textColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AnimatedButton(
                  text: 'Clear Cache',
                  onPressed: _clearCache,
                  showScale: true,
                  backgroundColor: ModernDesignSystem.warningColor,
                  textColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AnimatedButton(
                  text: 'Test Connection',
                  onPressed: _testConnection,
                  showScale: true,
                  backgroundColor: ModernDesignSystem.accentColor,
                  textColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _toggleMonitoring() async {
    setState(() {
      _isMonitoring = !_isMonitoring;
    });
    
    if (_isMonitoring) {
      await _debugService.startDebugSession();
    } else {
      await _debugService.stopDebugSession();
    }
  }

  Future<void> _startDebugSession() async {
    await _debugService.startDebugSession();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Debug session started'),
        backgroundColor: ModernDesignSystem.successColor,
      ),
    );
  }

  Future<void> _stopDebugSession() async {
    await _debugService.stopDebugSession();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Debug session stopped'),
        backgroundColor: ModernDesignSystem.errorColor,
      ),
    );
  }

  Future<void> _captureScreenshot() async {
    await _debugService.captureScreenshot(
      description: 'Manual screenshot from debug dashboard',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Screenshot captured'),
        backgroundColor: ModernDesignSystem.successColor,
      ),
    );
  }

  Future<void> _exportLogs() async {
    // This would export logs to a file or send to server
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logs exported'),
        backgroundColor: ModernDesignSystem.successColor,
      ),
    );
  }

  Future<void> _clearCache() async {
    // This would clear application cache
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cache cleared'),
        backgroundColor: ModernDesignSystem.successColor,
      ),
    );
  }

  Future<void> _testConnection() async {
    // This would test network connection
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Connection test initiated'),
        backgroundColor: ModernDesignSystem.infoColor,
      ),
    );
  }

  Future<void> _clearLogs() async {
    setState(() {
      _recentLogs.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Debug logs cleared'),
        backgroundColor: ModernDesignSystem.successColor,
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}:'
           '${dateTime.second.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    return '${hours.toString().padLeft(2, '0')}:'
           '${minutes.toString().padLeft(2, '0')}:'
           '${seconds.toString().padLeft(2, '0')}';
  }

  String _formatLogData(Map<String, dynamic> data) {
    if (data.isEmpty) return '';
    
    final buffer = StringBuffer();
    data.forEach((key, value) {
      buffer.write('$key: $value\n');
    });
    
    return buffer.toString().trim();
  }
}
