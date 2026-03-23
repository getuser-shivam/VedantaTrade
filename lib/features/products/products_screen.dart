import 'package:flutter/material.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';
import 'package:vedanta_trade/shared/app_scaffold.dart';
import 'package:provider/provider.dart';
import 'package:vedanta_trade/providers/auth_provider.dart';
import 'package:vedanta_trade/providers/product_provider.dart';

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
      context.read<ProductProvider>().fetchCategories();
      context.read<ProductProvider>().fetchProducts();
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
                    productProv.fetchProducts();
                  },
                ),
                ...productProv.categories.map((c) => _CategoryChip(
                  label: c['name'],
                  isSelected: _selectedCategoryId == c['id'],
                  onTap: () {
                    setState(() => _selectedCategoryId = c['id']);
                    productProv.fetchProducts(categoryId: c['id']);
                  },
                )),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Product Grid
          Expanded(
            child: productProv.isLoading
              ? const Center(child: CircularProgressIndicator())
              : productProv.error != null
                ? Center(child: Text(productProv.error!, style: const TextStyle(color: Colors.red)))
                : productProv.products.isEmpty
                  ? const Center(child: Text('No products found', style: TextStyle(color: Colors.white54)))
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, childAspectRatio: 0.75,
                        crossAxisSpacing: 16, mainAxisSpacing: 16,
                      ),
                      itemCount: productProv.products.length,
                      itemBuilder: (context, index) {
                        final p = productProv.products[index];
                        return _ProductCard(product: p);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String? role) {
    switch(role) {
      case 'ADMIN': return AppTheme.adminColor;
      case 'STOCKIST': return AppTheme.stockistColor;
      case 'RETAILER': return AppTheme.retailerColor;
      case 'DOCTOR': return AppTheme.doctorColor;
      default: return AppTheme.primary;
    }
  }

  List<NavItem> _getNavItems(String? role) {
    if (role == 'ADMIN') return const [
      NavItem(label: 'Dashboard', icon: Icons.dashboard_rounded, route: '/admin'),
      NavItem(label: 'Users', icon: Icons.people_rounded, route: '/admin/users'),
      NavItem(label: 'Products', icon: Icons.inventory_2_rounded, route: '/products'),
    ];
    if (role == 'STOCKIST') return const [
      NavItem(label: 'Dashboard', icon: Icons.dashboard_rounded, route: '/stockist'),
      NavItem(label: 'Orders', icon: Icons.shopping_bag_rounded, route: '/orders'),
      NavItem(label: 'Inventory', icon: Icons.inventory_rounded, route: '/products'),
    ];
    if (role == 'RETAILER') return const [
      NavItem(label: 'Dashboard', icon: Icons.dashboard_rounded, route: '/retailer'),
      NavItem(label: 'My Inventory', icon: Icons.inventory_rounded, route: '/products'),
    ];
    return const [];
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
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: AppTheme.cardDark,
        selectedColor: AppTheme.primary.withOpacity(0.3),
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white60, fontSize: 12),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

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
              child: const Icon(Icons.medication_rounded, size: 48, color: Colors.white12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(product.genericName ?? '', style: TextStyle(color: Colors.white54, fontSize: 11)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('₹${product.mrp}', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700)),
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
}
