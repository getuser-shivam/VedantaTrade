import 'dart:async';
import 'dart:convert';
import 'package:equatable/equatable.dart';

/// Workflow Manager
/// Comprehensive workflow management system for streamlining project processes
class WorkflowManager {
  final Map<String, Workflow> _workflows = {};
  final Map<String, WorkflowTask> _tasks = {};
  final Map<String, WorkflowExecution> _executions = {};
  final Map<String, List<WorkflowEvent>> _events = {};
  final Map<String, WorkflowTemplate> _templates = {};
  final StreamController<WorkflowEvent> _eventController;
  final StreamController<WorkflowExecution> _executionController;
  Timer? _monitoringTimer;
  bool _isInitialized = false;

  WorkflowManager()
    : _eventController = StreamController<WorkflowEvent>.broadcast(),
      _executionController = StreamController<WorkflowExecution>.broadcast();

  /// Stream of workflow events
  Stream<WorkflowEvent> get eventStream => _eventController.stream;

  /// Stream of workflow executions
  Stream<WorkflowExecution> get executionStream => _executionController.stream;

  /// Initialize workflow manager
  Future<void> initialize() async {
    try {
      if (_isInitialized) return;
      
      print('🔧 Initializing Workflow Manager...');
      
      // Load built-in workflows
      await _loadBuiltInWorkflows();
      
      // Load templates
      await _loadWorkflowTemplates();
      
      // Start monitoring
      _startMonitoring();
      
      _isInitialized = true;
      print('✅ Workflow Manager initialized successfully');
    } catch (e) {
      print('❌ Failed to initialize Workflow Manager: $e');
      rethrow;
    }
  }

