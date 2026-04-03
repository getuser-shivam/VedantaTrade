import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/marketing_provider.dart';
import '../widgets/campaign_card.dart';

class MarketingCampaignsScreen extends StatefulWidget {
  const MarketingCampaignsScreen({Key? key}) : super(key: key);

  @override
  _MarketingCampaignsScreenState createState() => _MarketingCampaignsScreenState();
}

class _MarketingCampaignsScreenState extends State<MarketingCampaignsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'All';
  String _selectedSort = 'Created Date';
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCampaigns();
  }

  Future<void> _loadCampaigns() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final marketingProvider = Provider.of<MarketingProvider>(context, listen: false);
      await marketingProvider.loadCampaigns();
    } catch (e) {
      setState(() {
        _error = 'Failed to load marketing campaigns';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    _searchController.text = value;
    _loadCampaigns();
  }

  void _onStatusChanged(String status) {
    setState(() {
      _selectedStatus = status;
    });
    _loadCampaigns();
  }

  void _onSortChanged(String sort) {
    setState(() {
      _selectedSort = sort;
    });
    _loadCampaigns();
  }

  @override
  Widget build(BuildContext context) {
    final marketingProvider = Provider.of<MarketingProvider>(context, listen: false);
    final campaigns = marketingProvider.campaigns;
    final filteredCampaigns = _getFilteredCampaigns(campaigns);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketing Campaigns'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/marketing/add-campaign');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search campaigns...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(height: 12),
                
                // Filter and Sort Options
                Row(
                  children: [
                    // Status Filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: ['All', 'Active', 'Completed', 'Paused'].map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: _onStatusChanged,
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Sort Options
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedSort,
                        decoration: InputDecoration(
                          labelText: 'Sort By',
                          border: OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: [
                          'Created Date',
                          'Start Date',
                          'End Date',
                          'Budget',
                          'Name',
                        ].map((sort) {
                          return DropdownMenuItem(
                            value: sort,
                            child: Text(sort),
                          );
                        }).toList(),
                        onChanged: _onSortChanged,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Loading Indicator
          if (_isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: Colors.blue[800],
                ),
              ),
            ),
          
          // Error Message
          if (_error != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.red[400],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadCampaigns,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          
          // Campaigns List
          if (!_isLoading && _error == null)
            Expanded(
              child: filteredCampaigns.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadCampaigns,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: filteredCampaigns.length,
                        itemBuilder: (context, index) {
                          final campaign = filteredCampaigns[index];
                          return CampaignCard(
                            campaign: campaign,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/marketing/campaign-details',
                                arguments: campaign,
                              );
                            },
                          );
                        },
                      ),
                    ),
                    ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/marketing/add-campaign');
        },
        backgroundColor: Colors.blue[800],
        child: const Icon(Icons.add),
      ),
    );
  }

  List<MarketingCampaign> _getFilteredCampaigns(List<MarketingCampaign> campaigns) {
    if (_searchController.text.isEmpty && _selectedStatus == 'All') {
      return _sortCampaigns(campaigns);
    }

    var filtered = campaigns.where((campaign) {
      final matchesSearch = _searchController.text.isEmpty ||
          campaign.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          (campaign.description?.toLowerCase().contains(_searchController.text.toLowerCase()) ?? false);

      final matchesStatus = _selectedStatus == 'All' ||
          (_selectedStatus == 'Active' && campaign.status == 'ACTIVE') ||
          (_selectedStatus == 'Completed' && campaign.status == 'COMPLETED') ||
          (_selectedStatus == 'Paused' && campaign.status == 'PAUSED');

      return matchesSearch && matchesStatus;
    }).toList();

    return _sortCampaigns(filtered);
  }

  List<MarketingCampaign> _sortCampaigns(List<MarketingCampaign> campaigns) {
    switch (_selectedSort) {
      case 'Created Date':
        campaigns.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'Start Date':
        campaigns.sort((a, b) => b.startDate.compareTo(a.startDate));
        break;
      case 'End Date':
        campaigns.sort((a, b) {
          if (a.endDate == null && b.endDate == null) return 0;
          if (a.endDate == null) return 1;
          if (b.endDate == null) return -1;
          return b.endDate!.compareTo(a.endDate!);
        });
        break;
      case 'Budget':
        campaigns.sort((a, b) => b.budget.compareTo(a.budget));
        break;
      case 'Name':
        campaigns.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    return campaigns;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.campaign_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No marketing campaigns found',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first marketing campaign to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/marketing/add-campaign');
            },
            icon: const Icon(Icons.add),
            label: 'Add Campaign',
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[800],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
