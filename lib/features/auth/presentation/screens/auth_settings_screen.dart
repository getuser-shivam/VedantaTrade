import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/glassmorphic_widgets.dart';
import '../providers/auth_provider.dart';
import '../../../app/theme/app_theme.dart';

class AuthSettingsScreen extends StatefulWidget {
  const AuthSettingsScreen({Key? key}) : super(key: key);

  @override
  State<AuthSettingsScreen> createState() => _AuthSettingsScreenState();
}

class _AuthSettingsScreenState extends State<AuthSettingsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          'Authentication Settings',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeController,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Security Status Card
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return GlassmorphicCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.security,
                                color: Color(0xFF4F46E5),
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Security Status',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildSecurityStatus(authProvider),
                        ],
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Authentication Methods
                GlassmorphicCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Authentication Methods',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildAuthMethods(context),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Session Settings
                GlassmorphicCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Session Settings',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSessionSettings(context),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Security Actions
                GlassmorphicCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Security Actions',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSecurityActions(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityStatus(AuthProvider authProvider) {
    return Column(
      children: [
        _buildStatusRow(
          'Biometric Authentication',
          authProvider.biometricEnabled,
          Icons.fingerprint,
          () => _toggleBiometric(authProvider),
        ),
        const SizedBox(height: 12),
        _buildStatusRow(
          'Two-Factor Authentication',
          false, // TODO: Implement 2FA
          Icons.security,
          () => _showComingSoon('Two-Factor Authentication'),
        ),
        const SizedBox(height: 12),
        _buildStatusRow(
          'Session Timeout',
          authProvider.isSessionExpired,
          Icons.timer,
          () => _showComingSoon('Session Management'),
        ),
      ],
    );
  }

  Widget _buildStatusRow(String title, bool enabled, IconData icon, VoidCallback onTap) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: enabled ? const Color(0xFF10B981).withOpacity(0.1) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: enabled ? const Color(0xFF10B981) : Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Icon(
              icon,
              color: enabled ? const Color(0xFF10B981) : Colors.white54,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: enabled ? Colors.white : Colors.white54,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Switch(
              value: enabled,
              onChanged: (value) => onTap(),
              activeColor: const Color(0xFF10B981),
              activeTrackColor: const Color(0xFF10B981).withOpacity(0.3),
              inactiveThumbColor: Colors.white.withOpacity(0.5),
              inactiveTrackColor: Colors.white.withOpacity(0.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthMethods(BuildContext context) {
    return Column(
      children: [
        _buildAuthMethod(
          'Biometric Login',
          'Use fingerprint or face recognition',
          Icons.fingerprint,
          Colors.green,
          () => Navigator.of(context).pushNamed('/biometric-auth'),
        ),
        const SizedBox(height: 12),
        _buildAuthMethod(
          'Secure PIN Login',
          'Use 4-digit PIN for quick access',
          Icons.pin,
          Colors.blue,
          () => Navigator.of(context).pushNamed('/secure-auth'),
        ),
        const SizedBox(height: 12),
        _buildAuthMethod(
          'Password Login',
          'Traditional email and password',
          Icons.lock,
          Colors.orange,
          () => Navigator.of(context).pushNamed('/auth'),
        ),
      ],
    );
  }

  Widget _buildAuthMethod(String title, String description, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionSettings(BuildContext context) {
    return Column(
      children: [
        _buildSettingRow(
          'Auto-Lock Timeout',
          '15 minutes',
          Icons.timer,
          () => _showComingSoon('Auto-Lock Settings'),
        ),
        const SizedBox(height: 12),
        _buildSettingRow(
          'Remember Login',
          'Enabled',
          Icons.save,
          () => _showComingSoon('Login Preferences'),
        ),
        const SizedBox(height: 12),
        _buildSettingRow(
          'Logout on Inactivity',
          '30 minutes',
          Icons.logout,
          () => _showComingSoon('Inactivity Settings'),
        ),
      ],
    );
  }

  Widget _buildSettingRow(String title, String value, IconData icon, VoidCallback onTap) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white54,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityActions(BuildContext context) {
    return Column(
      children: [
        _buildActionRow(
          'Change Password',
          'Update your account password',
          Icons.lock,
          Colors.orange,
          () => _showComingSoon('Password Change'),
        ),
        const SizedBox(height: 12),
        _buildActionRow(
          'Clear Biometric Data',
          'Remove stored biometric data',
          Icons.fingerprint,
          Colors.red,
          () => _showComingSoon('Biometric Data Clear'),
        ),
        const SizedBox(height: 12),
        _buildActionRow(
          'View Login History',
          'Check recent login attempts',
          Icons.history,
          Colors.blue,
          () => _showComingSoon('Login History'),
        ),
      ],
    );
  }

  Widget _buildActionRow(String title, String description, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleBiometric(AuthProvider authProvider) {
    // Toggle biometric authentication
    authProvider.toggleBiometric();
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        backgroundColor: const Color(0xFF4F46E5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
