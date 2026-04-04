import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/premium_glassmorphic_theme.dart';
import '../../../../shared/widgets/enhanced_animations.dart';
import '../../../../shared/utils/nepal_localization_utils.dart';
import '../providers/distribution_provider.dart';

/// Marketing Campaign Widget for Distribution Dashboard
class MarketingCampaignWidget extends StatefulWidget {
  const MarketingCampaignWidget({Key? key}) : super(key: key);

  @override
  State<MarketingCampaignWidget> createState() => _MarketingCampaignWidgetState();
}

class _MarketingCampaignWidgetState extends State<MarketingCampaignWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  String _selectedStatus = 'all';
  String _selectedType = 'all';

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    // Start animation
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DistributionProvider>(
      builder: (context, provider, child) {
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: PremiumGlassmorphicTheme.buildGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      _buildHeader(),
                      
                      const SizedBox(height: 16),
                      
                      // Campaign metrics
                      _buildCampaignMetrics(provider),
                      
                      const SizedBox(height: 24),
                      
                      // Filter controls
                      _buildFilterControls(),
                      
                      const SizedBox(height: 16),
                      
                      // Active campaigns
                      _buildActiveCampaigns(provider),
                      
                      const SizedBox(height: 24),
                      
                      // Campaign performance
                      _buildCampaignPerformance(provider),
                      
                      const SizedBox(height: 24),
                      
                      // Campaign list
                      _buildCampaignList(provider),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.campaign,
            color: Colors.purple,
            size: 24,
          ),
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Marketing Campaigns',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Manage and track marketing campaigns',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
        
        // Create campaign button
        Container(
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.add, color: Colors.purple),
            onPressed: () {
              // Show create campaign dialog
              _showCreateCampaignDialog();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCampaignMetrics(DistributionProvider provider) {
    return Row(
      children: [
        // Total campaigns
        Expanded(
          child: _buildMetricCard(
            'Total Campaigns',
            '${provider.campaigns.length}',
            Icons.campaign,
            Colors.purple,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Active campaigns
        Expanded(
          child: _buildMetricCard(
            'Active',
            '${provider.campaigns.where((c) => c['status'] == 'active').length}',
            Icons.play_circle,
            Colors.green,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Completed campaigns
        Expanded(
          child: _buildMetricCard(
            'Completed',
            '${provider.campaigns.where((c) => c['status'] == 'completed').length}',
            Icons.check_circle,
            Colors.blue,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Total ROI
        Expanded(
          child: _buildMetricCard(
            'Total ROI',
            '${_calculateTotalROI(provider.campaigns)}%',
            Icons.trending_up,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterControls() {
    return Row(
      children: [
        // Status filter
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: DropdownButton<String>(
              value: _selectedStatus,
              hint: const Text('Status...', style: TextStyle(color: Colors.white54)),
              isExpanded: true,
              dropdownColor: Colors.black87,
              style: const TextStyle(color: Colors.white),
              items: [
                const DropdownMenuItem(value: 'all', child: Text('All Status')),
                const DropdownMenuItem(value: 'active', child: Text('Active')),
                const DropdownMenuItem(value: 'pending', child: Text('Pending')),
                const DropdownMenuItem(value: 'completed', child: Text('Completed')),
                const DropdownMenuItem(value: 'paused', child: Text('Paused')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                });
              },
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Type filter
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: DropdownButton<String>(
              value: _selectedType,
              hint: const Text('Type...', style: TextStyle(color: Colors.white54)),
              isExpanded: true,
              dropdownColor: Colors.black87,
              style: const TextStyle(color: Colors.white),
              items: [
                const DropdownMenuItem(value: 'all', child: Text('All Types')),
                const DropdownMenuItem(value: 'promotion', child: Text('Promotion')),
                const DropdownMenuItem(value: 'discount', child: Text('Discount')),
                const DropdownMenuItem(value: 'awareness', child: Text('Awareness')),
                const DropdownMenuItem(value: 'launch', child: Text('Product Launch')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveCampaigns(DistributionProvider provider) {
    final activeCampaigns = provider.campaigns
        .where((c) => c['status'] == 'active')
        .toList();
    
    if (activeCampaigns.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.info, color: Colors.blue),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'No active campaigns',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Campaigns',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Active campaigns list
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activeCampaigns.length > 3 ? 3 : activeCampaigns.length,
          itemBuilder: (context, index) {
            final campaign = activeCampaigns[index];
            return _buildActiveCampaignItem(campaign);
          },
        ),
      ],
    );
  }

  Widget _buildActiveCampaignItem(Map<String, dynamic> campaign) {
    final progress = campaign['progress'] ?? 0.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  campaign['name'] ?? 'Unknown Campaign',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            campaign['description'] ?? 'No description available',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Progress bar
          Row(
            children: [
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignPerformance(DistributionProvider provider) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Campaign Performance',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Placeholder for campaign performance chart
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'Campaign Performance Chart\n(Implementation Required)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignList(DistributionProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'All Campaigns',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${provider.campaigns.length} campaigns',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Campaigns list
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.campaigns.length > 5 ? 5 : provider.campaigns.length,
          itemBuilder: (context, index) {
            final campaign = provider.campaigns[index];
            return _buildCampaignItem(campaign);
          },
        ),
      ],
    );
  }

  Widget _buildCampaignItem(Map<String, dynamic> campaign) {
    final status = campaign['status'] ?? 'unknown';
    final statusColor = _getStatusColor(status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          // Status indicator
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Campaign info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  campaign['name'] ?? 'Unknown Campaign',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${campaign['type'] ?? 'Unknown'} • ${campaign['startDate'] ?? 'N/A'}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Status and actions
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'ROI: ${campaign['roi'] ?? 0}%',
                style: TextStyle(
                  color: campaign['roi'] != null && campaign['roi'] > 0 
                      ? Colors.green 
                      : Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'paused':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  double _calculateTotalROI(List<Map<String, dynamic>> campaigns) {
    double totalROI = 0.0;
    int count = 0;
    
    for (final campaign in campaigns) {
      if (campaign['roi'] != null) {
        totalROI += campaign['roi'];
        count++;
      }
    }
    
    return count > 0 ? totalROI / count : 0.0;
  }

  void _showCreateCampaignDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Campaign'),
        content: const Text('Create campaign functionality would be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
