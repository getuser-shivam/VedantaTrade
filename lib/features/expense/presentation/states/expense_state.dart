import 'package:equatable/equatable.dart';
import '../../domain/entities/expense_entity.dart';

/// Expense State
/// Represents the current state of expense operations
class ExpenseState extends Equatable {
  final List<ExpenseEntity> expenses;
  final Map<String, dynamic>? statistics;
  final ExpenseFilter? activeFilter;
  final Set<String> selectedExpenses;
  final bool isLoading;
  final bool isSubmitting;
  final bool isApproving;
  final bool isRejecting;
  final bool isDeleting;
  final bool isExporting;
  final String? error;
  final String? successMessage;
  final bool hasActiveFilter;
  
  const ExpenseState({
    this.expenses = const [],
    this.statistics,
    this.activeFilter,
    this.selectedExpenses = const {},
    this.isLoading = false,
    this.isSubmitting = false,
    this.isApproving = false,
    this.isRejecting = false,
    this.isDeleting = false,
    this.isExporting = false,
    this.error,
    this.successMessage,
  }) : hasActiveFilter = activeFilter != null;
  
  /// Initial state
  const ExpenseState.initial()
      : expenses = const [],
        selectedExpenses = const {},
        isLoading = false,
        isSubmitting = false,
        isApproving = false,
        isRejecting = false,
        isDeleting = false,
        isExporting = false,
        hasActiveFilter = false;
  
  /// Loading state
  const ExpenseState.loading()
      : expenses = const [],
        selectedExpenses = const {},
        isLoading = true,
        isSubmitting = false,
        isApproving = false,
        isRejecting = false,
        isDeleting = false,
        isExporting = false,
        hasActiveFilter = false;
  
  /// Loaded state
  const ExpenseState.loaded({
    List<ExpenseEntity> expenses = const [],
    Map<String, dynamic>? statistics,
    ExpenseFilter? activeFilter,
    Set<String> selectedExpenses = const {},
    String? successMessage,
  }) : expenses = expenses,
       statistics = statistics,
       activeFilter = activeFilter,
       selectedExpenses = selectedExpenses,
       isLoading = false,
       isSubmitting = false,
       isApproving = false,
       isRejecting = false,
       isDeleting = false,
       isExporting = false,
       error = null,
       successMessage = successMessage,
       hasActiveFilter = activeFilter != null;
  
  /// Success state
  const ExpenseState.success({
    String? message,
  }) : expenses = const [],
        selectedExpenses = const {},
        isLoading = false,
        isSubmitting = false,
        isApproving = false,
        isRejecting = false,
        isDeleting = false,
        isExporting = false,
        error = null,
        successMessage = message,
        hasActiveFilter = false;
  
  /// Error state
  const ExpenseState.error({
    required String message,
    List<ExpenseEntity> expenses = const [],
    Set<String> selectedExpenses = const {},
    ExpenseFilter? activeFilter,
  }) : expenses = expenses,
       selectedExpenses = selectedExpenses,
       activeFilter = activeFilter,
       isLoading = false,
       isSubmitting = false,
       isApproving = false,
       isRejecting = false,
       isDeleting = false,
       isExporting = false,
       error = message,
       successMessage = null,
       hasActiveFilter = activeFilter != null;
  
  /// Submitting state
  const ExpenseState.submitting({
    List<ExpenseEntity> expenses = const [],
    Set<String> selectedExpenses = const {},
    ExpenseFilter? activeFilter,
  }) : expenses = expenses,
       selectedExpenses = selectedExpenses,
       activeFilter = activeFilter,
       isLoading = false,
       isSubmitting = true,
       isApproving = false,
       isRejecting = false,
       isDeleting = false,
       isExporting = false,
       error = null,
       successMessage = null,
       hasActiveFilter = activeFilter != null;
  
  /// Approving state
  const ExpenseState.approving({
    List<ExpenseEntity> expenses = const [],
    Set<String> selectedExpenses = const {},
    ExpenseFilter? activeFilter,
  }) : expenses = expenses,
       selectedExpenses = selectedExpenses,
       activeFilter = activeFilter,
       isLoading = false,
       isSubmitting = false,
       isApproving = true,
       isRejecting = false,
       isDeleting = false,
       isExporting = false,
       error = null,
       successMessage = null,
       hasActiveFilter = activeFilter != null;
  
