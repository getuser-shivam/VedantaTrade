import 'package:flutter/material.dart';
import '../../domain/models/marketing_campaign_entity.dart';

class MarketingCampaignCard extends StatelessWidget {
  final MarketingCampaignEntity campaign;
  final VoidCallback? onTap;
  final Function(CampaignStatus)? onStatusUpdate;

  const MarketingCampaignCard({
    Key? key,
    required this.campaign,
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
                          campaign.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          campaign.typeDisplay,
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
                      color: _getStatusColor(campaign.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      campaign.statusDisplay,
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
              // Description
              Text(
                campaign.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Campaign Details
              Row(
                children: [
                  Icon(
                    Icons.date_range,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Duration: ${campaign.formattedDuration}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.people,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Target: ${campaign.targetAudienceDisplay}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (campaign.hasDiscount)
                Row(
                  children: [
                    Icon(
                      Icons.local_offer,
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        campaign.formattedDiscount,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              // Budget and Performance
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Budget',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          campaign.formattedBudget,
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
                          'Participants',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${campaign.currentParticipants ?? 0}',
                          style: const TextStyle(
                            fontSize: 16,
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
              // Progress Bar
              if (campaign.targetAudienceSize != null && campaign.currentParticipants != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progress',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: (campaign.currentParticipants! / campaign.targetAudienceSize!).clamp(0.0, 1.0),
                      backgroundColor: Colors.grey[300],
                      valueColor: _getProgressColor(campaign),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${((campaign.currentParticipants! / campaign.targetAudienceSize!) * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              // Performance Metrics
              if (campaign.conversionRate != null && campaign.roi != null)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Conversion Rate',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[700],
                              ),
                            ),
                            Text(
                              '${campaign.conversionRate!.toStringAsFixed(2)}%',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'ROI',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green[700],
                              ),
                            ),
                            Text(
                              '${campaign.roi!.toStringAsFixed(2)}%',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              // Tags
              if (campaign.tags.isNotEmpty)
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: campaign.tags.take(3).map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black54,
                      ),
                    ),
                  )).toList(),
                ),
              const SizedBox(height: 16),
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
                    child: _buildStatusButton(context, campaign),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusButton(BuildContext context, MarketingCampaignEntity campaign) {
    switch (campaign.status) {
      case CampaignStatus.draft:
        return ElevatedButton.icon(
          onPressed: () => onStatusUpdate?.call(CampaignStatus.active),
          icon: const Icon(Icons.play_arrow),
          label: const Text('Launch'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        );
      case CampaignStatus.active:
        return ElevatedButton.icon(
          onPressed: () => onStatusUpdate?.call(CampaignStatus.paused),
          icon: const Icon(Icons.pause),
          label: const Text('Pause'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
        );
      case CampaignStatus.paused:
        return ElevatedButton.icon(
          onPressed: () => onStatusUpdate?.call(CampaignStatus.active),
          icon: const Icon(Icons.play_arrow),
          label: const Text('Resume'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        );
      case CampaignStatus.completed:
        return ElevatedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.check_circle),
          label: const Text('Completed'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white,
          ),
        );
      case CampaignStatus.cancelled:
        return ElevatedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.cancel),
          label: const Text('Cancelled'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        );
    }
  }

  Color _getStatusColor(CampaignStatus status) {
    switch (status) {
      case CampaignStatus.draft:
        return Colors.grey;
      case CampaignStatus.active:
        return Colors.green;
      case CampaignStatus.paused:
        return Colors.orange;
      case CampaignStatus.completed:
        return Colors.blue;
      case CampaignStatus.cancelled:
        return Colors.red;
    }
  }

  Color _getProgressColor(MarketingCampaignEntity campaign) {
    if (campaign.isPerformingWell) return Colors.green;
    if (campaign.conversionRateCalculated >= 1.0) return Colors.blue;
    if (campaign.conversionRateCalculated >= 0.5) return Colors.orange;
    return Colors.red;
  }

  void _showDetails(BuildContext context) {
    // Navigate to campaign details
  }
}
