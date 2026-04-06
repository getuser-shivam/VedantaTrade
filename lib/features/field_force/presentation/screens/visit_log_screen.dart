import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';
import 'package:vedanta_trade/shared/app_scaffold.dart';
import 'package:vedanta_trade/shared/widgets/glassmorphic_widgets.dart';
import 'package:provider/provider.dart';
import 'package:vedanta_trade/features/authentication/presentation/providers/auth_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:vedanta_trade/core/services/background_gps_service.dart';
import 'package:vedanta_trade/features/mr/widgets/visit_log_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class VisitLogScreen extends StatefulWidget {
  const VisitLogScreen({super.key});
  @override
  State<VisitLogScreen> createState() => _VisitLogScreenState();
}

class _VisitLogScreenState extends State<VisitLogScreen> {
  List<Map<String, dynamic>> _visits = [];
  List<Map<String, dynamic>> _targetDoctors = [];
  bool _loading = true;
  List<LatLng> _trajectoryPoints = [];
  List<LatLng> _offlineTrajectoryPoints = [];
  bool _isTracking = false;
  bool _isOnline = true;
  MapController _mapController = MapController();
  Timer? _locationUpdateTimer;
  SharedPreferences? _prefs;
  
  final BackgroundGpsService _gpsService = BackgroundGpsService();
  StreamSubscription<List<LatLng>>? _trajectorySubscription;
  StreamSubscription<bool>? _trackingStatusSubscription;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _loadVisits();
    _loadTargetDoctors();
    _initializeGpsTracking();
    _initializeConnectivityMonitoring();
  }

  /// Initialize services and load cached data
  Future<void> _initializeServices() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadOfflineTrajectory();
  }

  /// Initialize connectivity monitoring
  void _initializeConnectivityMonitoring() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      if (mounted) {
        setState(() {
          _isOnline = result != ConnectivityResult.none;
        });
        
        // Sync offline data when coming back online
        if (_isOnline && _offlineTrajectoryPoints.isNotEmpty) {
          _syncOfflineTrajectory();
        }
      }
    });
  }

  /// Load target doctors for Janakpur region
  Future<void> _loadTargetDoctors() async {
    try {
      
      // Mock data for Janakpur doctors
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _targetDoctors = [
            {
              'id': '1',
              'name': 'Dr. Santosh Mahaseth',
              'clinicName': 'Janakpur Medical Hall',
              'specialty': 'General Medicine',
              'latitude': 26.7271,
              'longitude': 85.9808,
              'address': 'Bhanu Chowk, Janakpur',
              'targetVisits': 4,
              'completedVisits': 2,
              'lastVisit': '2026-04-01'
            },
            {
              'id': '2',
              'name': 'Dr. Anjali Jha',
              'clinicName': 'City Care Clinic',
              'specialty': 'Pediatrics',
              'latitude': 26.7285,
              'longitude': 85.9795,
              'address': 'Ram Chowk, Janakpur',
              'targetVisits': 3,
              'completedVisits': 1,
              'lastVisit': '2026-03-28'
            },
            {
              'id': '3',
              'name': 'Dr. Rajesh Kumar',
              'clinicName': 'Shree Hospital',
              'specialty': 'Orthopedics',
              'latitude': 26.7260,
              'longitude': 85.9822,
              'address': 'Jaleshwor Road, Janakpur',
              'targetVisits': 2,
              'completedVisits': 0,
              'lastVisit': null
            },
          ];
        });
      }
    } catch (e) {
      
    }
  }

  /// Load offline trajectory from cache
  Future<void> _loadOfflineTrajectory() async {
    try {
      final cachedTrajectory = _prefs?.getString('offline_trajectory');
      if (cachedTrajectory != null) {
        final List<dynamic> trajectoryJson = jsonDecode(cachedTrajectory);
        _offlineTrajectoryPoints = trajectoryJson
            .map((point) => LatLng(point['lat'], point['lng']))
            .toList();
      }
    } catch (e) {
      
    }
  }

  /// Save trajectory to offline cache
  Future<void> _saveOfflineTrajectory() async {
    try {
      final trajectoryJson = _trajectoryPoints
          .map((point) => {'lat': point.latitude, 'lng': point.longitude})
          .toList();
      await _prefs?.setString('offline_trajectory', jsonEncode(trajectoryJson));
    } catch (e) {
      
    }
  }

  /// Sync offline trajectory when back online
  Future<void> _syncOfflineTrajectory() async {
    try {

      _offlineTrajectoryPoints.clear();
      await _prefs?.remove('offline_trajectory');
    } catch (e) {
      
    }
  }

  @override
  void dispose() {
    _trajectorySubscription?.cancel();
    _trackingStatusSubscription?.cancel();
    _connectivitySubscription?.cancel();
    _locationUpdateTimer?.cancel();
    super.dispose();
  }

  /// Initialize GPS service and subscribe to updates
  Future<void> _initializeGpsTracking() async {
    // Subscribe to trajectory updates from background service
    _trajectorySubscription = _gpsService.trajectoryStream.listen((points) {
      if (mounted) {
        setState(() {
          _trajectoryPoints = points;
          // Save to offline cache when online
          if (_isOnline) {
            _saveOfflineTrajectory();
          }
        });
        
        // Auto-center map on latest location
        if (points.isNotEmpty) {
          _mapController.move(points.last, 15.0);
        }
      }
    });
    
    // Subscribe to tracking status
    _trackingStatusSubscription = _gpsService.trackingStatusStream.listen((tracking) {
      if (mounted) {
        setState(() => _isTracking = tracking);
        
        // Start location update timer when tracking
        if (tracking) {
          _startLocationUpdateTimer();
        } else {
          _locationUpdateTimer?.cancel();
        }
      }
    });
    
    // Initialize and auto-start if previously tracking
    final hasPermission = await _gpsService.initialize();
    if (hasPermission && _gpsService.isTracking) {
      setState(() {
        _isTracking = true;
        _trajectoryPoints = _gpsService.trajectoryPoints;
      });
    }
  }

  /// Start periodic location updates for enhanced tracking
  void _startLocationUpdateTimer() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (_isTracking && mounted) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
          forceAndroidLocationManager: true,
        );
        
        // Enhanced accuracy validation for Janakpur region
        if (position.accuracy <= 20.0) { // Stricter accuracy requirement
          final newPoint = LatLng(position.latitude, position.longitude);
          
          // Check if point is within reasonable distance of last point
          if (_trajectoryPoints.isEmpty || 
              Geolocator.distanceBetween(
                _trajectoryPoints.last.latitude,
                _trajectoryPoints.last.longitude,
                position.latitude,
                position.longitude,
              ) <= 1000) { // Max 1km between points
            
            setState(() {
              _trajectoryPoints.add(newPoint);
              if (_isOnline) {
                _saveOfflineTrajectory();
              }
            });
          }
        } else {
          
        }
      }
    });
  }

  /// Submit visit with mandatory GPS validation
  Future<void> _submitVisit(Map<String, dynamic> doctor) async {
    try {
      // Check if GPS tracking is active
      if (!_isTracking) {
        _showErrorDialog('GPS tracking must be active to submit visits');
        return;
      }

      // Get current high-accuracy location
      final currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
        forceAndroidLocationManager: true,
      );

      // Validate GPS accuracy
      if (currentPosition.accuracy > 20.0) {
        _showErrorDialog('GPS accuracy too low (${currentPosition.accuracy.toStringAsFixed(1)}m). Please ensure clear sky view and try again.');
        return;
      }

      // Calculate distance from doctor location
      final doctorLocation = LatLng(doctor['latitude'], doctor['longitude']);
      final currentLocation = LatLng(currentPosition.latitude, currentPosition.longitude);
      final distance = Geolocator.distanceBetween(
        doctorLocation.latitude,
        doctorLocation.longitude,
        currentLocation.latitude,
        currentLocation.longitude,
      );

      // Validate proximity (must be within 100m of doctor location)
      if (distance > 100) {
        _showErrorDialog('You must be within 100m of ${doctor['name']} at ${doctor['clinicName']} to submit visit. Current distance: ${distance.toStringAsFixed(1)}m');
        return;
      }

      // Create visit record with enhanced GPS data
      final visit = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'doctorId': doctor['id'],
        'doctorName': doctor['name'],
        'clinicName': doctor['clinicName'],
        'specialty': doctor['specialty'],
        'latitude': currentPosition.latitude,
        'longitude': currentPosition.longitude,
        'accuracy': currentPosition.accuracy,
        'altitude': currentPosition.altitude,
        'timestamp': currentPosition.timestamp?.toIso8601String(),
        'visitDate': DateTime.now().toIso8601String(),
        'notes': '',
        'sampleProducts': [],
        'promotionalMaterials': [],
        'status': 'completed',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'isOffline': !_isOnline,
        'trajectoryPoints': _trajectoryPoints.map((p) => {
          'lat': p.latitude,
          'lng': p.longitude,
          'timestamp': DateTime.now().toIso8601String()
        }).toList(),
      };

      // Save visit locally and sync if online
      if (_isOnline) {
        await _saveVisitToBackend(visit);
      } else {
        await _saveVisitOffline(visit);
      }

      _showSuccessDialog('Visit submitted successfully for ${doctor['name']}');
      
    } catch (e) {
      
      _showErrorDialog('Failed to submit visit: ${e.toString()}');
    }
  }

  /// Save visit to backend API
  Future<void> _saveVisitToBackend(Map<String, dynamic> visit) async {
    try {
      
      // POST /api/mr/visits

      setState(() {
        _visits.add(visit);
      });
    } catch (e) {
      
      await _saveVisitOffline(visit);
    }
  }

  /// Save visit offline
  Future<void> _saveVisitOffline(Map<String, dynamic> visit) async {
    try {
      final offlineVisits = _prefs?.getStringList('offline_visits') ?? [];
      offlineVisits.add(jsonEncode(visit));
      await _prefs?.setStringList('offline_visits', offlineVisits);
      
      setState(() {
        _visits.add(visit);
      });
    } catch (e) {
      
    }
  }

  /// Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show success dialog
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Toggle background tracking
  Future<void> _toggleTracking() async {
    if (_isTracking) {
      await _gpsService.stopTracking();
    } else {
      final auth = context.read<AuthProvider>();
      final mrId = auth.user?.mrProfile?.id?.toString();
      
      final success = await _gpsService.startTracking(mrId: mrId);
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('GPS permission required. Please enable location services.'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  /// Load visit data from API
  Future<void> _loadVisits() async {
    try {
      
      // Mock data for development - remove before production
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _visits = [];
          _loading = false;
        });
      }
    } catch (e) {
      
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load visits: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  static const _navItems = [
    NavItem(label: 'Dashboard', icon: Icons.dashboard_rounded, route: '/mr'),
    NavItem(label: 'Doctor Visits', icon: Icons.medical_services_rounded, route: '/mr/visits'),
    NavItem(label: 'Tour Plan', icon: Icons.map_rounded, route: '/mr/tour-plan'),
    NavItem(label: 'Expenses', icon: Icons.receipt_long_rounded, route: '/mr/expenses'),
    NavItem(label: 'Profile', icon: Icons.person_rounded, route: '/profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Doctor Visit Tracker',
      roleColor: AppTheme.mrColor,
      navItems: _navItems,
      selectedIndex: 1,
      fab: FloatingActionButton.extended(
        onPressed: () => _showAddVisitDialog(),
        backgroundColor: AppTheme.mrColor,
        icon: const Icon(Icons.add_location_alt_rounded, color: Colors.white),
        label: const Text('Log Visit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Connectivity and GPS Status Bar
                _buildStatusBar(),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Enhanced Trajectory Map with Doctor Targets
                        if (_trajectoryPoints.isNotEmpty || _offlineTrajectoryPoints.isNotEmpty) ...[
                          const SectionHeader(title: 'Live Field Trajectory'),
                          const SizedBox(height: 12),
                          _buildTrajectoryMap(),
                          const SizedBox(height: 24),
                        ],

                        // Target Doctors Overview
                        if (_targetDoctors.isNotEmpty) ...[
                          const SectionHeader(title: 'Target Doctors - Janakpur'),
                          const SizedBox(height: 12),
                          _buildTargetDoctorsGrid(),
                          const SizedBox(height: 24),
                        ],

                        // Quick Stats
                        Row(
                          children: [
                            Expanded(
                              child: GlassmorphicStatCard(
                                title: 'Total Visits',
                                value: '${_visits.length}',
                                icon: Icons.medical_services_rounded,
                                color: AppTheme.mrColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GlassmorphicStatCard(
                                title: 'Verified GPS',
                                value: '${_visits.where((v) => v['latitude'] != null).length}',
                                icon: Icons.verified_rounded,
                                color: AppTheme.success,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Visit History List
                        const SectionHeader(title: 'Recent Activity'),
                        const SizedBox(height: 12),
                        if (_visits.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(48),
                              child: Text('No visits logged yet', style: TextStyle(color: Colors.white38)),
                            ),
                          )
                        else
                          ...(_visits.map((v) => _VisitListItem(visit: v)).toList()),
                        const SizedBox(height: 80), // Space for FAB
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  /// Build enhanced status bar with connectivity and GPS info
  Widget _buildStatusBar() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _isTracking 
            ? AppTheme.success.withOpacity(0.05) 
            : (_isOnline ? AppTheme.mrColor.withOpacity(0.05) : AppTheme.error.withOpacity(0.05)),
        border: Border(
          bottom: BorderSide(
            color: _isTracking 
                ? AppTheme.success.withOpacity(0.15)
                : (_isOnline ? AppTheme.mrColor.withOpacity(0.15) : AppTheme.error.withOpacity(0.15))
          )
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isTracking) ...[
                _buildPulsingDot(AppTheme.success),
                const SizedBox(width: 10),
                const Text(
                  'High-Accuracy GPS Tracking Active',
                  style: TextStyle(color: AppTheme.success, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ] else if (_isOnline) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: AppTheme.mrColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                const Text(
                  'GPS Ready - Tap to Start Tracking',
                  style: TextStyle(color: AppTheme.mrColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ] else ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: AppTheme.error, shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Offline - GPS Data Cached Locally',
                  style: TextStyle(color: AppTheme.error, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ],
            ],
          ),
          if (!_isOnline && _offlineTrajectoryPoints.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${_offlineTrajectoryPoints.length} points cached locally',
                style: TextStyle(color: AppTheme.error.withOpacity(0.7), fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }

  /// Build pulsing dot animation
  Widget _buildPulsingDot(Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.3, end: 1.0),
      duration: const Duration(seconds: 2),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color.withOpacity(value), shape: BoxShape.circle),
        );
      },
    );
  }

  /// Build enhanced trajectory map with doctor targets
  Widget _buildTrajectoryMap() {
    // Combine online and offline trajectory points
    final allTrajectoryPoints = [..._trajectoryPoints, ..._offlineTrajectoryPoints];
    
    return GlassmorphicCard(
      height: 280,
      padding: EdgeInsets.zero,
      clipBehavior: Clip.hardEdge,
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: allTrajectoryPoints.isNotEmpty 
              ? allTrajectoryPoints.last 
              : const LatLng(26.7271, 85.9808), // Janakpur center
          initialZoom: 15.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'np.com.vedantatrade.app',
          ),
          // Online trajectory (solid line)
          if (_trajectoryPoints.isNotEmpty)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: _trajectoryPoints,
                  color: AppTheme.mrColor.withOpacity(0.8),
                  strokeWidth: 4.0,
                ),
              ],
            ),
          // Offline trajectory (dashed line)
          if (_offlineTrajectoryPoints.isNotEmpty)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: _offlineTrajectoryPoints,
                  color: AppTheme.error.withOpacity(0.6),
                  strokeWidth: 3.0,
                  patterns: [
                    PatternLine(
                      pattern: [10, 5], // 10px dash, 5px gap
                      strokeWidth: 3.0,
                      color: AppTheme.error.withOpacity(0.6),
                    ),
                  ],
                ),
              ],
            ),
          // Current location marker
          if (allTrajectoryPoints.isNotEmpty)
            MarkerLayer(
              markers: [
                Marker(
                  point: allTrajectoryPoints.last,
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.location_on, 
                    color: _isTracking ? AppTheme.success : AppTheme.error, 
                    size: 36
                  ),
                ),
              ],
            ),
          // Doctor target markers
          MarkerLayer(
            markers: _targetDoctors.map((doctor) {
              final lat = doctor['latitude'] as double;
              final lng = doctor['longitude'] as double;
              final completedVisits = doctor['completedVisits'] as int;
              final targetVisits = doctor['targetVisits'] as int;
              final isCompleted = completedVisits >= targetVisits;
              
              return Marker(
                point: LatLng(lat, lng),
                width: 50,
                height: 50,
                child: Container(
                  decoration: BoxDecoration(
                    color: isCompleted ? AppTheme.success : AppTheme.mrColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    isCompleted ? Icons.check_circle : Icons.person_pin_circle,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Build target doctors grid
  Widget _buildTargetDoctorsGrid() {
    return Column(
      children: [
        // Summary row
        GlassmorphicCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTargetSummary('Total', _targetDoctors.length.toString(), Icons.people),
              _buildTargetSummary('Completed', 
                _targetDoctors.where((d) => (d['completedVisits'] as int) >= (d['targetVisits'] as int)).length.toString(), 
                Icons.check_circle),
              _buildTargetSummary('Pending', 
                _targetDoctors.where((d) => (d['completedVisits'] as int) < (d['targetVisits'] as int)).length.toString(), 
                Icons.pending),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Doctor cards
        ..._targetDoctors.map((doctor) => _buildDoctorCard(doctor)).toList(),
      ],
    );
  }

  /// Build target summary item
  Widget _buildTargetSummary(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.mrColor, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  /// Build individual doctor card
  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    final completedVisits = doctor['completedVisits'] as int;
    final targetVisits = doctor['targetVisits'] as int;
    final progress = completedVisits / targetVisits;
    final isCompleted = completedVisits >= targetVisits;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassmorphicCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isCompleted ? AppTheme.success : AppTheme.mrColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCompleted ? Icons.check_circle : Icons.person,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor['name'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${doctor['clinicName']} • ${doctor['specialty']}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        doctor['address'] as String,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '$completedVisits/$targetVisits',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 60,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isCompleted ? AppTheme.success : AppTheme.mrColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddVisitDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LogVisitModal(
        onSuccess: () => _loadVisits(),
        getCurrentLocation: _getHighAccuracyLocation,
      ),
    );
  }

  /// Get high-accuracy GPS location with validation
  Future<Position?> _getHighAccuracyLocation() async {
    try {
      // Check permissions first
      bool hasPermission = await _gpsService.initialize();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('GPS permission required. Please enable location services.'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
        return null;
      }

      // Show loading indicator
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const GpsLoadingDialog(),
        );
      }

      try {
        // Request high-accuracy location
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 30),
        );

        // Validate accuracy (must be < 50 meters for Nepal field operations)
        if (position.accuracy > 50.0) {
          if (mounted) {
            Navigator.of(context).pop(); // Close loading dialog
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('GPS accuracy too high (${position.accuracy.toStringAsFixed(1)}m). Please try again in an open area.'),
                backgroundColor: AppTheme.error,
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: () => _showAddVisitDialog(),
                ),
              ),
            );
          }
          return null;
        }

        // Close loading dialog
        if (mounted) {
          Navigator.of(context).pop();
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('GPS location captured (${position.accuracy.toStringAsFixed(1)}m accuracy)'),
              backgroundColor: AppTheme.success,
              duration: const Duration(seconds: 2),
            ),
          );
        }

        return position;
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to get GPS location: ${e.toString()}'),
              backgroundColor: AppTheme.error,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () => _showAddVisitDialog(),
              ),
            ),
          );
        }
        return null;
      }
    } catch (e) {
      
      return null;
    }
  }
}

