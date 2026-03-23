import 'package:flutter/material.dart';

import '../../../../app/neutralitical_brand.dart';
import '../../domain/models/business_role.dart';
import '../controllers/auth_controller.dart';

enum _AuthMode { signIn, register }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.authController});

  final AuthController authController;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  _AuthMode _mode = _AuthMode.signIn;
  BusinessRole _selectedRole = BusinessRole.medicalRepresentative;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    final success = switch (_mode) {
      _AuthMode.signIn => widget.authController.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      ),
      _AuthMode.register => widget.authController.register(
        fullName: _fullNameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        role: _selectedRole,
      ),
    };

    await success;
  }

  void _toggleMode(_AuthMode mode) {
    if (_mode == mode) {
      return;
    }

    setState(() {
      _mode = mode;
      _confirmPasswordController.clear();
    });
    widget.authController.clearStatus();
  }

  void _applyDemo(_DemoAccount account) {
    setState(() {
      _mode = _AuthMode.signIn;
      _emailController.text = account.email;
      _passwordController.text = account.password;
      _selectedRole = account.role;
      _obscurePassword = false;
    });
    widget.authController.clearStatus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: widget.authController,
      builder: (context, child) {
        return Scaffold(
          body: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: NeutraliticalBrand.shellGradient,
            ),
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1240),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= 980;

                        final formCard = _AuthFormCard(
                          formKey: _formKey,
                          mode: _mode,
                          selectedRole: _selectedRole,
                          fullNameController: _fullNameController,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          confirmPasswordController: _confirmPasswordController,
                          obscurePassword: _obscurePassword,
                          obscureConfirmPassword: _obscureConfirmPassword,
                          isSubmitting: widget.authController.isSubmitting,
                          statusMessage: widget.authController.statusMessage,
                          onModeChanged: _toggleMode,
                          onRoleChanged: (role) {
                            setState(() => _selectedRole = role);
                          },
                          onTogglePasswordVisibility: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          onToggleConfirmPasswordVisibility: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                          onChanged: widget.authController.clearStatus,
                          onSubmit: _submit,
                        );

                        final roleDeck = _RoleAccessDeck(
                          onApplyDemo: _applyDemo,
                        );

                        if (isWide) {
                          return SingleChildScrollView(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      _AuthBrandPanel(theme: theme),
                                      const SizedBox(height: 16),
                                      roleDeck,
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 20),
                                SizedBox(width: 460, child: formCard),
                              ],
                            ),
                          );
                        }

                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              _AuthBrandPanel(theme: theme, compact: true),
                              const SizedBox(height: 16),
                              roleDeck,
                              const SizedBox(height: 16),
                              formCard,
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AuthBrandPanel extends StatelessWidget {
  const _AuthBrandPanel({required this.theme, this.compact = false});

  final ThemeData theme;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 24 : 32),
      decoration: BoxDecoration(
        gradient: NeutraliticalBrand.heroGradient,
        borderRadius: BorderRadius.circular(34),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 30,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  NeutraliticalBrand.markAsset,
                  width: compact ? 58 : 70,
                  height: compact ? 58 : 70,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Secure access',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 18 : 24),
          Text(
            'Neutralitical Control Tower',
            style: theme.textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              height: 0.98,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'One workspace for admin operations, field-force execution, accounting, audit, doctors, stockists, retailers, and hospitals.',
            style: theme.textTheme.titleMedium?.copyWith(
              color: const Color(0xFFE8DDD0),
              height: 1.5,
            ),
          ),
          SizedBox(height: compact ? 22 : 28),
          const _SecurityPoint(
            title: 'Role-specific workspaces',
            body:
                'Each user lands in a tailored dashboard with only the modules that matter to that role.',
          ),
          const SizedBox(height: 14),
          const _SecurityPoint(
            title: 'Commercial + medical flow',
            body:
                'The same system can track doctor calls, stock flow, collections, audit, and reporting.',
          ),
          const SizedBox(height: 14),
          const _SecurityPoint(
            title: 'Data review first',
            body:
                'Imported or scraped leads should always flow through validation before they become master data.',
          ),
        ],
      ),
    );
  }
}

