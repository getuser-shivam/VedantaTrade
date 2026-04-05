import 'package:flutter/material.dart';
import '../../domain/models/distribution_entity.dart';

class DistributionCard extends StatelessWidget {
  final DistributionEntity distribution;
  final VoidCallback? onTap;
  final Function(DistributionStatus)? onStatusUpdate;

  const DistributionCard({
    Key? key,
    required this.distribution,
    this.onTap,
    this.onStatusUpdate,
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
                          'Distribution #${distribution.id}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Order: ${distribution.orderId}',
                          style: TextStyle(
                            fontSize: 14,
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
                      color: _getStatusColor(distribution.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      distribution.statusDisplay,
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
              // Product Info
              Row(
                children: [
                  Icon(
                    Icons.inventory_2,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Product: ${distribution.productId}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Quantity and Value
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quantity',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${distribution.quantity} units',
                          style: const TextStyle(
                            fontSize: 16,
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
                          'Total Value',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          distribution.formattedTotalValue,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Route Info
              Row(
                children: [
                  Icon(
                    Icons.route,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'From: ${distribution.fromWarehouseId} → To: ${distribution.toWarehouseId}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Tracking Info
              if (distribution.hasTracking)
                Row(
                  children: [
                    Icon(
                      Icons.local_shipping,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tracking: ${distribution.trackingNumber}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 16),
                      onPressed: () => _copyTrackingNumber(distribution.trackingNumber!),
                      tooltip: 'Copy tracking number',
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              // Dates
              Row(
                children: [
                  if (distribution.shippedAt != null) ...[
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Shipped: ${_formatDate(distribution.shippedAt!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (distribution.estimatedDeliveryAt != null)
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Est. Delivery: ${_formatDate(distribution.estimatedDeliveryAt!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showDetails(context),
                      child: const Text('View Details'),
                    ),
                  ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatusButton(context, distribution),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusButton(BuildContext context, DistributionEntity distribution) {
    switch (distribution.status) {
      case DistributionStatus.pending:
        return ElevatedButton(
          onPressed: () => onStatusUpdate?.call(DistributionStatus.inTransit),
          child: const Text('Start Transit'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        );
      case DistributionStatus.inTransit:
        return ElevatedButton(
          onPressed: () => onStatusUpdate?.call(DistributionStatus.delivered),
          child: const Text('Mark Delivered'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        );
      case DistributionStatus.delivered:
        return ElevatedButton(
          onPressed: null,
          child: const Text('Delivered'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white,
          ),
        );
      case DistributionStatus.cancelled:
        return ElevatedButton(
          onPressed: null,
          child: const Text('Cancelled'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Color _getStatusColor(DistributionStatus status) {
    switch (status) {
      case DistributionStatus.pending:
        return Colors.orange;
      case DistributionStatus.inTransit:
        return Colors.blue;
      case DistributionStatus.delivered:
        return Colors.green;
      case DistributionStatus.cancelled:
        return Colors.red;
      case DistributionStatus.failed:
        return Colors.red;
      case DistributionStatus.returned:
        return Colors.purple;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDetails(BuildContext context) {
    // Navigate to distribution details
  }

  void _copyTrackingNumber(String trackingNumber) {
    // Copy tracking number to clipboard
  }
}
