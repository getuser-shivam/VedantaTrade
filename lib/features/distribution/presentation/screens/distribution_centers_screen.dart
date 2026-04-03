import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/distribution_provider.dart';
import '../widgets/distribution_center_card.dart';
import '../widgets/inventory_allocation_card.dart';

class DistributionCentersScreen extends StatefulWidget {
  const DistributionCentersScreen({Key? key}) : super(key: key);

  @override
  _DistributionCentersScreenState createState() => _DistributionCentersScreenState();
}

class _DistributionCentersScreenState extends State<DistributionCentersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDistributionCenters();
  }

  Future<void> _loadDistributionCenters() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final distributionProvider = Provider.of<DistributionProvider>(context, listen: false);
      await distributionProvider.loadDistributionCenters();
    } catch (e) {
      setState(() {
        _error = 'Failed to load distribution centers';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    _searchController.text = value;
    _loadDistributionCenters();
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _loadDistributionCenters();
  }

  @override
  Widget build(BuildContext context) {
    final distributionProvider = Provider.of<DistributionProvider>(context, listen: false);
    final centers = distributionProvider.centers;
    final filteredCenters = _getFilteredCenters(centers);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Distribution Centers'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/distribution/add-center');
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
                    hintText: 'Search centers...',
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
                
                // Category Filter Chips
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: ['All', 'Active', 'Inactive'].map((category) {
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: category,
                          selected: isSelected,
                          onSelected: () => _onCategoryChanged(category),
                          backgroundColor: isSelected ? Colors.blue[800] : Colors.grey[200],
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
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
                      onPressed: _loadDistributionCenters,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          
          // Centers List
          if (!_isLoading && _error == null)
            Expanded(
              child: filteredCenters.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadDistributionCenters,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: filteredCenters.length,
                        itemBuilder: (context, index) {
                          final center = filteredCenters[index];
                          return DistributionCenterCard(
                            center: center,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/distribution/center-details',
                                arguments: center,
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
          Navigator.pushNamed(context, '/distribution/add-center');
        },
        backgroundColor: Colors.blue[800],
        child: const Icon(Icons.add),
      ),
    );
  }

  List<DistributionCenter> _getFilteredCenters(List<DistributionCenter> centers) {
    if (_searchController.text.isEmpty && _selectedCategory == 'All') {
      return centers;
    }

    return centers.where((center) {
      final matchesSearch = _searchController.text.isEmpty ||
          center.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          center.code.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          center.city.toLowerCase().contains(_searchController.text.toLowerCase());

      final matchesCategory = _selectedCategory == 'All' ||
          (_selectedCategory == 'Active' && center.isActive) ||
          (_selectedCategory == 'Inactive' && !center.isActive);

      return matchesSearch && matchesCategory;
    }).toList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.warehouse_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No distribution centers found',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first distribution center to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/distribution/add-center');
            },
            icon: const Icon(Icons.add),
            label: 'Add Center',
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