class _RoleAccessDeck extends StatelessWidget {
  const _RoleAccessDeck({required this.onApplyDemo});

  final ValueChanged<_DemoAccount> onApplyDemo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: NeutraliticalBrand.sand),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Demo role access',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: NeutraliticalBrand.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Use the seeded accounts below to explore each persona immediately. Default password for all demo roles: `Neutral@2026`.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF62615C),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _demoAccounts
                .map(
                  (account) => _DemoRoleCard(
                    account: account,
                    onTap: () => onApplyDemo(account),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _AuthFormCard extends StatelessWidget {
  const _AuthFormCard({
    required this.formKey,
    required this.mode,
    required this.selectedRole,
    required this.fullNameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.isSubmitting,
    required this.statusMessage,
    required this.onModeChanged,
    required this.onRoleChanged,
    required this.onTogglePasswordVisibility,
    required this.onToggleConfirmPasswordVisibility,
    required this.onChanged,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final _AuthMode mode;
  final BusinessRole selectedRole;
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final bool isSubmitting;
  final String? statusMessage;
  final ValueChanged<_AuthMode> onModeChanged;
  final ValueChanged<BusinessRole> onRoleChanged;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback onToggleConfirmPasswordVisibility;
  final VoidCallback onChanged;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRegister = mode == _AuthMode.register;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: NeutraliticalBrand.sand),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 28,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    NeutraliticalBrand.markAsset,
                    width: 42,
                    height: 42,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isRegister ? 'Create account' : 'Sign in',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: NeutraliticalBrand.ink,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isRegister
                  ? 'Register a local role-based account to unlock the workspace.'
                  : 'Use your account to access the role-specific control tower.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF5A605D),
              ),
            ),
            const SizedBox(height: 20),
            SegmentedButton<_AuthMode>(
              segments: const [
                ButtonSegment(
                  value: _AuthMode.signIn,
                  label: Text('Sign In'),
                  icon: Icon(Icons.lock_open_rounded),
                ),
                ButtonSegment(
                  value: _AuthMode.register,
                  label: Text('Register'),
                  icon: Icon(Icons.person_add_alt_1_rounded),
                ),
              ],
              selected: {mode},
              onSelectionChanged: (selection) => onModeChanged(selection.first),
            ),
            if (isRegister) ...[
              const SizedBox(height: 20),
              Text(
                'User role',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: BusinessRole.values
                    .map(
                      (role) => ChoiceChip(
                        label: Text(role.shortLabel),
                        selected: role == selectedRole,
                        onSelected: (_) => onRoleChanged(role),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 10),
              Text(
                selectedRole.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF6B6761),
                  height: 1.45,
                ),
              ),
            ],
            const SizedBox(height: 22),
            if (isRegister) ...[
              TextFormField(
                controller: fullNameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                onChanged: (_) => onChanged(),
                validator: (value) {
                  if (!isRegister) {
                    return null;
                  }
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.length < 2) {
                    return 'Enter your full name.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
            ],
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.mail_outline_rounded),
              ),
              onChanged: (_) => onChanged(),
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) {
                  return 'Enter your email address.';
                }
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmed)) {
                  return 'Enter a valid email address.';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: passwordController,
              obscureText: obscurePassword,
              textInputAction: isRegister
                  ? TextInputAction.next
                  : TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  onPressed: onTogglePasswordVisibility,
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                  ),
                ),
              ),
              onChanged: (_) => onChanged(),
              onFieldSubmitted: (_) {
                if (!isRegister) {
                  onSubmit();
                }
              },
              validator: (value) {
                final text = value ?? '';
                if (text.isEmpty) {
                  return 'Enter your password.';
                }
                if (isRegister) {
                  final hasUpper = RegExp(r'[A-Z]').hasMatch(text);
                  final hasLower = RegExp(r'[a-z]').hasMatch(text);
                  final hasDigit = RegExp(r'\d').hasMatch(text);
                  if (text.length < 8 || !hasUpper || !hasLower || !hasDigit) {
                    return 'Use 8+ chars with upper, lower, and a number.';
                  }
                }
                return null;
              },
            ),
            if (isRegister) ...[
              const SizedBox(height: 14),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: obscureConfirmPassword,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'Confirm password',
                  prefixIcon: const Icon(Icons.verified_user_outlined),
                  suffixIcon: IconButton(
                    onPressed: onToggleConfirmPasswordVisibility,
                    icon: Icon(
                      obscureConfirmPassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                    ),
                  ),
                ),
                onChanged: (_) => onChanged(),
                onFieldSubmitted: (_) => onSubmit(),
                validator: (value) {
                  if (!isRegister) {
                    return null;
                  }
                  if ((value ?? '').isEmpty) {
                    return 'Confirm your password.';
                  }
                  if (value != passwordController.text) {
                    return 'Passwords do not match.';
                  }
                  return null;
                },
              ),
            ],
            if (statusMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7EFE3),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE8D6B7)),
                ),
                child: Text(
                  statusMessage!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6B4F2A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isSubmitting ? null : onSubmit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isRegister ? 'Create Account' : 'Sign In'),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              isRegister
                  ? 'This scaffold stores accounts locally. For production, move identity to a secure backend or SSO provider.'
                  : 'You can also use the demo role shortcuts above to explore each workspace without manual setup.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF6B6761),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoRoleCard extends StatelessWidget {
  const _DemoRoleCard({required this.account, required this.onTap});

  final _DemoAccount account;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 220,
      child: Material(
        color: const Color(0xFFF9F6EF),
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: NeutraliticalBrand.forest.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(account.icon, color: NeutraliticalBrand.forest),
                ),
                const SizedBox(height: 12),
                Text(
                  account.role.label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: NeutraliticalBrand.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  account.email,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF5F5E58),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  account.role.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF6C6962),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SecurityPoint extends StatelessWidget {
  const _SecurityPoint({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.shield_outlined,
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
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                body,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFFE8DDD0),
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DemoAccount {
  const _DemoAccount({
    required this.role,
    required this.email,
    required this.password,
    required this.icon,
  });

  final BusinessRole role;
  final String email;
  final String password;
  final IconData icon;
}

const _demoAccounts = <_DemoAccount>[
  _DemoAccount(
    role: BusinessRole.admin,
    email: 'admin@neutralitical.app',
    password: 'Neutral@2026',
    icon: Icons.admin_panel_settings_outlined,
  ),
  _DemoAccount(
    role: BusinessRole.medicalRepresentative,
    email: 'mr.east@neutralitical.app',
    password: 'Neutral@2026',
    icon: Icons.route_outlined,
  ),
  _DemoAccount(
    role: BusinessRole.accountant,
    email: 'accounts@neutralitical.app',
    password: 'Neutral@2026',
    icon: Icons.account_balance_wallet_outlined,
  ),
  _DemoAccount(
    role: BusinessRole.auditor,
    email: 'audit@neutralitical.app',
    password: 'Neutral@2026',
    icon: Icons.fact_check_outlined,
  ),
  _DemoAccount(
    role: BusinessRole.doctor,
    email: 'doctor.demo@neutralitical.app',
    password: 'Neutral@2026',
    icon: Icons.medical_information_outlined,
  ),
  _DemoAccount(
    role: BusinessRole.stockist,
    email: 'stockist.demo@neutralitical.app',
    password: 'Neutral@2026',
    icon: Icons.inventory_2_outlined,
  ),
  _DemoAccount(
    role: BusinessRole.retailer,
    email: 'retailer.demo@neutralitical.app',
    password: 'Neutral@2026',
    icon: Icons.storefront_outlined,
  ),
  _DemoAccount(
    role: BusinessRole.hospital,
    email: 'hospital.demo@neutralitical.app',
    password: 'Neutral@2026',
    icon: Icons.local_hospital_outlined,
  ),
];
