import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';
import 'package:vedanta_trade/shared/app_scaffold.dart';
import 'package:vedanta_trade/shared/widgets/glassmorphic_widgets.dart';

class TourPlanScreen extends StatefulWidget {
  const TourPlanScreen({super.key});

  @override
  State<TourPlanScreen> createState() => _TourPlanScreenState();
}

class _TourPlanScreenState extends State<TourPlanScreen> {
  DateTime _selectedDate = DateTime.now();
  final List<DateTime> _weekDays = List.generate(14, (i) => DateTime.now().add(Duration(days: i)));
  
  final List<Map<String, dynamic>> _plannedVisits = [
    {
      'time': '10:00 AM',
      'doctor': 'Dr. Satosh Mahaseth',
      'clinic': 'Janakpur City Hospital',
      'location': const LatLng(26.7288, 85.9260),
      'status': 'PLANNED',
    },
    {
      'time': '12:30 PM',
      'doctor': 'Dr. Anjali Jha',
      'clinic': 'Jha Poly Clinic',
      'location': const LatLng(26.7310, 85.9220),
      'status': 'PLANNED',
    },
    {
      'time': '03:15 PM',
      'doctor': 'Dr. Bibek Mandal',
      'clinic': 'Mandal Pharma Care',
      'location': const LatLng(26.7250, 85.9310),
      'status': 'PLANNED',
    },
  ];

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
      title: 'Field Tour Plan',
      roleColor: AppTheme.mrColor,
      navItems: _navItems,
      selectedIndex: 2,
      body: Column(
        children: [
          // Date Selector Strip
          _buildDateSelector(),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Territory Map with Route
                  const SectionHeader(title: 'Route Overview'),
                  const SizedBox(height: 12),
                  GlassmorphicCard(
                    height: 250,
                    padding: EdgeInsets.zero,
                    clipBehavior: Clip.hardEdge,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: _plannedVisits.first['location'],
                        initialZoom: 14.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'np.com.vedantatrade.app',
                        ),
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: _plannedVisits.map((v) => v['location'] as LatLng).toList(),
                              color: AppTheme.mrColor.withOpacity(0.5),
                              strokeWidth: 3.0,
                              isDotted: true,
                            ),
                          ],
                        ),
                        MarkerLayer(
                          markers: _plannedVisits.asMap().entries.map((entry) {
                            final i = entry.key;
                            final v = entry.value;
                            return Marker(
                              point: v['location'],
                              width: 30,
                              height: 30,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.mrColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                                ),
                                child: Center(
                                  child: Text(
                                    '${i + 1}',
                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Planned Visits List
                  Row(
                    children: [
                      SectionHeader(title: 'Planned Stops (${_plannedVisits.length})'),
                      const Spacer(),
                      Text(
                        DateFormat('EEEE, d MMM').format(_selectedDate),
                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...(_plannedVisits.asMap().entries.map((entry) {
                    final i = entry.key;
                    final v = entry.value;
                    return _PlannedVisitCard(index: i + 1, visit: v);
                  }).toList()),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withOpacity(0.3),
        border: Border(bottom: BorderSide(color: AppTheme.dividerDark)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _weekDays.length,
        itemBuilder: (context, i) {
          final date = _weekDays[i];
          final isSelected = date.day == _selectedDate.day && date.month == _selectedDate.month;
          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 55,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(colors: [AppTheme.mrColor, AppTheme.mrColor.withOpacity(0.6)])
                    : null,
                color: isSelected ? null : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: isSelected ? null : Border.all(color: Colors.white10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date).toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? Colors.white70 : Colors.white38,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PlannedVisitCard extends StatelessWidget {
  final int index;
  final Map<String, dynamic> visit;
  const _PlannedVisitCard({required this.index, required this.visit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassmorphicCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Time and Index
            Column(
              children: [
                Text(
                  visit['time'],
                  style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppTheme.mrColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: const TextStyle(color: AppTheme.mrColor, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            const Container(width: 1, height: 40, color: Colors.white10),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    visit['doctor'],
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    visit['clinic'],
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
            // Action
            IconButton(
              icon: const Icon(Icons.directions_rounded, color: AppTheme.mrColor, size: 24),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.play_circle_fill_rounded, color: AppTheme.success, size: 32),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
