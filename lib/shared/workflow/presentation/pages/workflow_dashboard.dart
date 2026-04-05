import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/modern_design_system.dart';
import '../../../widgets/micro_interactions.dart';
import '../services/workflow_service.dart';
import '../entities/workflow_entities.dart';

/// Workflow Dashboard
/// Comprehensive dashboard for managing workflows and executions
class WorkflowDashboard extends StatefulWidget {
  const WorkflowDashboard({Key? key}) : super(key: key);

  @override
  _WorkflowDashboardState createState() => _WorkflowDashboardState();
}

class _WorkflowDashboardState extends State<WorkflowDashboard> 
    with TickerProviderStateMixin {
  late WorkflowService _workflowService;
  late TabController _tabController;
  List<Workflow> _workflows = [];
  List<WorkflowExecution> _executions = [];
  List<WorkflowTemplate> _templates = [];
  WorkflowStatistics? _statistics;
  bool _isLoading = false;
  String _searchQuery = '';
  WorkflowType? _selectedType;
  WorkflowStatus? _selectedStatus;
  ExecutionStatus? _selectedExecutionStatus;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeWorkflowService();
    _loadData();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer?.cancel();
    _workflowService.dispose();
    super.dispose();
  }

  Future<void> _initializeWorkflowService() async {
    _workflowService = WorkflowService();
    await _workflowService.initialize();
    
    // Listen to workflow events
    _workflowService.eventStream.listen((event) {
      if (mounted) {
        _handleWorkflowEvent(event);
      }
    });
    
    // Listen to execution events
    _workflowService.executionStream.listen((execution) {
      if (mounted) {
        _updateExecutionInList(execution);
      }
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      await Future.wait([
        _loadWorkflows(),
        _loadExecutions(),
        _loadTemplates(),
        _loadStatistics(),
      ]);
    } catch (e) {
      _showError('Failed to load data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadWorkflows() async {
    final result = await _workflowService.getAllWorkflows();
    result.fold(
      (error) => _showError(error.message),
      (workflows) => setState(() => _workflows = workflows),
    );
  }

  Future<void> _loadExecutions() async {
    final result = await _workflowService.getAllExecutions();
    result.fold(
      (error) => _showError(error.message),
      (executions) => setState(() => _executions = executions),
    );
  }

  Future<void> _loadTemplates() async {
    final result = await _workflowService.getAllTemplates();
    result.fold(
      (error) => _showError(error.message),
      (templates) => setState(() => _templates = templates),
    );
  }

  Future<void> _loadStatistics() async {
    final result = await _workflowService.getStatistics();
    result.fold(
      (error) => _showError(error.message),
      (statistics) => setState(() => _statistics = statistics),
    );
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _loadData();
      }
    });
  }

  void _handleWorkflowEvent(WorkflowEvent event) {
    // Handle workflow events
    switch (event.type) {
      case WorkflowEventType.workflowCreated:
        _showSuccess('Workflow created: ${event.metadata['workflow_name']}');
        break;
      case WorkflowEventType.executionStarted:
        _showInfo('Execution started: ${event.executionId}');
        break;
      case WorkflowEventType.executionCompleted:
        _showSuccess('Execution completed: ${event.executionId}');
        break;
      case WorkflowEventType.executionFailed:
        _showError('Execution failed: ${event.executionId}');
        break;
      default:
        break;
    }
  }

  void _updateExecutionInList(WorkflowExecution execution) {
    setState(() {
      final index = _executions.indexWhere((e) => e.id == execution.id);
      if (index != -1) {
        _executions[index] = execution;
      } else {
        _executions.insert(0, execution);
      }
    });
  }

  List<Workflow> get _filteredWorkflows {
    var filtered = _workflows;
    
    if (_selectedType != null) {
      filtered = filtered.where((w) => w.type == _selectedType).toList();
    }
    
    if (_selectedStatus != null) {
      filtered = filtered.where((w) => w.status == _selectedStatus).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((w) => 
        w.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        w.description.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    return filtered;
  }

  List<WorkflowExecution> get _filteredExecutions {
    var filtered = _executions;
    
    if (_selectedExecutionStatus != null) {
      filtered = filtered.where((e) => e.status == _selectedExecutionStatus).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((e) => 
        e.id.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernDesignSystem.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Workflow Management',
          style: ModernDesignSystem.headlineSmall.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: ModernDesignSystem.primaryColor,
        elevation: 0,
        actions: [
          AnimatedButton(
            text: 'Refresh',
            onPressed: _loadData,
            showScale: true,
            backgroundColor: ModernDesignSystem.secondaryColor,
            textColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          const SizedBox(width: 8),
          AnimatedButton(
            text: 'Create Workflow',
            onPressed: _navigateToCreateWorkflow,
            showScale: true,
            backgroundColor: ModernDesignSystem.successColor,
            textColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatisticsCards(),
          const SizedBox(height: 16),
          _buildSearchAndFilterBar(),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildWorkflowsTab(),
                _buildExecutionsTab(),
                _buildTemplatesTab(),
                _buildMonitoringTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    if (_statistics == null) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Workflows',
              '${_statistics!.totalWorkflows}',
              Icons.work,
              ModernDesignSystem.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Running Executions',
              '${_statistics!.runningExecutions}',
              Icons.play_arrow,
              ModernDesignSystem.infoColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Success Rate',
              '${_statistics!.successRate.toStringAsFixed(1)}%',
              Icons.trending_up,
              ModernDesignSystem.successColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Failed Executions',
              '${_statistics!.failedExecutions}',
              Icons.error,
              ModernDesignSystem.errorColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernDesignSystem.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: ModernDesignSystem.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: ModernDesignSystem.bodySmall.copyWith(
                  color: ModernDesignSystem.textSecondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: ModernDesignSystem.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernDesignSystem.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: ModernDesignSystem.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Search Workflows',
                    hintText: 'Enter workflow name or description',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: ModernDesignSystem.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: ModernDesignSystem.primaryColor, width: 2),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<WorkflowType>(
                value: _selectedType,
                hint: const Text('All Types'),
                items: WorkflowType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedType = value);
                },
              ),
              const SizedBox(width: 16),
              DropdownButton<WorkflowStatus>(
                value: _selectedStatus,
                hint: const Text('All Status'),
                items: WorkflowStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedStatus = value);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkflowsTab() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernDesignSystem.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: ModernDesignSystem.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.work,
                color: ModernDesignSystem.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Workflows',
                style: ModernDesignSystem.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${_filteredWorkflows.length}',
                style: ModernDesignSystem.bodyMedium.copyWith(
                  color: ModernDesignSystem.textSecondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: ModernDesignSystem.primaryColor,
                    ),
                  )
                : _filteredWorkflows.isEmpty
                    ? const Center(
                        child: Text(
                          'No workflows found',
                          style: TextStyle(
                            color: ModernDesignSystem.textSecondaryColor,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredWorkflows.length,
                        itemBuilder: (context, index) {
                          final workflow = _filteredWorkflows[index];
                          return _buildWorkflowCard(workflow);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkflowCard(Workflow workflow) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernDesignSystem.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getWorkflowStatusColor(workflow.status).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getWorkflowTypeIcon(workflow.type),
                color: _getWorkflowTypeColor(workflow.type),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workflow.name,
                      style: ModernDesignSystem.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      workflow.description,
                      style: ModernDesignSystem.bodySmall.copyWith(
                        color: ModernDesignSystem.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getWorkflowStatusColor(workflow.status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  workflow.status.displayName,
                  style: ModernDesignSystem.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildWorkflowInfoItem('Type', workflow.type.displayName),
              const SizedBox(width: 16),
              _buildWorkflowInfoItem('Tasks', '${workflow.tasks.length}'),
              const SizedBox(width: 16),
              _buildWorkflowInfoItem('Created', _formatDate(workflow.createdAt)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AnimatedButton(
                  text: 'Execute',
                  onPressed: () => _executeWorkflow(workflow),
                  showScale: true,
                  backgroundColor: ModernDesignSystem.successColor,
                  textColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AnimatedButton(
                  text: 'View Details',
                  onPressed: () => _viewWorkflowDetails(workflow),
                  showScale: true,
                  backgroundColor: ModernDesignSystem.infoColor,
                  textColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AnimatedButton(
                  text: 'Edit',
                  onPressed: () => _editWorkflow(workflow),
                  showScale: true,
                  backgroundColor: ModernDesignSystem.secondaryColor,
                  textColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExecutionsTab() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernDesignSystem.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: ModernDesignSystem.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.play_arrow,
                color: ModernDesignSystem.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Executions',
                style: ModernDesignSystem.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${_filteredExecutions.length}',
                style: ModernDesignSystem.bodyMedium.copyWith(
                  color: ModernDesignSystem.textSecondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: ModernDesignSystem.primaryColor,
                    ),
                  )
                : _filteredExecutions.isEmpty
                    ? const Center(
                        child: Text(
                          'No executions found',
                          style: TextStyle(
                            color: ModernDesignSystem.textSecondaryColor,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredExecutions.length,
                        itemBuilder: (context, index) {
                          final execution = _filteredExecutions[index];
                          return _buildExecutionCard(execution);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildExecutionCard(WorkflowExecution execution) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernDesignSystem.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getExecutionStatusColor(execution.status).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getExecutionStatusIcon(execution.status),
                color: _getExecutionStatusColor(execution.status),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      execution.id,
                      style: ModernDesignSystem.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      execution.status.displayName,
                      style: ModernDesignSystem.bodySmall.copyWith(
                        color: _getExecutionStatusColor(execution.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getExecutionStatusColor(execution.status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  execution.getProgressPercentage().toStringAsFixed(0) + '%',
                  style: ModernDesignSystem.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildExecutionInfoItem('Started', _formatDate(execution.startedAt)),
              const SizedBox(width: 16),
              _buildExecutionInfoItem('Duration', execution.getFormattedDuration()),
              const SizedBox(width: 16),
              _buildExecutionInfoItem('Tasks', '${execution.tasks.length}'),
            ],
          ),
          const SizedBox(height: 12),
          if (execution.status == ExecutionStatus.running) ...[
            LinearProgressIndicator(
              value: execution.getProgressPercentage() / 100,
              backgroundColor: ModernDesignSystem.borderColor,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getExecutionStatusColor(execution.status),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Expanded(
                child: AnimatedButton(
                  text: 'View Details',
                  onPressed: () => _viewExecutionDetails(execution),
                  showScale: true,
                  backgroundColor: ModernDesignSystem.infoColor,
                  textColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
              if (execution.canBePaused()) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: AnimatedButton(
                    text: 'Pause',
                    onPressed: () => _pauseExecution(execution),
                    showScale: true,
                    backgroundColor: ModernDesignSystem.warningColor,
                    textColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
              if (execution.canBeCanceled()) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: AnimatedButton(
                    text: 'Cancel',
                    onPressed: () => _cancelExecution(execution),
                    showScale: true,
                    backgroundColor: ModernDesignSystem.errorColor,
                    textColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTemplatesTab() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernDesignSystem.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: ModernDesignSystem.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description,
                color: ModernDesignSystem.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Templates',
                style: ModernDesignSystem.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${_templates.length}',
                style: ModernDesignSystem.bodyMedium.copyWith(
                  color: ModernDesignSystem.textSecondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: ModernDesignSystem.primaryColor,
                    ),
                  )
                : _templates.isEmpty
                    ? const Center(
                        child: Text(
                          'No templates found',
                          style: TextStyle(
                            color: ModernDesignSystem.textSecondaryColor,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _templates.length,
                        itemBuilder: (context, index) {
                          final template = _templates[index];
                          return _buildTemplateCard(template);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(WorkflowTemplate template) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernDesignSystem.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ModernDesignSystem.borderColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getWorkflowTypeIcon(template.type),
                color: _getWorkflowTypeColor(template.type),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: ModernDesignSystem.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      template.description,
                      style: ModernDesignSystem.bodySmall.copyWith(
                        color: ModernDesignSystem.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildTemplateInfoItem('Type', template.type.displayName),
              const SizedBox(width: 16),
              _buildTemplateInfoItem('Tasks', '${template.tasks.length}'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AnimatedButton(
                  text: 'Use Template',
                  onPressed: () => _useTemplate(template),
                  showScale: true,
                  backgroundColor: ModernDesignSystem.successColor,
                  textColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AnimatedButton(
                  text: 'View Details',
                  onPressed: () => _viewTemplateDetails(template),
                  showScale: true,
                  backgroundColor: ModernDesignSystem.infoColor,
                  textColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonitoringTab() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernDesignSystem.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: ModernDesignSystem.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.monitoring,
                color: ModernDesignSystem.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Monitoring',
                style: ModernDesignSystem.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildMonitoringContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildMonitoringContent() {
    return Column(
      children: [
        Expanded(
          child: _buildExecutionChart(),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _buildPerformanceMetrics(),
        ),
      ],
    );
  }

  Widget _buildExecutionChart() {
    // This would show a chart of execution trends
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernDesignSystem.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Execution Trends',
            style: ModernDesignSystem.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: Text(
                'Chart implementation would go here',
                style: ModernDesignSystem.bodySmall.copyWith(
                  color: ModernDesignSystem.textSecondaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernDesignSystem.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Metrics',
            style: ModernDesignSystem.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (_statistics != null) ...[
            _buildMetricRow('Average Execution Time', _statistics!.averageExecutionTime.toString()),
            _buildMetricRow('Success Rate', '${_statistics!.successRate.toStringAsFixed(1)}%'),
            _buildMetricRow('Total Executions', '${_statistics!.totalExecutions}'),
            _buildMetricRow('Active Workflows', '${_statistics!.activeWorkflows}'),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: ModernDesignSystem.bodySmall.copyWith(
              color: ModernDesignSystem.textSecondaryColor,
            ),
          ),
          Text(
            value,
            style: ModernDesignSystem.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkflowInfoItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: ModernDesignSystem.bodySmall.copyWith(
              color: ModernDesignSystem.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: ModernDesignSystem.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExecutionInfoItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: ModernDesignSystem.bodySmall.copyWith(
              color: ModernDesignSystem.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: ModernDesignSystem.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateInfoItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: ModernDesignSystem.bodySmall.copyWith(
              color: ModernDesignSystem.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: ModernDesignSystem.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getWorkflowStatusColor(WorkflowStatus status) {
    switch (status) {
      case WorkflowStatus.active:
        return ModernDesignSystem.successColor;
      case WorkflowStatus.inactive:
        return ModernDesignSystem.textSecondaryColor;
      case WorkflowStatus.archived:
        return ModernDesignSystem.warningColor;
      case WorkflowStatus.deprecated:
        return ModernDesignSystem.errorColor;
    }
  }

  Color _getWorkflowTypeColor(WorkflowType type) {
    switch (type) {
      case WorkflowType.development:
        return ModernDesignSystem.infoColor;
      case WorkflowType.deployment:
        return ModernDesignSystem.successColor;
      case WorkflowType.testing:
        return ModernDesignSystem.warningColor;
      case WorkflowType.documentation:
        return ModernDesignSystem.secondaryColor;
      case WorkflowType.maintenance:
        return ModernDesignSystem.accentColor;
      case WorkflowType.monitoring:
        return ModernDesignSystem.primaryColor;
      case WorkflowType.security:
        return ModernDesignSystem.errorColor;
      case WorkflowType.quality:
        return ModernDesignSystem.purpleColor;
    }
  }

  IconData _getWorkflowTypeIcon(WorkflowType type) {
    switch (type) {
      case WorkflowType.development:
        return Icons.code;
      case WorkflowType.deployment:
        return Icons.upload;
      case WorkflowType.testing:
        return Icons.bug_report;
      case WorkflowType.documentation:
        return Icons.description;
      case WorkflowType.maintenance:
        return Icons.build;
      case WorkflowType.monitoring:
        return Icons.monitoring;
      case WorkflowType.security:
        return Icons.security;
      case WorkflowType.quality:
        return Icons.verified;
    }
  }

  Color _getExecutionStatusColor(ExecutionStatus status) {
    switch (status) {
      case ExecutionStatus.pending:
        return ModernDesignSystem.textSecondaryColor;
      case ExecutionStatus.running:
        return ModernDesignSystem.infoColor;
      case ExecutionStatus.completed:
        return ModernDesignSystem.successColor;
      case ExecutionStatus.failed:
        return ModernDesignSystem.errorColor;
      case ExecutionStatus.canceled:
        return ModernDesignSystem.warningColor;
      case ExecutionStatus.paused:
        return ModernDesignSystem.accentColor;
    }
  }

  IconData _getExecutionStatusIcon(ExecutionStatus status) {
    switch (status) {
      case ExecutionStatus.pending:
        return Icons.schedule;
      case ExecutionStatus.running:
        return Icons.play_arrow;
      case ExecutionStatus.completed:
        return Icons.check_circle;
      case ExecutionStatus.failed:
        return Icons.error;
      case ExecutionStatus.canceled:
        return Icons.cancel;
      case ExecutionStatus.paused:
        return Icons.pause;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Navigation methods
  void _navigateToCreateWorkflow() {
    Navigator.of(context).pushNamed('/create-workflow');
  }

  Future<void> _executeWorkflow(Workflow workflow) async {
    final result = await _workflowService.executeWorkflow(workflow.id);
    result.fold(
      (error) => _showError(error.message),
      (execution) => _showSuccess('Workflow execution started: ${execution.id}'),
    );
  }

  void _viewWorkflowDetails(Workflow workflow) {
    Navigator.of(context).pushNamed('/workflow-details', arguments: workflow);
  }

  void _editWorkflow(Workflow workflow) {
    Navigator.of(context).pushNamed('/edit-workflow', arguments: workflow);
  }

  void _viewExecutionDetails(WorkflowExecution execution) {
    Navigator.of(context).pushNamed('/execution-details', arguments: execution);
  }

  Future<void> _pauseExecution(WorkflowExecution execution) async {
    final result = await _workflowService.pauseExecution(execution.id);
    result.fold(
      (error) => _showError(error.message),
      (_) => _showSuccess('Execution paused: ${execution.id}'),
    );
  }

  Future<void> _cancelExecution(WorkflowExecution execution) async {
    final result = await _workflowService.cancelExecution(execution.id);
    result.fold(
      (error) => _showError(error.message),
      (_) => _showSuccess('Execution canceled: ${execution.id}'),
    );
  }

  void _useTemplate(WorkflowTemplate template) {
    Navigator.of(context).pushNamed('/create-workflow-from-template', arguments: template);
  }

  void _viewTemplateDetails(WorkflowTemplate template) {
    Navigator.of(context).pushNamed('/template-details', arguments: template);
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ModernDesignSystem.successColor,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ModernDesignSystem.errorColor,
      ),
    );
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ModernDesignSystem.infoColor,
      ),
    );
  }
}

// Extension methods for workflow entities
extension WorkflowTypeExtension on WorkflowType {
  String get displayName {
    switch (this) {
      case WorkflowType.development:
        return 'Development';
      case WorkflowType.deployment:
        return 'Deployment';
      case WorkflowType.testing:
        return 'Testing';
      case WorkflowType.documentation:
        return 'Documentation';
      case WorkflowType.maintenance:
        return 'Maintenance';
      case WorkflowType.monitoring:
        return 'Monitoring';
      case WorkflowType.security:
        return 'Security';
      case WorkflowType.quality:
        return 'Quality';
    }
  }
}

extension WorkflowStatusExtension on WorkflowStatus {
  String get displayName {
    switch (this) {
      case WorkflowStatus.active:
        return 'Active';
      case WorkflowStatus.inactive:
        return 'Inactive';
      case WorkflowStatus.archived:
        return 'Archived';
      case WorkflowStatus.deprecated:
        return 'Deprecated';
    }
  }
}

extension ExecutionStatusExtension on ExecutionStatus {
  String get displayName {
    switch (this) {
      case ExecutionStatus.pending:
        return 'Pending';
      case ExecutionStatus.running:
        return 'Running';
      case ExecutionStatus.completed:
        return 'Completed';
      case ExecutionStatus.failed:
        return 'Failed';
      case ExecutionStatus.canceled:
        return 'Canceled';
      case ExecutionStatus.paused:
        return 'Paused';
    }
  }
}

extension WorkflowExecutionExtension on WorkflowExecution {
  double getProgressPercentage() {
    if (tasks.isEmpty) return 0.0;
    
    final completedTasks = tasks.where((t) => 
      t.status == WorkflowTaskExecutionStatus.completed
    ).length;
    
    return (completedTasks / tasks.length) * 100;
  }

  String getFormattedDuration() {
    final now = DateTime.now();
    final duration = now.difference(startedAt);
    
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  bool canBePaused() => status == ExecutionStatus.running;
  bool canBeCanceled() => status == ExecutionStatus.running || status == ExecutionStatus.paused;
}
