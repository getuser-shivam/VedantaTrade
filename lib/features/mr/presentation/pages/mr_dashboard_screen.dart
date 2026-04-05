import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import '../../../shared/theme/modern_design_system.dart';
import '../../../shared/widgets/micro_interactions.dart';
import '../../domain/services/mr_location_service.dart';
import '../../domain/entities/mr_location.dart';

/// Medical Representative Dashboard with Trajectory Visualization
/// Enhanced dashboard showing MR movement patterns, target coverage, and real-time GPS tracking
class MRDashboardScreen extends StatefulWidget {
  const MRDashboardScreen({Key? key}) : super(key: key);

  @override
  _MRDashboardScreenState createState() => _MRDashboardScreenState();
}

class _MRDashboardScreenState extends State<MRDashboardScreen> 
    with TickerProviderStateMixin {
  late MRLocationService _locationService;
  late TabController _tabController;
  late MapController _mapController;
  List<MRLocation> _locations = [];
  List<LatLng> _trajectoryPoints = [];
  List<Marker> _markers = [];
  List<Polyline> _polylines = [];
  bool _isLoading = true;
  bool _isTracking = false;
  String _selectedMrId = '';
  DateTime? _selectedDate;
  Map<String, dynamic> _statistics = {};
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _mapController = MapController();
    _initializeServices();
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _mapController.dispose();
    _refreshTimer?.cancel();
    _locationService.dispose();
    super.dispose();
  }

  Future<void> _initializeServices() async {
    // Initialize location service
    _locationService = MRLocationService(
      // This would be injected via dependency injection
      MRLocationService(/* repository */)
    );
    
    await _locationService.initialize();
    
    // Listen to location stream
    _locationService.locationStream.listen((location) {
      if (mounted) {
        setState(() {
          if (location.isHighAccuracy) {
            _updateTrajectory(location);
          }
        });
      }
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load today's locations
      final today = DateTime.now();
      final locations = await _locationService.getLocationHistory(
        mrId: _selectedMrId.isEmpty ? 'default' : _selectedMrId,
        startDate: DateTime(today.year, today.month, today.day, 0, 0, 0),
        endDate: DateTime(today.year, today.month, today.day, 23, 59, 59),
        limit: 100,
      );
      
      // Calculate trajectory
      final trajectory = await _locationService.calculateDailyTrajectory(
        mrId: _selectedMrId.isEmpty ? 'default' : _selectedMrId,
        date: today,
      );
      
      // Get statistics
      final stats = await _locationService.getLocationStatistics(
        mrId: _selectedMrId.isEmpty ? 'default' : _selectedMrId,
        startDate: DateTime(today.year, today.month, today.day, 0, 0, 0),
        endDate: DateTime(today.year, today.month, today.day, 23, 59, 59),
      );
      
      setState(() {
        _locations = locations;
        _trajectoryPoints = trajectory;
        _statistics = stats;
        _isLoading = false;
      });
      
      _updateMapMarkers();
      _updatePolylines();
      
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load data: $e'),
          backgroundColor: ModernDesignSystem.errorColor,
        ),
      );
    }
  }

  void _updateTrajectory(MRLocation location) {
    if (_trajectoryPoints.length > 100) {
      // Limit trajectory points for performance
      _trajectoryPoints.removeAt(0);
    }
    
    _trajectoryPoints.add(location.toLatLng());
  }

  void _updateMapMarkers() {
    _markers.clear();
    
    // Add current location marker
    if (_locations.isNotEmpty) {
      final currentLocation = _locations.first;
      _markers.add(
        Marker(
          point: currentLocation.toLatLng(),
          width: 40,
          height: 40,
          child: Container(
            decoration: BoxDecoration(
              color: ModernDesignSystem.primaryColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(
              Icons.person_pin_circle,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      );
    }
    
    // Add target locations (Janakpur doctors)
    _addTargetMarkers();
  }

  void _addTargetMarkers() {
    // Janakpur target locations (example coordinates)
    final targetLocations = [
      {'name': 'Janakpur Hospital', 'lat': 26.7146, 'lng': 85.9015},
      {'name': 'Birat Medical College', 'lat': 26.7146, 'lng': 85.9015},
      {'name': 'Mahendra Hospital', 'lat': 26.7146, 'lng': 85.9015},
      {'name': 'Koshi Hospital', 'lat': 26.7146, 'lng': 85.9015},
    ];
    
    for (final target in targetLocations) {
      _markers.add(
        Marker(
          point: LatLng(target['lat'] as double, target['lng'] as double),
          width: 30,
          height: 30,
          child: Container(
            decoration: BoxDecoration(
              color: ModernDesignSystem.secondaryColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(
              Icons.local_hospital,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      );
    }
  }

  void _updatePolylines() {
    _polylines.clear();
    
    if (_trajectoryPoints.length > 1) {
      _polylines.add(
        Polyline(
          points: _trajectoryPoints,
          strokeWidth: 3.0,
          color: ModernDesignSystem.primaryColor,
        ),
      );
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  Future<void> _toggleTracking() async {
    if (_isTracking) {
      await _locationService.stopTracking();
      setState(() => _isTracking = false);
    } else {
      await _locationService.startTracking(
        mrId: _selectedMrId.isEmpty ? 'default' : _selectedMrId,
        highAccuracy: true,
      );
      setState(() => _isTracking = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernDesignSystem.backgroundColor,
      appBar: AppBar(
        title: Text(
          'MR Dashboard',
          style: ModernDesignSystem.headlineSmall.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: ModernDesignSystem.primaryColor,
        elevation: 0,
        actions: [
          AnimatedButton(
            text: _isTracking ? 'Stop Tracking' : 'Start Tracking',
            onPressed: _toggleTracking,
            showScale: true,
            backgroundColor: _isTracking ? ModernDesignSystem.errorColor : ModernDesignSystem.successColor,
            textColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          const SizedBox(width: 8),
          AnimatedButton(
            text: 'Refresh',
            onPressed: _refreshData,
            showScale: true,
            backgroundColor: ModernDesignSystem.secondaryColor,
            textColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: ModernDesignSystem.primaryColor,
              ),
            )
          : Column(
              children: [
                _buildStatisticsCard(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMapTab(),
                      _buildTrajectoryTab(),
                      _buildTargetsTab(),
                      _buildHistoryTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatisticsCard() {
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
          Text(
            'Today\'s Statistics',
            style: ModernDesignSystem.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Locations',
                  _statistics['total_locations']?.toString() ?? '0',
                  Icons.location_on,
                  ModernDesignSystem.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'High Accuracy',
                  _statistics['high_accuracy_locations']?.toString() ?? '0',
                  Icons.gps_fixed,
                  ModernDesignSystem.successColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Avg Accuracy',
                  '${_statistics['average_accuracy'] ?? '0.0'}m',
                  Icons.speed,
                  ModernDesignSystem.warningColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'Coverage',
                  '${_statistics['coverage_percentage']?.toString() ?? '0'}%',
                  Icons.map,
                  ModernDesignSystem.infoColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Janakpur Coverage',
                  _statistics['janakpur_coverage']?.toString() ?? '0',
                  Icons.location_city,
                  ModernDesignSystem.accentColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'Quality',
                  _statistics['tracking_quality']?.toString() ?? 'Poor',
                  Icons.assessment,
                  _getQualityColor(_statistics['tracking_quality']?.toString() ?? 'Poor'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: ModernDesignSystem.bodySmall.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: ModernDesignSystem.headlineSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getQualityColor(String quality) {
    switch (quality.toLowerCase()) {
      case 'excellent':
        return ModernDesignSystem.successColor;
      case 'good':
        return ModernDesignSystem.infoColor;
      case 'fair':
        return ModernDesignSystem.warningColor;
      case 'poor':
        return ModernDesignSystem.errorColor;
      default:
        return ModernDesignSystem.textSecondaryColor;
    }
  }

  Widget _buildMapTab() {
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
          Text(
            'Live GPS Tracking',
            style: ModernDesignSystem.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: LatLng(26.7146, 85.9015), // Janakpur center
                zoom: 12.0,
                maxZoom: 18.0,
                interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                PolylineLayer(
                  polylines: _polylines,
                ),
                MarkerLayer(
                  markers: _markers,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrajectoryTab() {
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
          Text(
            'Daily Trajectory',
            style: ModernDesignSystem.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _trajectoryPoints.isEmpty
                ? const Center(
                    child: Text(
                      'No trajectory data available',
                      style: TextStyle(
                        color: ModernDesignSystem.textSecondaryColor,
                        fontSize: 16,
                      ),
                    ),
                  )
                : SfMaps(
                    initialZoomLevel: 12,
                    initialCenter: LatLng(26.7146, 85.9015),
                    initialMarkers: _trajectoryPoints
                        .map((point) => MapMarker(
                              latitude: point.latitude,
                              longitude: point.longitude,
                              color: ModernDesignSystem.primaryColor,
                              markerIcon: MarkerIcon.circle,
                              iconSize: 8,
                            ))
                        .toList(),
                    initialPolylines: [
                      MapPolyline(
                        points: _trajectoryPoints,
                        color: ModernDesignSystem.primaryColor,
                        width: 3,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetsTab() {
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
          Text(
            'Target Locations (Janakpur)',
            style: ModernDesignSystem.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildTargetItem(
                  'Janakpur Hospital',
                  'Main government hospital',
                  Icons.local_hospital,
                  ModernDesignSystem.primaryColor,
                  26.7146,
                  85.9015,
                ),
                _buildTargetItem(
                  'Birat Medical College',
                  'Teaching hospital',
                  Icons.school,
                  ModernDesignSystem.secondaryColor,
                  26.7146,
                  85.9015,
                ),
                _buildTargetItem(
                  'Mahendra Hospital',
                  'Private hospital',
                  Icons.local_hospital,
                  ModernDesignSystem.accentColor,
                  26.7146,
                  85.9015,
                ),
                _buildTargetItem(
                  'Koshi Hospital',
                  'Regional hospital',
                  Icons.local_hospital,
                  ModernDesignSystem.infoColor,
                  26.7146,
                  85.9015,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetItem(String name, String description, IconData icon, Color color, double lat, double lng) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernDesignSystem.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: ModernDesignSystem.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: ModernDesignSystem.bodySmall.copyWith(
                    color: ModernDesignSystem.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Lat: ${lat.toStringAsFixed(4)}, Lng: ${lng.toStringAsFixed(4)}',
                  style: ModernDesignSystem.bodySmall.copyWith(
                    color: ModernDesignSystem.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
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
          Text(
            'Location History',
            style: ModernDesignSystem.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _locations.isEmpty
                ? const Center(
                    child: Text(
                      'No location history available',
                      style: TextStyle(
                        color: ModernDesignSystem.textSecondaryColor,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _locations.length,
                    itemBuilder: (context, index) {
                      final location = _locations[index];
                      return _buildLocationItem(location);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationItem(MRLocation location) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ModernDesignSystem.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: location.isHighAccuracy 
              ? ModernDesignSystem.successColor.withOpacity(0.3)
              : ModernDesignSystem.warningColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                location.isHighAccuracy ? Icons.gps_fixed : Icons.gps_not_fixed,
                color: location.isHighAccuracy 
                    ? ModernDesignSystem.successColor 
                    : ModernDesignSystem.warningColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.getFormattedLocation(),
                      style: ModernDesignSystem.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Accuracy: ${location.getFormattedAccuracy()}',
                      style: ModernDesignSystem.bodySmall.copyWith(
                        color: ModernDesignSystem.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                location.timestamp.toString().substring(11, 19),
                style: ModernDesignSystem.bodySmall.copyWith(
                  color: ModernDesignSystem.textSecondaryColor,
                ),
              ),
            ],
          ),
          if (location.address != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Address: ${location.address}',
                style: ModernDesignSystem.bodySmall.copyWith(
                  color: ModernDesignSystem.textSecondaryColor,
                ),
              ),
            ),
          if (location.landmark != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Landmark: ${location.landmark}',
                style: ModernDesignSystem.bodySmall.copyWith(
                  color: ModernDesignSystem.textSecondaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
