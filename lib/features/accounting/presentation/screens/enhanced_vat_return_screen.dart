import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../../../shared/widgets/premium_glassmorphic_theme.dart';
import '../../../../shared/widgets/enhanced_animations.dart';
import '../../../../shared/utils/nepal_localization_utils.dart';
import '../../../../shared/utils/error_handling_utils.dart';
import '../../data/services/vat_return_service.dart';
import '../providers/vat_return_provider.dart';
import '../widgets/vat_summary_card.dart';
import '../widgets/vat_transaction_list.dart';
import '../widgets/vat_return_form.dart';
import '../widgets/vat_validation_widget.dart';

/// Enhanced VAT Return Screen with IRDN Compliance
class EnhancedVATReturnScreen extends StatefulWidget {
  const EnhancedVATReturnScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedVATReturnScreen> createState() => _EnhancedVATReturnScreenState();
}

class _EnhancedVATReturnScreenState extends State<EnhancedVATReturnScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  String _selectedPeriod = 'current';
  DateTime? _startDate;
  DateTime? _endDate;
  VATReturnType _selectedReturnType = VATReturnType.monthly;
  
  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(length: 4, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
    
    // Initialize VAT return service and load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _initializeData() {
    context.read<VATReturnProvider>().initialize();
    _loadVATData();
  }

  Future<void> _loadVATData() async {
    try {
      await Future.wait([
        context.read<VATReturnProvider>().loadVATReturns(),
        context.read<VATReturnProvider>().loadVATTransactions(),
        context.read<VATReturnProvider>().calculateVATSummary(
          startDate: _startDate,
          endDate: _endDate,
        ),
      ]);
    } catch (e) {
      ErrorHandlingUtils.showErrorSnackBar(
        context,
        'Failed to load VAT data: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildBody(),
            ),
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'VAT Returns',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'Nepal IRDN Compliance',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
      backgroundColor: PremiumGlassmorphicTheme.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              PremiumGlassmorphicTheme.primaryColor,
              PremiumGlassmorphicTheme.secondaryColor,
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadVATData,
          tooltip: 'Refresh Data',
        ),
        IconButton(
          icon: const Icon(Icons.download),
          onPressed: _exportAllData,
          tooltip: 'Export All',
        ),
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings),
                  SizedBox(width: 8),
                  Text('Settings'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'help',
              child: Row(
                children: [
                  Icon(Icons.help_outline),
                  SizedBox(width: 8),
                  Text('Help'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'about',
              child: Row(
                children: [
                  Icon(Icons.info_outline),
                  SizedBox(width: 8),
                  Text('About'),
                ],
              ),
            ),
          ],
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.7),
        tabs: const [
          Tab(
            icon: Icon(Icons.dashboard),
            text: 'Dashboard',
          ),
          Tab(
            icon: Icon(Icons.receipt_long),
            text: 'Returns',
          ),
          Tab(
            icon: Icon(Icons.list_alt),
            text: 'Transactions',
          ),
          Tab(
            icon: Icon(Icons.add_chart),
            text: 'Generate',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildDashboardTab(),
        _buildReturnsTab(),
        _buildTransactionsTab(),
        _buildGenerateTab(),
      ],
    );
  }

  Widget _buildDashboardTab() {
    return Consumer<VATReturnProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading VAT data',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.red[400],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.errorMessage ?? 'Unknown error occurred',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _loadVATData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PremiumGlassmorphicTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period Selector
              _buildPeriodSelector(),
              const SizedBox(height: 16),
              
              // VAT Summary Cards
              EnhancedAnimations.slideIn(
                child: VATSummaryCard(
                  summary: provider.currentSummary,
                  onTap: () => _showVATSummaryDetails(provider.currentSummary),
                ),
                delay: const Duration(milliseconds: 100),
              ),
              
              const SizedBox(height: 16),
              
              // Quick Stats
              EnhancedAnimations.slideIn(
                child: _buildQuickStats(provider),
                delay: const Duration(milliseconds: 200),
              ),
              
              const SizedBox(height: 16),
              
              // Recent VAT Returns
              EnhancedAnimations.slideIn(
                child: _buildRecentReturns(provider),
                delay: const Duration(milliseconds: 300),
              ),
              
              const SizedBox(height: 16),
              
              // VAT Compliance Status
              EnhancedAnimations.slideIn(
                child: _buildComplianceStatus(provider),
                delay: const Duration(milliseconds: 400),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Period',
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
                child: DropdownButtonFormField<String>(
                  value: _selectedPeriod,
                  decoration: InputDecoration(
                    labelText: 'Period',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'current', child: Text('Current Month')),
                    DropdownMenuItem(value: 'last_month', child: Text('Last Month')),
                    DropdownMenuItem(value: 'quarter', child: Text('Current Quarter')),
                    DropdownMenuItem(value: 'last_quarter', child: Text('Last Quarter')),
                    DropdownMenuItem(value: 'year', child: Text('Current Year')),
                    DropdownMenuItem(value: 'custom', child: Text('Custom Range')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedPeriod = value!;
                    });
                    _updateDateRange();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<VATReturnType>(
                  value: _selectedReturnType,
                  decoration: InputDecoration(
                    labelText: 'Return Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: VATReturnType.monthly,
                      child: Text('Monthly'),
                    ),
                    DropdownMenuItem(
                      value: VATReturnType.quarterly,
                      child: Text('Quarterly'),
                    ),
                    DropdownMenuItem(
                      value: VATReturnType.yearly,
                      child: Text('Yearly'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedReturnType = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          if (_selectedPeriod == 'custom') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Start Date',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () => _selectStartDate(),
                    controller: TextEditingController(
                      text: _startDate != null
                          ? NepalLocalizationUtils.formatNepaliDate(_startDate!)
                          : '',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'End Date',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () => _selectEndDate(),
                    controller: TextEditingController(
                      text: _endDate != null
                          ? NepalLocalizationUtils.formatNepaliDate(_endDate!)
                          : '',
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _loadVATData,
            icon: const Icon(Icons.search),
            label: const Text('Load Data'),
            style: ElevatedButton.styleFrom(
              backgroundColor: PremiumGlassmorphicTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(VATReturnProvider provider) {
    final summary = provider.currentSummary;
    if (summary == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Statistics',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: PremiumGlassmorphicTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Sales',
                  summary.formattedTotalSales,
                  Icons.trending_up,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'Payable VAT',
                  summary.formattedPayableVAT,
                  Icons.account_balance,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Transactions',
                  '${summary.transactionCount}',
                  Icons.receipt,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'Avg. Transaction',
                  summary.formattedAverageTransactionValue,
                  Icons.calculate,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentReturns(VATReturnProvider provider) {
    final recentReturns = provider.vatReturns.take(3).toList();
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent VAT Returns',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: PremiumGlassmorphicTheme.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () => _tabController.animateTo(1),
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: PremiumGlassmorphicTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (recentReturns.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No VAT returns found',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else
            ...recentReturns.map((vatReturn) => _buildVATReturnItem(vatReturn)),
        ],
      ),
    );
  }

  Widget _buildVATReturnItem(VATReturn vatReturn) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                vatReturn.id,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: PremiumGlassmorphicTheme.textPrimary,
                ),
              ),
              _buildStatusChip(vatReturn.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Period: ${vatReturn.period}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Payable VAT: ${vatReturn.formattedPayableVAT}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                NepalLocalizationUtils.formatNepaliDate(vatReturn.createdAt),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility, size: 16),
                    onPressed: () => _viewVATReturn(vatReturn),
                    tooltip: 'View Details',
                  ),
                  IconButton(
                    icon: const Icon(Icons.download, size: 16),
                    onPressed: () => _downloadVATReturn(vatReturn),
                    tooltip: 'Download PDF',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(VATReturnStatus status) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case VATReturnStatus.draft:
        backgroundColor = Colors.grey[200]!;
        textColor = Colors.grey[700]!;
        text = 'Draft';
        break;
      case VATReturnStatus.submitted:
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[700]!;
        text = 'Submitted';
        break;
      case VATReturnStatus.approved:
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[700]!;
        text = 'Approved';
        break;
      case VATReturnStatus.rejected:
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[700]!;
        text = 'Rejected';
        break;
      case VATReturnStatus.paid:
        backgroundColor = Colors.purple[100]!;
        textColor = Colors.purple[700]!;
        text = 'Paid';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildComplianceStatus(VATReturnProvider provider) {
    final pendingReturns = provider.vatReturns
        .where((vr) => vr.status == VATReturnStatus.draft)
        .length;
    
    final overdueReturns = provider.vatReturns
        .where((vr) => vr.isOverdue && vr.status != VATReturnStatus.paid)
        .length;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'VAT Compliance Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: PremiumGlassmorphicTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildComplianceItem(
                  'Pending Returns',
                  pendingReturns.toString(),
                  pendingReturns > 0 ? Colors.orange : Colors.green,
                  Icons.pending_actions,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildComplianceItem(
                  'Overdue Returns',
                  overdueReturns.toString(),
                  overdueReturns > 0 ? Colors.red : Colors.green,
                  Icons.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceItem(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
            ),
      ],
    ),
  );

  Widget _buildReturnsTab() {
    return Consumer<VATReturnProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            // Filter and Search Bar
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Search VAT Returns',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        // Implement search functionality
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  DropdownButtonFormField<VATReturnStatus>(
                    decoration: InputDecoration(
                      labelText: 'Filter by Status',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: VATReturnStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.toString().split('.').last),
                      );
                    }).toList(),
                    onChanged: (value) {
                      // Implement filter functionality
                    },
                  ),
                ],
              ),
            ),
            // VAT Returns List
            Expanded(
              child: provider.vatReturns.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No VAT Returns Found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Generate your first VAT return to get started',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.vatReturns.length,
                      itemBuilder: (context, index) {
                        final vatReturn = provider.vatReturns[index];
                        return _buildVATReturnItem(vatReturn);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTransactionsTab() {
    return Consumer<VATReturnProvider>(
      builder: (context, provider, child) {
        return VATTransactionList(
          transactions: provider.transactions,
          onRefresh: _loadVATData,
        );
      },
    );
  }

  Widget _buildGenerateTab() {
    return VATReturnForm(
      onSubmit: _generateVATReturn,
      onValidate: _validateVATReturn,
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => _tabController.animateTo(3),
      icon: const Icon(Icons.add),
      label: const Text('Generate Return'),
      backgroundColor: PremiumGlassmorphicTheme.primaryColor,
      foregroundColor: Colors.white,
    );
  }

  void _updateDateRange() {
    final now = DateTime.now();
    
    switch (_selectedPeriod) {
      case 'current':
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = DateTime(now.year, now.month + 1, 0);
        break;
      case 'last_month':
        _startDate = DateTime(now.year, now.month - 1, 1);
        _endDate = DateTime(now.year, now.month, 0);
        break;
      case 'quarter':
        final quarter = ((now.month - 1) ~/ 3) + 1;
        _startDate = DateTime(now.year, (quarter - 1) * 3 + 1, 1);
        _endDate = DateTime(now.year, quarter * 3 + 1, 0);
        break;
      case 'last_quarter':
        final quarter = ((now.month - 1) ~/ 3);
        _startDate = DateTime(now.year, (quarter - 1) * 3 + 1, 1);
        _endDate = DateTime(now.year, quarter * 3 + 1, 0);
        break;
      case 'year':
        _startDate = DateTime(now.year, 1, 1);
        _endDate = DateTime(now.year, 12, 31);
        break;
      case 'custom':
        // Keep existing dates
        break;
    }
    
    setState(() {});
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (date != null) {
      setState(() {
        _startDate = date;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now(),
    );
    
    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'settings':
        _showSettings();
        break;
      case 'help':
        _showHelp();
        break;
      case 'about':
        _showAbout();
        break;
    }
  }

  void _showVATSummaryDetails(VATSummary? summary) {
    if (summary == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('VAT Summary Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Period', summary.period),
              _buildDetailRow('Start Date', NepalLocalizationUtils.formatNepaliDate(summary.startDate)),
              _buildDetailRow('End Date', NepalLocalizationUtils.formatNepaliDate(summary.endDate)),
              _buildDetailRow('Total Sales', summary.formattedTotalSales),
              _buildDetailRow('Total Purchases', NepalLocalizationUtils.formatNPRCurrency(summary.totalPurchases)),
              _buildDetailRow('Output VAT', NepalLocalizationUtils.formatNPRCurrency(summary.totalOutputVAT)),
              _buildDetailRow('Input VAT', NepalLocalizationUtils.formatNPRCurrency(summary.totalInputVAT)),
              _buildDetailRow('Payable VAT', summary.formattedPayableVAT),
              _buildDetailRow('Transaction Count', summary.transactionCount.toString()),
              _buildDetailRow('Average Transaction', summary.formattedAverageTransactionValue),
              _buildDetailRow('Top Categories', summary.topCategories.join(', ')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _viewVATReturn(VATReturn vatReturn) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VATReturnDetailScreen(vatReturn: vatReturn),
      ),
    );
  }

  Future<void> _downloadVATReturn(VATReturn vatReturn) async {
    try {
      final pdfData = await context.read<VATReturnProvider>().exportVATReturnToPDF(vatReturn);
      
      // In a real app, you would save the PDF to device or share it
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('VAT return ${vatReturn.id} downloaded successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ErrorHandlingUtils.showErrorSnackBar(
        context,
        'Failed to download VAT return: $e',
      );
    }
  }

  Future<void> _exportAllData() async {
    try {
      // Implement export all functionality
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exporting all VAT data...'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      ErrorHandlingUtils.showErrorSnackBar(
        context,
        'Failed to export data: $e',
      );
    }
  }

  Future<void> _generateVATReturn(Map<String, dynamic> returnData) async {
    try {
      final vatReturn = await context.read<VATReturnProvider>().generateVATReturn(
        startDate: returnData['startDate'],
        endDate: returnData['endDate'],
        returnType: returnData['returnType'],
        additionalData: returnData,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('VAT return ${vatReturn.id} generated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navigate to returns tab
      _tabController.animateTo(1);
    } catch (e) {
      ErrorHandlingUtils.showErrorSnackBar(
        context,
        'Failed to generate VAT return: $e',
      );
    }
  }

  VATValidationResult _validateVATReturn(Map<String, dynamic> returnData) {
    // Implement validation logic
    return const VATValidationResult(
      isValid: true,
      errors: [],
      warnings: [],
    );
  }

  void _showSettings() {
    // Show settings dialog
  }

  void _showHelp() {
    // Show help dialog
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'VedantaTrade VAT Returns',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.account_balance),
      children: [
        const Text('Nepal IRDN compliant VAT return management system'),
      ],
    );
  }
}

/// VAT Return Detail Screen
class VATReturnDetailScreen extends StatelessWidget {
  final VATReturn vatReturn;

  const VATReturnDetailScreen({
    Key? key,
    required this.vatReturn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('VAT Return ${vatReturn.id}'),
        backgroundColor: PremiumGlassmorphicTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Return Details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Return Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: PremiumGlassmorphicTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Return ID', vatReturn.id),
                  _buildDetailRow('Period', vatReturn.period),
                  _buildDetailRow('Tax Period', vatReturn.taxPeriod),
                  _buildDetailRow('Return Type', vatReturn.returnType.toString().split('.').last),
                  _buildDetailRow('Status', vatReturn.statusText),
                  _buildDetailRow('Start Date', NepalLocalizationUtils.formatNepaliDate(vatReturn.startDate)),
                  _buildDetailRow('End Date', NepalLocalizationUtils.formatNepaliDate(vatReturn.endDate)),
                  if (vatReturn.submittedAt != null)
                    _buildDetailRow('Submitted At', NepalLocalizationUtils.formatNepaliDate(vatReturn.submittedAt!)),
                  if (vatReturn.approvedAt != null)
                    _buildDetailRow('Approved At', NepalLocalizationUtils.formatNepaliDate(vatReturn.approvedAt!)),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Financial Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Financial Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: PremiumGlassmorphicTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Total Sales', vatReturn.formattedTotalSales),
                  _buildDetailRow('Output VAT (13%)', vatReturn.formattedTotalVAT),
                  _buildDetailRow('Total Purchases', NepalLocalizationUtils.formatNPRCurrency(vatReturn.totalPurchases)),
                  _buildDetailRow('Input VAT (13%)', NepalLocalizationUtils.formatNPRCurrency(vatReturn.totalInputVAT)),
                  _buildDetailRow('Payable VAT', vatReturn.formattedPayableVAT),
                ],
              ),
            ),
            
            if (vatReturn.remarks != null && vatReturn.remarks!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Remarks',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: PremiumGlassmorphicTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(vatReturn.remarks!),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