  /// Rejecting state
  const ExpenseState.rejecting({
    List<ExpenseEntity> expenses = const [],
    Set<String> selectedExpenses = const {},
    ExpenseFilter? activeFilter,
  }) : expenses = expenses,
       selectedExpenses = selectedExpenses,
       activeFilter = activeFilter,
       isLoading = false,
       isSubmitting = false,
       isApproving = false,
       isRejecting = true,
       isDeleting = false,
       isExporting = false,
       error = null,
       successMessage = null,
       hasActiveFilter = activeFilter != null;
  
  /// Deleting state
  const ExpenseState.deleting({
    List<ExpenseEntity> expenses = const [],
    Set<String> selectedExpenses = const {},
    ExpenseFilter? activeFilter,
  }) : expenses = expenses,
       selectedExpenses = selectedExpenses,
       activeFilter = activeFilter,
       isLoading = false,
       isSubmitting = false,
       isApproving = false,
       isRejecting = false,
       isDeleting = true,
       isExporting = false,
       error = null,
       successMessage = null,
       hasActiveFilter = activeFilter != null;
  
  /// Exporting state
  const ExpenseState.exporting({
    List<ExpenseEntity> expenses = const [],
    Set<String> selectedExpenses = const {},
    ExpenseFilter? activeFilter,
  }) : expenses = expenses,
       selectedExpenses = selectedExpenses,
       activeFilter = activeFilter,
       isLoading = false,
       isSubmitting = false,
       isApproving = false,
       isRejecting = false,
       isDeleting = false,
       isExporting = true,
       error = null,
       successMessage = null,
       hasActiveFilter = activeFilter != null;
  
  @override
  List<Object?> get props => [
        expenses,
        statistics,
        activeFilter,
        selectedExpenses,
        isLoading,
        isSubmitting,
        isApproving,
        isRejecting,
        isDeleting,
        isExporting,
        error,
        successMessage,
        hasActiveFilter,
      ];
  
  /// Check if state is loading
  bool get isAnyLoading => isLoading || isSubmitting || isApproving || isRejecting || isDeleting || isExporting;
  
  /// Check if state has error
  bool get hasError => error != null;
  
  /// Check if state has success message
  bool get hasSuccessMessage => successMessage != null;
  
  /// Check if expenses are loaded
  bool get isLoaded => !isLoading && !hasError;
  
  /// Get pending expenses count
  int get pendingCount => expenses.where((e) => 
    e.status == ExpenseStatus.pending || e.status == ExpenseStatus.submitted
  ).length;
  
  /// Get approved expenses count
  int get approvedCount => expenses.where((e) => e.status == ExpenseStatus.approved).length;
  
  /// Get rejected expenses count
  int get rejectedCount => expenses.where((e) => e.status == ExpenseStatus.rejected).length;
  
  /// Get total expenses amount
  double get totalAmount => expenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
  
  /// Get pending expenses amount
  double get pendingAmount => expenses
      .where((e) => e.status == ExpenseStatus.pending || e.status == ExpenseStatus.submitted)
      .fold<double>(0.0, (sum, expense) => sum + expense.amount);
  
  /// Get approved expenses amount
  double get approvedAmount => expenses
      .where((e) => e.status == ExpenseStatus.approved)
      .fold<double>(0.0, (sum, expense) => sum + expense.amount);
  
  /// Get rejected expenses amount
  double get rejectedAmount => expenses
      .where((e) => e.status == ExpenseStatus.rejected)
      .fold<double>(0.0, (sum, expense) => sum + expense.amount);
  
  /// Get selected expenses count
  int get selectedCount => selectedExpenses.length;
  
  /// Check if all expenses are selected
  bool get allSelected => expenses.isNotEmpty && selectedExpenses.length == expenses.length;
  
  /// Check if any expenses are selected
  bool get hasSelected => selectedExpenses.isNotEmpty;
  
  /// Get expenses by status
  List<ExpenseEntity> getExpensesByStatus(ExpenseStatus status) {
    return expenses.where((e) => e.status == status).toList();
  }
  
