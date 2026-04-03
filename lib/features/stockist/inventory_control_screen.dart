import 'package:flutter/material.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';
import 'package:vedanta_trade/shared/app_scaffold.dart';
import 'package:vedanta_trade/shared/widgets.dart';
import 'package:provider/provider.dart';
import 'package:vedanta_trade/features/auth/presentation/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:vedanta_trade/core/api_config.dart';
import 'package:intl/intl.dart';

class InventoryControlScreen extends StatefulWidget {
  const InventoryControlScreen({Key? key}) : super(key: key);

  @override
  _InventoryControlScreenState createState() => _InventoryControlScreenState();
}

class _InventoryControlScreenState extends State<InventoryControlScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _products = [];
  List<dynamic> _lowStockProducts = [];
  List<dynamic> _expiringProducts = [];
  List<dynamic> _categories = [];
  bool _loading = true;
  String _selectedCategory = 'ALL';
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _stockAlertController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadInventoryData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _stockAlertController.dispose();
    super.dispose();
  }

  Future<void> _loadInventoryData() async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
      
      final futures = await Future.wait([
        dio.get('${ApiConfig.baseUrl}/stockist/inventory', 
             options: Options(headers: {'Authorization': 'Bearer ${auth.token}'})),
        dio.get('${ApiConfig.baseUrl}/stockist/inventory/alerts', 
             options: Options(headers: {'Authorization': 'Bearer ${auth.token}'})),
        dio.get('${ApiConfig.baseUrl}/stockist/categories', 
             options: Options(headers: {'Authorization': 'Bearer ${auth.token}'})),
      ]);

      if (mounted) {
        setState(() {
          _products = futures[0].data['data'] ?? [];
          _lowStockProducts = futures[1].data['lowStock'] ?? [];
          _expiringProducts = futures[1].data['expiring'] ?? [];
          _categories = futures[2].data['data'] ?? [];
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading inventory: $e'), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  List<dynamic> get _filteredProducts {
    var filtered = _products.where((product) {
      if (_selectedCategory != 'ALL' && product['category']?['name'] != _selectedCategory) {
        return false;
      }
      if (_searchController.text.isNotEmpty) {
        final searchTerm = _searchController.text.toLowerCase();
        final name = product['name']?.toString().toLowerCase() ?? '';
        final sku = product['sku']?.toString().toLowerCase() ?? '';
        return name.contains(searchTerm) || sku.contains(searchTerm);
      }
      return true;
    }).toList();

    // Sort by stock level (lowest first) and then by name
    filtered.sort((a, b) {
      final stockA = a['stock'] ?? 0;
      final stockB = b['stock'] ?? 0;
      if (stockA != stockB) {
        return stockA.compareTo(stockB);
      }
      return (a['name'] ?? '').compareTo(b['name'] ?? '');
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Inventory Control',
      roleColor: AppTheme.stockistColor,
      navItems: [
        NavItem(label: 'Dashboard', icon: Icons.dashboard_rounded, route: '/stockist'),
        NavItem(label: 'Orders', icon: Icons.shopping_cart_rounded, route: '/stockist/orders'),
        NavItem(label: 'Inventory', icon: Icons.inventory_2_rounded, route: '/stockist/inventory'),
        NavItem(label: 'Reports', icon: Icons.assessment_rounded, route: '/stockist/reports'),
      ],
      selectedIndex: 2,
      body: Column(
        children: [
          // Alert Banner
          if (_lowStockProducts.isNotEmpty || _expiringProducts.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.red.withOpacity(0.1),
                    Colors.orange.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_rounded, color: Colors.orange, size: 24),
                      const SizedBox(width: 12),
                      const Text(
                        'Inventory Alerts',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${(_lowStockProducts.length + _expiringProducts.length)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_lowStockProducts.isNotEmpty)
                    _buildAlertItem('Low Stock', _lowStockProducts.length, Icons.inventory_2_rounded, Colors.red),
                  if (_expiringProducts.isNotEmpty)
                    _buildAlertItem('Expiring Soon', _expiringProducts.length, Icons.schedule_rounded, Colors.orange),
                ],
              ),
            ),
          
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              border: Border(bottom: BorderSide(color: AppTheme.dividerDark)),
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search by product name or SKU...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    prefixIcon: const Icon(Icons.search, color: Colors.white38),
                    filled: true,
                    fillColor: AppTheme.surfaceDark,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 12),
                // Category Filter
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length + 1,
                    itemBuilder: (context, index) {
                      final category = index == 0 ? 'ALL' : _categories[index - 1]['name'];
                      final isSelected = _selectedCategory == category;
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            category,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white38,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() => _selectedCategory = category);
                          },
                          backgroundColor: AppTheme.surfaceDark,
                          selectedColor: AppTheme.stockistColor,
                          checkmarkColor: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Tab Bar
          Container(
            color: AppTheme.cardDark,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.stockistColor,
              labelColor: AppTheme.stockistColor,
              unselectedLabelColor: Colors.white38,
              tabs: const [
                Tab(text: 'Products', icon: Icon(Icons.inventory_rounded)),
                Tab(text: 'Low Stock', icon: Icon(Icons.warning_rounded)),
                Tab(text: 'Expiring', icon: Icon(Icons.schedule_rounded)),
                Tab(text: 'Analytics', icon: Icon(Icons.analytics_rounded)),
              ],
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProductsTab(),
                _buildLowStockTab(),
                _buildExpiringTab(),
                _buildAnalyticsTab(),
              ],
            ),
          ),
        ],
      ),
      fab: FloatingActionButton.extended(
        onPressed: () => _showStockUpdateDialog(),
        backgroundColor: AppTheme.stockistColor,
        icon: const Icon(Icons.edit_rounded),
        label: const Text('Update Stock'),
      ),
    );
  }

  Widget _buildAlertItem(String title, int count, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            '$count $title',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              // Navigate to relevant tab
              if (title.contains('Low Stock')) {
                _tabController.animateTo(1);
              } else {
                _tabController.animateTo(2);
              }
            },
            child: const Text('View', style: TextStyle(color: AppTheme.stockistColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTab() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.stockistColor));
    }

    final filteredProducts = _filteredProducts;

    if (filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: AppTheme.stockistColor.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text('No products found', style: TextStyle(color: Colors.white38, fontSize: 18)),
            const SizedBox(height: 8),
            const Text('Try adjusting filters or add products to inventory', style: TextStyle(color: Colors.white24, fontSize: 14)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(dynamic product) {
    final stock = product['stock'] ?? 0;
    final lowStockThreshold = product['lowStockThreshold'] ?? 10;
    final isLowStock = stock <= lowStockThreshold;
    final price = product['price'] ?? 0.0;
    final category = product['category']?['name'] ?? 'Uncategorized';
    final sku = product['sku'] ?? '';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLowStock ? Colors.red.withOpacity(0.3) : AppTheme.dividerDark,
          width: isLowStock ? 2 : 1,
        ),
        boxShadow: isLowStock ? [
          BoxShadow(
            color: Colors.red.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            product['name'] ?? 'Unknown Product',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isLowStock) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'LOW',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'SKU: $sku',
                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category,
                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                
                // Stock Status
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isLowStock ? Colors.red.withOpacity(0.2) : AppTheme.stockistColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$stock',
                            style: TextStyle(
                              color: isLowStock ? Colors.red : AppTheme.stockistColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'units',
                            style: TextStyle(
                              color: isLowStock ? Colors.red70 : AppTheme.stockistColor.withOpacity(0.7),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'NPR ${price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Product Details
          if (product['expiryDate'] != null || product['batchNumber'] != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product['expiryDate'] != null) ...[
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded, size: 16, color: Colors.white38),
                        const SizedBox(width: 8),
                        Text(
                          'Expires: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(product['expiryDate']))}',
                          style: const TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                        const Spacer(),
                        _getExpiryStatusBadge(product['expiryDate']),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (product['batchNumber'] != null)
                    Row(
                      children: [
                        Icon(Icons.qr_code_rounded, size: 16, color: Colors.white38),
                        const SizedBox(width: 8),
                        Text(
                          'Batch: ${product['batchNumber']}',
                          style: const TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          
          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showStockUpdateDialog(product: product),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Update Stock'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.stockistColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 36),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showProductDetails(product),
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: const Text('Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.stockistColor,
                      side: BorderSide(color: AppTheme.stockistColor),
                      minimumSize: const Size(0, 36),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _getExpiryStatusBadge(String expiryDate) {
    final now = DateTime.now();
    final expiry = DateTime.parse(expiryDate);
    final daysUntilExpiry = expiry.difference(now).inDays;
    
    Color color;
    String text;
    
    if (daysUntilExpiry < 0) {
      color = Colors.red;
      text = 'EXPIRED';
    } else if (daysUntilExpiry <= 30) {
      color = Colors.orange;
      text = '${daysUntilExpiry}d';
    } else if (daysUntilExpiry <= 90) {
      color = Colors.yellow;
      text = '${daysUntilExpiry}d';
    } else {
      color = Colors.green;
      text = 'OK';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLowStockTab() {
    if (_lowStockProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_rounded, size: 64, color: Colors.green.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text('No low stock items', style: TextStyle(color: Colors.white38, fontSize: 18)),
            const SizedBox(height: 8),
            const Text('All products have adequate stock levels', style: TextStyle(color: Colors.white24, fontSize: 14)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _lowStockProducts.length,
      itemBuilder: (context, index) {
        final product = _lowStockProducts[index];
        return _buildLowStockCard(product);
      },
    );
  }

  Widget _buildLowStockCard(dynamic product) {
    final stock = product['stock'] ?? 0;
    final threshold = product['lowStockThreshold'] ?? 10;
    final deficit = threshold - stock;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.red, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  product['name'] ?? 'Unknown Product',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '$stock units',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Low by $deficit units',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showStockUpdateDialog(product: product),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Restock'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 32),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpiringTab() {
    if (_expiringProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule_rounded, size: 64, color: Colors.green.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text('No expiring items', style: TextStyle(color: Colors.white38, fontSize: 18)),
            const SizedBox(height: 8),
            const Text('All products have valid expiry dates', style: TextStyle(color: Colors.white24, fontSize: 14)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _expiringProducts.length,
      itemBuilder: (context, index) {
        final product = _expiringProducts[index];
        return _buildExpiringCard(product);
      },
    );
  }

  Widget _buildExpiringCard(dynamic product) {
    final expiryDate = DateTime.parse(product['expiryDate']);
    final now = DateTime.now();
    final daysUntilExpiry = expiryDate.difference(now).inDays;
    
    Color color;
    String urgency;
    
    if (daysUntilExpiry < 0) {
      color = Colors.red;
      urgency = 'EXPIRED';
    } else if (daysUntilExpiry <= 7) {
      color = Colors.red;
      urgency = 'URGENT';
    } else if (daysUntilExpiry <= 30) {
      color = Colors.orange;
      urgency = 'SOON';
    } else {
      color = Colors.yellow;
      urgency = 'WARNING';
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule_rounded, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  product['name'] ?? 'Unknown Product',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  urgency,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Expires: ${DateFormat('MMM dd, yyyy').format(expiryDate)}',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const Spacer(),
              Text(
                '$daysUntilExpiry days',
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (product['stock'] > 0)
            Row(
              children: [
                Text(
                  'Stock: ${product['stock']} units',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _showDiscountDialog(product),
                  child: const Text('Apply Discount', style: TextStyle(color: AppTheme.stockistColor)),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Inventory Analytics',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Products',
                  '${_products.length}',
                  Icons.inventory_rounded,
                  AppTheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Low Stock',
                  '${_lowStockProducts.length}',
                  Icons.warning_rounded,
                  Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Expiring',
                  '${_expiringProducts.length}',
                  Icons.schedule_rounded,
                  Colors.orange,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Total Value Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.stockistColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.stockistColor.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Inventory Value',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  'NPR ${_calculateTotalValue().toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppTheme.stockistColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Category Distribution Chart Placeholder
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.dividerDark),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pie_chart_rounded, size: 48, color: Colors.white38),
                  SizedBox(height: 8),
                  Text('Category Distribution', style: TextStyle(color: Colors.white38)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }

  double _calculateTotalValue() {
    return _products.fold(0.0, (sum, product) {
      final stock = product['stock'] ?? 0;
      final price = product['price'] ?? 0.0;
      return sum + (stock * price);
    });
  }

  void _showStockUpdateDialog({dynamic product}) {
    final TextEditingController quantityController = TextEditingController();
    String operation = 'add'; // add or remove
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.cardDark,
          title: Text(
            product != null ? 'Update Stock: ${product['name']}' : 'Update Stock',
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (product != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Current Stock: ${product['stock']} units',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              // Operation Selection
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Add Stock', style: TextStyle(color: Colors.white)),
                      value: 'add',
                      groupValue: operation,
                      onChanged: (value) => setDialogState(() => operation = value!),
                      activeColor: AppTheme.stockistColor,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Remove', style: TextStyle(color: Colors.white)),
                      value: 'remove',
                      groupValue: operation,
                      onChanged: (value) => setDialogState(() => operation = value!),
                      activeColor: AppTheme.stockistColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  labelStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: AppTheme.surfaceDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
            ),
            ElevatedButton(
              onPressed: () {
                final quantity = int.tryParse(quantityController.text);
                if (quantity != null && quantity > 0) {
                  _updateStock(product, operation, quantity);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.stockistColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateStock(dynamic product, String operation, int quantity) async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
      
      await dio.post(
        '${ApiConfig.baseUrl}/stockist/inventory/update',
        data: {
          productId: product['id'],
          operation: operation,
          quantity: quantity,
        },
        options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}),
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stock ${operation}ed successfully'),
          backgroundColor: AppTheme.success,
        ),
      );
      _loadInventoryData(); // Refresh data
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating stock: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  void _showProductDetails(dynamic product) {
    // Show detailed product information
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: Text(
          product['name'] ?? 'Product Details',
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('SKU', product['sku'] ?? 'N/A'),
              _buildDetailRow('Category', product['category']?['name'] ?? 'N/A'),
              _buildDetailRow('Current Stock', '${product['stock'] ?? 0} units'),
              _buildDetailRow('Price', 'NPR ${(product['price'] ?? 0.0).toStringAsFixed(2)}'),
              _buildDetailRow('Low Stock Threshold', '${product['lowStockThreshold'] ?? 10} units'),
              if (product['expiryDate'] != null)
                _buildDetailRow('Expiry Date', DateFormat('MMM dd, yyyy').format(DateTime.parse(product['expiryDate']))),
              if (product['batchNumber'] != null)
                _buildDetailRow('Batch Number', product['batchNumber']),
              if (product['description'] != null)
                _buildDetailRow('Description', product['description']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.white38)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white38, fontSize: 14),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _showDiscountDialog(dynamic product) {
    // Show discount application dialog for expiring products
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: const Text(
          'Apply Discount',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Apply discount to ${product['name']} (${product['stock']} units)?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Apply discount logic here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Discount applied successfully'),
                  backgroundColor: AppTheme.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.stockistColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
