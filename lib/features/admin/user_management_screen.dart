import 'package:flutter/material.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';
import 'package:vedanta_trade/shared/app_scaffold.dart';
import 'package:vedanta_trade/shared/widgets.dart';
import 'package:provider/provider.dart';
import 'package:vedanta_trade/features/auth/presentation/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:vedanta_trade/core/api_config.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});
  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<dynamic> _users = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _loadUsers(); }

  Future<void> _loadUsers() async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
      final res = await dio.get('${ApiConfig.baseUrl}/users', options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}));
      if (mounted) setState(() { _users = res.data['data'] ?? []; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  static const _navItems = [
    NavItem(label: 'Admin Dashboard', icon: Icons.dashboard_rounded, route: '/admin'),
    NavItem(label: 'Users', icon: Icons.people_rounded, route: '/admin/users'),
    NavItem(label: 'Web Scraper', icon: Icons.travel_explore_rounded, route: '/admin/scraper'),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'User Management',
      roleColor: AppTheme.adminColor,
      navItems: _navItems,
      selectedIndex: 1,
      fab: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppTheme.adminColor,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add User'),
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: AppTheme.adminColor))
        : ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: _users.length,
            itemBuilder: (ctx, i) {
              final u = _users[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  CircleAvatar(radius: 20, backgroundColor: _roleColor(u['role']).withOpacity(0.2), child: Text(u['name'].toString().substring(0, 1), style: TextStyle(color: _roleColor(u['role']), fontWeight: FontWeight.bold))),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text(u['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                      if (!u['isActive']) ...[
                        const SizedBox(width: 8),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppTheme.error.withOpacity(0.2), borderRadius: BorderRadius.circular(4)), child: const Text('INACTIVE', style: TextStyle(color: AppTheme.error, fontSize: 9, fontWeight: FontWeight.bold))),
                      ]
                    ]),
                    Text(u['email'], style: const TextStyle(color: Colors.white54, fontSize: 11)),
                  ])),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: _roleColor(u['role']).withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: _roleColor(u['role']).withOpacity(0.3))),
                    child: Text(u['role']?.toString().replaceAll('_', ' ') ?? '', style: TextStyle(color: _roleColor(u['role']), fontSize: 10, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 16),
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert_rounded, color: Colors.white54, size: 20),
                    color: AppTheme.cardDark,
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit User', style: TextStyle(color: Colors.white))),
                      const PopupMenuItem(value: 'reset', child: Text('Reset Password', style: TextStyle(color: Colors.white))),
                      const PopupMenuItem(value: 'deactivate', child: Text('Deactivate', style: TextStyle(color: AppTheme.error))),
                    ],
                  ),
                ]),
              );
            },
          ),
    );
  }

  Color _roleColor(String? role) {
    switch (role) {
      case 'ADMIN': return AppTheme.adminColor;
      case 'MEDICAL_REP': return AppTheme.mrColor;
      case 'ACCOUNTANT': return AppTheme.accountantColor;
      case 'DOCTOR': return AppTheme.doctorColor;
      case 'STOCKIST': return AppTheme.stockistColor;
      case 'RETAILER': return AppTheme.retailerColor;
      default: return Colors.white;
    }
  }
}
