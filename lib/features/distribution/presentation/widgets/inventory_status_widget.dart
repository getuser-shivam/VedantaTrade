import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/widgets/premium_glassmorphic_theme.dart';
import '../../data/services/distribution_management_service.dart';
import '../providers/distribution_provider.dart';

class InventoryStatusWidget extends StatefulWidget {
  const InventoryStatusWidget({Key? key}) : super(key: key);

  @override
  State<InventoryStatusWidget> createState() => _InventoryStatusWidgetState();
}

class _InventoryStatusWidgetState extends State<InventoryStatusWidget> {
  late DistributionManagementService _distributionService;

  @override
  void initState() {
    super.initState();
    _distributionService = DistributionManagementService();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<InventoryItem>>(
      stream: _distributionService.inventoryStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        }

        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        }

        final inventory = snapshot.data ?? [];
        final lowStockItems = _distributionService.getLowStockItems();
        final outOfStockItems = _distributionService.getOutOfStockItems();
        
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withOpacity(0.05),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.inventory_outlined,
                    color: PremiumGlassmorphicTheme.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Inventory Status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: PremiumGlassmorphicTheme.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: PremiumGlassmorphicTheme.primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${inventory.length} Items',
                      style: TextStyle(
                        color: PremiumGlassmorphicTheme.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Status Summary Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatusCard(
                      'Low Stock',
                      lowStockItems.length.toString(),
                      Colors.orange,
                      Icons.warning_outlined,
                      'Items need reordering',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatusCard(
                      'Out of Stock',
                      outOfStockItems.length.toString(),
                      Colors.red,
                      Icons.error_outline,
                      'Immediate attention',
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Critical Items List
              if (lowStockItems.isNotEmpty || outOfStockItems.isNotEmpty)
                _buildCriticalItemsList(lowStockItems, outOfStockItems),
              
              const SizedBox(height: 20),
              
              // Categories Overview
              _buildCategoriesOverview(inventory),
              
              const SizedBox(height: 20),
              
              // Quick Actions
              _buildQuickActions(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusCard(String title, String count, Color color, IconData icon, String subtitle) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.1),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: PremiumGlassmorphicTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: PremiumGlassmorphicTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCriticalItemsList(List<InventoryItem> lowStockItems, List<InventoryItem> outOfStockItems) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.red.withOpacity(0.05),
        border: Border.all(
          color: Colors.red.withOpacity(0.2),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.crisis_alert_outlined,
                color: Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Critical Items',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Out of Stock Items
          if (outOfStockItems.isNotEmpty) ...[
            Text(
              'Out of Stock',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: PremiumGlassmorphicTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ...outOfStockItems.take(3).map((item) => _buildCriticalItemRow(item, true)),
            if (outOfStockItems.length > 3)
              Text(
                '... and ${outOfStockItems.length - 3} more',
                style: TextStyle(
                  fontSize: 12,
                  color: PremiumGlassmorphicTheme.textSecondary,
                ),
              ),
            const SizedBox(height: 12),
          ],
          
          // Low Stock Items
          if (lowStockItems.isNotEmpty) ...[
            Text(
              'Low Stock',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: PremiumGlassmorphicTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ...lowStockItems.take(3).map((item) => _buildCriticalItemRow(item, false)),
            if (lowStockItems.length > 3)
              Text(
                '... and ${lowStockItems.length - 3} more',
                style: TextStyle(
                  fontSize: 12,
                  color: PremiumGlassmorphicTheme.textSecondary,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildCriticalItemRow(InventoryItem item, bool isOutOfStock) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isOutOfStock ? Colors.red : Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: PremiumGlassmorphicTheme.textPrimary,
                  ),
                ),
                Text(
                  '${item.sku} • Stock: ${item.currentStock}',
                  style: TextStyle(
                    fontSize: 12,
                    color: PremiumGlassmorphicTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            isOutOfStock ? 'OUT' : 'LOW',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isOutOfStock ? Colors.red : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesOverview(List<InventoryItem> inventory) {
    final categories = <String, int>{};
    for (final item in inventory) {
      categories[item.category] = (categories[item.category] ?? 0) + 1;
    }
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categories',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: PremiumGlassmorphicTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          
          ...categories.entries.map((entry) => _buildCategoryRow(entry.key, entry.value)),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(String category, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.category_outlined,
            color: PremiumGlassmorphicTheme.primaryColor,
            size: 16,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              category,
              style: TextStyle(
                fontSize: 14,
                color: PremiumGlassmorphicTheme.textPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: PremiumGlassmorphicTheme.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                color: PremiumGlassmorphicTheme.primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: PremiumGlassmorphicTheme.primaryColor.withOpacity(0.1),
        border: Border.all(
          color: PremiumGlassmorphicTheme.primaryColor.withOpacity(0.3),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: PremiumGlassmorphicTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Reorder',
                  Icons.shopping_cart_outlined,
                  () => _handleReorder(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'Transfer',
                  Icons.swap_horiz_outlined,
                  () => _handleTransfer(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'Report',
                  Icons.assessment_outlined,
                  () => _handleReport(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white.withOpacity(0.1),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: PremiumGlassmorphicTheme.primaryColor,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: PremiumGlassmorphicTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleReorder() {
    // Handle reorder action
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reorder functionality coming soon'),
        backgroundColor: PremiumGlassmorphicTheme.primaryColor,
      ),
    );
  }

  void _handleTransfer() {
    // Handle transfer action
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transfer functionality coming soon'),
        backgroundColor: PremiumGlassmorphicTheme.primaryColor,
      ),
    );
  }

  void _handleReport() {
    // Handle report action
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Report functionality coming soon'),
        backgroundColor: PremiumGlassmorphicTheme.primaryColor,
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.inventory_outlined,
              color: PremiumGlassmorphicTheme.primaryColor,
              size: 40,
            ),
            const SizedBox(height: 16),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                PremiumGlassmorphicTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.red.withOpacity(0.1),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 40,
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Inventory',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              fontSize: 14,
              color: Colors.red.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
