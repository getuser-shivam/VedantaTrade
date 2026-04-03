import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';
import 'package:vedanta_trade/shared/app_scaffold.dart';
import 'package:vedanta_trade/shared/widgets/glassmorphic_widgets.dart';
import 'package:provider/provider.dart';
import 'package:vedanta_trade/features/auth/presentation/providers/auth_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';

class VisitLogScreen extends StatefulWidget {
  const VisitLogScreen({super.key});
  @override
  State<VisitLogScreen> createState() => _VisitLogScreenState();
}

class _VisitLogScreenState extends State<VisitLogScreen> {
  List<dynamic> _visits = [];
  bool _loading = true;
  List<LatLng> _trajectoryPoints = [];
  bool _isTracking = false;
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _loadVisits();
    _startBackgroundTracking();
  }

  @override
  void dispose() {
    _stopBackgroundTracking();
    super.dispose();
  }

  Future<void> _startBackgroundTracking() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await Geolocator.openLocationSettings();
        if (!serviceEnabled) return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
          return;
        }
      }

      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );

      _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
        (Position position) {
          if (mounted) {
            setState(() {
              _trajectoryPoints.add(LatLng(position.latitude, position.longitude));
              if (_trajectoryPoints.length > 100) {
                _trajectoryPoints.removeAt(0);
              }
            });
          }
        },
        onError: (error) {
          debugPrint('GPS tracking error: $error');
        },
      );

      setState(() => _isTracking = true);
    } catch (e) {
      debugPrint('Failed to start GPS tracking: $e');
    }
  }

  Future<void> _stopBackgroundTracking() async {
    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    if (mounted) setState(() => _isTracking = false);
  }

  Future<Position?> _getCurrentHighAccuracyLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> _loadVisits() async {
    // Mocking for Phase 5 demo
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _visits = [
          {
            'doctor': {'name': 'Dr. Santosh Mahaseth', 'clinicName': 'Janakpur City Hospital', 'specialization': 'Cardiologist'},
            'visitType': 'ROUTINE',
            'visitDate': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
            'notes': 'Discussed new range of hypertension medications. Sample provided.',
            'nextFollowUp': DateTime.now().add(const Duration(days: 14)).toIso8601String(),
            'latitude': 26.7288,
            'longitude': 85.9260,
          },
          {
            'doctor': {'name': 'Dr. Anjali Jha', 'clinicName': 'Jha Poly Clinic', 'specialization': 'Pediatrician'},
            'visitType': 'SAMPLE',
            'visitDate': DateTime.now().subtract(const Duration(days: 1, hours: 4)).toIso8601String(),
            'notes': 'Follow-up on previous sample results. Positive feedback.',
            'latitude': 26.7310,
            'longitude': 85.9220,
          },
        ];
        _loading = false;
      });
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
          ? const Center(child: LoadingAnimation())
          : Column(
              children: [
                // GPS Pulsating Status Bar
                if (_isTracking) const _GpsStatusBar(),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Trajectory Map Section
                        if (_trajectoryPoints.isNotEmpty) ...[
                          const SectionHeader(title: 'Live Field Trajectory'),
                          const SizedBox(height: 12),
                          GlassmorphicCard(
                            height: 220,
                            padding: EdgeInsets.zero,
                            clipBehavior: Clip.hardEdge,
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: _trajectoryPoints.last,
                                initialZoom: 15.0,
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
                                    Marker(
                                      point: _trajectoryPoints.last,
                                      width: 40,
                                      height: 40,
                                      child: Icon(Icons.location_on, color: AppTheme.error, size: 36),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
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

  void _showAddVisitDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _LogVisitModal(
        onSuccess: () => _loadVisits(),
        getCurrentLocation: _getCurrentHighAccuracyLocation,
      ),
    );
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
