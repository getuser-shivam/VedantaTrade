import 'package:flutter/material.dart';
import '../../../shared/widgets/premium_glassmorphic_theme.dart';
import '../../domain/models/sales_tracking_models.dart';

class TopPerformersWidget extends StatelessWidget {
  final String title;
  final List<dynamic> performers;
  final String type;

  const TopPerformersWidget({
    Key? key,
    required this.title,
    required this.performers,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumGlassmorphicTheme.glassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                type == 'product' ? Icons.inventory : Icons.people,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Top ${performers.length}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (performers.isEmpty)
            Center(
              child: Text(
                'No data available',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            )
          else
            Column(
              children: performers.asMap().entries.map((entry) {
                final index = entry.key;
                final performer = entry.value;
                return _buildPerformerItem(context, index + 1, performer);
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildPerformerItem(BuildContext context, int rank, dynamic performer) {
    String name = '';
    String subtitle = '';
    double value = 0.0;
    String valueLabel = '';

    if (performer is TopProduct) {
      name = performer.productName;
      subtitle = 'Product ID: ${performer.productId}';
      value = performer.revenue;
      valueLabel = 'Revenue: NPR ${value.toStringAsFixed(0)}';
    } else if (performer is TopDistributor) {
      name = performer.distributorName;
      subtitle = 'ID: ${performer.distributorId}';
      value = performer.performanceScore;
      valueLabel = 'Score: ${value.toStringAsFixed(1)}';
    }

    Color rankColor = _getRankColor(rank);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rankColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: TextStyle(
                  color: rankColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                valueLabel,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (performer is TopProduct) ...[
                const SizedBox(height: 4),
                Text(
                  '${performer.unitsSold} units',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ] else if (performer is TopDistributor) ...[
                const SizedBox(height: 4),
                Text(
                  '${performer.ordersCount} orders',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.brown;
      default:
        return Colors.blue;
    }
  }
}
