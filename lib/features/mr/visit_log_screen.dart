import 'package:flutter/material.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';
import 'package:vedanta_trade/shared/app_scaffold.dart';
import 'package:vedanta_trade/shared/widgets.dart';
import 'package:provider/provider.dart';
import 'package:vedanta_trade/features/auth/presentation/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:vedanta_trade/core/api_config.dart';
import 'package:geolocator/geolocator.dart';

class VisitLogScreen extends StatefulWidget {
  const VisitLogScreen({super.key});
  @override
  State<VisitLogScreen> createState() => _VisitLogScreenState();
}

class _VisitLogScreenState extends State<VisitLogScreen> {
  List<dynamic> _visits = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _loadVisits(); }

  Future<void> _loadVisits() async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
      final res = await dio.get('${ApiConfig.baseUrl}/mr/visits', options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}));
      if (mounted) setState(() { _visits = res.data['data'] ?? []; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  static const _navItems = [
    NavItem(label: 'MR Dashboard', icon: Icons.dashboard_rounded, route: '/mr'),
    NavItem(label: 'Doctor Visits', icon: Icons.medical_services_rounded, route: '/mr/visits'),
    NavItem(label: 'Tour Plan', icon: Icons.map_rounded, route: '/mr/tour-plan'),
    NavItem(label: 'Expenses', icon: Icons.receipt_long_rounded, route: '/mr/expenses'),
    NavItem(label: 'Doctor List', icon: Icons.health_and_safety_rounded, route: '/doctors-list'),
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
        icon: const Icon(Icons.add_location_alt_rounded),
        label: const Text('Log Visit'),
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: AppTheme.mrColor))
        : Column(children: [
            // Header stats
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(children: [
                Expanded(child: StatCard(title: 'Total Visits', value: '${_visits.length}', icon: Icons.medical_services_rounded, color: AppTheme.mrColor)),
                const SizedBox(width: 16),
                Expanded(child: StatCard(title: 'This Week', value: '${_visits.where((v) { try { return DateTime.parse(v['visitDate'].toString()).isAfter(DateTime.now().subtract(const Duration(days: 7))); } catch (_) { return false; } }).length}', icon: Icons.calendar_month_rounded, color: AppTheme.primary)),
                const SizedBox(width: 16),
                Expanded(child: StatCard(title: 'Pending Follow-ups', value: '${_visits.where((v) => v['nextFollowUp'] != null).length}', icon: Icons.schedule_rounded, color: AppTheme.warning)),
              ]),
            ),
            const Divider(height: 1),
            // Visit List
            Expanded(
              child: _visits.isEmpty
                ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.medical_services_rounded, size: 56, color: AppTheme.mrColor.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    const Text('No visits logged yet', style: TextStyle(color: Colors.white38, fontSize: 16)),
                    const SizedBox(height: 8),
                    const Text('Tap "+ Log Visit" to record your first doctor visit', style: TextStyle(color: Colors.white24, fontSize: 13)),
                  ]))
                : ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: _visits.length,
                    itemBuilder: (ctx, i) {
                      final v = _visits[i];
                      final doctor = v['doctor'];
                      final hasFollowUp = v['nextFollowUp'] != null;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.dividerDark)),
                        child: Column(children: [
                          Row(children: [
                            CircleAvatar(radius: 22, backgroundColor: AppTheme.mrColor.withOpacity(0.15), child: Icon(Icons.person_rounded, color: AppTheme.mrColor, size: 22)),
                            const SizedBox(width: 14),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(doctor?['name'] ?? 'Unknown Doctor', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                              Text('${doctor?['specialization'] ?? ''} • ${doctor?['clinicName'] ?? ''}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                            ])),
                            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: AppTheme.mrColor.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                                child: Text(v['visitType']?.toString().replaceAll('_', ' ') ?? '', style: const TextStyle(color: AppTheme.mrColor, fontSize: 11, fontWeight: FontWeight.w600)),
                              ),
                              const SizedBox(height: 4),
                              Text(v['visitDate']?.toString().substring(0, 10) ?? '', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                            ]),
                          ]),
                          if (v['notes'] != null && (v['notes'] as String).isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(8)),
                              child: Text(v['notes'], style: const TextStyle(color: Colors.white60, fontSize: 12)),
                            ),
                          ],
                          if (hasFollowUp) ...[
                            const SizedBox(height: 10),
                            Row(children: [
                              const Icon(Icons.schedule_rounded, size: 14, color: Colors.orange),
                              const SizedBox(width: 6),
                              Text('Follow-up: ${v['nextFollowUp']?.toString().substring(0, 10)}', style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.w500)),
                            ]),
                          ],
                        ]),
                      );
                    },
                  ),
            ),
          ]),
    );
  }

  void _showAddVisitDialog() async {
    final auth = context.read<AuthProvider>();
    final dio = Dio();
    List<dynamic> doctors = [];
    bool loadingDoctors = true;

    // Pre-fetch doctors
    try {
      final res = await dio.get('${ApiConfig.baseUrl}/doctors', options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}));
      doctors = res.data['data'];
      loadingDoctors = false;
    } catch (_) { loadingDoctors = false; }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          int? selectedDoctorId;
          String visitType = 'ROUTINE';
          final notesController = TextEditingController();
          DateTime? followUpDate;
          bool submittig = false;

          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(color: AppTheme.bgDark, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(children: [
              Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2))),
              const Padding(padding: EdgeInsets.all(16), child: Text('Log Doctor Visit', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    const Text('Select Doctor', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    if (loadingDoctors) const Center(child: CircularProgressIndicator())
                    else if (doctors.isEmpty) const Text('No doctors found', style: TextStyle(color: Colors.white38))
                    else DropdownButtonFormField<int>(
                      dropdownColor: AppTheme.surfaceDark,
                      decoration: AppTheme.inputDecoration('Select a doctor'),
                      items: doctors.map((d) => DropdownMenuItem<int>(value: d['id'], child: Text(d['name']))).toList(),
                      onChanged: (val) => setModalState(() => selectedDoctorId = val),
                    ),
                    const SizedBox(height: 20),
                    const Text('Visit Type', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Row(
                      children: ['ROUTINE', 'FOLLOW_UP', 'STAMPING', 'SAMPLE'].map((t) {
                        final sel = visitType == t;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(t, style: TextStyle(color: sel ? Colors.white : Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
                            selected: sel,
                            onSelected: (v) { if (v) setModalState(() => visitType = t); },
                            backgroundColor: AppTheme.surfaceDark,
                            selectedColor: AppTheme.mrColor,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    const Text('Notes', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: AppTheme.inputDecoration('Mention discussion points...'),
                    ),
                    const SizedBox(height: 20),
                    const Text('Next Follow-up (Optional)', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final d = await showDatePicker(context: context, initialDate: DateTime.now().add(const Duration(days: 7)), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 90)));
                        if (d != null) setModalState(() => followUpDate = d);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: AppTheme.surfaceDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
                        child: Row(children: [
                          Icon(Icons.calendar_today_rounded, size: 18, color: followUpDate != null ? AppTheme.mrColor : Colors.white38),
                          const SizedBox(width: 12),
                          Text(followUpDate == null ? 'Select date' : followUpDate!.toString().substring(0,10), style: TextStyle(color: followUpDate != null ? Colors.white : Colors.white38)),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: submittig || (selectedDoctorId == null) ? null : () async {
                      setModalState(() => submittig = true);
                      try {
                        // Capture GPS Coordinates
                        double? lat;
                        double? lng;
                        
                        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
                        if (serviceEnabled) {
                          LocationPermission permission = await Geolocator.checkPermission();
                          if (permission == LocationPermission.denied) {
                            permission = await Geolocator.requestPermission();
                          }
                          if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
                            Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                            lat = pos.latitude;
                            lng = pos.longitude;
                          }
                        }

                        await dio.post(
                          '${ApiConfig.baseUrl}/mr/visits',
                          data: {
                            'doctorId': selectedDoctorId,
                            'visitType': visitType,
                            'visitDate': DateTime.now().toIso8601String(),
                            'notes': notesController.text,
                            'nextFollowUp': followUpDate?.toIso8601String(),
                            'latitude': lat, 'longitude': lng,
                          },
                          options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}),
                        );
                        if (context.mounted) {
                          Navigator.pop(context);
                          _loadVisits();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Visit logged successfully!'), backgroundColor: AppTheme.success));
                        }
                      } catch (e) {
                        setModalState(() => submittig = false);
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error));
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.mrColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: submittig ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('SUBMIT VISIT', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),
                ),
              ),
            ]),
          );
        }
      ),
    );
  }
}

