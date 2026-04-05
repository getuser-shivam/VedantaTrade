import 'package:flutter/material.dart';
import '../../domain/models/order_entity.dart';

class OrderCard extends StatelessWidget {
  final OrderEntity order;
  final VoidCallback? onTap;
  final Function(OrderStatus)? onStatusUpdate;

  const OrderCard({
    Key? key,
    required this.order,
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
                          'Order #${order.orderNumber}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.customerName ?? 'Unknown Customer',
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
                      color: _getStatusColor(order.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.statusDisplay,
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
              // Order Details
              Row(
                children: [
                  Icon(
                    Icons.shopping_cart,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${order.totalItems} items',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    order.formattedTotalAmount,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Delivery Type
              Row(
                children: [
                  Icon(
                    Icons.local_shipping,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    order.deliveryTypeDisplay,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const Spacer(),
                  if (order.isPriorityOrder)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'PRIORITY',
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
              // Payment Status
              Row(
                children: [
                  Icon(
                    Icons.payment,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    order.paymentStatusDisplay,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const Spacer(),
                  if (order.isPaymentCompleted)
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Colors.green,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Dates
              Row(
                children: [
                  Icon(
                    Icons.date_range,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Created: ${_formatDate(order.createdAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  if (order.estimatedDeliveryDate != null)
                    Text(
                      'Est. Delivery: ${_formatDate(order.estimatedDeliveryDate!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Risk Assessment
              if (order.fraudRiskScore > 0)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getRiskColor(order.fraudRiskScore),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning,
                        size: 16,
                        color: _getRiskColor(order.fraudRiskScore),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Risk Level: ${order.riskLevel}',
                        style: TextStyle(
                          color: _getRiskColor(order.fraudRiskScore),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Score: ${order.fraudRiskScore.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: _getRiskColor(order.fraudRiskScore),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showDetails(context),
                      icon: const Icon(Icons.visibility),
                      label: const Text('View Details'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatusButton(context, order),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusButton(BuildContext context, OrderEntity order) {
    switch (order.status) {
      case OrderStatus.pending:
        return ElevatedButton.icon(
          onPressed: () => onStatusUpdate?.call(OrderStatus.confirmed),
          icon: const Icon(Icons.check),
          label: const Text('Confirm'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        );
      case OrderStatus.confirmed:
        return ElevatedButton.icon(
          onPressed: () => onStatusUpdate?.call(OrderStatus.processing),
          icon: const Icon(Icons.inventory),
          label: const Text('Process'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        );
      case OrderStatus.processing:
        return ElevatedButton.icon(
          onPressed: () => onStatusUpdate?.call(OrderStatus.shipped),
          icon: const Icon(Icons.local_shipping),
          label: const Text('Ship'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
        );
      case OrderStatus.shipped:
        return ElevatedButton.icon(
          onPressed: () => onStatusUpdate?.call(OrderStatus.delivered),
          icon: const Icon(Icons.check_circle),
          label: const Text('Mark Delivered'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        );
      case OrderStatus.delivered:
        return ElevatedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.check_circle),
          label: const Text('Delivered'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white,
          ),
        );
      case OrderStatus.cancelled:
        return ElevatedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.cancel),
          label: const Text('Cancelled'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        );
      case OrderStatus.returned:
        return ElevatedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.keyboard_return),
          label: const Text('Returned'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
          ),
        );
      case OrderStatus.refunded:
        return ElevatedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.money_off),
          label: const Text('Refunded'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        );
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.processing:
        return Colors.purple;
      case OrderStatus.shipped:
        return Colors.indigo;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.returned:
        return Colors.purple;
      case OrderStatus.refunded:
        return Colors.red;
    }
  }

  Color _getRiskColor(double riskScore) {
    if (riskScore >= 50) return Colors.red;
    if (riskScore >= 30) return Colors.orange;
    if (riskScore >= 15) return Colors.yellow;
    return Colors.green;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDetails(BuildContext context) {
    // Navigate to order details
  }
}
