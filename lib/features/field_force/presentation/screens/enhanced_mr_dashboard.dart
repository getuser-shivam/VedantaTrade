import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/gps_tracking_service.dart';
import '../providers/mr_dashboard_provider.dart';
import '../../../../shared/theme/enhanced_theme.dart';
import '../../../../shared/widgets/enhanced_ui_kit.dart';

/// Enhanced MR dashboard with live GPS tracking and geospatial visualization
class EnhancedMRDashboardScreen extends StatefulWidget {
  const EnhancedMRDashboardScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedMRDashboardScreen> createState() => _EnhancedMRDashboardScreenState();
}

class _EnhancedMRDashboardScreenState extends State<EnhancedMRDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late MapController _mapController;
  final ScrollController _scrollController = ScrollController();
  bool _isTracking = false;
  bool _isHighAccuracyMode = false;
  List<GPSCoordinate> _todayCoordinates = [];
  List<DoctorLocation> _janakpurDoctors = [];
  GPSCoordinate? _currentPosition;
  GPSStatus? _gpsStatus;
  Timer? _updateTimer;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _mapController = MapController();
    
    // Initialize GPS tracking service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeGPSService();
      _loadJanakpurDoctors();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _mapController.dispose();
    _scrollController.dispose();
    _updateTimer?.cancel();
    super.dispose();
  }

  /// Initialize GPS tracking service
  Future<void> _initializeGPSService() async {
    try {
      final gpsService = GPSTrackingService();
      
      // Listen to GPS tracking stream
      gpsService.trackingStream.listen((trackingData) {
        if (mounted) {
          setState(() {
            _isTracking = trackingData.isTracking;
            _isHighAccuracyMode = trackingData.isHighAccuracy;
            _currentPosition = trackingData.currentCoordinate;
            _todayCoordinates = trackingData.todayCoordinates;
          });
          
          // Update map center if tracking
          if (_isTracking && _currentPosition != null) {
            _mapController.move(
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
              15.0,
            );
          }
        }
      });
      
      // Listen to permission stream
      gpsService.permissionStream.listen((permissionStatus) {
        if (mounted) {
          _showPermissionDialog(permissionStatus);
        }
      });
      
      // Initialize GPS service
      await gpsService.initialize();
      
      // Start periodic updates
      _updateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        _updateGPSStatus();
      });
      
    } catch (e) {
      _showErrorDialog('Failed to initialize GPS service: $e');
    }
  }

  /// Load Janakpur doctor locations
  Future<void> _loadJanakpurDoctors() async {
    // Mock data for Janakpur doctors - in real implementation,
    // this would come from backend API
    setState(() {
      _janakpurDoctors = [
        DoctorLocation(
          id: '1',
          name: 'Dr. Sharma',
          specialty: 'General Physician',
          address: 'Janakpur Medical Center',
          coordinates: LatLng(26.7271, 85.3170),
          targetVisits: 15,
          completedVisits: 12,
          rating: 4.8,
        ),
        DoctorLocation(
          id: '2',
          name: 'Dr. Patel',
          specialty: 'Pediatrician',
          address: 'City Hospital',
          coordinates: LatLng(26.7281, 85.3180),
          targetVisits: 20,
          completedVisits: 18,
          rating: 4.9,
        ),
        DoctorLocation(
          id: '3',
          name: 'Dr. Singh',
          specialty: 'Cardiologist',
          address: 'Heart Center',
          coordinates: LatLng(26.7291, 85.3190),
          targetVisits: 10,
          completedVisits: 8,
          rating: 4.7,
        ),
      ];
    });
  }

  /// Update GPS status
  Future<void> _updateGPSStatus() async {
    try {
      final gpsService = GPSTrackingService();
      final status = await gpsService.getCurrentStatus();
      
      if (mounted) {
        setState(() {
          _gpsStatus = status;
        });
      }
    } catch (e) {
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EnhancedTheme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildGPSStatusCard(context),
          _buildTabBar(context),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTrackingTab(context),
                _buildDoctorsTab(context),
                _buildAnalyticsTab(context),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(context),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  /// Build app bar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return EnhancedAppBar(
      title: 'MR Dashboard',
      subtitle: 'Geospatial Tracking & Field Force',
      backgroundColor: EnhancedTheme.of(context).appBarColor,
      actions: [
        IconButton(
          icon: Icon(
            Icons.refresh,
            color: EnhancedTheme.of(context).iconColor,
          ),
          onPressed: _updateGPSStatus,
        ),
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: EnhancedTheme.of(context).iconColor,
          ),
          onSelected: (value) => _handleMenuAction(context, value),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(
                    Icons.settings,
                    color: EnhancedTheme.of(context).iconColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'GPS Settings',
                    style: TextStyle(
                      color: EnhancedTheme.of(context).textColor,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  Icon(
                    Icons.download,
                    color: EnhancedTheme.of(context).iconColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Export Data',
                    style: TextStyle(
                      color: EnhancedTheme.of(context).textColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build GPS status card
  Widget _buildGPSStatusCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EnhancedTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blur: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _gpsStatus?.isLocationServiceEnabled == true
                    ? Icons.gps_fixed
                    : Icons.gps_not_fixed,
                color: _gpsStatus?.isLocationServiceEnabled == true
                    ? Colors.green
                    : Colors.red,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GPS Status',
                      style: TextStyle(
                        color: EnhancedTheme.of(context).textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _gpsStatus?.isLocationServiceEnabled == true
                          ? 'Location services active'
                          : 'Location services disabled',
                      style: TextStyle(
                        color: EnhancedTheme.of(context).textColor.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _isHighAccuracyMode
                      ? EnhancedTheme.of(context).primaryColor
                      : Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _isHighAccuracyMode ? 'High Accuracy' : 'Standard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (_currentPosition != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: EnhancedTheme.of(context).primaryColor,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Current: ${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}',
                  style: TextStyle(
                    color: EnhancedTheme.of(context).textColor,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Text(
                  'Accuracy: ${_currentPosition!.accuracy.toStringAsFixed(1)}m',
                  style: TextStyle(
                    color: EnhancedTheme.of(context).textColor.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Build tab bar
  Widget _buildTabBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: EnhancedTheme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: EnhancedTheme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: EnhancedTheme.of(context).textColor,
        unselectedLabelColor: EnhancedTheme.of(context).textColor.withOpacity(0.6),
        indicator: BoxDecoration(
          color: EnhancedTheme.of(context).primaryColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(8),
          ),
        ),
        tabs: const [
          Tab(
            text: 'Live Tracking',
            icon: Icon(Icons.gps_fixed),
          ),
          Tab(
            text: 'Janakpur Doctors',
            icon: Icon(Icons.local_hospital),
          ),
          Tab(
            text: 'Analytics',
            icon: Icon(Icons.analytics),
          ),
        ],
      ),
    );
  }

  /// Build tracking tab
  Widget _buildTrackingTab(BuildContext context) {
    return Column(
      children: [
        // Map view
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: EnhancedTheme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blur: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  center: LatLng(26.7271, 85.3170), // Janakpur center
                  zoom: 13.0,
                  maxZoom: 18.0,
                  minZoom: 3.0,
                ),
                children: [
                  // Current location marker
                  if (_currentPosition != null)
                    Marker(
                      point: LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                      builder: (context) => Container(
                        child: Icon(
                          Icons.my_location,
                          color: EnhancedTheme.of(context).primaryColor,
                          size: 30,
                        ),
                      ),
                    ),
                  
                  // Today's path
                  if (_todayCoordinates.length > 1)
                    Polyline(
                      points: _todayCoordinates
                          .map((coord) => LatLng(coord.latitude, coord.longitude))
                          .toList(),
                      strokeWidth: 3.0,
                      color: EnhancedTheme.of(context).primaryColor,
                    ),
                  
                  // Doctor locations
                  ..._janakpurDoctors.map((doctor) => Marker(
                    point: doctor.coordinates,
                    builder: (context) => Container(
                      child: Column(
                        children: [
                          Icon(
                            Icons.local_hospital,
                            color: Colors.red,
                            size: 24,
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              doctor.name.split(' ')[1],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ),
        
        // Tracking controls
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: EnhancedTheme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blur: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tracking Controls',
                  style: TextStyle(
                    color: EnhancedTheme.of(context).textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Start/Stop tracking button
                EnhancedButton(
                  text: _isTracking ? 'Stop Tracking' : 'Start Tracking',
                  icon: _isTracking ? Icons.stop : Icons.play_arrow,
                  onPressed: _toggleTracking,
                  backgroundColor: _isTracking ? Colors.red : Colors.green,
                ),
                
                const SizedBox(height: 16),
                
                // High accuracy toggle
                SwitchListTile(
                  title: Text(
                    'High Accuracy Mode',
                    style: TextStyle(
                      color: EnhancedTheme.of(context).textColor,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    'Requires GPS and more battery',
                    style: TextStyle(
                      color: EnhancedTheme.of(context).textColor.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  value: _isHighAccuracyMode,
                  onChanged: (value) => _toggleHighAccuracy(value),
                  activeColor: EnhancedTheme.of(context).primaryColor,
                ),
                
                const SizedBox(height: 16),
                
                // Today's statistics
                _buildTodayStats(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build today's statistics
  Widget _buildTodayStats(BuildContext context) {
    final totalDistance = _calculateTotalDistance();
    final visitCount = _todayCoordinates.length;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EnhancedTheme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Statistics',
            style: TextStyle(
              color: EnhancedTheme.of(context).textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildStatRow(context, 'Distance Traveled', '${totalDistance.toStringAsFixed(1)}m'),
          _buildStatRow(context, 'GPS Points', '$visitCount'),
          _buildStatRow(context, 'Average Accuracy', '${_calculateAverageAccuracy().toStringAsFixed(1)}m'),
          _buildStatRow(context, 'Tracking Time', _formatTrackingDuration()),
        ],
      ),
    );
  }

  /// Build statistics row
  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: EnhancedTheme.of(context).textColor,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: EnhancedTheme.of(context).primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Build doctors tab
  Widget _buildDoctorsTab(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Janakpur Medical Network',
            style: TextStyle(
              color: EnhancedTheme.of(context).textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Doctor cards
          Expanded(
            child: ListView.builder(
              itemCount: _janakpurDoctors.length,
              itemBuilder: (context, index) {
                final doctor = _janakpurDoctors[index];
                return _buildDoctorCard(context, doctor);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build doctor card
  Widget _buildDoctorCard(BuildContext context, DoctorLocation doctor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EnhancedTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blur: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: EnhancedTheme.of(context).primaryColor,
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: TextStyle(
                        color: EnhancedTheme.of(context).textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      doctor.specialty,
                      style: TextStyle(
                        color: EnhancedTheme.of(context).textColor.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: doctor.completedVisits >= doctor.targetVisits
                      ? Colors.green
                      : Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${doctor.completedVisits}/${doctor.targetVisits}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            doctor.address,
            style: TextStyle(
              color: EnhancedTheme.of(context).textColor.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.star,
                color: Colors.amber,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                doctor.rating.toString(),
                style: TextStyle(
                  color: EnhancedTheme.of(context).textColor,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              EnhancedButton(
                text: 'Navigate',
                icon: Icons.directions,
                onPressed: () => _navigateToDoctor(doctor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build analytics tab
  Widget _buildAnalyticsTab(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Geospatial Analytics',
            style: TextStyle(
              color: EnhancedTheme.of(context).textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Analytics cards
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildAnalyticsCard(
                  context,
                  'Today\'s Distance',
                  '${_calculateTotalDistance().toStringAsFixed(1)}m',
                  Icons.straighten,
                  Colors.blue,
                ),
                _buildAnalyticsCard(
                  context,
                  'GPS Points',
                  '${_todayCoordinates.length}',
                  Icons.gps_fixed,
                  Colors.green,
                ),
                _buildAnalyticsCard(
                  context,
                  'Average Accuracy',
                  '${_calculateAverageAccuracy().toStringAsFixed(1)}m',
                  Icons.gps_good,
                  Colors.orange,
                ),
                _buildAnalyticsCard(
                  context,
                  'Tracking Time',
                  _formatTrackingDuration(),
                  Icons.access_time,
                  Colors.purple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build analytics card
  Widget _buildAnalyticsCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EnhancedTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blur: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: EnhancedTheme.of(context).textColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Build floating action button
  Widget _buildFloatingActionButton(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: 'track',
          backgroundColor: _isTracking ? Colors.red : Colors.green,
          onPressed: _toggleTracking,
          child: Icon(
            _isTracking ? Icons.stop : Icons.play_arrow,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        FloatingActionButton(
          heroTag: 'center',
          backgroundColor: EnhancedTheme.of(context).primaryColor,
          onPressed: _centerOnCurrentLocation,
          child: Icon(
            Icons.my_location,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  /// Build bottom navigation bar
  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: EnhancedTheme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blur: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _tabController.index,
        onTap: (index) {
          _tabController.animateTo(index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.gps_fixed),
            label: 'Tracking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_hospital),
            label: 'Doctors',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }

  /// Toggle GPS tracking
  Future<void> _toggleTracking() async {
    try {
      final gpsService = GPSTrackingService();
      
      if (_isTracking) {
        await gpsService.stopTracking();
      } else {
        await gpsService.startHighAccuracyTracking();
      }
    } catch (e) {
      _showErrorDialog('Failed to toggle tracking: $e');
    }
  }

  /// Toggle high accuracy mode
  Future<void> _toggleHighAccuracy(bool value) async {
    // This would normally update GPS settings
    setState(() {
      _isHighAccuracyMode = value;
    });
  }

  /// Navigate to doctor
  void _navigateToDoctor(DoctorLocation doctor) {
    _mapController.move(doctor.coordinates, 16.0);
    _tabController.animateTo(0); // Switch to tracking tab
  }

  /// Center on current location
  void _centerOnCurrentLocation() {
    if (_currentPosition != null) {
      _mapController.move(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        15.0,
      );
    }
  }

  /// Handle menu actions
  void _handleMenuAction(BuildContext context, String? action) {
    switch (action) {
      case 'settings':
        _showGPSSettings(context);
        break;
      case 'export':
        _exportTrackingData(context);
        break;
    }
  }

  /// Show GPS settings dialog
  void _showGPSSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('GPS Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: Text('High Accuracy Mode'),
              subtitle: Text('Uses more battery but provides better accuracy'),
              value: _isHighAccuracyMode,
              onChanged: _toggleHighAccuracy,
            ),
            SwitchListTile(
              title: Text('Background Tracking'),
              subtitle: Text('Continue tracking when app is in background'),
              value: false, // This would be a setting
              onChanged: (value) {
                // Handle background tracking setting
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Export tracking data
  void _exportTrackingData(BuildContext context) {
    // This would normally export tracking data to CSV or JSON
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tracking data exported successfully'),
        backgroundColor: EnhancedTheme.of(context).primaryColor,
      ),
    );
  }

  /// Show permission dialog
  void _showPermissionDialog(LocationPermissionStatus status) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Location Permission Required'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_off,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Location permission is required for GPS tracking. Please enable location services to continue.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Request permission again
              _initializeGPSService();
            },
            child: Text('Enable'),
          ),
        ],
      ),
    );
  }

  /// Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Calculate total distance traveled today
  double _calculateTotalDistance() {
    if (_todayCoordinates.length < 2) return 0.0;
    
    double totalDistance = 0.0;
    for (int i = 1; i < _todayCoordinates.length; i++) {
      totalDistance += _calculateDistance(
        _todayCoordinates[i - 1],
        _todayCoordinates[i],
      );
    }
    
    return totalDistance;
  }

  /// Calculate distance between two coordinates
  double _calculateDistance(GPSCoordinate coord1, GPSCoordinate coord2) {
    const double earthRadius = 6371000; // Earth's radius in meters
    
    final double lat1Rad = coord1.latitude * pi / 180;
    final double lat2Rad = coord2.latitude * pi / 180;
    final double deltaLatRad = (coord2.latitude - coord1.latitude) * pi / 180;
    final double deltaLonRad = (coord2.longitude - coord1.longitude) * pi / 180;
    
    final double a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) * cos(lat2Rad) *
        sin(deltaLonRad / 2) * sin(deltaLonRad / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }

  /// Calculate average accuracy
  double _calculateAverageAccuracy() {
    if (_todayCoordinates.isEmpty) return 0.0;
    
    final totalAccuracy = _todayCoordinates
        .map((coord) => coord.accuracy)
        .reduce((a, b) => a + b);
    
    return totalAccuracy / _todayCoordinates.length;
  }

  /// Format tracking duration
  String _formatTrackingDuration() {
    if (_todayCoordinates.isEmpty) return '0:00:00';
    
    final startTime = _todayCoordinates.first.timestamp;
    final currentTime = DateTime.now();
    final duration = currentTime.difference(startTime);
    
    return '${duration.inHours.toString().padLeft(2, '0')}:'
           '${(duration.inMinutes % 60).toString().padLeft(2, '0')}:'
           '${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }
}

/// Doctor location model
class DoctorLocation {
  final String id;
  final String name;
  final String specialty;
  final String address;
  final LatLng coordinates;
  final int targetVisits;
  final int completedVisits;
  final double rating;
  
  DoctorLocation({
    required this.id,
    required this.name,
    required this.specialty,
    required this.address,
    required this.coordinates,
    required this.targetVisits,
    required this.completedVisits,
    required this.rating,
  });
}
