import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/enhanced_theme_provider.dart';
import '../widgets/premium_gremium_widgets.dart';

class EnhancedUIComponentsScreen extends StatefulWidget {
  const EnhancedUIComponentsScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedUIComponentsScreen> createState() => _EnhancedUIComponentsScreenState();
}

class _EnhancedUIComponentsScreenState extends State<EnhancedUIComponentsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _demoController;
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  bool _isDarkMode = true;
  bool _isGlassmorphic = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _demoController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _demoController.repeat();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _demoController.dispose();
    _textController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.watch<EnhancedThemeProvider>().backgroundPrimary,
      appBar: AppBar(
        title: const Text(
          'Enhanced UI Components',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              context.watch<EnhancedThemeProvider>().isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
              color: Colors.white,
            ),
            onPressed: () {
              context.read<EnhancedThemeProvider>().toggleTheme();
            },
          ),
          IconButton(
            icon: Icon(
              context.watch<EnhancedThemeProvider>().isGlassmorphic
                  ? Icons.blur_on
                  : Icons.blur_off,
              color: Colors.white,
            ),
            onPressed: () {
              context.read<EnhancedThemeProvider>().toggleGlassmorphic();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCardsDemo(),
                _buildButtonsDemo(),
                _buildTextFieldsDemo(),
                _buildAdvancedDemo(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Premium UI Components',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enhanced glassmorphic widgets with smooth animations and interactions',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildThemeChip('Dark Mode', _isDarkMode, () {
                setState(() {
                  _isDarkMode = !_isDarkMode;
                });
                context.read<EnhancedThemeProvider>().setThemeMode(
                  _isDarkMode ? ThemeMode.dark : ThemeMode.light,
                );
              }),
              const SizedBox(width: 12),
              _buildThemeChip('Glassmorphic', _isGlassmorphic, () {
                setState(() {
                  _isGlassmorphic = !_isGlassmorphic;
                });
                context.read<EnhancedThemeProvider>().setGlassmorphic(_isGlassmorphic);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeChip(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isActive
              ? context.watch<EnhancedThemeProvider>().primaryGradient
              : LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? Colors.transparent
                : Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: context.watch<EnhancedThemeProvider>().primaryGradient,
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        tabs: const [
          Tab(text: 'Cards'),
          Tab(text: 'Buttons'),
          Tab(text: 'Text Fields'),
          Tab(text: 'Advanced'),
        ],
      ),
    );
  }

  Widget _buildCardsDemo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Glassmorphic Cards',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildBasicCard(),
          const SizedBox(height: 16),
          _buildInteractiveCard(),
          const SizedBox(height: 16),
          _buildCardWithShimmer(),
          const SizedBox(height: 16),
          _buildCardGrid(),
        ],
      ),
    );
  }

  Widget _buildBasicCard() {
    return PremiumGlassmorphicCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Glassmorphic Card',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'A beautiful glassmorphic card with blur effects and subtle animations.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveCard() {
    return PremiumGlassmorphicCard(
      padding: const EdgeInsets.all(20),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Card tapped!'),
            backgroundColor: Color(0xFF4F46E5),
          ),
        );
      },
      enableShimmer: true,
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: context.watch<EnhancedThemeProvider>().primaryGradient,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.touch_app,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Interactive Card',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap to interact with shimmer effects',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardWithShimmer() {
    return PremiumGlassmorphicCard(
      padding: const EdgeInsets.all(20),
      enableShimmer: true,
      enableGradient: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Card with Shimmer',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Animated shimmer effect for visual appeal.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              context.watch<EnhancedThemeProvider>().primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Card Grid',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _buildGridCard('Analytics', Icons.analytics, Colors.blue),
            _buildGridCard('Sales', Icons.trending_up, Colors.green),
            _buildGridCard('Users', Icons.people, Colors.orange),
            _buildGridCard('Settings', Icons.settings, Colors.purple),
          ],
        ),
      ],
    );
  }

  Widget _buildGridCard(String title, IconData icon, Color color) {
    return PremiumGlassmorphicCard(
      padding: const EdgeInsets.all(16),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title tapped!'),
            backgroundColor: color,
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              icon,
              color: color,
              size: 25,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonsDemo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enhanced Buttons',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildPrimaryButton(),
          const SizedBox(height: 16),
          _buildSecondaryButton(),
          const SizedBox(height: 16),
          _buildIconButton(),
          const SizedBox(height: 16),
          _buildLoadingButton(),
          const SizedBox(height: 16),
          _buildButtonRow(),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton() {
    return PremiumGlassmorphicButton(
      text: 'Primary Action',
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Primary action triggered!'),
            backgroundColor: Color(0xFF4F46E5),
          ),
        );
      },
      icon: Icons.arrow_forward,
      gradient: context.watch<EnhancedThemeProvider>().primaryGradient,
    );
  }

  Widget _buildSecondaryButton() {
    return PremiumGlassmorphicButton(
      text: 'Secondary Action',
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Secondary action triggered!'),
            backgroundColor: Color(0xFF06B6D4),
          ),
        );
      },
      backgroundColor: const Color(0x1A06B6D4),
      borderColor: const Color(0x4D06B6D4),
    );
  }

  Widget _buildIconButton() {
    return PremiumGlassmorphicButton(
      text: 'Icon Button',
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Icon button triggered!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      },
      icon: Icons.favorite,
      backgroundColor: const Color(0x1A10B981),
      borderColor: const Color(0x4D10B981),
    );
  }

  Widget _buildLoadingButton() {
    return PremiumGlassmorphicButton(
      text: 'Loading State',
      onPressed: () {
        setState(() {
          _isLoading = !_isLoading;
        });
      },
      isLoading: _isLoading,
      icon: Icons.download,
      backgroundColor: const Color(0x1AF59E0B),
      borderColor: const Color(0x4DF59E0B),
    );
  }

  Widget _buildButtonRow() {
    return Row(
      children: [
        Expanded(
          child: PremiumGlassmorphicButton(
            text: 'Small',
            onPressed: () {},
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PremiumGlassmorphicButton(
            text: 'Medium',
            onPressed: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PremiumGlassmorphicButton(
            text: 'Large',
            onPressed: () {},
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          ),
        ),
      ],
    );
  }

  Widget _buildTextFieldsDemo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enhanced Text Fields',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildBasicTextField(),
          const SizedBox(height: 16),
          _buildTextFieldWithIcon(),
          const SizedBox(height: 16),
          _buildSearchField(),
          const SizedBox(height: 16),
          _buildPasswordField(),
          const SizedBox(height: 16),
          _buildMultilineField(),
        ],
      ),
    );
  }

  Widget _buildBasicTextField() {
    return PremiumGlassmorphicTextField(
      controller: _textController,
      hintText: 'Enter your text here...',
      labelText: 'Basic Text Field',
      onChanged: (value) {
        // Handle text change
      },
    );
  }

  Widget _buildTextFieldWithIcon() {
    return PremiumGlassmorphicTextField(
      controller: _textController,
      hintText: 'Enter your email...',
      labelText: 'Email Address',
      prefixIcon: Icons.email,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!value.contains('@')) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildSearchField() {
    return PremiumGlassmorphicTextField(
      controller: _searchController,
      hintText: 'Search products...',
      prefixIcon: Icons.search,
      suffixIcon: Icons.clear,
      onSuffixIconTap: () {
        _searchController.clear();
      },
      onChanged: (value) {
        // Handle search
      },
    );
  }

  Widget _buildPasswordField() {
    return PremiumGlassmorphicTextField(
      controller: _textController,
      hintText: 'Enter your password...',
      labelText: 'Password',
      prefixIcon: Icons.lock,
      suffixIcon: Icons.visibility,
      onSuffixIconTap: () {
        // Toggle password visibility
      },
      obscureText: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  Widget _buildMultilineField() {
    return PremiumGlassmorphicTextField(
      controller: _textController,
      hintText: 'Enter your message here...',
      labelText: 'Message',
      maxLines: 4,
      prefixIcon: Icons.message,
    );
  }

  Widget _buildAdvancedDemo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Advanced Components',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatsCards(),
          const SizedBox(height: 16),
          _buildProgressIndicators(),
          const SizedBox(height: 16),
          _buildChips(),
          const SizedBox(height: 16),
          _buildNotificationCard(),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistics Cards',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard('Revenue', '\$12,345', Icons.trending_up, Colors.green),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard('Users', '1,234', Icons.people, Colors.blue),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard('Orders', '456', Icons.shopping_cart, Colors.orange),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard('Rating', '4.8', Icons.star, Colors.purple),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return PremiumGlassmorphicCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              const Spacer(),
              AnimatedBuilder(
                animation: _demoController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_demoController.value * 0.1),
                    child: Text(
                      value,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicators() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress Indicators',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildProgressIndicator('Project Progress', 0.75, Colors.blue),
        const SizedBox(height: 12),
        _buildProgressIndicator('Sales Target', 0.45, Colors.green),
        const SizedBox(height: 12),
        _buildProgressIndicator('Customer Satisfaction', 0.92, Colors.orange),
      ],
    );
  }

  Widget _buildProgressIndicator(String label, double value, Color color) {
    return PremiumGlassmorphicCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(value * 100).toInt()}%',
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter Chips',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip('All Products', true),
            _buildChip('Medicines', false),
            _buildChip('Equipment', false),
            _buildChip('Supplements', false),
            _buildChip('Personal Care', false),
          ],
        ),
      ],
    );
  }

  Widget _buildChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        // Handle chip selection
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? context.watch<EnhancedThemeProvider>().primaryGradient
              : LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard() {
    return PremiumGlassmorphicCard(
      padding: const EdgeInsets.all(20),
      enableShimmer: true,
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.orange, Colors.red],
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
              Icons.notifications,
              color: Colors.white,
              size: 25,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New Notification',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You have 3 new orders to process',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
