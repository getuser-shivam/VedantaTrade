import 'package:flutter/material.dart';
import 'package:vedanta_trade/shared/widgets/glassmorphic_widgets.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';

/// Inventory Status Indicator Widget
class InventoryStatusIndicator extends StatelessWidget {
  final int stockQuantity;
  final int reorderLevel;
  final int maxCapacity;
  final String? lastUpdated;

  const InventoryStatusIndicator({
    Key? key,
    required this.stockQuantity,
    required this.reorderLevel,
    required this.maxCapacity,
    this.lastUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stockPercentage = (stockQuantity / maxCapacity).clamp(0.0, 1.0);
    final stockStatus = _getStockStatus(stockQuantity, reorderLevel);
    final stockColor = _getStockColor(stockStatus);

    return GlassmorphicCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                _getStockIcon(stockStatus),
                color: stockColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Inventory Status',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: stockColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: stockColor, width: 1),
                ),
                child: Text(
                  stockStatus,
                  style: TextStyle(
                    color: stockColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Stock Quantity
          Row(
            children: [
              Text(
                '$stockQuantity units',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                'of $maxCapacity',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Progress Bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              children: [
                // Background
                Container(
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // Fill
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: double.infinity * stockPercentage,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: stockColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // Reorder level indicator
                Positioned(
                  left: double.infinity * (reorderLevel / maxCapacity),
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 2,
                    color: AppTheme.warning,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Legend
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: stockColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Current Stock',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppTheme.warning,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Reorder Level',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          
          if (lastUpdated != null) ...[
            const SizedBox(height: 12),
            Text(
              'Last updated: $lastUpdated',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getStockStatus(int quantity, int reorderLevel) {
    if (quantity == 0) return 'Out of Stock';
    if (quantity <= reorderLevel) return 'Low Stock';
    if (quantity <= reorderLevel * 2) return 'Medium Stock';
    return 'In Stock';
  }

  Color _getStockColor(String status) {
    switch (status) {
      case 'Out of Stock':
        return AppTheme.error;
      case 'Low Stock':
        return AppTheme.warning;
      case 'Medium Stock':
        return AppTheme.info;
      default:
        return AppTheme.success;
    }
  }

  IconData _getStockIcon(String status) {
    switch (status) {
      case 'Out of Stock':
        return Icons.inventory_2_outlined;
      case 'Low Stock':
        return Icons.warning_amber;
      case 'Medium Stock':
        return Icons.inventory;
      default:
        return Icons.check_circle;
    }
  }
}

/// Real-time Stock Monitor Widget
class RealTimeStockMonitor extends StatefulWidget {
  final String productId;
  final Function(int)? onStockUpdate;

  const RealTimeStockMonitor({
    Key? key,
    required this.productId,
    this.onStockUpdate,
  }) : super(key: key);

  @override
  State<RealTimeStockMonitor> createState() => _RealTimeStockMonitorState();
}

class _RealTimeStockMonitorState extends State<RealTimeStockMonitor>
    with SingleTickerProviderStateMixin {
  int _currentStock = 0;
  int _previousStock = 0;
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _loadInitialStock();
    _startRealTimeMonitoring();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadInitialStock() {
    // TODO: Load initial stock from API
    setState(() {
      _currentStock = 150; // Example value
      _previousStock = _currentStock;
    });
  }

  void _startRealTimeMonitoring() {
    // Simulate real-time updates
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _simulateStockUpdate();
      }
    });
  }

  void _simulateStockUpdate() {
    final randomChange = (DateTime.now().millisecond % 21) - 10; // -10 to +10
    final newStock = (_currentStock + randomChange).clamp(0, 500);
    
    setState(() {
      _previousStock = _currentStock;
      _currentStock = newStock;
    });

    if (newStock != _previousStock) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
      
      widget.onStockUpdate?.call(newStock);
      
      // Schedule next update
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          _simulateStockUpdate();
        }
      });
    } else {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _simulateStockUpdate();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _currentStock != _previousStock ? _pulseAnimation.value : 1.0,
          child: InventoryStatusIndicator(
            stockQuantity: _currentStock,
            reorderLevel: 50,
            maxCapacity: 500,
            lastUpdated: DateTime.now().toString().substring(11, 19),
          ),
        );
      },
    );
  }
}

/// Stock Alert Widget
class StockAlertWidget extends StatelessWidget {
  final List<String> lowStockProducts;
  final List<String> outOfStockProducts;

  const StockAlertWidget({
    Key? key,
    required this.lowStockProducts,
    required this.outOfStockProducts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasAlerts = lowStockProducts.isNotEmpty || outOfStockProducts.isNotEmpty;
    
    if (!hasAlerts) {
      return GlassmorphicCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: AppTheme.success,
              size: 20,
            ),
            const SizedBox(width: 12),
            const Text(
              'All products have adequate stock levels',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return GlassmorphicCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning,
                color: AppTheme.warning,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Stock Alerts',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.warning, width: 1),
                ),
                child: Text(
                  '${lowStockProducts.length + outOfStockProducts.length}',
                  style: const TextStyle(
                    color: AppTheme.warning,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Out of Stock
          if (outOfStockProducts.isNotEmpty) ...[
            _buildAlertSection(
              'Out of Stock',
              outOfStockProducts,
              AppTheme.error,
              Icons.inventory_2_outlined,
            ),
            const SizedBox(height: 8),
          ],
          
          // Low Stock
          if (lowStockProducts.isNotEmpty) ...[
            _buildAlertSection(
              'Low Stock',
              lowStockProducts,
              AppTheme.warning,
              Icons.warning_amber,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAlertSection(
    String title,
    List<String> products,
    Color color,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ...products.map((product) => Padding(
          padding: const EdgeInsets.only(left: 20, top: 2),
          child: Text(
            product,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        )),
      ],
    );
  }
}
