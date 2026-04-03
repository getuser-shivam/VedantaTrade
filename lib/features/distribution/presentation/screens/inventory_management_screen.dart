import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/distribution_provider.dart';
import '../widgets/inventory_allocation_card.dart';
import '../widgets/stock_alert_widget.dart';

class InventoryManagementScreen extends StatefulWidget {
  const InventoryManagementScreen({Key? key}) : super(key: key);

  @override
  _InventoryManagementScreenState createState() => _InventoryManagementScreenState();
}

class _InventoryManagementScreenState extends State<InventoryManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCenter = 'all';
  String _selectedFilter = 'all';
  bool _showAlertsOnly = false;

  @override
  void initState() {
    super.initState();
    _loadInventoryData();
  }

  Future<void> _loadInventoryData() async {
    final distributionProvider = Provider.of<DistributionProvider>(context, listen: false);
    await distributionProvider.loadInventoryAllocations(
      _selectedCenter == 'all' ? null : int.parse(_selectedCenter),
      search: _searchController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showAlertsOnly ? Icons.list : Icons.notifications),
            onPressed: () {
              setState(() {
                _showAlertsOnly = !_showAlertsOnly;
              });
              _loadInventoryData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportInventoryData,
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
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) {
                    _debounceSearch();
                  },
                ),
                const SizedBox(height: 12),
                
                // Filter Options
                Row(
                  children: [
                    // Center Filter
                    Expanded(
                      child: Consumer<DistributionProvider>(
                        builder: (context, provider, child) {
                          return DropdownButtonFormField<String>(
                            value: _selectedCenter,
                            decoration: InputDecoration(
                              labelText: 'Distribution Center',
                              border: OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            items: [
                              const DropdownMenuItem(value: 'all', child: Text('All Centers')),
                              ...provider.centers.map((center) {
                                return DropdownMenuItem(
                                  value: center.id.toString(),
                                  child: Text(center.name),
                                );
                              }).toList(),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedCenter = value!;
                              });
                              _loadInventoryData();
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Stock Status Filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedFilter,
                        decoration: InputDecoration(
                          labelText: 'Stock Status',
                          border: OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('All')),
                          DropdownMenuItem(value: 'low_stock', child: Text('Low Stock')),
                          DropdownMenuItem(value: 'out_of_stock', child: Text('Out of Stock')),
                          DropdownMenuItem(value: 'good_stock', child: Text('Good Stock')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedFilter = value!;
                          });
                          _loadInventoryData();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Main Content
          Expanded(
            child: Consumer<DistributionProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: Colors.blue,
                    ),
                  );
                }

                if (provider.error != null) {
                  return Center(
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
                          provider.error!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadInventoryData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final allocations = _showAlertsOnly 
                    ? provider.inventoryAlerts.where((alert) => 
                        alert.stockStatus == 'LOW_STOCK' || alert.stockStatus == 'OUT_OF_STOCK')
                    : provider.inventoryAllocations;

                if (allocations.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: _loadInventoryData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: allocations.length,
                    itemBuilder: (context, index) {
                      if (_showAlertsOnly) {
                        return StockAlertWidget(
                          alert: allocations[index],
                          onTap: () => _showAllocationDetails(allocations[index]),
                        );
                      } else {
                        return InventoryAllocationCard(
                          allocation: allocations[index],
                          onTap: () => _showAllocationDetails(allocations[index]),
                          onTransfer: () => _showTransferDialog(allocations[index]),
                          onAdjust: () => _showAdjustDialog(allocations[index]),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAllocationDialog,
        backgroundColor: Colors.blue[800],
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _showAlertsOnly ? Icons.notifications_off : Icons.inventory_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _showAlertsOnly 
                ? 'No inventory alerts found'
                : 'No inventory allocations found',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _showAlertsOnly
                ? 'All inventory levels are within acceptable limits'
                : 'Start by allocating inventory to distribution centers',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _debounceSearch() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _loadInventoryData();
      }
    });
  }

  void _showAllocationDetails(dynamic allocation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(allocation.productName ?? 'Product Details'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Center: ${allocation.centerName ?? 'N/A'}'),
              Text('Allocated: ${allocation.quantityAllocated ?? 0}'),
              Text('Available: ${allocation.quantityAvailable ?? 0}'),
              Text('Status: ${allocation.stockStatus ?? 'Unknown'}'),
              Text('Last Updated: ${_formatDate(allocation.lastUpdated)}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showAdjustDialog(allocation);
            },
            child: const Text('Adjust'),
          ),
        ],
      ),
    );
  }

  void _showTransferDialog(dynamic allocation) {
    final TextEditingController _quantityController = TextEditingController();
    String _selectedCenter = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transfer Inventory'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('From: ${allocation.centerName ?? 'N/A'}'),
              Text('Available: ${allocation.quantityAvailable ?? 0}'),
              const SizedBox(height: 16),
              Consumer<DistributionProvider>(
                builder: (context, provider, child) {
                  return DropdownButtonFormField<String>(
                    value: _selectedCenter,
                    decoration: InputDecoration(
                      labelText: 'To Center',
                      border: OutlineInputBorder(),
                    ),
                    items: provider.centers
                        .where((center) => center.id.toString() != allocation.centerId.toString())
                        .map((center) {
                          return DropdownMenuItem(
                            value: center.id.toString(),
                            child: Text(center.name),
                          );
                        }).toList(),
                    onChanged: (value) {
                      _selectedCenter = value!;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_selectedCenter.isNotEmpty && _quantityController.text.isNotEmpty) {
                final success = await _transferInventory(
                  allocation,
                  _selectedCenter,
                  double.parse(_quantityController.text),
                );
                if (success) {
                  Navigator.of(context).pop();
                }
              }
            },
            child: const Text('Transfer'),
          ),
        ],
      ),
    );
  }

  void _showAdjustDialog(dynamic allocation) {
    final TextEditingController _quantityController = TextEditingController(
      text: allocation.quantityAvailable?.toString() ?? '0',
    );
    String _adjustmentType = 'SET';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adjust Inventory'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Product: ${allocation.productName ?? 'N/A'}'),
              Text('Current Available: ${allocation.quantityAvailable ?? 0}'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _adjustmentType,
                decoration: InputDecoration(
                  labelText: 'Adjustment Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'SET', child: Text('Set Quantity')),
                  DropdownMenuItem(value: 'INCREASE', child: Text('Increase')),
                  DropdownMenuItem(value: 'DECREASE', child: Text('Decrease')),
                ],
                onChanged: (value) {
                  _adjustmentType = value!;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'New Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_quantityController.text.isNotEmpty) {
                final success = await _adjustInventory(
                  allocation,
                  _adjustmentType,
                  double.parse(_quantityController.text),
                );
                if (success) {
                  Navigator.of(context).pop();
                }
              }
            },
            child: const Text('Adjust'),
          ),
        ],
      ),
    );
  }

  void _showAllocationDialog() {
    // Show dialog to create new allocation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Allocate Inventory'),
        content: const Text('Allocation dialog content here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Implement allocation logic
            },
            child: const Text('Allocate'),
          ),
        ],
      ),
    );
  }

  Future<bool> _transferInventory(dynamic allocation, String toCenter, double quantity) async {
    try {
      final distributionProvider = Provider.of<DistributionProvider>(context, listen: false);
      return await distributionProvider.transferInventory(
        allocation.productId,
        allocation.centerId,
        int.parse(toCenter),
        quantity,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transfer failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  Future<bool> _adjustInventory(dynamic allocation, String adjustmentType, double newQuantity) async {
    try {
      final distributionProvider = Provider.of<DistributionProvider>(context, listen: false);
      return await distributionProvider.adjustInventory(
        allocation.id,
        adjustmentType,
        newQuantity,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Adjustment failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  void _exportInventoryData() async {
    // Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export feature coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
