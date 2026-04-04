import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/premium_glassmorphic_theme.dart';
import '../../../../shared/widgets/enhanced_animations.dart';
import '../../../../shared/utils/nepal_localization_utils.dart';
import '../providers/distribution_provider.dart';

/// Inventory Management Widget for Distribution Dashboard
class InventoryManagementWidget extends StatefulWidget {
  const InventoryManagementWidget({Key? key}) : super(key: key);

  @override
  State<InventoryManagementWidget> createState() => _InventoryManagementWidgetState();
}

class _InventoryManagementWidgetState extends State<InventoryManagementWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  String _selectedFilter = 'all';
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    // Start animation
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DistributionProvider>(
      builder: (context, provider, child) {
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: PremiumGlassmorphicTheme.buildGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      _buildHeader(),
                      
                      const SizedBox(height: 16),
                      
                      // Inventory metrics
                      _buildInventoryMetrics(provider),
                      
                      const SizedBox(height: 24),
                      
                      // Filter controls
                      _buildFilterControls(),
                      
                      const SizedBox(height: 16),
                      
                      // Inventory status overview
                      _buildInventoryStatusOverview(provider),
                      
                      const SizedBox(height: 24),
                      
                      // Stock alerts
                      _buildStockAlerts(provider),
                      
                      const SizedBox(height: 24),
                      
                      // Inventory list
                      _buildInventoryList(provider),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.inventory_2,
            color: Colors.blue,
            size: 24,
          ),
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Inventory Management',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Track and manage product inventory levels',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
        
        // Add inventory button
        Container(
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.add, color: Colors.blue),
            onPressed: () {
              // Show add inventory dialog
              _showAddInventoryDialog();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryMetrics(DistributionProvider provider) {
    return Row(
      children: [
        // Total products
        Expanded(
          child: _buildMetricCard(
            'Total Products',
            '${provider.inventoryAllocations.length}',
            Icons.category,
            Colors.blue,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // In stock
        Expanded(
          child: _buildMetricCard(
            'In Stock',
            '${provider.inventoryAllocations.where((item) => item.quantity > 0).length}',
            Icons.check_circle,
            Colors.green,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Low stock
        Expanded(
          child: _buildMetricCard(
            'Low Stock',
            '${provider.inventoryAllocations.where((item) => item.quantity <= item.minStockLevel).length}',
            Icons.warning,
            Colors.orange,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Out of stock
        Expanded(
          child: _buildMetricCard(
            'Out of Stock',
            '${provider.inventoryAllocations.where((item) => item.quantity == 0).length}',
            Icons.error,
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterControls() {
    return Row(
      children: [
        // Filter dropdown
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: DropdownButton<String>(
              value: _selectedFilter,
              hint: const Text('Filter by...', style: TextStyle(color: Colors.white54)),
              isExpanded: true,
              dropdownColor: Colors.black87,
              style: const TextStyle(color: Colors.white),
              items: [
                const DropdownMenuItem(value: 'all', child: Text('All Products')),
                const DropdownMenuItem(value: 'low_stock', child: Text('Low Stock')),
                const DropdownMenuItem(value: 'out_of_stock', child: Text('Out of Stock')),
                const DropdownMenuItem(value: 'expiring', child: Text('Expiring Soon')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
              },
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Status dropdown
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: DropdownButton<String>(
              value: _selectedStatus,
              hint: const Text('Status...', style: TextStyle(color: Colors.white54)),
              isExpanded: true,
              dropdownColor: Colors.black87,
              style: const TextStyle(color: Colors.white),
              items: [
                const DropdownMenuItem(value: 'all', child: Text('All Status')),
                const DropdownMenuItem(value: 'active', child: Text('Active')),
                const DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                const DropdownMenuItem(value: 'discontinued', child: Text('Discontinued')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryStatusOverview(DistributionProvider provider) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Inventory Status Overview',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Placeholder for inventory status chart
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'Inventory Status Chart\n(Implementation Required)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockAlerts(DistributionProvider provider) {
    final lowStockItems = provider.inventoryAllocations
        .where((item) => item.quantity <= item.minStockLevel)
        .toList();
    
    if (lowStockItems.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'All inventory levels are healthy',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.warning, color: Colors.orange),
            const SizedBox(width: 8),
            Text(
              '${lowStockItems.length} items need attention',
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Low stock items
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: lowStockItems.length > 3 ? 3 : lowStockItems.length,
          itemBuilder: (context, index) {
            final item = lowStockItems[index];
            return _buildStockAlertItem(item);
          },
        ),
      ],
    );
  }

  Widget _buildStockAlertItem(dynamic item) {
    final isOutOfStock = item.quantity == 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOutOfStock ? Colors.red.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOutOfStock ? Colors.red.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isOutOfStock ? Icons.error : Icons.warning,
            color: isOutOfStock ? Colors.red : Colors.orange,
            size: 20,
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName ?? 'Unknown Product',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Current: ${item.quantity} • Min: ${item.minStockLevel}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Action button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: IconButton(
              icon: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 16),
              onPressed: () {
                // Reorder item
                _reorderItem(item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryList(DistributionProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Inventory Items',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${provider.inventoryAllocations.length} items',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Inventory items list
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.inventoryAllocations.length > 10 ? 10 : provider.inventoryAllocations.length,
          itemBuilder: (context, index) {
            final item = provider.inventoryAllocations[index];
            return _buildInventoryItem(item);
          },
        ),
      ],
    );
  }

  Widget _buildInventoryItem(dynamic item) {
    final stockLevel = _getStockLevel(item.quantity, item.minStockLevel);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          // Stock level indicator
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: stockLevel.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName ?? 'Unknown Product',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'SKU: ${item.sku ?? 'N/A'} • Location: ${item.location ?? 'N/A'}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Quantity and status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.quantity}',
                style: TextStyle(
                  color: stockLevel.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                stockLevel.label,
                style: TextStyle(
                  color: stockLevel.color,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  StockLevel _getStockLevel(int quantity, int minStockLevel) {
    if (quantity == 0) {
      return StockLevel('Out of Stock', Colors.red);
    } else if (quantity <= minStockLevel) {
      return StockLevel('Low Stock', Colors.orange);
    } else {
      return StockLevel('In Stock', Colors.green);
    }
  }

  void _showAddInventoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Inventory'),
        content: const Text('Add inventory functionality would be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _reorderItem(dynamic item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reorder Item'),
        content: Text('Reorder functionality for ${item.productName} would be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Reorder'),
          ),
        ],
      ),
    );
  }
}

class StockLevel {
  final String label;
  final Color color;
  
  StockLevel(this.label, this.color);
}
