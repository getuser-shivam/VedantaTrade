import 'package:flutter/material.dart';
import 'package:vedanta_trade/shared/theme/enhanced_theme.dart';
import 'package:vedanta_trade/shared/widgets/common/enhanced_ui_components.dart';
import 'package:vedanta_trade/shared/widgets/responsive/responsive_layout.dart';
import 'package:vedanta_trade/shared/widgets/animations/enhanced_animations.dart';
import 'package:vedanta_trade/shared/widgets/navigation/enhanced_navigation.dart';
import 'package:vedanta_trade/shared/widgets/accessibility/enhanced_accessibility.dart';
import 'package:vedanta_trade/shared/widgets/performance/performance_optimizer.dart';

/// UI Components Demo Page
/// Showcases all enhanced UI/UX components

class UIComponentsDemo extends StatefulWidget {
  const UIComponentsDemo({Key? key}) : super(key: key);

  @override
  State<UIComponentsDemo> createState() => _UIComponentsDemoState();
}

class _UIComponentsDemoState extends State<UIComponentsDemo> {
  int _currentNavIndex = 0;
  bool _isLoading = false;
  double _progressValue = 0.7;
  int _counterValue = 1234;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: EnhancedAppBar(
        title: 'UI Components Demo',
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => _showAccessibilitySettings(),
          ),
        ],
      ),
      body: PerformanceMonitor(
        enabled: true,
        showOverlay: true,
        child: ResponsiveLayout(
          mobile: _buildMobileLayout(),
          tablet: _buildTabletLayout(),
          desktop: _buildDesktopLayout(),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Buttons'),
          const SizedBox(height: 16),
          _buildButtonDemo(),
          const SizedBox(height: 24),
          
          _buildSectionTitle('Cards'),
          const SizedBox(height: 16),
          _buildCardDemo(),
          const SizedBox(height: 24),
          
          _buildSectionTitle('Forms'),
          const SizedBox(height: 16),
          _buildFormDemo(),
          const SizedBox(height: 24),
          
          _buildSectionTitle('Chips'),
          const SizedBox(height: 16),
          _buildChipDemo(),
          const SizedBox(height: 24),
          
          _buildSectionTitle('Loading States'),
          const SizedBox(height: 16),
          _buildLoadingDemo(),
          const SizedBox(height: 24),
          
          _buildSectionTitle('Progress & Counters'),
          const SizedBox(height: 16),
          _buildProgressDemo(),
          const SizedBox(height: 24),
          
          _buildSectionTitle('Animations'),
          const SizedBox(height: 16),
          _buildAnimationDemo(),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return ResponsiveGrid(
      children: [
        _buildButtonDemo(),
        _buildCardDemo(),
        _buildFormDemo(),
        _buildChipDemo(),
        _buildLoadingDemo(),
        _buildProgressDemo(),
      ],
      mobileColumns: 1,
      tabletColumns: 2,
      desktopColumns: 3,
    );
  }

  Widget _buildDesktopLayout() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildSectionTitle('Enhanced UI Components Showcase'),
          const SizedBox(height: 24),
          Expanded(
            child: ResponsiveGrid(
              children: [
                _buildButtonDemo(),
                _buildCardDemo(),
                _buildFormDemo(),
                _buildChipDemo(),
                _buildLoadingDemo(),
                _buildProgressDemo(),
                _buildAnimationDemo(),
                _buildNavigationDemo(),
              ],
              mobileColumns: 1,
              tabletColumns: 2,
              desktopColumns: 3,
              largeDesktopColumns: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildButtonDemo() {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Buttons',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              EnhancedButton(
                text: 'Primary',
                onPressed: () => _showMessage('Primary button pressed'),
              ),
              EnhancedButton(
                text: 'Secondary',
                onPressed: () => _showMessage('Secondary button pressed'),
                type: ButtonType.secondary,
              ),
              EnhancedButton(
                text: 'Success',
                onPressed: () => _showMessage('Success button pressed'),
                type: ButtonType.success,
              ),
              EnhancedButton(
                text: 'Warning',
                onPressed: () => _showMessage('Warning button pressed'),
                type: ButtonType.warning,
              ),
              EnhancedButton(
                text: 'Error',
                onPressed: () => _showMessage('Error button pressed'),
                type: ButtonType.error,
              ),
              EnhancedButton(
                text: 'Outlined',
                onPressed: () => _showMessage('Outlined button pressed'),
                type: ButtonType.outlined,
              ),
              EnhancedButton(
                text: 'Loading',
                onPressed: () {},
                isLoading: _isLoading,
              ),
              EnhancedButton(
                text: 'With Icon',
                onPressed: () => _showMessage('Icon button pressed'),
                icon: Icons.star,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardDemo() {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cards',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: EnhancedCard(
                  onTap: () => _showMessage('Card 1 tapped'),
                  isClickable: true,
                  child: const Column(
                    children: [
                      Icon(Icons.home, size: 32),
                      SizedBox(height: 8),
                      Text('Clickable Card'),
                      Text('Tap to interact', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: EnhancedCard(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: const Column(
                    children: [
                      Icon(Icons.favorite, size: 32),
                      SizedBox(height: 8),
                      Text('Styled Card'),
                      Text('Custom background', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormDemo() {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Forms',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Column(
              children: [
                AccessibleInputField(
                  label: 'Email',
                  hint: 'Enter your email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    if (!value.contains('@')) {
                      return 'Invalid email format';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AccessibleInputField(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                EnhancedButton(
                  text: 'Submit Form',
                  onPressed: _submitForm,
                  type: ButtonType.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipDemo() {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chips',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              EnhancedChip(
                label: 'Active',
                type: ChipType.success,
                onTap: () => _showMessage('Active chip tapped'),
              ),
              EnhancedChip(
                label: 'Pending',
                type: ChipType.warning,
                onTap: () => _showMessage('Pending chip tapped'),
              ),
              EnhancedChip(
                label: 'Inactive',
                type: ChipType.error,
                onTap: () => _showMessage('Inactive chip tapped'),
              ),
              EnhancedChip(
                label: 'Notifications',
                type: ChipType.primary,
                badgeCount: 5,
                onTap: () => _showMessage('Notifications chip tapped'),
              ),
              EnhancedChip(
                label: 'Filter',
                type: ChipType.outline,
                onTap: () => _showMessage('Filter chip tapped'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingDemo() {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Loading States',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      EnhancedLoading(
                        type: LoadingType.circular,
                        message: 'Circular',
                      ),
                      const SizedBox(height: 8),
                      const Text('Circular'),
                    ],
                  ),
                  Column(
                    children: [
                      EnhancedLoading(
                        type: LoadingType.linear,
                        message: 'Linear',
                      ),
                      const SizedBox(height: 8),
                      const Text('Linear'),
                    ],
                  ),
                  Column(
                    children: [
                      EnhancedLoading(
                        type: LoadingType.dots,
                        message: 'Dots',
                      ),
                      const SizedBox(height: 8),
                      const Text('Dots'),
                    ],
                  ),
                  Column(
                    children: [
                      EnhancedLoading(
                        type: LoadingType.pulse,
                        message: 'Pulse',
                      ),
                      const SizedBox(height: 8),
                      const Text('Pulse'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressDemo() {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress & Counters',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              AnimatedProgressIndicator(
                value: _progressValue,
                label: 'Upload Progress',
                showPercentage: true,
              ),
              const SizedBox(height: 24),
              AnimatedCounter(
                value: _counterValue,
                prefix: 'Orders: ',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: EnhancedButton(
                      text: 'Update Progress',
                      onPressed: () {
                        setState(() {
                          _progressValue = (_progressValue + 0.1) % 1.0;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: EnhancedButton(
                      text: 'Update Counter',
                      onPressed: () {
                        setState(() {
                          _counterValue += 123;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimationDemo() {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Animations',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          AnimatedList(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Animated Item 1'),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Animated Item 2'),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Animated Item 3'),
              ),
            ],
            duration: const Duration(milliseconds: 300),
            staggerDelay: const Duration(milliseconds: 100),
            slideDirection: SlideDirection.bottomToTop,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationDemo() {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Navigation',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          BreadcrumbNavigation(
            items: const [
              BreadcrumbItem(
                label: 'Home',
                icon: Icons.home,
              ),
              BreadcrumbItem(
                label: 'Demo',
                icon: Icons.widgets,
              ),
              BreadcrumbItem(
                label: 'Components',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return EnhancedNavigation(
      currentIndex: _currentNavIndex,
      onTap: (index) {
        setState(() {
          _currentNavIndex = index;
        });
        _showMessage('Navigation to index $index');
      },
      type: NavigationType.bottom,
      showLabels: true,
      items: const [
        NavigationItem(icon: Icons.home, label: 'Home'),
        NavigationItem(icon: Icons.widgets, label: 'Components'),
        NavigationItem(icon: Icons.animation, label: 'Animations'),
        NavigationItem(icon: Icons.accessibility, label: 'A11y'),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _showMessage('Form submitted successfully!');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAccessibilitySettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => AccessibilitySettings(
        onSettingsChanged: () {
          setState(() {});
        },
      ),
    );
  }
}
