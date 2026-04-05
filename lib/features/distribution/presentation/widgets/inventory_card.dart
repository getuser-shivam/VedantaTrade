import 'package:flutter/material.dart';
import '../../domain/models/inventory_entity.dart';

class InventoryCard extends StatelessWidget {
  final InventoryEntity inventory;
  final VoidCallback? onTap;
  final Function(int quantity, String reason)? onStockAdjust;

  const InventoryCard({
    Key? key,
    required this.inventory,
    this.onTap,
    this.onStockAdjust,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          inventory.productId,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Location: ${inventory.location}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStockStatusColor(inventory.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      inventory.statusDisplay,
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
              // Stock Information
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Stock',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${inventory.currentStock} units',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available Stock',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${inventory.availableStock} units',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Stock Level Indicator
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _getStockUtilization(inventory),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getStockUtilizationColor(inventory),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Storage Information
              if (inventory.requiresSpecialStorage)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.ac_unit,
                            size: 16,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Storage Requirements',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (inventory.requiresTemperatureControl)
                        Row(
                          children: [
                            Icon(
                              Icons.thermostat,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Temperature: ${inventory.storageTemperature?.toStringAsFixed(1)}°C',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      if (inventory.requiresHumidityControl)
                        Row(
                          children: [
                            Icon(
                              Icons.water_drop,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Humidity: ${inventory.storageHumidity?.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              // Risk Assessment
              if (inventory.stockoutRiskScore > 0)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getRiskColor(inventory.stockoutRiskScore),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning,
                        size: 16,
                        color: _getRiskColor(inventory.stockoutRiskScore),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Risk Level: ${inventory.riskLevel}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _getRiskColor(inventory.stockoutRiskScore),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Score: ${inventory.stockoutRiskScore.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: _getRiskColor(inventory.stockoutRiskScore),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              // Recommendations
              if (inventory.recommendations.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb,
                            size: 16,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Recommendations',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...inventory.recommendations.map((recommendation) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.arrow_right,
                              size: 12,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                recommendation,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              // Quick Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _adjustStock('increase'),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Stock'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _adjustStock('decrease'),
                      icon: const Icon(Icons.remove),
                      label: const Text('Remove Stock'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _transferStock(),
                      icon: const Icon(Icons.swap_horiz),
                      label: const Text('Transfer'),
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

  Color _getStockStatusColor(InventoryStatus status) {
    switch (status) {
      case InventoryStatus.inStock:
        return Colors.green;
      case InventoryStatus.lowStock:
        return Colors.orange;
      case InventoryStatus.outOfStock:
        return Colors.red;
      case InventoryStatus.reserved:
        return Colors.blue;
      case InventoryStatus.onOrder:
        return Colors.purple;
      case InventoryStatus.damaged:
        return Colors.red;
      case InventoryStatus.expired:
        return Colors.red;
    }
  }

  double _getStockUtilization(InventoryEntity inventory) {
    return inventory.stockUtilization.clamp(0.0, 1.0);
  }

  Color _getStockUtilizationColor(InventoryEntity inventory) {
    final utilization = _getStockUtilization(inventory);
    if (utilization >= 0.8) return Colors.red;
    if (utilization >= 0.6) return Colors.orange;
    if (utilization >= 0.4) return Colors.yellow;
    return Colors.green;
  }

  Color _getRiskColor(double riskScore) {
    if (riskScore >= 80) return Colors.red;
    if (riskScore >= 60) return Colors.orange;
    if (riskScore >= 40) return Colors.yellow;
    return Colors.green;
  }

  void _adjustStock(String action) {
    if (onStockAdjust == null) return;
    
    final quantity = action == 'increase' ? 10 : -10;
    final reason = action == 'increase' ? 'Manual stock addition' : 'Manual stock removal';
    onStockAdjust!(quantity, reason);
  }

  void _transferStock() {
    // Implementation for stock transfer
  }
}
