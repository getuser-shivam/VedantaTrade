import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/premium_glassmorphic_theme.dart';
import '../models/distribution_center_model.dart';

class EnhancedDistributionCenterCard extends StatelessWidget {
  final DistributionCenter center;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const EnhancedDistributionCenterCard({
    Key? key,
    required this.center,
    this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumGlassmorphicTheme.glassCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Status
          Row(
            children: [
              Expanded(
                child: Text(
                  center.name,
                  style: const TextStyle(
                    color: PremiumGlassmorphicTheme.textPrimary,
                    fontSize: PremiumGlassmorphicTheme.fontSizeMd,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: PremiumGlassmorphicTheme.spacingXs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(PremiumGlassmorphicTheme.radiusXs),
                ),
                child: Text(
                  center.status,
                  style: TextStyle(
                    color: _getStatusColor(),
                    fontSize: PremiumGlassmorphicTheme.fontSizeXs,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingSm),
          
          // Location Information
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: PremiumGlassmorphicTheme.textTertiary,
                size: 16,
              ),
              const SizedBox(width: PremiumGlassmorphicTheme.spacingXs),
              Expanded(
                child: Text(
                  center.city,
                  style: const TextStyle(
                    color: PremiumGlassmorphicTheme.textSecondary,
                    fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingXs),
          
          Row(
            children: [
              Icon(
                Icons.person,
                color: PremiumGlassmorphicTheme.textTertiary,
                size: 16,
              ),
              const SizedBox(width: PremiumGlassmorphicTheme.spacingXs),
              Expanded(
                child: Text(
                  center.manager,
                  style: const TextStyle(
                    color: PremiumGlassmorphicTheme.textSecondary,
                    fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const Spacer(),
          
          // Capacity Information
          Container(
            padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingSm),
            decoration: BoxDecoration(
              color: PremiumGlassmorphicTheme.surfaceLight.withOpacity(0.3),
              borderRadius: BorderRadius.circular(PremiumGlassmorphicTheme.radiusSm),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Capacity',
                  style: const TextStyle(
                    color: PremiumGlassmorphicTheme.textTertiary,
                    fontSize: PremiumGlassmorphicTheme.fontSizeXs,
                  ),
                ),
                const SizedBox(height: PremiumGlassmorphicTheme.spacingXs),
                Text(
                  center.formattedCapacity,
                  style: const TextStyle(
                    color: PremiumGlassmorphicTheme.textPrimary,
                    fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: PremiumGlassmorphicTheme.spacingXs),
                // Inventory Utilization
                LinearProgressIndicator(
                  value: center.inventoryUtilization / 100,
                  backgroundColor: PremiumGlassmorphicTheme.surfaceDark.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    center.isLowStock ? Colors.red : Colors.green,
                  ),
                ),
                const SizedBox(height: PremiumGlassmorphicTheme.spacingXs),
                Text(
                  '${center.inventoryUtilization.toStringAsFixed(1)}% Utilized',
                  style: TextStyle(
                    color: center.isLowStock ? Colors.red : Colors.green,
                    fontSize: PremiumGlassmorphicTheme.fontSizeXs,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingMd),
          
          // Action Buttons
          Row(
            children: [
              if (onEdit != null)
                Expanded(
                  child: PremiumGlassmorphicTheme.glassButton(
                    onPressed: onEdit,
                    child: const Text(
                      'Edit',
                      style: TextStyle(
                        color: PremiumGlassmorphicTheme.indigo500,
                        fontSize: PremiumGlassmorphicTheme.fontSizeXs,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    height: 32,
                  ),
                ),
              ),
              if (onEdit != null && onDelete != null)
                const SizedBox(width: PremiumGlassmorphicTheme.spacingSm),
              if (onDelete != null)
                Expanded(
                  child: PremiumGlassmorphicTheme.glassButton(
                    onPressed: onDelete,
                    child: const Text(
                      'Delete',
                      style: TextStyle(
                        color: PremiumGlassmorphicTheme.error,
                        fontSize: PremiumGlassmorphicTheme.fontSizeXs,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    height: 32,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (center.status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.red;
      case 'needs update':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
