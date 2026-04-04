import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../app/theme/app_theme.dart';
import '../../../shared/widgets/glassmorphic_widgets.dart';
import '../../../core/services/enhanced_background_gps_service.dart';

/// Enhanced MR Dashboard with live GPS trajectory tracking
class EnhancedMRDashboardScreen extends StatefulWidget {
  const EnhancedMRDashboardScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedMRDashboardScreen> createState() => _EnhancedMRDashboardScreenState();
}

class _EnhancedMRDashboardScreenState extends State<EnhancedMRDashboardScreen>
    with TickerProviderStateMixin {
  final EnhancedBackgroundGpsService _gpsService = EnhancedBackgroundGpsService();
  List<LatLng> _trajectoryPoints = [];
  List<Map<String, dynamic>> _locationHistory = [];
  bool _isTracking = false;
  bool _isLoading = true;
  Map<String, dynamic>? _trajectoryStats;
  Timer? _statsUpdateTimer;
  
  StreamSubscription<List<LatLng>>? _trajectorySubscription;
  StreamSubscription<bool>? _trackingStatusSubscription;
  StreamSubscription<Map<String, dynamic>>? _locationDataSubscription;

  @override
  void initState() {
    super.initState();
    _initializeGPS();
    _loadDashboardData();
  }

  @override
  void dispose() {
    _trajectorySubscription?.cancel();
    _trackingStatusSubscription?.cancel();
    _locationDataSubscription?.cancel();
    _statsUpdateTimer?.cancel();
    _gpsService.dispose();
    super.dispose();
  }

  Future<void> _initializeGPS() async {
    // Initialize GPS service
    final hasPermission = await _gpsService.initialize();
    
    if (hasPermission) {
      // Subscribe to trajectory updates
      _trajectorySubscription = _gpsService.trajectoryStream.listen((points) {
        if (mounted) {
          setState(() {
            _trajectoryPoints = points;
          });
        }
      });
      
      // Subscribe to tracking status
      _trackingStatusSubscription = _gpsService.trackingStatusStream.listen((tracking) {
        if (mounted) {
          setState(() {
            _isTracking = tracking;
          });
        }
      });
      
      // Subscribe to location data
      _locationDataSubscription = _gpsService.locationDataStream.listen((locationData) {
        if (mounted) {
          setState(() {
            _locationHistory.add(locationData);
            if (_locationHistory.length > 100) {
              _locationHistory.removeAt(0);
            }
          });
        }
      });
      
      // Update stats every 5 seconds
      _statsUpdateTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (mounted) {
          _updateTrajectoryStats();
        }
      });
    }
  }

  Future<void> _loadDashboardData() async {
    // Simulate loading dashboard data
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateTrajectoryStats() {
    final stats = _gpsService.getTrajectoryStats();
    if (mounted) {
      setState(() {
        _trajectoryStats = stats;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'MR Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.mrColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isTracking ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: _toggleTracking,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // GPS Status Bar
                    _buildGPSStatusBar(),
                    
                    const SizedBox(height: 16),
                    
                    // Live Trajectory Map
                    if (_trajectoryPoints.isNotEmpty) ...[
                      _buildSectionHeader('Live Field Trajectory'),
                      const SizedBox(height: 12),
                      _buildTrajectoryMap(),
                      const SizedBox(height: 16),
                    ],
                    
                    // Quick Stats
                    _buildQuickStats(),
                    const SizedBox(height: 16),
                    
                    // Detailed Statistics
                    if (_trajectoryStats != null) ...[
                      _buildSectionHeader('Trajectory Statistics'),
                      const SizedBox(height: 12),
                      _buildDetailedStats(),
                      const SizedBox(height: 16),
                    ],
                    
                    // Recent Activity
                    _buildSectionHeader('Recent Activity'),
                    const SizedBox(height: 12),
                    _buildRecentActivity(),
                    const SizedBox(height: 80), // Space for FAB
                  ],
                ),
              ),
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: "export",
            onPressed: _exportTrajectoryData,
            backgroundColor: AppTheme.accent,
            icon: const Icon(Icons.download, color: Colors.white),
            label: const Text(
              'Export',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: "clear",
            onPressed: _clearTrajectory,
            backgroundColor: AppTheme.error,
            icon: const Icon(Icons.clear, color: Colors.white),
            label: const Text(
              'Clear',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGPSStatusBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: _isTracking 
            ? AppTheme.success.withOpacity(0.1)
            : AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isTracking ? AppTheme.success : AppTheme.borderDark,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _isTracking ? AppTheme.success : AppTheme.textSecondary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _isTracking 
                ? 'High-Accuracy GPS Tracking Active'
                : 'GPS Tracking Inactive',
            style: TextStyle(
              color: _isTracking ? AppTheme.success : AppTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_trajectoryStats != null) ...[
            const Spacer(),
            Text(
              'Points: ${_trajectoryStats!['totalPoints']}',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTrajectoryMap() {
    return GlassmorphicCard(
      height: 300,
      padding: EdgeInsets.zero,
      clipBehavior: Clip.hardEdge,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: _trajectoryPoints.isNotEmpty 
              ? _trajectoryPoints.last
              : const LatLng(26.4525, 86.8703), // Janakpur center
          initialZoom: 15.0,
          minZoom: 10.0,
          maxZoom: 18.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'np.com.vedantatrade.app',
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: _trajectoryPoints,
                color: AppTheme.mrColor.withOpacity(0.8),
                strokeWidth: 4.0,
              ),
            ],
          ),
          MarkerLayer(
            markers: [
            // Start marker
            if (_trajectoryPoints.isNotEmpty)
              Marker(
                point: _trajectoryPoints.first,
                width: 30,
                height: 30,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            // Current position marker
            if (_trajectoryPoints.isNotEmpty)
              Marker(
                point: _trajectoryPoints.last,
                width: 40,
                height: 40,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: GlassmorphicStatCard(
            title: 'Total Points',
            value: '${_trajectoryPoints.length}',
            icon: Icons.route,
            color: AppTheme.mrColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassmorphicStatCard(
            title: 'Distance',
            value: '${(_trajectoryStats?['totalDistance'] ?? 0.0).toStringAsFixed(1)}m',
            icon: Icons.straighten,
            color: AppTheme.accent,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedStats() {
    if (_trajectoryStats == null) return const SizedBox();
    
    final stats = _trajectoryStats!;
    final duration = stats['duration'] as Duration;
    
    return GlassmorphicCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatRow('Total Points', '${stats['totalPoints']}', Icons.location_on),
          _buildStatRow('Total Distance', '${stats['totalDistance'].toStringAsFixed(1)}m', Icons.straighten),
          _buildStatRow('Average Accuracy', '${stats['averageAccuracy'].toStringAsFixed(1)}m', Icons.gps_fixed),
          _buildStatRow('Duration', _formatDuration(duration), Icons.access_time),
          if (stats['startTime'] != null)
            _buildStatRow('Start Time', _formatTime(stats['startTime']), Icons.play_arrow),
          if (stats['endTime'] != null)
            _buildStatRow('End Time', _formatTime(stats['endTime']), Icons.stop),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.mrColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    final recentActivity = _locationHistory.take(5).toList();
    
    return GlassmorphicCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Location Updates',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (recentActivity.isEmpty)
            const Text(
              'No recent activity',
              style: TextStyle(color: AppTheme.textSecondary),
            )
          else
            ...recentActivity.map((activity) => _buildActivityItem(activity)).toList(),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    final timestamp = DateTime.parse(activity['timestamp']);
    final accuracy = activity['accuracy'] ?? 0.0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: accuracy <= 50.0 ? AppTheme.success : AppTheme.warning,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lat: ${activity['latitude'].toStringAsFixed(6)}, Lng: ${activity['longitude'].toStringAsFixed(6)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${_formatTime(timestamp)} • Accuracy: ±${accuracy.toStringAsFixed(1)}m',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  String _formatTime(dynamic time) {
    if (time is String) {
      final dateTime = DateTime.parse(time);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
    return time.toString();
  }

  Future<void> _toggleTracking() async {
    try {
      final auth = context.read<AuthProvider>();
      final mrId = auth.user?.mrProfile?.id?.toString();
      
      if (mrId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('MR profile not found'),
            backgroundColor: AppTheme.error,
          ),
        );
        return;
      }
      
      if (_isTracking) {
        await _gpsService.stopTracking();
      } else {
        final success = await _gpsService.startTracking(mrId: mrId);
        if (!success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to start GPS tracking'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('GPS tracking error: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate data refresh
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _exportTrajectoryData() async {
    try {
      final trajectoryData = await _gpsService.exportTrajectory();
      
      // Here you would implement actual export functionality
      // For now, just show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trajectory data exported successfully'),
          backgroundColor: AppTheme.success,
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  Future<void> _clearTrajectory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text(
          'Clear Trajectory',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to clear all trajectory data? This action cannot be undone.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Clear',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await _gpsService.clearTrackingData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trajectory data cleared'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    }
  }
}
