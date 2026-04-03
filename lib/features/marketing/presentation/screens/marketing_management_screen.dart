import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/glassmorphic_widgets.dart';
import '../../data/services/marketing_service.dart';
import '../providers/marketing_provider.dart';
import '../../../app/theme/app_theme.dart';
import '../models/marketing_campaign.dart';

class MarketingManagementScreen extends StatefulWidget {
  const MarketingManagementScreen({Key? key}) : super(key: key);

  @override
  State<MarketingManagementScreen> createState() => _MarketingManagementScreenState();
}

class _MarketingManagementScreenState extends State<MarketingManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          'Marketing Management',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _showAddCampaignDialog,
          ),
          IconButton(
            icon: const Icon(Icons.analytics, color: Colors.white),
            onPressed: _showAnalyticsDialog,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeController,
        child: Column(
          children: [
            _buildSearchAndFilter(),
            _buildStatisticsCards(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCampaignsList('all'),
                  _buildCampaignsList('active'),
                  _buildCampaignsList('draft'),
                  _buildCampaignsList('completed'),
                  _buildCampaignsList('paused'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: GlassmorphicTextField(
              controller: _searchController,
              hintText: 'Search campaigns...',
              prefixIcon: Icons.search,
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF4F46E5).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF4F46E5).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: DropdownButton<String>(
              value: _selectedStatus,
              dropdownColor: const Color(0xFF1E293B),
              style: const TextStyle(color: Colors.white),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Status')),
                DropdownMenuItem(value: 'active', child: Text('Active')),
                DropdownMenuItem(value: 'draft', child: Text('Draft')),
                DropdownMenuItem(value: 'completed', child: Text('Completed')),
                DropdownMenuItem(value: 'paused', child: Text('Paused')),
                DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return Consumer<MarketingProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Campaigns',
                      '${provider.totalCampaigns}',
                      Icons.campaign,
                      const Color(0xFF4F46E5),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Active',
                      '${provider.activeCampaigns}',
                      Icons.play_circle,
                      const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Budget',
                      'NPR ${provider.totalBudget.toStringAsFixed(0)}',
                      Icons.account_balance_wallet,
                      const Color(0xFFF59E0B),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'ROI',
                      '${provider.roi.toStringAsFixed(1)}%',
                      Icons.trending_up,
                      const Color(0xFF06B6D4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4F46E5), Color(0xFF3730A3)],
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Active'),
          Tab(text: 'Draft'),
          Tab(text: 'Completed'),
          Tab(text: 'Paused'),
        ],
      ),
    );
  }

  Widget _buildCampaignsList(String status) {
    return Consumer<MarketingProvider>(
      builder: (context, provider, child) {
        List<MarketingCampaign> campaigns = provider.campaigns;
        
        if (status != 'all') {
          campaigns = campaigns.where((c) => c.status == status).toList();
        }

        if (_searchController.text.isNotEmpty) {
          campaigns = campaigns.where((c) =>
            c.searchableText.contains(_searchController.text.toLowerCase())
          ).toList();
        }

        if (campaigns.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => provider.refreshCampaigns(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: campaigns.length,
            itemBuilder: (context, index) {
              final campaign = campaigns[index];
              return _buildCampaignCard(campaign);
            },
          ),
        );
      },
    );
  }

  Widget _buildCampaignCard(MarketingCampaign campaign) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassmorphicCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (campaign.imageUrl != null)
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(campaign.imageUrl!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.campaign,
                      color: Color(0xFF4F46E5),
                      size: 30,
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        campaign.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        campaign.description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(campaign.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getStatusColor(campaign.status).withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    campaign.statusDisplay,
                    style: TextStyle(
                      color: _getStatusColor(campaign.status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoRow(
                  'Type',
                  campaign.typeDisplay,
                  Icons.category,
                ),
                const SizedBox(width: 16),
                _buildInfoRow(
                  'Duration',
                  campaign.formattedDuration,
                  Icons.date_range,
                ),
                const SizedBox(width: 16),
                _buildInfoRow(
                  'Budget',
                  campaign.formattedBudget,
                  Icons.account_balance_wallet,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoRow(
                  'Spent',
                  campaign.formattedSpent,
                  Icons.money_off,
                ),
                const SizedBox(width: 16),
                _buildInfoRow(
                  'CTR',
                  campaign.formattedCTR,
                  Icons.touch_app,
                ),
                const SizedBox(width: 16),
                _buildInfoRow(
                  'Conversions',
                  '${campaign.conversions}',
                  Icons.trending_up,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (campaign.budgetUtilization / 100).clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: campaign.isOverBudget 
                        ? const Color(0xFFEF4444)
                        : campaign.isNearBudgetLimit
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${campaign.formattedBudgetUtilization} of budget used',
              style: TextStyle(
                color: campaign.isOverBudget 
                    ? const Color(0xFFEF4444)
                    : campaign.isNearBudgetLimit
                        ? const Color(0xFFF59E0B)
                        : Colors.white.withOpacity(0.7),
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (campaign.isDraft)
                  TextButton(
                    onPressed: () => _launchCampaign(campaign.id),
                    child: const Text(
                      'Launch',
                      style: TextStyle(color: Color(0xFF10B981)),
                    ),
                  ),
                if (campaign.isActive)
                  TextButton(
                    onPressed: () => _pauseCampaign(campaign.id),
                    child: const Text(
                      'Pause',
                      style: TextStyle(color: Color(0xFFF59E0B)),
                    ),
                  ),
                if (campaign.isPaused)
                  TextButton(
                    onPressed: () => _resumeCampaign(campaign.id),
                    child: const Text(
                      'Resume',
                      style: TextStyle(color: Color(0xFF10B981)),
                    ),
                  ),
                TextButton(
                  onPressed: () => _showCampaignDetails(campaign),
                  child: const Text(
                    'View Details',
                    style: TextStyle(color: Color(0xFF4F46E5)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white54,
          size: 16,
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 10,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.campaign_outlined,
            color: Colors.white.withOpacity(0.3),
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'No campaigns found',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first campaign to get started',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          GlassmorphicButton(
            text: 'Create Campaign',
            onPressed: _showAddCampaignDialog,
            icon: Icons.add,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return const Color(0xFF10B981);
      case 'draft':
        return const Color(0xFF6B7280);
      case 'completed':
        return const Color(0xFF4F46E5);
      case 'paused':
        return const Color(0xFFF59E0B);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  void _showAddCampaignDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add campaign dialog coming soon!'),
        backgroundColor: Color(0xFF4F46E5),
      ),
    );
  }

  void _showAnalyticsDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Analytics dashboard coming soon!'),
        backgroundColor: Color(0xFF4F46E5),
      ),
    );
  }

  void _showCampaignDetails(MarketingCampaign campaign) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Campaign details for ${campaign.name}'),
        backgroundColor: const Color(0xFF4F46E5),
      ),
    );
  }

  void _launchCampaign(String id) async {
    final provider = Provider.of<MarketingProvider>(context, listen: false);
    await provider.updateCampaignStatus(id, 'active');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Campaign launched successfully!'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  void _pauseCampaign(String id) async {
    final provider = Provider.of<MarketingProvider>(context, listen: false);
    await provider.updateCampaignStatus(id, 'paused');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Campaign paused'),
        backgroundColor: Color(0xFFF59E0B),
      ),
    );
  }

  void _resumeCampaign(String id) async {
    final provider = Provider.of<MarketingProvider>(context, listen: false);
    await provider.updateCampaignStatus(id, 'active');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Campaign resumed'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }
}
