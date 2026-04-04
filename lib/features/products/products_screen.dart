import 'package:flutter/material.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';
import 'package:vedanta_trade/shared/app_scaffold.dart';
import 'package:provider/provider.dart';
import 'package:vedanta_trade/features/auth/presentation/providers/auth_provider.dart';
import 'package:vedanta_trade/features/catalog/presentation/providers/product_provider.dart';
import 'package:vedanta_trade/features/catalog/domain/models/product.dart';
import 'package:vedanta_trade/core/api_config.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});
  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final productProv = context.watch<ProductProvider>();

    return AppScaffold(
      title: 'Products Inventory',
      roleColor: _getRoleColor(auth.userRole),
      navItems: _getNavItems(auth.userRole),
      selectedIndex: 2,
      body: Column(
        children: [
          // Category Selector
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _CategoryChip(
                  label: 'All',
                  isSelected: _selectedCategoryId == null,
                  onTap: () {
                    setState(() => _selectedCategoryId = null);
                    productProv.loadProducts();
                  },
                ),
                ...productProv.categories.map((c) => _CategoryChip(
                  label: c.toString(),
                  isSelected: _selectedCategoryId == null,
                  onTap: () {
                    setState(() => _selectedCategoryId = null);
                    productProv.loadProducts();
                  },
                )),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Product Grid
          Expanded(
            child: productProv.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
              : productProv.errorMessage != null
                ? Center(child: Text(productProv.errorMessage!, style: const TextStyle(color: Colors.red)))
                : productProv.products.isEmpty
                  ? const Center(child: Text('No products found', style: TextStyle(color: Colors.white54)))
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = constraints.maxWidth < 600 ? 2 : (constraints.maxWidth < 1000 ? 3 : 5);
                        return GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount, childAspectRatio: 0.72,
                            crossAxisSpacing: 16, mainAxisSpacing: 16,
                          ),
                          itemCount: productProv.products.length,
                          itemBuilder: (context, index) {
                            final p = productProv.products[index];
                            return _ProductCard(product: p, roleColor: _getRoleColor(auth.userRole));
                          },
                        );
                      }
                    ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String? role) {
    switch (role) {
      case 'ADMIN': return AppTheme.adminColor;
      case 'STOCKIST': return AppTheme.stockistColor;
      case 'RETAILER': return AppTheme.retailerColor;
      case 'DOCTOR': return AppTheme.doctorColor;
      case 'MEDICAL_REP': return AppTheme.mrColor;
      default: return AppTheme.primary;
    }
  }

  List<NavItem> _getNavItems(String? role) {
    if (role == 'ADMIN') return const [
      NavItem(label: 'Dashboard', icon: Icons.dashboard_rounded, route: '/admin'),
      NavItem(label: 'Users', icon: Icons.people_rounded, route: '/admin/users'),
      NavItem(label: 'Products', icon: Icons.inventory_2_rounded, route: '/products'),
      NavItem(label: 'Orders', icon: Icons.shopping_bag_rounded, route: '/orders'),
      NavItem(label: 'Scraper', icon: Icons.travel_explore_rounded, route: '/admin/scraper'),
    ];
    if (role == 'MEDICAL_REP') return const [
      NavItem(label: 'Dashboard', icon: Icons.dashboard_rounded, route: '/mr'),
      NavItem(label: 'Visits', icon: Icons.medical_services_rounded, route: '/mr/visits'),
      NavItem(label: 'Tour Plan', icon: Icons.map_rounded, route: '/mr/tour-plan'),
      NavItem(label: 'Expenses', icon: Icons.receipt_long_rounded, route: '/mr/expenses'),
      NavItem(label: 'Orders', icon: Icons.shopping_bag_rounded, route: '/orders'),
      NavItem(label: 'Products', icon: Icons.inventory_2_rounded, route: '/products'),
    ];
    return [
      NavItem(label: 'Dashboard', icon: Icons.dashboard_rounded, route: role == 'STOCKIST' ? '/stockist' : '/retailer'),
      NavItem(label: 'Orders', icon: Icons.shopping_bag_rounded, route: '/orders'),
      NavItem(label: 'Products', icon: Icons.inventory_2_rounded, route: '/products'),
    ];
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _CategoryChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.white60, fontSize: 11, fontWeight: FontWeight.bold)),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: AppTheme.surfaceDark,
        selectedColor: AppTheme.primary.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        showCheckmark: false,
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final Color roleColor;
  const _ProductCard({required this.product, required this.roleColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: (product.images?.isNotEmpty ?? false)
                ? _buildProductImage(product.images!.first)
                : const Icon(Icons.medication_rounded, size: 48, color: Colors.white12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(product.manufacturer, style: const TextStyle(color: Colors.white38, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('₹${product.price}', style: TextStyle(color: roleColor, fontWeight: FontWeight.w700, fontSize: 14)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: product.stockQuantity > 20 ? AppTheme.success.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('${product.stockQuantity} Left', style: TextStyle(color: product.stockQuantity > 20 ? AppTheme.success : Colors.orange, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(String imagePath) {
    final url = imagePath.startsWith('http') ? imagePath : '${ApiConfig.baseUrl}$imagePath';
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Image.network(
        url, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.medication_rounded, size: 48, color: Colors.white12),
      ),
    );
  }
}