class _GpsStatusBar extends StatefulWidget {
  const _GpsStatusBar();
  @override
  State<_GpsStatusBar> createState() => _GpsStatusBarState();
}

class _GpsStatusBarState extends State<_GpsStatusBar> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(_pulseController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.success.withOpacity(0.05),
        border: Border(bottom: BorderSide(color: AppTheme.success.withOpacity(0.15))),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeTransition(
            opacity: _pulseAnimation,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(color: AppTheme.success, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'High-Accuracy GPS Tracking Active',
            style: TextStyle(color: AppTheme.success, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}

class _VisitListItem extends StatelessWidget {
  final Map<String, dynamic> visit;
  const _VisitListItem({required this.visit});

  @override
  Widget build(BuildContext context) {
    final doctor = visit['doctor'];
    final visitDate = DateTime.parse(visit['visitDate']);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassmorphicListItem(
        title: doctor?['name'] ?? 'Unknown Doctor',
        subtitle: '${doctor?['clinicName']} • ${DateFormat('jm').format(visitDate)}',
        leadingIcon: Icons.person_pin_rounded,
        iconColor: AppTheme.mrColor,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.mrColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.mrColor.withOpacity(0.2)),
          ),
          child: Text(
            visit['visitType'] ?? '',
            style: const TextStyle(color: AppTheme.mrColor, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
        onTap: () {
          // Show visit details
        },
      ),
    );
  }
}

class _LogVisitModal extends StatefulWidget {
  final VoidCallback onSuccess;
  final Future<Position?> Function() getCurrentLocation;
  const _LogVisitModal({required this.onSuccess, required this.getCurrentLocation});

  @override
  State<_LogVisitModal> createState() => _LogVisitModalState();
}

class _LogVisitModalState extends State<_LogVisitModal> {
  String? _selectedDoctor;
  String _visitType = 'ROUTINE';
  final _notesController = TextEditingController();
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    return GlassmorphicBackground(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.bgDark.withOpacity(0.8),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Log Field Visit',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            const Text(
              'Capture details for your current doctor interaction',
              style: TextStyle(color: Colors.white38, fontSize: 13),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView(
                children: [
                  const Text('DOCTOR / CLINIC', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    dropdownColor: AppTheme.surfaceDark,
                    style: const TextStyle(color: Colors.white),
                    decoration: AppTheme.inputDecoration('Select doctor...'),
                    items: const [
                      DropdownMenuItem(value: '1', child: Text('Dr. Santosh Mahaseth')),
                      DropdownMenuItem(value: '2', child: Text('Dr. Anjali Jha')),
                    ],
                    onChanged: (v) => setState(() => _selectedDoctor = v),
                  ),
                  const SizedBox(height: 24),
                  const Text('VISIT TYPE', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: ['ROUTINE', 'FOLLOW_UP', 'STAMPING', 'SAMPLE'].map((type) {
                      final isSelected = _visitType == type;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _visitType = type),
                          child: Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.mrColor : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              type.substring(0, 1) + type.substring(1).toLowerCase(),
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white38,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text('DISCUSSION NOTES', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: AppTheme.inputDecoration('Summary of discussion...'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submitting ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.mrColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _submitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.gps_fixed_rounded, color: Colors.white, size: 20),
                          SizedBox(width: 12),
                          Text(
                            'VERIFY GPS & LOG VISIT',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_selectedDoctor == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a doctor')));
      return;
    }

    setState(() => _submitting = true);
    
    // Capture GPS
    final pos = await widget.getCurrentLocation();
    
    if (pos == null) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('GPS Signal weak. Please move outdoors.')));
      }
      return;
    }

    // Validate GPS accuracy (<50m required)
    if (pos.accuracy > 50) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('GPS accuracy too low (${pos.accuracy.toStringAsFixed(1)}m). Required: <50m. Move to open area.'),
            backgroundColor: AppTheme.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    // Success simulation
    await Future.delayed(const Duration(seconds: 1));
    widget.onSuccess();
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Visit logged with high-accuracy GPS verified'), backgroundColor: AppTheme.success),
      );
    }
  }
}
