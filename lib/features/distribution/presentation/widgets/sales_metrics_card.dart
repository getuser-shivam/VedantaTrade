import 'package:flutter/material.dart';
import '../../../shared/widgets/premium_glassmorphic_theme.dart';

class SalesMetricsCard extends StatelessWidget {
  final String title;
  final double value;
  final IconData icon;
  final Color color;
  final double? growth;
  final String suffix;
  final bool isInteger;

  const SalesMetricsCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.growth,
    this.suffix = '',
    this.isInteger = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formattedValue = isInteger 
        ? value.toInt().toString()
        : value.toStringAsFixed(2) + suffix;
    
    final growthColor = growth != null 
        ? (growth! >= 0 ? Colors.green : Colors.red)
        : Colors.transparent;

    return PremiumGlassmorphicTheme.glassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const Spacer(),
              if (growth != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: growthColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        growth! >= 0 ? Icons.trending_up : Icons.trending_down,
                        color: growthColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${growth!.abs().toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: growthColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formattedValue,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
