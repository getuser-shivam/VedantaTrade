import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/premium_glassmorphic_theme.dart';
import '../models/inventory_transfer_model.dart';

class EnhancedInventoryTransferCard extends StatelessWidget {
  final InventoryTransfer transfer;
  final VoidCallback? onTap;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const EnhancedInventoryTransferCard({
    Key? key,
    required this.transfer,
    this.onTap,
    this.onApprove,
    this.onReject,
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
                  'Transfer #${transfer.id}',
                  style: const TextStyle(
                    color: PremiumGlassmorphicTheme.textPrimary,
                    fontSize: PremiumGlassmorphicTheme.fontSizeMd,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: PremiumGlassmorphicTheme.spacingXs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: transfer.statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(PremiumGlassmorphicTheme.radiusXs),
                ),
                child: Text(
                  transfer.statusDisplay,
                  style: TextStyle(
                    color: transfer.statusColor,
                    fontSize: PremiumGlassmorphicTheme.fontSizeXs,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingSm),
          
          // Transfer Route
          Row(
            children: [
              Icon(
                Icons.arrow_forward,
                color: PremiumGlassmorphicTheme.textTertiary,
                size: 16,
              ),
              const SizedBox(width: PremiumGlassmorphicTheme.spacingXs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'From',
                      style: const TextStyle(
                        color: PremiumGlassmorphicTheme.textTertiary,
                        fontSize: PremiumGlassmorphicTheme.fontSizeXs,
                      ),
                    ),
                    Text(
                      transfer.fromCenter,
                      style: const TextStyle(
                        color: PremiumGlassmorphicTheme.textSecondary,
                        fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: PremiumGlassmorphicTheme.spacingSm),
              Icon(
                Icons.arrow_forward,
                color: PremiumGlassmorphicTheme.indigo500,
                size: 16,
              ),
              const SizedBox(width: PremiumGlassmorphicTheme.spacingXs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'To',
                      style: const TextStyle(
                        color: PremiumGlassmorphicTheme.textTertiary,
                        fontSize: PremiumGlassmorphicTheme.fontSizeXs,
                      ),
                    ),
                    Text(
                      transfer.toCenter,
                      style: const TextStyle(
                        color: PremiumGlassmorphicTheme.textSecondary,
                        fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingMd),
          
          // Products Information
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
                  children: [
                    Icon(
                      Icons.inventory_2,
                      color: PremiumGlassmorphicTheme.textTertiary,
                      size: 16,
                    ),
                    const SizedBox(width: PremiumGlassmorphicTheme.spacingXs),
                    Text(
                      'Products (${transfer.totalProducts})',
                      style: const TextStyle(
                        color: PremiumGlassmorphicTheme.textSecondary,
                        fontSize: PremiumGlassmorphicTheme.fontSizeXs,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Total Quantity: ${transfer.totalQuantity}',
                      style: const TextStyle(
                        color: PremiumGlassmorphicTheme.textSecondary,
                        fontSize: PremiumGlassmorphicTheme.fontSizeXs,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: PremiumGlassmorphicTheme.spacingXs),
                Text(
                  transfer.productsDisplay,
                  style: const TextStyle(
                    color: PremiumGlassmorphicTheme.textPrimary,
                    fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingMd),
          
          // Timeline Information
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Requested',
                      style: const TextStyle(
                        color: PremiumGlassmorphicTheme.textTertiary,
                        fontSize: PremiumGlassmorphicTheme.fontSizeXs,
                      ),
                    ),
                    Text(
                      transfer.requestedAtDisplay,
                      style: const TextStyle(
                        color: PremiumGlassmorphicTheme.textSecondary,
                        fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                        fontWeight: FontWeight.w600,
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
                      'Processing Time',
                      style: const TextStyle(
                        color: PremiumGlassmorphicTheme.textTertiary,
                        fontSize: PremiumGlassmorphicTheme.fontSizeXs,
                      ),
                    ),
                    Text(
                      transfer.processingTime,
                      style: const TextStyle(
                        color: PremiumGlassmorphicTheme.textSecondary,
                        fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Requested By
          if (transfer.requestedBy != null) ...[
            const SizedBox(height: PremiumGlassmorphicTheme.spacingSm),
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: PremiumGlassmorphicTheme.textTertiary,
                  size: 16,
                ),
                const SizedBox(width: PremiumGlassmorphicTheme.spacingXs),
                Text(
                  'Requested by: ${transfer.requestedBy}',
                  style: const TextStyle(
                    color: PremiumGlassmorphicTheme.textSecondary,
                    fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                  ),
                ),
              ],
            ),
          ],
          
          // Rejection Reason
          if (transfer.isRejected && transfer.rejectedReason != null) ...[
            const SizedBox(height: PremiumGlassmorphicTheme.spacingSm),
            Container(
              padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingSm),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(PremiumGlassmorphicTheme.radiusSm),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: PremiumGlassmorphicTheme.spacingXs),
                      Text(
                        'Rejection Reason',
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: PremiumGlassmorphicTheme.fontSizeXs,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: PremiumGlassmorphicTheme.spacingXs),
                  Text(
                    transfer.rejectedReason!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingMd),
          
          // Action Buttons
          Row(
            children: [
              if (transfer.isPending && onApprove != null)
                Expanded(
                  child: PremiumGlassmorphicTheme.glassButton(
                    onPressed: onApprove,
                    child: const Text(
                      'Approve',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: PremiumGlassmorphicTheme.fontSizeXs,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    height: 32,
                  ),
                ),
              if (transfer.isPending && onApprove != null && onReject != null)
                const SizedBox(width: PremiumGlassmorphicTheme.spacingSm),
              if (transfer.isPending && onReject != null)
                Expanded(
                  child: PremiumGlassmorphicTheme.glassButton(
                    onPressed: onReject,
                    child: const Text(
                      'Reject',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: PremiumGlassmorphicTheme.fontSizeXs,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    height: 32,
                  ),
                ),
              if (transfer.isApproved) ...[
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PremiumGlassmorphicTheme.spacingSm,
                      vertical: PremiumGlassmorphicTheme.spacingXs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(PremiumGlassmorphicTheme.radiusSm),
                    ),
                    child: const Text(
                      'Approved',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: PremiumGlassmorphicTheme.fontSizeXs,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
              if (transfer.isRejected) ...[
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PremiumGlassmorphicTheme.spacingSm,
                      vertical: PremiumGlassmorphicTheme.spacingXs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(PremiumGlassmorphicTheme.radiusSm),
                    ),
                    child: const Text(
                      'Rejected',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: PremiumGlassmorphicTheme.fontSizeXs,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
