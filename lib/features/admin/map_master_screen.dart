import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';
import 'package:vedanta_trade/shared/app_scaffold.dart';
import 'package:vedanta_trade/shared/widgets.dart';

class MapMasterScreen extends StatefulWidget {
  const MapMasterScreen({super.key});
  @override
  State<MapMasterScreen> createState() => _MapMasterScreenState();
}

class _MapMasterScreenState extends State<MapMasterScreen> {
  // Janakpur central coordinates
  final _janakpurCenter = const LatLng(26.7288, 85.9260);
  final _mapController = MapController();
  
  bool _loading = true;
  List<Marker> _markers = [];
  String _filter = 'ALL'; 

  @override
  void initState() {
    super.initState();
    _loadGeospatialData();
  }

  Future<void> _loadGeospatialData() async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
      final res = await dio.get(
        '${ApiConfig.baseUrl}/users/admin/map-data',
        options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}),
      );
      if (res.data['success'] == true) {
        final List<dynamic> data = res.data['data'];
        _buildMarkers(data.map((e) => Map<String, dynamic>.from(e)).toList());
      } else {
        if (mounted) setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }
  
  void _buildMarkers(List<Map<String, dynamic>> rawData) {
    final newMarkers = <Marker>[];
    for (var entity in rawData) {
      if (_filter != 'ALL' && entity['type'] != _filter) continue;
      
      Color markerColor;
      IconData iconData;
      
      switch (entity['type']) {
        case 'DOCTOR': markerColor = AppTheme.primary; iconData = Icons.local_hospital_rounded; break;
        case 'STOCKIST': markerColor = AppTheme.warning; iconData = Icons.store_rounded; break;
        case 'RETAILER': markerColor = AppTheme.secondary; iconData = Icons.shopping_basket_rounded; break;
        case 'MR_VISIT': markerColor = AppTheme.success; iconData = Icons.person_pin_circle_rounded; break;
        default: markerColor = Colors.grey; iconData = Icons.location_on_rounded;
      }

      newMarkers.add(
        Marker(
          point: LatLng(entity['lat'], entity['lng']),
          width: 40, height: 40,
          child: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(entity['name']), backgroundColor: markerColor, duration: const Duration(seconds: 2)
              ));
            },
            child: Icon(iconData, color: markerColor, size: 32),
          ),
        )
      );
    }
    
    if (mounted) {
      setState(() {
        _markers = newMarkers;
        _loading = false;
      });
    }
  }

  static const _navItems = [
    NavItem(label: 'Dashboard', icon: Icons.dashboard_rounded, route: '/admin'),
    NavItem(label: 'Janakpur Map', icon: Icons.map_rounded, route: '/admin/map'),
    NavItem(label: 'Users', icon: Icons.people_rounded, route: '/admin/users'),
    NavItem(label: 'Products', icon: Icons.inventory_2_rounded, route: '/admin/products'),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Janakpur Geospatial Tracker',
      roleColor: AppTheme.adminColor,
      navItems: _navItems,
      selectedIndex: 1,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _janakpurCenter,
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'np.com.vedantatrade.app',
              ),
              MarkerLayer(markers: _markers),
            ],
          ),
          
          // Filter Bar
          Positioned(
            top: 16, left: 16, right: 16,
            child: Container(
              height: 50,
              decoration: BoxDecoration(color: AppTheme.bgDark.withOpacity(0.9), borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.white12)),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  _FilterChip(label: 'All Entities', isSelected: _filter == 'ALL', onSelect: () { setState(() => _filter = 'ALL'); _loadGeospatialData(); }),
                  _FilterChip(label: 'Hospitals/Doctors', isSelected: _filter == 'DOCTOR', color: AppTheme.primary, onSelect: () { setState(() => _filter = 'DOCTOR'); _loadGeospatialData(); }),
                  _FilterChip(label: 'Stockists', isSelected: _filter == 'STOCKIST', color: AppTheme.warning, onSelect: () { setState(() => _filter = 'STOCKIST'); _loadGeospatialData(); }),
                  _FilterChip(label: 'Retailers', isSelected: _filter == 'RETAILER', color: AppTheme.secondary, onSelect: () { setState(() => _filter = 'RETAILER'); _loadGeospatialData(); }),
                  _FilterChip(label: 'MR Live Locations', isSelected: _filter == 'MR_VISIT', color: AppTheme.success, onSelect: () { setState(() => _filter = 'MR_VISIT'); _loadGeospatialData(); }),
                ],
              ),
            ),
          ),
          
          if (_loading)
            const Center(child: CircularProgressIndicator(color: AppTheme.adminColor)),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelect;
  final Color? color;
  
  const _FilterChip({required this.label, required this.isSelected, required this.onSelect, this.color});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
      child: GestureDetector(
        onTap: onSelect,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? (color ?? AppTheme.adminColor).withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? (color ?? AppTheme.adminColor) : Colors.white24)
          ),
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(color: isSelected ? (color ?? AppTheme.adminColor) : Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