  /// Get filtered expenses
  List<ExpenseEntity> get filteredExpenses {
    if (activeFilter == null) return expenses;
    
    List<ExpenseEntity> filtered = expenses;
    
    // Filter by status
    if (activeFilter!.status != null) {
      filtered = filtered.where((e) => e.status == activeFilter!.status).toList();
    }
    
    // Filter by category
    if (activeFilter!.category != null) {
      filtered = filtered.where((e) => e.category == activeFilter!.category).toList();
    }
    
    // Filter by date range
    if (activeFilter!.dateRange != null) {
      filtered = filtered.where((e) => 
        e.expenseDate.isAfter(activeFilter!.dateRange!.start) &&
        e.expenseDate.isBefore(activeFilter!.dateRange!.end)
      ).toList();
    }
    
    // Filter by search term
    if (activeFilter!.searchTerm != null && activeFilter!.searchTerm!.isNotEmpty) {
      final searchTerm = activeFilter!.searchTerm!.toLowerCase();
      filtered = filtered.where((e) => 
        e.description.toLowerCase().contains(searchTerm) ||
        e.retailerName.toLowerCase().contains(searchTerm) ||
        e.mrName.toLowerCase().contains(searchTerm) ||
        (e.referenceNumber?.toLowerCase().contains(searchTerm) ?? false)
      ).toList();
    }
    
    // Filter by amount range
    if (activeFilter!.minAmount != null) {
      filtered = filtered.where((e) => e.amount >= activeFilter!.minAmount!).toList();
    }
    
    if (activeFilter!.maxAmount != null) {
      filtered = filtered.where((e) => e.amount <= activeFilter!.maxAmount!).toList();
    }
    
    return filtered;
  }
  
  /// Copy with updated fields
  ExpenseState copyWith({
    List<ExpenseEntity>? expenses,
    Map<String, dynamic>? statistics,
    ExpenseFilter? activeFilter,
    Set<String>? selectedExpenses,
    bool? isLoading,
    bool? isSubmitting,
    bool? isApproving,
    bool? isRejecting,
    bool? isDeleting,
    bool? isExporting,
    String? error,
    String? successMessage,
  }) {
    return ExpenseState(
      expenses: expenses ?? this.expenses,
      statistics: statistics ?? this.statistics,
      activeFilter: activeFilter ?? this.activeFilter,
      selectedExpenses: selectedExpenses ?? this.selectedExpenses,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isApproving: isApproving ?? this.isApproving,
      isRejecting: isRejecting ?? this.isRejecting,
      isDeleting: isDeleting ?? this.isDeleting,
      isExporting: isExporting ?? this.isExporting,
      error: error ?? this.error,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}

/// Expense Filter
/// Represents filter criteria for expenses
class ExpenseFilter extends Equatable {
  final ExpenseStatus? status;
  final ExpenseCategory? category;
  final DateTimeRange? dateRange;
  final String? searchTerm;
  final double? minAmount;
  final double? maxAmount;
  final String? retailerId;
  final String? mrId;
  
  const ExpenseFilter({
    this.status,
    this.category,
    this.dateRange,
    this.searchTerm,
    this.minAmount,
    this.maxAmount,
    this.retailerId,
    this.mrId,
  });
  
  @override
  List<Object?> get props => [
        status,
        category,
        dateRange,
        searchTerm,
        minAmount,
        maxAmount,
        retailerId,
        mrId,
      ];
  
  /// Check if filter is active
  bool get isActive => 
       status != null || 
       category != null || 
       dateRange != null || 
       (searchTerm != null && searchTerm!.isNotEmpty) ||
       minAmount != null || 
       maxAmount != null ||
       retailerId != null ||
       mrId != null;
  
  /// Copy with updated fields
  ExpenseFilter copyWith({
    ExpenseStatus? status,
    ExpenseCategory? category,
    DateTimeRange? dateRange,
    String? searchTerm,
    double? minAmount,
    double? maxAmount,
    String? retailerId,
    String? mrId,
  }) {
    return ExpenseFilter(
      status: status ?? this.status,
      category: category ?? this.category,
      dateRange: dateRange ?? this.dateRange,
      searchTerm: searchTerm ?? this.searchTerm,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      retailerId: retailerId ?? this.retailerId,
      mrId: mrId ?? this.mrId,
    );
  }
}

/// Date Range
/// Represents a date range for filtering
class DateTimeRange extends Equatable {
  final DateTime start;
  final DateTime end;
  
  const DateTimeRange({
    required this.start,
    required this.end,
  });
  
  @override
  List<Object?> get props => [start, end];
  
  /// Check if date is within range
  bool contains(DateTime date) {
    return date.isAfter(start.subtract(const Duration(days: 1))) &&
           date.isBefore(end.add(const Duration(days: 1)));
  }
  
  /// Get duration of range
  Duration get duration => end.difference(start);
  
  /// Get formatted string
  String get formatted {
    final formatter = DateFormat('MMM dd, yyyy');
    return '${formatter.format(start)} - ${formatter.format(end)}';
  }
}
