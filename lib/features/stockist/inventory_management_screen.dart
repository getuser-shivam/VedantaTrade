import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../../app/theme/app_theme.dart';
import '../../../shared/widgets/glassmorphic_widgets.dart';

/// Stockist SKU-level inventory control with low-stock alerts
class StockistInventoryScreen extends StatefulWidget {
  const StockistInventoryScreen({Key? key}) : super(key: key);

  @override
  State<StockistInventoryScreen> createState() => _StockistInventoryScreenState();
}

class _StockistInventoryScreenState extends State<StockistInventoryScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  String _selectedCategory = 'all';
  String _searchQuery = '';
  String _sortBy = 'name';
  bool _showLowStockOnly = false;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      await _loadProducts();
      await _loadCategories();
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Failed to load inventory data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadProducts() async {
    // TODO: Replace with real API call - GET /api/stockist/inventory
    await Future.delayed(const Duration(milliseconds: 500));
    
    final mockProducts = [
      {
        'id': '1',
        'sku': 'PAR-500',
        'name': 'Paracetamol 500mg',
        'category': 'Pain Relief',
        'stock': 150,
        'lowStockThreshold': 50,
        'unitPrice': 8.0,
        'currency': 'NPR',
        'expiryDate': DateTime.now().add(const Duration(days: 365)).toIso8601String(),
        'supplier': 'Pharma Nepal',
        'lastRestock': DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
        'status': 'normal',
      },
      {
        'id': '2',
        'sku': 'AMX-250',
        'name': 'Amoxicillin 250mg',
        'category': 'Antibiotics',
        'stock': 45,
        'lowStockThreshold': 100,
        'unitPrice': 120.0,
        'currency': 'NPR',
        'expiryDate': DateTime.now().add(const Duration(days: 180)).toIso8601String(),
        'supplier': 'MediSupply',
        'lastRestock': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        'status': 'low_stock',
      },
      {
        'id': '3',
        'sku': 'IBU-400',
        'name': 'Ibuprofen 400mg',
        'category': 'Pain Relief',
        'stock': 280,
        'lowStockThreshold': 75,
        'unitPrice': 45.0,
        'currency': 'NPR',
        'expiryDate': DateTime.now().add(const Duration(days: 270)).toIso8601String(),
        'supplier': 'Pharma Nepal',
        'lastRestock': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'status': 'normal',
      },
      {
        'id': '4',
        'sku': 'COU-100',
        'name': 'Cough Syrup',
        'category': 'Cold & Flu',
        'stock': 25,
        'lowStockThreshold': 40,
        'unitPrice': 150.0,
        'currency': 'NPR',
        'expiryDate': DateTime.now().add(const Duration(days: 90)).toIso8601String(),
        'supplier': 'MediSupply',
        'lastRestock': DateTime.now().subtract(const Duration(days: 45)).toIso8601String(),
        'status': 'low_stock',
      },
      {
        'id': '5',
        'sku': 'VIT-C',
        'name': 'Vitamin C',
        'category': 'Vitamins',
        'stock': 500,
        'lowStockThreshold': 150,
        'unitPrice': 25.0,
        'currency': 'NPR',
        'expiryDate': DateTime.now().add(const Duration(days: 450)).toIso8601String(),
        'supplier': 'HealthPlus',
        'lastRestock': DateTime.now().subtract(const Duration(days: 20)).toIso8601String(),
        'status': 'normal',
      },
      {
        'id': '6',
        'sku': 'BAN-50',
        'name': 'Bandages',
        'category': 'Medical Supplies',
        'stock': 15,
        'lowStockThreshold': 30,
        'unitPrice': 80.0,
        'currency': 'NPR',
        'expiryDate': DateTime.now().add(const Duration(days: 720)).toIso8601String(),
        'supplier': 'HealthPlus',
        'lastRestock': DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
        'status': 'critical',
      },
    ];
    
    if (mounted) {
      setState(() {
        _products = mockProducts;
      });
    }
  }

  Future<void> _loadCategories() async {
    // TODO: Replace with real API call - GET /api/categories
    await Future.delayed(const Duration(milliseconds: 200));
    
    final mockCategories = [
      {'id': 'all', 'name': 'All Categories'},
      {'id': 'pain_relief', 'name': 'Pain Relief'},
      {'id': 'antibiotics', 'name': 'Antibiotics'},
      {'id': 'cold_flu', 'name': 'Cold & Flu'},
      {'id': 'vitamins', 'name': 'Vitamins'},
      {'id': 'medical_supplies', 'name': 'Medical Supplies'},
    ];
    
    if (mounted) {
      setState(() {
        _categories = mockCategories;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredProducts {
    var filtered = _products;
    
    // Filter by category
    if (_selectedCategory != 'all') {
      filtered = filtered.where((product) => product['category'] == _selectedCategory).toList();
    }
    
    // Filter by low stock
    if (_showLowStockOnly) {
      filtered = filtered.where((product) => 
        product['status'] == 'low_stock' || product['status'] == 'critical'
      ).toList();
    }
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        final query = _searchQuery.toLowerCase();
        return product['name'].toString().toLowerCase().contains(query) ||
               product['sku'].toString().toLowerCase().contains(query) ||
               product['supplier'].toString().toLowerCase().contains(query);
      }).toList();
    }
    
    // Sort products
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'name':
          return a['name'].toString().compareTo(b['name'].toString());
        case 'stock':
          return (b['stock'] as int).compareTo(a['stock'] as int);
        case 'price':
          return (a['unitPrice'] as double).compareTo(b['unitPrice'] as double);
        case 'expiry':
          return DateTime.parse(a['expiryDate']).compareTo(DateTime.parse(b['expiryDate']));
        default:
          return 0;
      }
    });
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'Inventory Management',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.stockistColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _showAddProductDialog,
          ),
          IconButton(
            icon: const Icon(Icons.warning, color: Colors.white),
            onPressed: _showLowStockAlerts,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                _buildFilterBar(),
                _buildStatsBar(),
                Expanded(
                  child: _buildProductsList(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _updateStockLevels,
        backgroundColor: AppTheme.accent,
        icon: const Icon(Icons.refresh, color: Colors.white),
        label: const Text(
          'Update Stock',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: GlassmorphicCard(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search products...',
                      hintStyle: TextStyle(color: AppTheme.textSecondary),
                      prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GlassmorphicButton(
                text: 'Add Product',
                icon: Icons.add,
                onPressed: _showAddProductDialog,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip('all', 'All'),
                ..._categories.where((cat) => cat['id'] != 'all').map((cat) {
                  return _buildCategoryChip(cat['id'], cat['name']);
                }).toList(),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Checkbox(
                      value: _showLowStockOnly,
                      onChanged: (value) {
                        setState(() {
                          _showLowStockOnly = value;
                        });
                      },
                      activeColor: AppTheme.warning,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Show Low Stock Only',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: AppTheme.inputDecoration('Sort by...'),
                  value: _sortBy,
                  items: const [
                    DropdownMenuItem(value: 'name', child: Text('Name', style: TextStyle(color: Colors.white))),
                    DropdownMenuItem(value: 'stock', child: Text('Stock Level', style: TextStyle(color: Colors.white))),
                    DropdownMenuItem(value: 'price', child: Text('Price', style: TextStyle(color: Colors.white))),
                    DropdownMenuItem(value: 'expiry', child: Text('Expiry Date', style: TextStyle(color: Colors.white))),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String categoryId, String label) {
    final isSelected = _selectedCategory == categoryId;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = categoryId;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.stockistColor : AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.stockistColor : AppTheme.borderDark,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsBar() {
    final totalProducts = _products.length;
    final lowStockProducts = _products.where((p) => 
      p['status'] == 'low_stock' || p['status'] == 'critical'
    ).length;
    final criticalProducts = _products.where((p) => p['status'] == 'critical').length;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: GlassmorphicStatCard(
              title: 'Total Products',
              value: '$totalProducts',
              icon: Icons.inventory,
              color: AppTheme.stockistColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GlassmorphicStatCard(
              title: 'Low Stock',
              value: '$lowStockProducts',
              icon: Icons.warning,
              color: AppTheme.warning,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GlassmorphicStatCard(
              title: 'Critical',
              value: '$criticalProducts',
              icon: Icons.error,
              color: AppTheme.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList() {
    final filteredProducts = _filteredProducts;
    
    if (filteredProducts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_outlined, size: 64, color: AppTheme.textSecondary),
            SizedBox(height: 16),
            Text(
              'No products found',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 18),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        return _buildProductCard(filteredProducts[index]);
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final status = product['status'] as String;
    final stock = product['stock'] as int;
    final threshold = product['lowStockThreshold'] as int;
    final statusColor = _getStockStatusColor(status, stock, threshold);
    final statusIcon = _getStockStatusIcon(status, stock, threshold);
    
    return GlassmorphicCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'SKU: ${product['sku']}',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product['category'],
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        status.toUpperCase().replaceAll('_', ' '),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stock: $stock units',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Threshold: $threshold units',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'NPR ${product['unitPrice'].toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Supplier: ${product['supplier']}',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Last Restock: ${_formatDate(product['lastRestock'])}',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Expiry: ${_formatDate(product['expiryDate'])}',
                  style: TextStyle(
                    color: _isExpiringSoon(product['expiryDate']) 
                        ? AppTheme.warning 
                        : AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GlassmorphicButton(
                    text: 'Update Stock',
                    icon: Icons.edit,
                    onPressed: () => _updateProductStock(product),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GlassmorphicButton(
                    text: 'Restock',
                    icon: Icons.add_shopping_cart,
                    onPressed: () => _restockProduct(product),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStockStatusColor(String status, int stock, int threshold) {
    switch (status) {
      case 'critical':
        return AppTheme.error;
      case 'low_stock':
        return AppTheme.warning;
      case 'normal':
        return AppTheme.success;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _getStockStatusIcon(String status, int stock, int threshold) {
    switch (status) {
      case 'critical':
        return Icons.error;
      case 'low_stock':
        return Icons.warning;
      case 'normal':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  bool _isExpiringSoon(String expiryDate) {
    final expiry = DateTime.parse(expiryDate);
    final now = DateTime.now();
    final daysUntilExpiry = expiry.difference(now).inDays;
    return daysUntilExpiry <= 30;
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddProductDialog(
        onSuccess: () => _loadProducts(),
      ),
    );
  }

  void _showLowStockAlerts() {
    final lowStockProducts = _products.where((p) => 
      p['status'] == 'low_stock' || p['status'] == 'critical'
    ).toList();
    
    showDialog(
      context: context,
      builder: (context) => _LowStockAlertsDialog(
        lowStockProducts: lowStockProducts,
      ),
    );
  }

  void _updateProductStock(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => _UpdateStockDialog(
        product: product,
        onSuccess: () => _loadProducts(),
      ),
    );
  }

  void _restockProduct(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => _RestockDialog(
        product: product,
        onSuccess: () => _loadProducts(),
      ),
    );
  }

  Future<void> _updateStockLevels() async {
    try {
      // TODO: Replace with real API call - POST /api/stockist/inventory/update
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stock levels updated successfully'),
            backgroundColor: AppTheme.success,
          ),
        );
        _loadProducts();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update stock levels: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }
}

class _AddProductDialog extends StatefulWidget {
  final VoidCallback onSuccess;

  const _AddProductDialog({required this.onSuccess, Key? key}) : super(key: key);

  @override
  State<_AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<_AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _thresholdController = TextEditingController();
  final _supplierController = TextEditingController();
  DateTime? _expiryDate;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surfaceDark,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add New Product',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              Expanded(
                child: ListView(
                  children: [
                    _buildTextField('Product Name', _nameController, validator: (value) {
                      if (value == null || value.isEmpty) return 'Product name is required';
                      return null;
                    }),
                    _buildTextField('SKU', _skuController, validator: (value) {
                      if (value == null || value.isEmpty) return 'SKU is required';
                      return null;
                    }),
                    _buildTextField('Unit Price (NPR)', _priceController, 
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Price is required';
                        if (double.tryParse(value) == null) return 'Invalid price';
                        return null;
                      }),
                    _buildTextField('Current Stock', _stockController, 
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Stock is required';
                        if (int.tryParse(value) == null) return 'Invalid stock quantity';
                        return null;
                      }),
                    _buildTextField('Low Stock Threshold', _thresholdController, 
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Threshold is required';
                        if (int.tryParse(value) == null) return 'Invalid threshold';
                        return null;
                      }),
                    _buildTextField('Supplier', _supplierController, validator: (value) {
                      if (value == null || value.isEmpty) return 'Supplier is required';
                      return null;
                    }),
                    
                    const SizedBox(height: 16),
                    
                    // Expiry Date
                    const Text(
                      'Expiry Date',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _selectExpiryDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.borderDark),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, color: AppTheme.textSecondary),
                            const SizedBox(width: 12),
                            Text(
                              _expiryDate != null 
                                  ? '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}'
                                  : 'Select expiry date',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: GlassmorphicButton(
                  text: 'Add Product',
                  icon: Icons.check,
                  onPressed: _isSubmitting ? null : _submitProduct,
                  isLoading: _isSubmitting,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, 
      {TextInputType? keyboardType, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: Colors.white),
          decoration: AppTheme.inputDecoration(''),
        ),
      ],
    );
  }

  Future<void> _selectExpiryDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 1095)), // 3 years
    );
    
    if (date != null) {
      setState(() {
        _expiryDate = date;
      });
    }
  }

  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isSubmitting = true;
    });

    try {
      // TODO: Replace with real API call - POST /api/stockist/products
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product added successfully'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add product: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}

class _LowStockAlertsDialog extends StatelessWidget {
  final List<Map<String, dynamic>> lowStockProducts;

  const _LowStockAlertsDialog({required this.lowStockProducts, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surfaceDark,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Low Stock Alerts',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            Expanded(
              child: ListView.builder(
                itemCount: lowStockProducts.length,
                itemBuilder: (context, index) {
                  final product = lowStockProducts[index];
                  return _buildAlertItem(product);
                },
              ),
            ),
            
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              child: GlassmorphicButton(
                text: 'Close',
                icon: Icons.close,
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertItem(Map<String, dynamic> product) {
    final status = product['status'] as String;
    final stock = product['stock'] as int;
    final threshold = product['lowStockThreshold'] as int;
    
    return GlassmorphicCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    product['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: status == 'critical' ? AppTheme.error : AppTheme.warning,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toUpperCase().replaceAll('_', ' '),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Current Stock: $stock',
                  style: const TextStyle(color: Colors.white),
                ),
                const Spacer(),
                Text(
                  'Threshold: $threshold',
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'SKU: ${product['sku']}',
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpdateStockDialog extends StatefulWidget {
  final Map<String, dynamic> product;
  final VoidCallback onSuccess;

  const _UpdateStockDialog({
    required this.product,
    required this.onSuccess,
    Key? key,
  }) : super(key: key);

  @override
  State<_UpdateStockDialog> createState() => _UpdateStockDialogState();
}

class _UpdateStockDialogState extends State<_UpdateStockDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _stockController;
  late TextEditingController _thresholdController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _stockController = TextEditingController(text: widget.product['stock'].toString());
    _thresholdController = TextEditingController(text: widget.product['lowStockThreshold'].toString());
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surfaceDark,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        height: MediaQuery.of(context).size.height * 0.4,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Update Stock: ${widget.product['name']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              _buildTextField('Current Stock', _stockController, 
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Stock is required';
                  if (int.tryParse(value) == null) return 'Invalid stock quantity';
                  return null;
                }),
              _buildTextField('Low Stock Threshold', _thresholdController, 
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Threshold is required';
                  if (int.tryParse(value) == null) return 'Invalid threshold';
                  return null;
                }),
              
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: GlassmorphicButton(
                      text: 'Update',
                      icon: Icons.check,
                      onPressed: _isSubmitting ? null : _submitUpdate,
                      isLoading: _isSubmitting,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassmorphicButton(
                      text: 'Cancel',
                      icon: Icons.close,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, 
      {TextInputType? keyboardType, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: Colors.white),
          decoration: AppTheme.inputDecoration(''),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isSubmitting = true;
    });

    try {
      // TODO: Replace with real API call - PATCH /api/stockist/inventory/{id}
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stock updated successfully'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update stock: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}

class _RestockDialog extends StatefulWidget {
  final Map<String, dynamic> product;
  final VoidCallback onSuccess;

  const _RestockDialog({
    required this.product,
    required this.onSuccess,
    Key? key,
  }) : super(key: key);

  @override
  State<_RestockDialog> createState() => _RestockDialogState();
}

class _RestockDialogState extends State<_RestockDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _quantityController;
  late TextEditingController _costController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController();
    _costController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surfaceDark,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        height: MediaQuery.of(context).size.height * 0.4,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Restock: ${widget.product['name']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              _buildTextField('Restock Quantity', _quantityController, 
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Quantity is required';
                  if (int.tryParse(value) == null) return 'Invalid quantity';
                  return null;
                }),
              _buildTextField('Total Cost (NPR)', _costController, 
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Cost is required';
                  if (double.tryParse(value) == null) return 'Invalid cost';
                  return null;
                }),
              
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: GlassmorphicButton(
                      text: 'Restock',
                      icon: Icons.add_shopping_cart,
                      onPressed: _isSubmitting ? null : _submitRestock,
                      isLoading: _isSubmitting,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassmorphicButton(
                      text: 'Cancel',
                      icon: Icons.close,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, 
      {TextInputType? keyboardType, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: Colors.white),
          decoration: AppTheme.inputDecoration(''),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _submitRestock() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isSubmitting = true;
    });

    try {
      // TODO: Replace with real API call - POST /api/stockist/restock
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product restocked successfully'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to restock product: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
