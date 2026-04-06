import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vedanta_trade/features/authentication/presentation/providers/auth_provider.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Color roleColor;
  final List<NavItem> navItems;
  final int selectedIndex;
  final FloatingActionButton? fab;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.roleColor,
    required this.navItems,
    required this.selectedIndex,
    this.actions,
    this.fab,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;
        final auth = context.watch<AuthProvider>();
        
        return Scaffold(
          key: isMobile ? GlobalKey<ScaffoldState>() : null,
          backgroundColor: AppTheme.bgDark,
          drawer: isMobile ? _buildSidebar(context, auth, isMobile: true) : null,
          body: Row(
            children: [
              // Sidebar Navigation (Desktop/Tablet)
              if (!isMobile) _buildSidebar(context, auth),
              
              // Main Content
              Expanded(
                child: Column(
                  children: [
                    // Top bar
                    Container(
                      height: 60,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceDark,
                        border: Border(bottom: BorderSide(color: AppTheme.dividerDark)),
                      ),
                      child: Row(children: [
                        if (isMobile) ...[
                          Builder(
                            builder: (context) => IconButton(
                              icon: const Icon(Icons.menu_rounded, color: Colors.white),
                              onPressed: () => Scaffold.of(context).openDrawer(),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                        const Spacer(),
                        if (actions != null) ...actions!,
                      ]),
                    ),
                    Expanded(child: body),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: fab,
        );
      }
    );
  }

  Widget _buildSidebar(BuildContext context, AuthProvider auth, {bool isMobile = false}) {
    return Container(
      width: isMobile ? 280 : 220,
      color: AppTheme.surfaceDark,
      child: Column(
        children: [
          // Logo
          Container(
            padding: EdgeInsets.only(top: isMobile ? 50 : 20, bottom: 20, left: 20, right: 20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.dividerDark)),
            ),
            child: Row(children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [roleColor, roleColor.withOpacity(0.6)]),
                ),
                child: const Icon(Icons.local_pharmacy_rounded, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('VedantaTrade', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                  Text('Enterprise', style: TextStyle(color: Colors.white38, fontSize: 10)),
                ],
              ),
            ]),
          ),
          // User info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: roleColor.withOpacity(0.2),
                child: Text((auth.userName ?? 'U').substring(0, 1).toUpperCase(), style: TextStyle(color: roleColor, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(auth.userName ?? '', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                Text(_roleLabel(auth.userRole), style: TextStyle(color: roleColor, fontSize: 10, fontWeight: FontWeight.w500)),
              ])),
            ]),
          ),
          const Divider(height: 1),
          // Nav Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              itemCount: navItems.length,
              itemBuilder: (ctx, i) {
                final item = navItems[i];
                final selected = i == selectedIndex;
                return Container(
                  margin: const EdgeInsets.only(bottom: 2),
                  decoration: BoxDecoration(
                    color: selected ? roleColor.withOpacity(0.15) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    dense: true,
                    leading: Icon(item.icon, color: selected ? roleColor : Colors.white38, size: 20),
                    title: Text(item.label, style: TextStyle(color: selected ? roleColor : Colors.white60, fontWeight: selected ? FontWeight.w600 : FontWeight.normal, fontSize: 13)),
                    selected: selected,
                    onTap: () {
                      if (isMobile) Navigator.pop(context);
                      context.go(item.route);
                    },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          // Logout
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.white38, size: 20),
            title: const Text('Sign Out', style: TextStyle(color: Colors.white38, fontSize: 13)),
            onTap: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                if (isMobile) Navigator.pop(context);
                context.go('/login');
              }
            },
          ),
        ],
      ),
    );
  }

  String _roleLabel(String? role) {
    switch (role) {
      case 'ADMIN': return 'Administrator';
      case 'MEDICAL_REP': return 'Medical Representative';
      case 'ACCOUNTANT': return 'Accountant';
      case 'DOCTOR': return 'Doctor';
      case 'STOCKIST': return 'Stockist';
      case 'RETAILER': return 'Retailer';
      default: return 'User';
    }
  }
}

class NavItem {
  final String label;
  final IconData icon;
  final String route;
  const NavItem({required this.label, required this.icon, required this.route});
}
