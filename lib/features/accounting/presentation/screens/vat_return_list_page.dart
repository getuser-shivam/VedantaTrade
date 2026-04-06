import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../providers/vat_return_provider.dart';
import '../widgets/vat_return_card.dart';
import '../widgets/vat_return_filter_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/theme/app_theme.dart';

/// VAT Return List Page
/// Displays list of VAT returns with filtering and management options
class VatReturnListPage extends StatefulWidget {
  const VatReturnListPage({Key? key}) : super(key: key);

  @override
  _VatReturnListPageState createState() => _VatReturnListPageState();
}

class _VatReturnListPageState extends State<VatReturnListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  VatReturnFilter _filter = VatReturnFilter();
  bool _isSearching = false;
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVatReturns();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  void _loadVatReturns() {
    final provider = VatReturnProvider.of(context);
    final currentTab = _tabController.index;
    
    switch (currentTab) {
      case 0: // All
        provider.loadVatReturns();
        break;
      case 1: // Draft
        provider.loadVatReturnsByStatus(VatReturnStatus.draft);
        break;
      case 2: // Submitted
        provider.loadVatReturnsByStatus(VatReturnStatus.submitted);
        break;
      case 3: // Approved
        provider.loadVatReturnsByStatus(VatReturnStatus.approved);
        break;
    }
  }
  
  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    
    // Debounce search
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_searchQuery == query) {
        _performSearch();
      }
    });
  }
  
  void _performSearch() {
    final provider = VatReturnProvider.of(context);
    if (_searchQuery.isNotEmpty) {
      provider.searchVatReturns(_searchQuery);
    } else {
      _loadVatReturns();
    }
  }
  
  void _onFilterChanged(VatReturnFilter filter) {
    setState(() {
      _filter = filter;
    });
    _applyFilter();
  }
  
  void _applyFilter() {
    final provider = VatReturnProvider.of(context);
    provider.filterVatReturns(_filter);
  }
  
  void _onRefresh() {
    _loadVatReturns();
  }
  
  void _onCreateNew() {
    Navigator.pushNamed(context, '/vat-return/create');
  }
  
  void _onExportSelected() {
    final provider = VatReturnProvider.of(context);
    final selectedReturns = provider.selectedReturns;
    
    if (selectedReturns.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select VAT returns to export')),
      );
      return;
    }
    
    // Show export options
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildExportOptions(selectedReturns),
    );
  }
  
  void _onBulkAction(String action) {
    final provider = VatReturnProvider.of(context);
    final selectedReturns = provider.selectedReturns;
    
    if (selectedReturns.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select VAT returns to perform bulk action')),
      );
      return;
    }
    
    switch (action) {
      case 'delete':
        _showDeleteConfirmation(selectedReturns);
        break;
      case 'submit':
        _submitSelectedReturns(selectedReturns);
        break;
      case 'approve':
        _approveSelectedReturns(selectedReturns);
        break;
      case 'export':
        _onExportSelected();
        break;
    }
  }
  
  void _showDeleteConfirmation(List<String> returnIds) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete VAT Returns'),
        content: Text('Are you sure you want to delete ${returnIds.length} VAT return(s)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteSelectedReturns(returnIds);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  void _deleteSelectedReturns(List<String> returnIds) {
    final provider = VatReturnProvider.of(context);
    provider.deleteVatReturns(returnIds);
  }
  
  void _submitSelectedReturns(List<String> returnIds) {
    final provider = VatReturnProvider.of(context);
    provider.submitVatReturns(returnIds);
  }
  
  void _approveSelectedReturns(List<String> returnIds) {
    final provider = VatReturnProvider.of(context);
    provider.approveVatReturns(returnIds);
  }
  
  Widget _buildExportOptions(List<String> returnIds) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Export Options',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: const Text('Export as PDF'),
            subtitle: Text('Generate PDF for ${returnIds.length} return(s)'),
            onTap: () {
              Navigator.pop(context);
              _exportAsPdf(returnIds);
            },
          ),
          ListTile(
            leading: const Icon(Icons.table_chart),
            title: const Text('Export as Excel'),
            subtitle: Text('Export to Excel format'),
            onTap: () {
              Navigator.pop(context);
              _exportAsExcel(returnIds);
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Export as CSV'),
            subtitle: Text('Export to CSV format'),
            onTap: () {
              Navigator.pop(context);
              _exportAsCsv(returnIds);
            },
          ),
        ],
      ),
    );
  }
  
  void _exportAsPdf(List<String> returnIds) {
    final provider = VatReturnProvider.of(context);
    provider.exportVatReturnsAsPdf(returnIds);
  }
  
  void _exportAsExcel(List<String> returnIds) {
    final provider = VatReturnProvider.of(context);
    provider.exportVatReturnsAsExcel(returnIds);
  }
  
  void _exportAsCsv(List<String> returnIds) {
    final provider = VatReturnProvider.of(context);
    provider.exportVatReturnsAsCsv(returnIds);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VAT Returns'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = '';
                  _loadVatReturns();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => VatReturnFilterWidget(
                  filter: _filter,
                  onFilterChanged: _onFilterChanged,
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: _onBulkAction,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'export', child: Text('Export Selected')),
              const PopupMenuItem(value: 'submit', child: Text('Submit Selected')),
              const PopupMenuItem(value: 'approve', child: Text('Approve Selected')),
              const PopupMenuItem(value: 'delete', child: Text('Delete Selected')),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Draft'),
            Tab(text: 'Submitted'),
            Tab(text: 'Approved'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          if (_isSearching)
            Container(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search VAT returns...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                  ),
                ),
                onChanged: _onSearchChanged,
              ),
            ),
          
          // Filter chips
          if (_filter.isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 8,
                children: [
                  if (_filter.dateRange != null)
                    Chip(
                      label: Text(
                        '${DateFormat('MMM dd').format(_filter.dateRange!.start)} - ${DateFormat('MMM dd').format(_filter.dateRange!.end)}',
                      ),
                      onDeleted: () {
                        _onFilterChanged(_filter.copyWith(dateRange: null));
                      },
                    ),
                  if (_filter.status != null)
                    Chip(
                      label: Text(_formatStatus(_filter.status!)),
                      onDeleted: () {
                        _onFilterChanged(_filter.copyWith(status: null));
                      },
                    ),
                  if (_filter.returnType != null)
                    Chip(
                      label: Text(_formatReturnType(_filter.returnType!)),
                      onDeleted: () {
                        _onFilterChanged(_filter.copyWith(returnType: null));
                      },
                    ),
                ],
              ),
            ),
          
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVatReturnsList(),
                _buildVatReturnsList(status: VatReturnStatus.draft),
                _buildVatReturnsList(status: VatReturnStatus.submitted),
                _buildVatReturnsList(status: VatReturnStatus.approved),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onCreateNew,
        child: const Icon(Icons.add),
        tooltip: 'Create New VAT Return',
      ),
    );
  }
  
  Widget _buildVatReturnsList({VatReturnStatus? status}) {
    return Consumer<VatReturnProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const LoadingWidget();
        }
        
        if (provider.error != null) {
          return AppErrorWidget(
            message: provider.error!,
            onRetry: _onRefresh,
          );
        }
        
        final vatReturns = provider.vatReturns;
        
        if (vatReturns.isEmpty) {
          return EmptyStateWidget(
            title: 'No VAT Returns Found',
            subtitle: 'Create your first VAT return to get started',
            action: _onCreateNew,
            actionText: 'Create VAT Return',
          );
        }
        
        return RefreshIndicator(
          onRefresh: () async => _onRefresh(),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: vatReturns.length,
            itemBuilder: (context, index) {
              final vatReturn = vatReturns[index];
              return VatReturnCard(
                vatReturn: vatReturn,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/vat-return/details',
                    arguments: vatReturn.id,
                  );
                },
                onEdit: () {
                  Navigator.pushNamed(
                    context,
                    '/vat-return/edit',
                    arguments: vatReturn.id,
                  );
                },
                onDelete: () {
                  _showDeleteConfirmation([vatReturn.id]);
                },
                onExport: () {
                  _exportAsPdf([vatReturn.id]);
                },
                onSubmit: () {
                  _submitSelectedReturns([vatReturn.id]);
                },
                onApprove: () {
                  _approveSelectedReturns([vatReturn.id]);
                },
                isSelected: provider.selectedReturns.contains(vatReturn.id),
                onSelected: (selected) {
                  provider.toggleSelection(vatReturn.id);
                },
              );
            },
          ),
        );
      },
    );
  }
  
  String _formatStatus(VatReturnStatus status) {
    switch (status) {
      case VatReturnStatus.draft:
        return 'Draft';
      case VatReturnStatus.pending:
        return 'Pending';
      case VatReturnStatus.submitted:
        return 'Submitted';
      case VatReturnStatus.processing:
        return 'Processing';
      case VatReturnStatus.approved:
        return 'Approved';
      case VatReturnStatus.rejected:
        return 'Rejected';
      case VatReturnStatus.paid:
        return 'Paid';
      case VatReturnStatus.refunded:
        return 'Refunded';
      case VatReturnStatus.cancelled:
        return 'Cancelled';
      case VatReturnStatus.archived:
        return 'Archived';
    }
  }
  
  String _formatReturnType(VatReturnType type) {
    switch (type) {
      case VatReturnType.monthly:
        return 'Monthly';
      case VatReturnType.quarterly:
        return 'Quarterly';
      case VatReturnType.halfYearly:
        return 'Half-Yearly';
      case VatReturnType.yearly:
        return 'Yearly';
      case VatReturnType.adHoc:
        return 'Ad-Hoc';
    }
  }
}
