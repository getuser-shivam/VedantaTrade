import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/widgets/premium_glassmorphic_theme.dart';
import '../../../marketing/data/services/marketing_management_service.dart';

class MarketingOverviewWidget extends StatefulWidget {
  const MarketingOverviewWidget({Key? key}) : super(key: key);

  @override
  State<MarketingOverviewWidget> createState() => _MarketingOverviewWidgetState();
}

class _MarketingOverviewWidgetState extends State<MarketingOverviewWidget> {
  late MarketingManagementService _marketingService;

  @override
  void initState() {
    super.initState();
    _marketingService = MarketingManagementService();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MarketingAnalytics>(
      stream: _marketingService.analyticsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        }

        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        }

        final analytics = snapshot.data ?? MarketingAnalytics();
        
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withOpacity(0.05),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.campaign_outlined,
                    color: PremiumGlassmorphicTheme.secondaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Marketing Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: PremiumGlassmorphicTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Campaign Performance
              _buildCampaignPerformance(analytics),
              
              const SizedBox(height: 20),
              
              // ROI and Revenue
              _buildROISection(analytics),
              
              const SizedBox(height: 20),
              
              // Top Channels
              _buildTopChannels(analytics),
              
              const SizedBox(height: 20),
              
              // Customer Metrics
              _buildCustomerMetrics(analytics),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCampaignPerformance(MarketingAnalytics analytics) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: PremiumGlassmorphicTheme.secondaryColor.withOpacity(0.1),
        border: Border.all(
          color: PremiumGlassmorphicTheme.secondaryColor.withOpacity(0.3),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Campaign Performance',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: PremiumGlassmorphicTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildPerformanceMetric(
                  'Active Campaigns',
                  analytics.activeCampaigns.toString(),
                  Icons.campaign_outlined,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPerformanceMetric(
                  'Total Campaigns',
                  analytics.totalCampaigns.toString(),
                  Icons.list_alt_outlined,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildPerformanceMetric(
                  'Conversions',
                  analytics.totalConversions.toString(),
                  Icons.trending_up_outlined,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPerformanceMetric(
                  'Engagement Rate',
                  '${analytics.engagementRate.toStringAsFixed(1)}%',
                  Icons.people_outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetric(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: PremiumGlassmorphicTheme.secondaryColor,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: PremiumGlassmorphicTheme.textSecondary,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: PremiumGlassmorphicTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildROISection(MarketingAnalytics analytics) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ROI & Revenue',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: PremiumGlassmorphicTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          
          // ROI Score
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: analytics.averageROI > 3 
                  ? Colors.green.withOpacity(0.1) 
                  : Colors.orange.withOpacity(0.1),
              border: Border.all(
                color: analytics.averageROI > 3 
                    ? Colors.green.withOpacity(0.3) 
                    : Colors.orange.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Average ROI',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: PremiumGlassmorphicTheme.textPrimary,
                  ),
                ),
                Text(
                  '${analytics.averageROI.toStringAsFixed(2)}x',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: analytics.averageROI > 3 ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildRevenueMetric(
                  'Total Revenue',
                  'NPR ${analytics.totalRevenue.toStringAsFixed(2)}',
                  Icons.attach_money,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildRevenueMetric(
                  'Budget Used',
                  'NPR ${analytics.totalSpent.toStringAsFixed(2)}',
                  Icons.account_balance_wallet_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueMetric(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: PremiumGlassmorphicTheme.primaryColor,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: PremiumGlassmorphicTheme.textSecondary,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: PremiumGlassmorphicTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopChannels(MarketingAnalytics analytics) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Performing Channels',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: PremiumGlassmorphicTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          
          ...analytics.topPerformingChannels.take(3).map((channel) => _buildChannelRow(channel)),
        ],
      ),
    );
  }

  Widget _buildChannelRow(String channel) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: PremiumGlassmorphicTheme.secondaryColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              channel,
              style: TextStyle(
                fontSize: 14,
                color: PremiumGlassmorphicTheme.textPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: PremiumGlassmorphicTheme.secondaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Active',
              style: TextStyle(
                color: PremiumGlassmorphicTheme.secondaryColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerMetrics(MarketingAnalytics analytics) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: PremiumGlassmorphicTheme.accentColor.withOpacity(0.1),
        border: Border.all(
          color: PremiumGlassmorphicTheme.accentColor.withOpacity(0.3),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customer Metrics',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: PremiumGlassmorphicTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildCustomerMetric(
                  'CAC',
                  'NPR ${analytics.customerAcquisitionCost.toStringAsFixed(2)}',
                  Icons.person_add_outlined,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCustomerMetric(
                  'CLV',
                  'NPR ${analytics.customerLifetimeValue.toStringAsFixed(2)}',
                  Icons.trending_up_outlined,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: analytics.customerValueRatio > 5 
                  ? Colors.green.withOpacity(0.1) 
                  : Colors.orange.withOpacity(0.1),
              border: Border.all(
                color: analytics.customerValueRatio > 5 
                    ? Colors.green.withOpacity(0.3) 
                    : Colors.orange.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CLV/CAC Ratio',
                  style: TextStyle(
                    fontSize: 12,
                    color: PremiumGlassmorphicTheme.textSecondary,
                  ),
                ),
                Text(
                  analytics.customerValueRatio.toStringAsFixed(2),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: analytics.customerValueRatio > 5 ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerMetric(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: PremiumGlassmorphicTheme.accentColor,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: PremiumGlassmorphicTheme.textSecondary,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: PremiumGlassmorphicTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.campaign_outlined,
              color: PremiumGlassmorphicTheme.secondaryColor,
              size: 40,
            ),
            const SizedBox(height: 16),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                PremiumGlassmorphicTheme.secondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.red.withOpacity(0.1),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 40,
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Marketing Data',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              fontSize: 14,
              color: Colors.red.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
