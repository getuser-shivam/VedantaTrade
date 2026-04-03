import 'package:flutter/material.dart';

class StockAlert {
  final String productName;
  final String centerName;
  final double quantityAvailable;
  final double quantityAllocated;
  final double threshold;
  final DateTime lastActivity;
  final String alertType;

  StockAlert({
    required this.productName,
    required this.centerName,
    required this.quantityAvailable,
    required this.quantityAllocated,
    required this.threshold,
    required this.lastActivity,
    required this.alertType,
  });

  factory StockAlert.fromJson(Map<String, dynamic> json) {
    return StockAlert(
      productName: json['product_name'] ?? '',
      centerName: json['center_name'] ?? '',
      quantityAvailable: (json['quantity_available'] ?? 0).toDouble(),
      quantityAllocated: (json['quantity_allocated'] ?? 0).toDouble(),
      threshold: (json['threshold'] ?? 0).toDouble(),
      lastActivity: DateTime.parse(json['last_activity'] ?? DateTime.now().toIso8601String()),
      alertType: json['alert_type'] ?? 'UNKNOWN',
    );
  }
}

class StockAlertWidget extends StatelessWidget {
  final StockAlert alert;
  final VoidCallback? onTap;

  const StockAlertWidget({
    Key? key,
    required this.alert,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getAlertColor(alert.alertType),
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with alert type and icon
                Row(
                  children: [
                    Icon(
                      _getAlertIcon(alert.alertType),
                      size: 24,
                      color: _getAlertColor(alert.alertType),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getAlertTitle(alert.alertType),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            alert.centerName,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Product name
                Text(
                  alert.productName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Stock information
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Available Stock',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            alert.quantityAvailable.toString(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _getAlertColor(alert.alertType),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey[300],
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Threshold',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            alert.threshold.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Stock level indicator
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getAlertColor(alert.alertType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _getAlertMessage(alert.alertType),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _getAlertColor(alert.alertType),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      if (alert.alertType == 'LOW_STOCK')
                        Text(
                          '${((alert.quantityAvailable / alert.quantityAllocated) * 100).toStringAsFixed(1)}% of allocated stock',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                // Last activity
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Last activity: ${_formatDate(alert.lastActivity)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                
                // Quick actions
                if (alert.alertType == 'LOW_STOCK')
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 12),
                    child: ElevatedButton.icon(
                      onPressed: () => _handleQuickAction(context, alert),
                      icon: const Icon(Icons.inventory_2_outlined),
                      label: 'Reorder Stock',
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[800],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getAlertIcon(String alertType) {
    switch (alertType) {
      case 'OUT_OF_STOCK':
        return Icons.error_outline;
      case 'LOW_STOCK':
        return Icons.warning_amber;
      case 'OVERSTOCK':
        return Icons.inventory_2_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Color _getAlertColor(String alertType) {
    switch (alertType) {
      case 'OUT_OF_STOCK':
        return Colors.red;
      case 'LOW_STOCK':
        return Colors.orange;
      case 'OVERSTOCK':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getAlertTitle(String alertType) {
    switch (alertType) {
      case 'OUT_OF_STOCK':
        return 'Out of Stock Alert';
      case 'LOW_STOCK':
        return 'Low Stock Alert';
      case 'OVERSTOCK':
        return 'Overstock Alert';
      default:
        return 'Stock Alert';
    }
  }

  String _getAlertMessage(String alertType) {
    switch (alertType) {
      case 'OUT_OF_STOCK':
        return 'Product is completely out of stock';
      case 'LOW_STOCK':
        return 'Stock level is below 20% of allocated quantity';
      case 'OVERSTOCK':
        return 'Stock level exceeds 150% of allocated quantity';
      default:
        return 'Stock level requires attention';
    }
  }

  void _handleQuickAction(BuildContext context, StockAlert alert) {
    switch (alert.alertType) {
      case 'LOW_STOCK':
        _showReorderDialog(context, alert);
        break;
      case 'OUT_OF_STOCK':
        _showEmergencyReorderDialog(context, alert);
        break;
      case 'OVERSTOCK':
        _showTransferDialog(context, alert);
        break;
    }
  }

  void _showReorderDialog(BuildContext context, StockAlert alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reorder ${alert.productName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Stock: ${alert.quantityAvailable}'),
            Text('Suggested Reorder: ${(alert.quantityAllocated * 0.8).toStringAsFixed(0)}'),
            const SizedBox(height: 16),
            const Text('This will create a purchase order for the suggested quantity.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Implement reorder logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reorder order created successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Create Order'),
          ),
        ],
      ),
    );
  }

  void _showEmergencyReorderDialog(BuildContext context, StockAlert alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Reorder Required'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error, color: Colors.red[400]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${alert.productName} is completely out of stock at ${alert.centerName}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Suggested Emergency Order: ${(alert.quantityAllocated).toStringAsFixed(0)}'),
            const SizedBox(height: 8),
            const Text('This will be marked as high priority and expedited delivery.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[800],
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              // Implement emergency reorder logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Emergency reorder created successfully'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Emergency Order'),
          ),
        ],
      ),
    );
  }

  void _showTransferDialog(BuildContext context, StockAlert alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Transfer ${alert.productName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Stock: ${alert.quantityAvailable}'),
            Text('Allocated: ${alert.quantityAllocated}'),
            const SizedBox(height: 16),
            Text('This product is overstocked at ${alert.centerName}'),
            Text('Consider transferring excess stock to other centers.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Implement transfer logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Transfer initiated successfully'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Transfer Stock'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
