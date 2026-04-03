import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/premium_glassmorphic_theme.dart';
import '../models/marketing_campaign_model.dart';

class EnhancedCampaignCard extends StatelessWidget {
  final MarketingCampaign campaign;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleStatus;

  const EnhancedCampaignCard({
    Key? key,
    required this.campaign,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumGlassmorphicTheme.glassCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Status and Actions
          Row(
            children: [
              Expanded(
                child: Text(
                  campaign.name,
                  style: const TextStyle(
                    color: PremiumGlassmorphicTheme.textPrimary,
                    fontSize: PremiumGlassmorphicTheme.fontSizeLg,
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
                  campaign.statusDisplay,
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
          
          // Campaign Description
          Text(
            campaign.description,
            style: const TextStyle(
              color: PremiumGlassmorphicTheme.textSecondary,
              fontSize: PremiumGlassmorphicTheme.fontSizeSm,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingMd),
          
          // Campaign Details
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: PremiumGlassmorphicTheme.textTertiary,
                size: 16,
              ),
              const SizedBox(width: PremiumGlassmorphicTheme.spacingXs),
              Text(
                campaign.durationDisplay,
                style: const TextStyle(
                  color: PremiumGlassmorphicTheme.textSecondary,
                  fontSize: PremiumGlassmorphicTheme.fontSizeXs,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.people,
                color: PremiumGlassmorphicTheme.textTertiary,
                size: 16,
              ),
              const SizedBox(width: PremiumGlassmorphicTheme.spacingXs),
              Text(
                campaign.targetAudienceDisplay,
                style: const TextStyle(
                  color: PremiumGlassmorphicTheme.textSecondary,
                  fontSize: PremiumGlassmorphicTheme.fontSizeXs,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingSm),
          
          // Budget and Discount
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Budget',
                      style: const TextStyle(
                        color: PremiumGlassmorphicTheme.textTertiary,
                        fontSize: PremiumGlassmorphicTheme.fontSizeXs,
                      ),
                    ),
                    Text(
                      campaign.formattedBudget,
                      style: const TextStyle(
                        color: PremiumGlassmorphicTheme.textPrimary,
                        fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: PremiumGlassmorphicTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Discount',
                      style: const TextStyle(
                        color: PremiumGlassmorphicTheme.textTertiary,
                        fontSize: PremiumGlassmorphicTheme.fontSizeXs,
                      ),
                    ),
                    Text(
                      campaign.formattedDiscount,
                      style: const TextStyle(
                        color: PremiumGlassmorphicTheme.indigo500,
                        fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingMd),
          
          // Products
          if (campaign.topProducts.isNotEmpty) ...[
            Text(
              'Featured Products',
              style: const TextStyle(
                color: PremiumGlassmorphicTheme.textSecondary,
                fontSize: PremiumGlassmorphicTheme.fontSizeXs,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: PremiumGlassmorphicTheme.spacingXs),
            Wrap(
              spacing: PremiumGlassmorphicTheme.spacingXs,
              runSpacing: PremiumGlassmorphicTheme.spacingXs,
              children: campaign.topProducts.map((product) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PremiumGlassmorphicTheme.spacingXs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: PremiumGlassmorphicTheme.indigo500.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(PremiumGlassmorphicTheme.radiusXs),
                  ),
                  child: Text(
                    product,
                    style: const TextStyle(
                      color: PremiumGlassmorphicTheme.indigo500,
                      fontSize: PremiumGlassmorphicTheme.fontSizeXs,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: PremiumGlassmorphicTheme.spacingMd),
          ],
          
          // Progress Bar for Budget Utilization
          Container(
            padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingSm),
            decoration: BoxDecoration(
              color: PremiumGlassmorphicTheme.surfaceLight.withOpacity(0.3),
              borderRadius: BorderRadius.circular(PremiumGlassmorphicTheme.radiusSm),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Budget Utilization',
                      style: const TextStyle(
                        color: PremiumGlassmorphicTheme.textSecondary,
                        fontSize: PremiumGlassmorphicTheme.fontSizeXs,
                      ),
                    ),
                    Text(
                      '${((campaign.budgetUtilized / campaign.budget) * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: PremiumGlassmorphicTheme.textPrimary,
                        fontSize: PremiumGlassmorphicTheme.fontSizeXs,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: PremiumGlassmorphicTheme.spacingXs),
                LinearProgressIndicator(
                  value: campaign.budgetUtilized / campaign.budget,
                  backgroundColor: PremiumGlassmorphicTheme.surfaceDark.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    campaign.budgetUtilized > campaign.budget * 0.8
                        ? Colors.red
                        : campaign.budgetUtilized > campaign.budget * 0.6
                            ? Colors.orange
                            : Colors.green,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingMd),
          
          // Action Buttons
          Row(
            children: [
              if (campaign.isActive && onToggleStatus != null)
                Expanded(
                  child: PremiumGlassmorphicTheme.glassButton(
                    onPressed: onToggleStatus,
                    child: const Text(
                      'Pause',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: PremiumGlassmorphicTheme.fontSizeXs,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    height: 32,
                  ),
                ),
              if (!campaign.isActive && onToggleStatus != null)
                Expanded(
                  child: PremiumGlassmorphicTheme.glassButton(
                    onPressed: onToggleStatus,
                    child: const Text(
                      'Activate',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: PremiumGlassmorphicTheme.fontSizeXs,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    height: 32,
                  ),
                ),
              if (onToggleStatus != null && onEdit != null)
                const SizedBox(width: PremiumGlassmorphicTheme.spacingSm),
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
    switch (campaign.status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'upcoming':
        return Colors.blue;
      case 'completed':
        return Colors.grey;
      case 'paused':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'planning':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