  /// Create workflow
  Future<Either<WorkflowError, Workflow>> createWorkflow({
    required String name,
    required String description,
    required List<WorkflowTask> tasks,
    required WorkflowType type,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      print('📝 Creating workflow: $name');
      
      final workflowId = _generateWorkflowId();
      final workflow = Workflow(
        id: workflowId,
        name: name,
        description: description,
        tasks: tasks,
        type: type,
        status: WorkflowStatus.active,
        metadata: metadata ?? {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Validate workflow
      final validation = _validateWorkflow(workflow);
      if (!validation.isValid) {
        return Left(WorkflowError(
          code: 'INVALID_WORKFLOW',
          message: 'Workflow validation failed',
          details: validation.errors,
        ));
      }
      
      // Store workflow
      _workflows[workflowId] = workflow;
      
      // Store tasks
      for (final task in tasks) {
        _tasks[task.id] = task;
      }
      
      // Emit event
      _emitEvent(WorkflowEvent(
        id: _generateEventId(),
        workflowId: workflowId,
        type: WorkflowEventType.workflowCreated,
        description: 'Workflow created: $name',
        timestamp: DateTime.now(),
        metadata: {'workflow_name': name},
      ));
      
      print('✅ Workflow created successfully: $name');
      return Right(workflow);
    } catch (e) {
      print('❌ Failed to create workflow: $e');
      return Left(WorkflowError(
        code: 'CREATE_ERROR',
        message: 'Failed to create workflow',
        details: e,
      ));
    }
  }

  /// Execute workflow
  Future<Either<WorkflowError, WorkflowExecution>> executeWorkflow({
    required String workflowId,
    Map<String, dynamic>? parameters,
    String? initiatedBy,
  }) async {
    try {
      print('🚀 Executing workflow: $workflowId');
      
      final workflow = _workflows[workflowId];
      if (workflow == null) {
        return Left(WorkflowError(
          code: 'WORKFLOW_NOT_FOUND',
          message: 'Workflow not found',
          details: workflowId,
        ));
      }
      
      if (!workflow.canBeExecuted()) {
        return Left(WorkflowError(
          code: 'INVALID_STATUS',
          message: 'Workflow cannot be executed in current status',
          details: workflow.status.name,
        ));
      }
      
      final executionId = _generateExecutionId();
      final execution = WorkflowExecution(
        id: executionId,
        workflowId: workflowId,
        status: WorkflowExecutionStatus.running,
        startedAt: DateTime.now(),
        parameters: parameters ?? {},
        initiatedBy: initiatedBy,
        tasks: workflow.tasks.map((task) => WorkflowTaskExecution(
          id: _generateTaskExecutionId(),
          taskId: task.id,
          status: WorkflowTaskExecutionStatus.pending,
          startedAt: null,
          completedAt: null,
          result: null,
          error: null,
        )).toList(),
      );
      
      // Store execution
      _executions[executionId] = execution;
      
      // Emit event
      _emitEvent(WorkflowEvent(
        id: _generateEventId(),
        workflowId: workflowId,
        executionId: executionId,
        type: WorkflowEventType.executionStarted,
        description: 'Workflow execution started',
        timestamp: DateTime.now(),
        metadata: {'initiated_by': initiatedBy},
      ));
      
      // Start execution
      await _executeWorkflow(execution);
      
      print('✅ Workflow execution started: $executionId');
      return Right(execution);
    } catch (e) {
      print('❌ Failed to execute workflow: $e');
      return Left(WorkflowError(
        code: 'EXECUTION_ERROR',
        message: 'Failed to execute workflow',
        details: e,
      ));
    }
  }

  /// Get workflow by ID
  Workflow? getWorkflow(String id) {
    return _workflows[id];
  }

  /// Get execution by ID
  WorkflowExecution? getExecution(String id) {
    return _executions[id];
  }

  /// Get workflows by type
  List<Workflow> getWorkflowsByType(WorkflowType type) {
    return _workflows.values.where((w) => w.type == type).toList();
  }

  /// Get executions by status
  List<WorkflowExecution> getExecutionsByStatus(WorkflowExecutionStatus status) {
    return _executions.values.where((e) => e.status == status).toList();
  }

  /// Get workflow statistics
  WorkflowStatistics getWorkflowStatistics() {
    final totalWorkflows = _workflows.length;
    final activeWorkflows = _workflows.values.where((w) => w.status == WorkflowStatus.active).length;
    final totalExecutions = _executions.length;
    final runningExecutions = _executions.values.where((e) => e.status == WorkflowExecutionStatus.running).length;
    final completedExecutions = _executions.values.where((e) => e.status == WorkflowExecutionStatus.completed).length;
    final failedExecutions = _executions.values.where((e) => e.status == WorkflowExecutionStatus.failed).length;
    
    return WorkflowStatistics(
      totalWorkflows: totalWorkflows,
      activeWorkflows: activeWorkflows,
      totalExecutions: totalExecutions,
      runningExecutions: runningExecutions,
      completedExecutions: completedExecutions,
      failedExecutions: failedExecutions,
      successRate: totalExecutions > 0 ? (completedExecutions / totalExecutions) * 100 : 0.0,
    );
  }

  /// Cancel workflow execution
  Future<Either<WorkflowError, void>> cancelExecution(String executionId) async {
    try {
      print('⏹️ Canceling workflow execution: $executionId');
      
      final execution = _executions[executionId];
      if (execution == null) {
        return Left(WorkflowError(
          code: 'EXECUTION_NOT_FOUND',
          message: 'Execution not found',
          details: executionId,
        ));
      }
      
      if (!execution.canBeCanceled()) {
        return Left(WorkflowError(
          code: 'INVALID_STATUS',
          message: 'Execution cannot be canceled in current status',
          details: execution.status.name,
        ));
      }
      
      final updatedExecution = execution.copyWith(
        status: WorkflowExecutionStatus.canceled,
        completedAt: DateTime.now(),
      );
      
      _executions[executionId] = updatedExecution;
      
      // Emit event
      _emitEvent(WorkflowEvent(
        id: _generateEventId(),
        workflowId: execution.workflowId,
        executionId: executionId,
        type: WorkflowEventType.executionCanceled,
        description: 'Workflow execution canceled',
        timestamp: DateTime.now(),
      ));
      
      print('✅ Workflow execution canceled: $executionId');
      return const Right(null);
    } catch (e) {
      print('❌ Failed to cancel workflow execution: $e');
      return Left(WorkflowError(
        code: 'CANCEL_ERROR',
        message: 'Failed to cancel workflow execution',
        details: e,
      ));
    }
  }

  /// Create workflow from template
  Future<Either<WorkflowError, Workflow>> createWorkflowFromTemplate({
    required String templateId,
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      print('📋 Creating workflow from template: $templateId');
      
      final template = _templates[templateId];
      if (template == null) {
        return Left(WorkflowError(
          code: 'TEMPLATE_NOT_FOUND',
          message: 'Template not found',
          details: templateId,
        ));
      }
      
      final workflow = Workflow(
        id: _generateWorkflowId(),
        name: name,
        description: template.description,
        tasks: template.tasks,
        type: template.type,
        status: WorkflowStatus.active,
        metadata: {
          ...template.metadata,
          'template_id': templateId,
          'template_parameters': parameters ?? {},
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Store workflow
      _workflows[workflow.id] = workflow;
      
      // Store tasks
      for (final task in workflow.tasks) {
        _tasks[task.id] = task;
      }
      
      print('✅ Workflow created from template: $name');
      return Right(workflow);
    } catch (e) {
      print('❌ Failed to create workflow from template: $e');
      return Left(WorkflowError(
        code: 'TEMPLATE_ERROR',
        message: 'Failed to create workflow from template',
        details: e,
      ));
    }
  }

  /// Execute workflow from template
  Future<Either<WorkflowError, WorkflowExecution>> executeWorkflowFromTemplate({
    required String templateId,
    required String name,
    Map<String, dynamic>? parameters,
    String? initiatedBy,
  }) async {
    try {
      print('🚀 Executing workflow from template: $templateId');
      
      final workflowResult = await createWorkflowFromTemplate(
        templateId: templateId,
        name: name,
        parameters: parameters,
      );
      
      return workflowResult.fold(
        (error) => Left(error),
        (workflow) async {
          return await executeWorkflow(
            workflowId: workflow.id,
            parameters: parameters,
            initiatedBy: initiatedBy,
          );
        },
      );
    } catch (e) {
      print('❌ Failed to execute workflow from template: $e');
      return Left(WorkflowError(
        code: 'TEMPLATE_EXECUTION_ERROR',
        message: 'Failed to execute workflow from template',
        details: e,
      ));
    }
  }

  /// Validate workflow
  WorkflowValidationResult _validateWorkflow(Workflow workflow) {
    final errors = <String>[];
    final warnings = <String>[];
    
    if (workflow.name.isEmpty) {
      errors.add('Workflow name cannot be empty');
    }
    
    if (workflow.tasks.isEmpty) {
      errors.add('Workflow must have at least one task');
    }
    
    // Validate tasks
    for (int i = 0; i < workflow.tasks.length; i++) {
      final task = workflow.tasks[i];
      
      if (task.name.isEmpty) {
        errors.add('Task ${i + 1} name cannot be empty');
      }
      
      if (task.dependencies.isNotEmpty) {
        for (final dependency in task.dependencies) {
          if (!workflow.tasks.any((t) => t.id == dependency)) {
            errors.add('Task ${i + 1} has invalid dependency: $dependency');
          }
        }
      }
    }
    
    // Check for circular dependencies
    if (_hasCircularDependencies(workflow.tasks)) {
      errors.add('Workflow has circular dependencies');
    }
    
    return WorkflowValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Check for circular dependencies
  bool _hasCircularDependencies(List<WorkflowTask> tasks) {
    final visited = <String>{};
    final recursionStack = <String>{};
    
    bool hasCycle(String taskId) {
      if (recursionStack.contains(taskId)) {
        return true;
      }
      
      if (visited.contains(taskId)) {
        return false;
      }
      
      visited.add(taskId);
      recursionStack.add(taskId);
      
      final task = tasks.firstWhere((t) => t.id == taskId);
      for (final dependency in task.dependencies) {
        if (hasCycle(dependency)) {
          return true;
        }
      }
      
      recursionStack.remove(taskId);
      return false;
    }
    
    for (final task in tasks) {
      if (hasCycle(task.id)) {
        return true;
      }
    }
    
    return false;
  }

  /// Execute workflow
  Future<void> _executeWorkflow(WorkflowExecution execution) async {
    try {
      final workflow = _workflows[execution.workflowId]!;
      
      // Execute tasks in dependency order
      final taskQueue = <WorkflowTaskExecution>[];
      final completedTasks = <String>{};
      
      // Initialize task queue
      for (final taskExecution in execution.tasks) {
        if (taskExecution.task.dependencies.isEmpty) {
          taskQueue.add(taskExecution);
        }
      }
      
      while (taskQueue.isNotEmpty) {
        final taskExecution = taskQueue.removeAt(0);
        final task = workflow.tasks.firstWhere((t) => t.id == taskExecution.taskId);
        
        // Check if all dependencies are completed
        if (!task.dependencies.every((dep) => completedTasks.contains(dep))) {
          taskQueue.add(taskExecution); // Re-add to queue
          continue;
        }
        
        // Execute task
        await _executeTask(taskExecution, task);
        completedTasks.add(task.id);
        
        // Add dependent tasks to queue
        for (final nextTaskExecution in execution.tasks) {
          if (nextTaskExecution.task.dependencies.contains(task.id) &&
              !completedTasks.contains(nextTaskExecution.taskId) &&
              !taskQueue.contains(nextTaskExecution)) {
            taskQueue.add(nextTaskExecution);
          }
        }
      }
      
      // Update execution status
      final allTasksCompleted = execution.tasks.every((t) => 
        t.status == WorkflowTaskExecutionStatus.completed ||
        t.status == WorkflowTaskExecutionStatus.failed
      );
      
      if (allTasksCompleted) {
        final hasFailedTasks = execution.tasks.any((t) => t.status == WorkflowTaskExecutionStatus.failed);
        final updatedExecution = execution.copyWith(
          status: hasFailedTasks ? WorkflowExecutionStatus.failed : WorkflowExecutionStatus.completed,
          completedAt: DateTime.now(),
        );
        
        _executions[execution.id] = updatedExecution;
        
        // Emit event
        _emitEvent(WorkflowEvent(
          id: _generateEventId(),
          workflowId: execution.workflowId,
          executionId: execution.id,
          type: hasFailedTasks ? WorkflowEventType.executionFailed : WorkflowEventType.executionCompleted,
          description: hasFailedTasks ? 'Workflow execution failed' : 'Workflow execution completed',
          timestamp: DateTime.now(),
        ));
      }
    } catch (e) {
      print('❌ Workflow execution error: $e');
      
      final updatedExecution = execution.copyWith(
        status: WorkflowExecutionStatus.failed,
        completedAt: DateTime.now(),
      );
      
      _executions[execution.id] = updatedExecution;
      
      // Emit event
      _emitEvent(WorkflowEvent(
        id: _generateEventId(),
        workflowId: execution.workflowId,
        executionId: execution.id,
        type: WorkflowEventType.executionFailed,
        description: 'Workflow execution failed',
        timestamp: DateTime.now(),
        metadata: {'error': e.toString()},
      ));
    }
  }

  /// Execute task
  Future<void> _executeTask(WorkflowTaskExecution taskExecution, WorkflowTask task) async {
    try {
      print('🔧 Executing task: ${task.name}');
      
      final updatedTaskExecution = taskExecution.copyWith(
        status: WorkflowTaskExecutionStatus.running,
        startedAt: DateTime.now(),
      );
      
      // Update task execution
      final execution = _executions.values.firstWhere((e) => e.workflowId == taskExecution.workflowId);
      final taskIndex = execution.tasks.indexWhere((t) => t.id == taskExecution.id);
      execution.tasks[taskIndex] = updatedTaskExecution;
      
      // Execute task logic
      final result = await _executeTaskLogic(task);
      
      final completedTaskExecution = updatedTaskExecution.copyWith(
        status: WorkflowTaskExecutionStatus.completed,
        completedAt: DateTime.now(),
        result: result,
      );
      
      execution.tasks[taskIndex] = completedTaskExecution;
      
      // Emit event
      _emitEvent(WorkflowEvent(
        id: _generateEventId(),
        workflowId: taskExecution.workflowId,
        executionId: execution.id,
        type: WorkflowEventType.taskCompleted,
        description: 'Task completed: ${task.name}',
        timestamp: DateTime.now(),
        metadata: {'task_name': task.name, 'task_id': task.id},
      ));
      
      print('✅ Task completed: ${task.name}');
    } catch (e) {
      print('❌ Task execution error: $e');
      
      final failedTaskExecution = taskExecution.copyWith(
        status: WorkflowTaskExecutionStatus.failed,
        completedAt: DateTime.now(),
        error: e.toString(),
      );
      
      final execution = _executions.values.firstWhere((e) => e.workflowId == taskExecution.workflowId);
      final taskIndex = execution.tasks.indexWhere((t) => t.id == taskExecution.id);
      execution.tasks[taskIndex] = failedTaskExecution;
      
      // Emit event
      _emitEvent(WorkflowEvent(
        id: _generateEventId(),
        workflowId: taskExecution.workflowId,
        executionId: execution.id,
        type: WorkflowEventType.taskFailed,
        description: 'Task failed: ${task.name}',
        timestamp: DateTime.now(),
        metadata: {'task_name': task.name, 'error': e.toString()},
      ));
    }
  }

  /// Execute task logic
  Future<Map<String, dynamic>> _executeTaskLogic(WorkflowTask task) async {
    // This would contain the actual task execution logic
    // For now, we'll simulate task execution
    
    print('⚙️ Executing task logic: ${task.name}');
    
    // Simulate task execution time
    await Future.delayed(Duration(milliseconds: task.estimatedDuration));
    
    // Return task result
    return {
      'task_id': task.id,
      'task_name': task.name,
      'completed_at': DateTime.now().toIso8601String(),
      'success': true,
    };
  }

  /// Load built-in workflows
  Future<void> _loadBuiltInWorkflows() async {
    try {
      print('📂 Loading built-in workflows...');
      
      // Development workflow
      await _createDevelopmentWorkflow();
      
      // Deployment workflow
      await _createDeploymentWorkflow();
      
      // Testing workflow
      await _createTestingWorkflow();
      
      // Documentation workflow
      await _createDocumentationWorkflow();
      
      print('✅ Built-in workflows loaded');
    } catch (e) {
      print('❌ Failed to load built-in workflows: $e');
    }
  }

  /// Create development workflow
  Future<void> _createDevelopmentWorkflow() async {
    final tasks = [
      WorkflowTask(
        id: 'setup-dev-env',
        name: 'Setup Development Environment',
        description: 'Configure development environment and dependencies',
        estimatedDuration: 30000,
        dependencies: [],
        type: WorkflowTaskType.setup,
      ),
      WorkflowTask(
        id: 'implement-features',
        name: 'Implement Features',
        description: 'Develop new features and functionality',
        estimatedDuration: 60000,
        dependencies: ['setup-dev-env'],
        type: WorkflowTaskType.development,
      ),
      WorkflowTask(
        id: 'unit-testing',
        name: 'Unit Testing',
        description: 'Write and run unit tests',
        estimatedDuration: 30000,
        dependencies: ['implement-features'],
        type: WorkflowTaskType.testing,
      ),
      WorkflowTask(
        id: 'code-review',
        name: 'Code Review',
        description: 'Review code quality and best practices',
        estimatedDuration: 20000,
        dependencies: ['unit-testing'],
        type: WorkflowTaskType.review,
      ),
    ];
    
    await createWorkflow(
      name: 'Development Workflow',
      description: 'Standard development process for new features',
      tasks: tasks,
      type: WorkflowType.development,
    );
  }

  /// Create deployment workflow
  Future<void> _createDeploymentWorkflow() async {
    final tasks = [
      WorkflowTask(
        id: 'build-artifacts',
        name: 'Build Artifacts',
        description: 'Build application artifacts for deployment',
        estimatedDuration: 45000,
        dependencies: [],
        type: WorkflowTaskType.build,
      ),
      WorkflowTask(
        id: 'security-scan',
        name: 'Security Scan',
        description: 'Run security vulnerability scans',
        estimatedDuration: 30000,
        dependencies: ['build-artifacts'],
        type: WorkflowTaskType.security,
      ),
      WorkflowTask(
        id: 'deploy-staging',
        name: 'Deploy to Staging',
        description: 'Deploy application to staging environment',
        estimatedDuration: 60000,
        dependencies: ['security-scan'],
        type: WorkflowTaskType.deployment,
      ),
      WorkflowTask(
        id: 'integration-testing',
        name: 'Integration Testing',
        description: 'Run integration tests on staging',
        estimatedDuration: 45000,
        dependencies: ['deploy-staging'],
        type: WorkflowTaskType.testing,
      ),
      WorkflowTask(
        id: 'deploy-production',
        name: 'Deploy to Production',
        description: 'Deploy application to production environment',
        estimatedDuration: 60000,
        dependencies: ['integration-testing'],
        type: WorkflowTaskType.deployment,
      ),
    ];
    
    await createWorkflow(
      name: 'Deployment Workflow',
      description: 'Standard deployment process for production releases',
      tasks: tasks,
      type: WorkflowType.deployment,
    );
  }

  /// Create testing workflow
  Future<void> _createTestingWorkflow() async {
    final tasks = [
      WorkflowTask(
        id: 'unit-tests',
        name: 'Unit Tests',
        description: 'Run unit test suite',
        estimatedDuration: 30000,
        dependencies: [],
        type: WorkflowTaskType.testing,
      ),
      WorkflowTask(
        id: 'integration-tests',
        name: 'Integration Tests',
        description: 'Run integration test suite',
        estimatedDuration: 45000,
        dependencies: ['unit-tests'],
        type: WorkflowTaskType.testing,
      ),
      WorkflowTask(
        id: 'e2e-tests',
        name: 'End-to-End Tests',
        description: 'Run end-to-end test suite',
        estimatedDuration: 60000,
        dependencies: ['integration-tests'],
        type: WorkflowTaskType.testing,
      ),
      WorkflowTask(
        id: 'performance-tests',
        name: 'Performance Tests',
        description: 'Run performance and load tests',
        estimatedDuration: 90000,
        dependencies: ['e2e-tests'],
        type: WorkflowTaskType.testing,
      ),
    ];
    
    await createWorkflow(
      name: 'Testing Workflow',
      description: 'Comprehensive testing process for quality assurance',
      tasks: tasks,
      type: WorkflowType.testing,
    );
  }

  /// Create documentation workflow
  Future<void> _createDocumentationWorkflow() async {
    final tasks = [
      WorkflowTask(
        id: 'generate-docs',
        name: 'Generate Documentation',
        description: 'Generate API documentation and user guides',
        estimatedDuration: 30000,
        dependencies: [],
        type: WorkflowTaskType.documentation,
      ),
      WorkflowTask(
        id: 'review-docs',
        name: 'Review Documentation',
        description: 'Review documentation for accuracy and completeness',
        estimatedDuration: 20000,
        dependencies: ['generate-docs'],
        type: WorkflowTaskType.review,
      ),
      WorkflowTask(
        id: 'publish-docs',
        name: 'Publish Documentation',
        description: 'Publish documentation to documentation portal',
        estimatedDuration: 15000,
        dependencies: ['review-docs'],
        type: WorkflowTaskType.deployment,
      ),
    ];
    
    await createWorkflow(
      name: 'Documentation Workflow',
      description: 'Documentation generation and publishing process',
      tasks: tasks,
      type: WorkflowType.documentation,
    );
  }

  /// Load workflow templates
  Future<void> _loadWorkflowTemplates() async {
    try {
      print('📂 Loading workflow templates...');
      
      // Add built-in templates
      _templates['feature-development'] = WorkflowTemplate(
        id: 'feature-development',
        name: 'Feature Development Template',
        description: 'Template for developing new features',
        type: WorkflowType.development,
        tasks: [
          WorkflowTask(
            id: 'feature-analysis',
            name: 'Feature Analysis',
            description: 'Analyze requirements and create design',
            estimatedDuration: 30000,
            dependencies: [],
            type: WorkflowTaskType.analysis,
          ),
          WorkflowTask(
            id: 'feature-development',
            name: 'Feature Development',
            description: 'Implement the feature',
            estimatedDuration: 90000,
            dependencies: ['feature-analysis'],
            type: WorkflowTaskType.development,
          ),
          WorkflowTask(
            id: 'feature-testing',
            name: 'Feature Testing',
            description: 'Test the feature implementation',
            estimatedDuration: 45000,
            dependencies: ['feature-development'],
            type: WorkflowTaskType.testing,
          ),
        ],
        metadata: {},
      );
      
      print('✅ Workflow templates loaded');
    } catch (e) {
      print('❌ Failed to load workflow templates: $e');
    }
  }

  /// Start monitoring
  void _startMonitoring() {
    _monitoringTimer?.cancel();
    
    _monitoringTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      if (!_isInitialized) return;
      
      try {
        await _monitorExecutions();
      } catch (e) {
        print('❌ Failed to monitor executions: $e');
      }
    });
    
    print('✅ Workflow monitoring started');
  }

  /// Monitor executions
  Future<void> _monitorExecutions() async {
    try {
      final runningExecutions = _executions.values.where((e) => e.status == WorkflowExecutionStatus.running);
      
      for (final execution in runningExecutions) {
        final duration = DateTime.now().difference(execution.startedAt!);
        
        // Check for timeout (30 minutes)
        if (duration.inMinutes > 30) {
          print('⚠️ Workflow execution timeout: ${execution.id}');
          
          await cancelExecution(execution.id);
        }
      }
    } catch (e) {
      print('❌ Failed to monitor executions: $e');
    }
  }

  /// Emit event
  void _emitEvent(WorkflowEvent event) {
    _eventController.add(event);
    
    // Store event
    if (!_events.containsKey(event.workflowId)) {
      _events[event.workflowId] = [];
    }
    _events[event.workflowId]!.add(event);
  }

  /// Generate IDs
  String _generateWorkflowId() => 'wf_${DateTime.now().millisecondsSinceEpoch}';
  String _generateExecutionId() => 'exec_${DateTime.now().millisecondsSinceEpoch}';
  String _generateEventId() => 'evt_${DateTime.now().millisecondsSinceEpoch}';
  String _generateTaskExecutionId() => 'task_${DateTime.now().millisecondsSinceEpoch}';

  /// Dispose resources
  void dispose() {
    print('🗑️ Disposing Workflow Manager...');
    
    _monitoringTimer?.cancel();
    _eventController.close();
    _executionController.close();
    
    print('✅ Workflow Manager disposed');
  }
}

// Entity classes for workflow management

class Workflow extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<WorkflowTask> tasks;
  final WorkflowType type;
  final WorkflowStatus status;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Workflow({
    required this.id,
    required this.name,
    required this.description,
    required this.tasks,
    required this.type,
    required this.status,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  Workflow copyWith({
    String? id,
    String? name,
    String? description,
    List<WorkflowTask>? tasks,
    WorkflowType? type,
    WorkflowStatus? status,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Workflow(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      tasks: tasks ?? this.tasks,
      type: type ?? this.type,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool canBeExecuted() => status == WorkflowStatus.active;

  @override
  List<Object> get props => [
        id,
        name,
        description,
        tasks,
        type,
        status,
        metadata,
        createdAt,
        updatedAt,
      ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Workflow && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class WorkflowTask extends Equatable {
  final String id;
  final String name;
  final String description;
  final int estimatedDuration; // in milliseconds
  final List<String> dependencies;
  final WorkflowTaskType type;

  const WorkflowTask({
    required this.id,
    required this.name,
    required this.description,
    required this.estimatedDuration,
    required this.dependencies,
    required this.type,
  });

  @override
  List<Object> get props => [
        id,
        name,
        description,
        estimatedDuration,
        dependencies,
        type,
      ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkflowTask && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class WorkflowExecution extends Equatable {
  final String id;
  final String workflowId;
  final WorkflowExecutionStatus status;
  final DateTime startedAt;
  final DateTime? completedAt;
  final Map<String, dynamic> parameters;
  final String? initiatedBy;
  final List<WorkflowTaskExecution> tasks;

  const WorkflowExecution({
    required this.id,
    required this.workflowId,
    required this.status,
    required this.startedAt,
    this.completedAt,
    required this.parameters,
    this.initiatedBy,
    required this.tasks,
  });

  WorkflowExecution copyWith({
    String? id,
    String? workflowId,
    WorkflowExecutionStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
    Map<String, dynamic>? parameters,
    String? initiatedBy,
    List<WorkflowTaskExecution>? tasks,
  }) {
    return WorkflowExecution(
      id: id ?? this.id,
      workflowId: workflowId ?? this.workflowId,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      parameters: parameters ?? this.parameters,
      initiatedBy: initiatedBy ?? this.initiatedBy,
      tasks: tasks ?? this.tasks,
    );
  }

  bool canBeCanceled() => status == WorkflowExecutionStatus.running;

  @override
  List<Object> get props => [
        id,
        workflowId,
        status,
        startedAt,
        completedAt,
        parameters,
        initiatedBy,
        tasks,
      ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkflowExecution && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class WorkflowTaskExecution extends Equatable {
  final String id;
  final String taskId;
  final WorkflowTaskExecutionStatus status;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final Map<String, dynamic>? result;
  final String? error;

  const WorkflowTaskExecution({
    required this.id,
    required this.taskId,
    required this.status,
    this.startedAt,
    this.completedAt,
    this.result,
    this.error,
  });

  WorkflowTaskExecution copyWith({
    String? id,
    String? taskId,
    WorkflowTaskExecutionStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
    Map<String, dynamic>? result,
    String? error,
  }) {
    return WorkflowTaskExecution(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      result: result ?? this.result,
      error: error ?? this.error,
    );
  }

  @override
  List<Object> get props => [
        id,
        taskId,
        status,
        startedAt,
        completedAt,
        result,
        error,
      ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkflowTaskExecution && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class WorkflowEvent extends Equatable {
  final String id;
  final String workflowId;
  final String? executionId;
  final WorkflowEventType type;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const WorkflowEvent({
    required this.id,
    required this.workflowId,
    this.executionId,
    required this.type,
    required this.description,
    required this.timestamp,
    required this.metadata,
  });

  @override
  List<Object> get props => [
        id,
        workflowId,
        executionId,
        type,
        description,
        timestamp,
        metadata,
      ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkflowEvent && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class WorkflowTemplate extends Equatable {
  final String id;
  final String name;
  final String description;
  final WorkflowType type;
  final List<WorkflowTask> tasks;
  final Map<String, dynamic> metadata;

  const WorkflowTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.tasks,
    required this.metadata,
  });

  @override
  List<Object> get props => [
        id,
        name,
        description,
        type,
        tasks,
        metadata,
      ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkflowTemplate && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class WorkflowStatistics extends Equatable {
  final int totalWorkflows;
  final int activeWorkflows;
  final int totalExecutions;
  final int runningExecutions;
  final int completedExecutions;
  final int failedExecutions;
  final double successRate;

  const WorkflowStatistics({
    required this.totalWorkflows,
    required this.activeWorkflows,
    required this.totalExecutions,
    required this.runningExecutions,
    required this.completedExecutions,
    required this.failedExecutions,
    required this.successRate,
  });

  @override
  List<Object> get props => [
        totalWorkflows,
        activeWorkflows,
        totalExecutions,
        runningExecutions,
        completedExecutions,
        failedExecutions,
        successRate,
      ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkflowStatistics && 
           other.totalWorkflows == totalWorkflows &&
           other.activeWorkflows == activeWorkflows &&
           other.totalExecutions == totalExecutions &&
           other.runningExecutions == runningExecutions &&
           other.completedExecutions == completedExecutions &&
           other.failedExecutions == failedExecutions &&
           other.successRate == successRate;
  }

  @override
  int get hashCode => Object.hash(
        totalWorkflows,
        activeWorkflows,
        totalExecutions,
        runningExecutions,
        completedExecutions,
        failedExecutions,
        successRate,
      );
}

class WorkflowValidationResult extends Equatable {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const WorkflowValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });

  @override
  List<Object> get props => [isValid, errors, warnings];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkflowValidationResult && 
           other.isValid == isValid &&
           other.errors == errors &&
           other.warnings == warnings;
  }

  @override
  int get hashCode => Object.hash(isValid, errors, warnings);
}

class WorkflowError extends Equatable {
  final String code;
  final String message;
  final dynamic details;

  const WorkflowError({
    required this.code,
    required this.message,
    this.details,
  });

  @override
  List<Object> get props => [code, message, details];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkflowError && 
           other.code == code &&
           other.message == message &&
           other.details == details;
  }

  @override
  int get hashCode => Object.hash(code, message, details);
}

// Enums
enum WorkflowType {
  development,
  deployment,
  testing,
  documentation,
  maintenance,
  monitoring,
  security,
  quality,
}

enum WorkflowStatus {
  active,
  inactive,
  archived,
  deprecated,
}

enum WorkflowExecutionStatus {
  pending,
  running,
  completed,
  failed,
  canceled,
  paused,
}

enum WorkflowTaskType {
  setup,
  analysis,
  development,
  testing,
  review,
  build,
  deployment,
  security,
  documentation,
  monitoring,
  maintenance,
  quality,
}

enum WorkflowTaskExecutionStatus {
  pending,
  running,
  completed,
  failed,
  canceled,
  skipped,
}

enum WorkflowEventType {
  workflowCreated,
  workflowUpdated,
  workflowDeleted,
  executionStarted,
  executionCompleted,
  executionFailed,
  executionCanceled,
  executionPaused,
  executionResumed,
  taskStarted,
  taskCompleted,
  taskFailed,
  taskCanceled,
  taskSkipped,
}

// Either type for error handling
class Either<L, R> {
  final L? _left;
  final R? _right;
  final bool _isLeft;

  const Either.left(L value) : _left = value, _right = null, _isLeft = true;
  const Either.right(R value) : _left = null, _right = value, _isLeft = false;

  bool isLeft() => _isLeft;
  bool isRight() => !_isLeft;

  L? get left => _left;
  R? get right => _right;

  T fold<T>(T Function(L) ifLeft, T Function(R) ifRight) {
    return _isLeft ? ifLeft(_left!) : ifRight(_right!);
  }
}
