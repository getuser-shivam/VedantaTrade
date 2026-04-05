import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';
import '../../../../shared/utils/app_utils.dart';

/// Expense Service for VedantaTrade
/// Handles expense management, receipt processing, and reconciliation
class ExpenseService {
  final ExpenseRepository _repository;
  final AppUtils _appUtils;
  
  ExpenseService({
    required ExpenseRepository repository,
    AppUtils? appUtils,
  }) : _repository = repository,
       _appUtils = appUtils ?? AppUtils();
  
  /// Create new expense
  Future<Either<String, ExpenseEntity>> createExpense({
    required String mrId,
    required String mrName,
    required String retailerId,
    required String retailerName,
    required String expenseType,
    required ExpenseCategory category,
    required double amount,
    required String currency,
    required DateTime expenseDate,
    required String description,
    required List<ExpenseItem> items,
    required PaymentMethod paymentMethod,
    String? referenceNumber,
    String? supplierName,
    String? supplierInvoice,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Validate expense data
      final validationResult = _validateExpenseData(
        amount: amount,
        expenseDate: expenseDate,
        items: items,
      );
      
      if (validationResult != null) {
        return Left(validationResult);
      }
      
      // Create expense entity
      final expense = ExpenseEntity(
        id: _appUtils.generateId(),
        mrId: mrId,
        mrName: mrName,
        retailerId: retailerId,
        retailerName: retailerName,
        expenseType: expenseType,
        category: category,
        amount: amount,
        currency: currency,
        expenseDate: expenseDate,
        description: description,
        receipts: [],
        status: ExpenseStatus.pending,
        items: items,
        paymentMethod: paymentMethod,
        referenceNumber: referenceNumber,
        supplierName: supplierName,
        supplierInvoice: supplierInvoice,
        metadata: metadata,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Save expense
      final result = await _repository.createExpense(expense);
      
      return result.fold(
        (error) => Left(error),
        (expense) => Right(expense),
      );
    } catch (e) {
      return Left('Failed to create expense: ${e.toString()}');
    }
  }
  
  /// Add receipt to expense
  Future<Either<String, ExpenseReceipt>> addReceiptToExpense({
    required String expenseId,
    required List<XFile> images,
    required String receiptType,
    String? merchantName,
    String? merchantAddress,
    double? amount,
    String? currency,
    String? receiptNumber,
    String? notes,
  }) async {
    try {
      // Validate images
      if (images.isEmpty) {
        return Left('At least one receipt image is required');
      }
      
      // Process images
      final imageUrls = <String>[];
      final thumbnailUrls = <String>[];
      
      for (int i = 0; i < images.length; i++) {
        final image = images[i];
        
        // Upload image to storage
        final uploadResult = await _uploadReceiptImage(
          expenseId: expenseId,
          imageFile: image,
          fileName: 'receipt_${i + 1}.jpg',
        );
        
        uploadResult.fold(
          (error) => return Left(error),
          (url) {
            imageUrls.add(url);
            
            // Generate thumbnail
            final thumbnailResult = await _generateThumbnail(image);
            thumbnailResult.fold(
              (error) => thumbnailUrls.add(''), // Use original if thumbnail fails
              (thumbnailUrl) => thumbnailUrls.add(thumbnailUrl),
            );
          },
        );
      }
      
      // Create receipt entity
      final receipt = ExpenseReceipt(
        id: _appUtils.generateId(),
        expenseId: expenseId,
        receiptType: receiptType,
        imageUrls: imageUrls,
        thumbnailUrls: thumbnailUrls,
        receiptDate: DateTime.now(),
        merchantName: merchantName,
        merchantAddress: merchantAddress,
        amount: amount,
        currency: currency,
        receiptNumber: receiptNumber,
        notes: notes,
        status: ReceiptStatus.uploaded,
        uploadedBy: 'current_user', // TODO: Get from auth
        uploadedAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Save receipt
      final result = await _repository.createReceipt(receipt);
      
      return result.fold(
        (error) => Left(error),
        (receipt) => Right(receipt),
      );
    } catch (e) {
      return Left('Failed to add receipt: ${e.toString()}');
    }
  }
  
  /// Upload receipt image
  Future<Either<String, String>> _uploadReceiptImage({
    required String expenseId,
    required XFile imageFile,
    required String fileName,
  }) async {
    try {
      // Validate image
      if (imageFile.path.isEmpty) {
        return const Left('Invalid image file');
      }
      
      // Check file size (max 10MB)
      final fileSize = await imageFile.length();
      if (fileSize > 10 * 1024 * 1024) {
        return const Left('Image file size exceeds 10MB limit');
      }
      
      // Check file type
      final allowedTypes = ['jpg', 'jpeg', 'png', 'pdf'];
      final fileExtension = fileName.split('.').last.toLowerCase();
      if (!allowedTypes.contains(fileExtension)) {
        return const Left('Invalid file type. Only JPG, PNG, and PDF are allowed');
      }
      
      // Upload to Firebase Storage
      final result = await _repository.uploadReceiptImage(
        expenseId: expenseId,
        imageFile: imageFile.path,
        fileName: fileName,
      );
      
      return result;
    } catch (e) {
      return Left('Failed to upload receipt image: ${e.toString()}');
    }
  }
  
  /// Generate thumbnail for image
  Future<Either<String, String>> _generateThumbnail(XFile imageFile) async {
    try {
      // TODO: Implement image processing for thumbnail generation
      // For now, return the original image URL
      // In a real implementation, you would:
      // 1. Load the image
      // 2. Resize to thumbnail size (e.g., 200x200)
      // 3. Compress the thumbnail
      // 4. Upload the thumbnail
      // 5. Return the thumbnail URL
      
      // For now, we'll simulate thumbnail generation
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Return a placeholder thumbnail URL
      final thumbnailName = 'thumb_${DateTime.now().millisecondsSinceEpoch}.jpg';
      return Right('https://placeholder.com/thumbnails/$thumbnailName');
    } catch (e) {
      return Left('Failed to generate thumbnail: ${e.toString()}');
    }
  }
  
  /// Process expense images using device camera
  Future<Either<String, List<String>>> captureExpenseImages({
    int maxImages = 5,
    ImageSource source = ImageSource.camera,
    double? maxFileSize,
    double? maxHeight,
    double? maxWidth,
  }) async {
    try {
      final imagePicker = ImagePicker();
      final pickedFiles = <XFile>[];
      
      // Allow multiple images up to maxImages
      final List<XFile>? images = await imagePicker.pickMultiImage(
        source: source,
        imageQuality: 85,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );
      
      if (images != null) {
        pickedFiles.addAll(images);
      }
      
      // Validate file count
      if (pickedFiles.length > maxImages) {
        return Left('Maximum $maxImages images allowed');
      }
      
      // Validate file sizes
      final validFiles = <String>[];
      for (final file in pickedFiles) {
        final fileSize = await file.length();
        final maxSize = maxFileSize ?? 10 * 1024 * 1024; // 10MB default
        
        if (fileSize <= maxSize) {
          validFiles.add(file.path);
        }
      }
      
      if (validFiles.isEmpty) {
        return const Left('No valid images captured');
      }
      
      return Right(validFiles);
    } catch (e) {
      return Left('Failed to capture images: ${e.toString()}');
    }
  }
  
  /// Submit expense for approval
  Future<Either<String, void>> submitExpenseForApproval(String expenseId) async {
    try {
      // Get expense
      final expenseResult = await _repository.getExpense(expenseId);
      
      if (expenseResult.isLeft()) {
        return expenseResult;
      }
      
      final expense = expenseResult.getOrElse(() => throw Exception('Expense not found'));
      
      // Validate expense before submission
      final validationError = _validateExpenseForSubmission(expense);
      if (validationError != null) {
        return Left(validationError);
      }
      
      // Update expense status
      final submittedExpense = expense.copyWith(
        status: ExpenseStatus.submitted,
        updatedAt: DateTime.now(),
      );
      
      return await _repository.updateExpense(submittedExpense);
    } catch (e) {
      return Left('Failed to submit expense: ${e.toString()}');
    }
  }
  
  /// Approve expense
  Future<Either<String, void>> approveExpense({
    required String expenseId,
    required String approvedBy,
    String? notes,
  }) async {
    try {
      // Get expense
      final expenseResult = await _repository.getExpense(expenseId);
      
      if (expenseResult.isLeft()) {
        return expenseResult;
      }
      
      final expense = expenseResult.getOrElse(() => throw Exception('Expense not found'));
      
      // Update expense status
      final approvedExpense = expense.copyWith(
        status: ExpenseStatus.approved,
        approvedBy: approvedBy,
        approvedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      return await _repository.updateExpense(approvedExpense);
    } catch (e) {
      return Left('Failed to approve expense: ${e.toString()}');
    }
  }
  
  /// Reject expense
  Future<Either<String, void>> rejectExpense({
    required String expenseId,
    required String rejectedBy,
    required String rejectionReason,
  }) async {
    try {
      // Get expense
      final expenseResult = await _repository.getExpense(expenseId);
      
      if (expenseResult.isLeft()) {
        return expenseResult;
      }
      
      final expense = expenseResult.getOrElse(() => throw Exception('Expense not found'));
      
      // Update expense status
      final rejectedExpense = expense.copyWith(
        status: ExpenseStatus.rejected,
        rejectedBy: rejectedBy,
        rejectedAt: DateTime.now(),
        rejectionReason: rejectionReason,
        updatedAt: DateTime.now(),
      );
      
      return await _repository.updateExpense(rejectedExpense);
    } catch (e) {
      return Left('Failed to reject expense: ${e.toString()}');
    }
  }
  
  /// Verify receipt
  Future<Either<String, void>> verifyReceipt({
    required String receiptId,
    required String verifiedBy,
    required bool isApproved,
    String? notes,
  }) async {
    try {
      // Get receipt
      final receiptResult = await _repository.getReceipt(receiptId);
      
      if (receiptResult.isLeft()) {
        return receiptResult;
      }
      
      final receipt = receiptResult.getOrElse(() => throw Exception('Receipt not found'));
      
      // Update receipt status
      final verifiedReceipt = receipt.copyWith(
        status: isApproved ? ReceiptStatus.approved : ReceiptStatus.rejected,
        verifiedBy: verifiedBy,
        verifiedAt: DateTime.now(),
        rejectionReason: isApproved ? null : notes,
        updatedAt: DateTime.now(),
      );
      
      return await _repository.updateReceipt(verifiedReceipt);
    } catch (e) {
      return Left('Failed to verify receipt: ${e.toString()}');
    }
  }
  
  /// Get expense statistics
  Future<Either<String, Map<String, dynamic>>> getExpenseStatistics({
    required String mrId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final statisticsResult = await _repository.getExpenseStatistics(mrId);
      
      if (statisticsResult.isLeft()) {
        return statisticsResult;
      }
      
      final statistics = statisticsResult.getOrElse(() => {});
      
      // Filter by date range if provided
      if (startDate != null || endDate != null) {
        final expensesResult = await _repository.getExpensesByDateRange(
          mrId,
          startDate ?? DateTime.now().subtract(const Duration(days: 30)),
          endDate ?? DateTime.now(),
        );
        
        if (expensesResult.isRight()) {
          final expenses = expensesResult.getOrElse(() => []);
          
          // Recalculate statistics for date range
          final filteredStats = _calculateStatisticsFromExpenses(expenses);
          
          return Right({
            ...statistics,
            ...filteredStats,
            'dateRange': {
              'startDate': startDate?.toIso8601String(),
              'endDate': endDate?.toIso8601String(),
            },
          });
        }
      }
      
      return Right(statistics);
    } catch (e) {
      return Left('Failed to get expense statistics: ${e.toString()}');
    }
  }
  
  /// Calculate statistics from expense list
  Map<String, dynamic> _calculateStatisticsFromExpenses(List<ExpenseEntity> expenses) {
    if (expenses.isEmpty) {
      return {
        'totalExpenses': 0,
        'totalAmount': 0.0,
        'averageAmount': 0.0,
        'statusBreakdown': {},
        'categoryBreakdown': {},
        'monthlyBreakdown': {},
      };
    }
    
    final totalExpenses = expenses.length;
    final totalAmount = expenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
    final averageAmount = totalAmount / totalExpenses;
    
    // Status breakdown
    final statusBreakdown = <String, dynamic>{};
    for (final expense in expenses) {
      final status = expense.status.name;
      statusBreakdown[status] = (statusBreakdown[status] ?? 0) + 1;
    }
    
    // Category breakdown
    final categoryBreakdown = <String, dynamic>{};
    for (final expense in expenses) {
      final category = expense.category.name;
      categoryBreakdown[category] = (categoryBreakdown[category] ?? 0.0) + expense.amount;
    }
    
    // Monthly breakdown
    final monthlyBreakdown = <String, dynamic>{};
    for (final expense in expenses) {
      final monthKey = '${expense.expenseDate.year}-${expense.expenseDate.month.toString().padLeft(2, '0')}';
      monthlyBreakdown[monthKey] = (monthlyBreakdown[monthKey] ?? 0.0) + expense.amount;
    }
    
    return {
      'totalExpenses': totalExpenses,
      'totalAmount': totalAmount,
      'averageAmount': averageAmount,
      'statusBreakdown': statusBreakdown,
      'categoryBreakdown': categoryBreakdown,
      'monthlyBreakdown': monthlyBreakdown,
    };
  }
  
  /// Generate expense report
  Future<Either<String, ExpenseReport>> generateExpenseReport({
    required String mrId,
    required DateTime startDate,
    required DateTime endDate,
    String? retailerId,
  }) async {
    try {
      final reportResult = await _repository.generateExpenseReport(
        mrId: mrId,
        startDate: startDate,
        endDate: endDate,
        retailerId: retailerId,
      );
      
      return reportResult;
    } catch (e) {
      return Left('Failed to generate expense report: ${e.toString()}');
    }
  }
  
  /// Auto-categorize expense based on description
  ExpenseCategory categorizeExpense(String description, double amount) {
    final lowerDescription = description.toLowerCase();
    
    // Category mapping based on keywords
    final categoryKeywords = {
      ExpenseCategory.travel: ['travel', 'taxi', 'bus', 'train', 'flight', 'hotel', 'accommodation'],
      ExpenseCategory.meals: ['food', 'restaurant', 'meal', 'lunch', 'dinner', 'breakfast', 'coffee'],
      ExpenseCategory.transportation: ['gas', 'fuel', 'parking', 'uber', 'taxi', 'bus fare'],
      ExpenseCategory.communication: ['phone', 'internet', 'mobile', 'data', 'call'],
      ExpenseCategory.office: ['office', 'supplies', 'stationery', 'printer', 'computer'],
      ExpenseCategory.marketing: ['advertising', 'promotion', 'marketing', 'brochure'],
      ExpenseCategory.entertainment: ['movie', 'entertainment', 'cinema', 'theater', 'show'],
      ExpenseCategory.training: ['training', 'course', 'seminar', 'workshop', 'conference'],
      ExpenseCategory.equipment: ['laptop', 'computer', 'equipment', 'tools', 'device'],
      ExpenseCategory.supplies: ['supplies', 'materials', 'inventory', 'stock'],
      ExpenseCategory.utilities: ['electricity', 'water', 'gas', 'internet', 'phone bill', 'rent'],
      ExpenseCategory.insurance: ['insurance', 'health', 'life', 'car', 'property'],
      ExpenseCategory.taxes: ['tax', 'vat', 'income tax', 'property tax'],
    };
    
    // Check for category matches
    for (final entry in categoryKeywords.entries) {
      for (final keyword in entry.value) {
        if (lowerDescription.contains(keyword)) {
          return entry.key;
        }
      }
    }
    
    // Default categorization based on amount
    if (amount > 10000) {
      return ExpenseCategory.equipment;
    } else if (amount > 5000) {
      return ExpenseCategory.office;
    } else if (amount > 1000) {
      return ExpenseCategory.supplies;
    } else {
      return ExpenseCategory.other;
    }
  }
  
  /// Validate expense data
  String? _validateExpenseData({
    required double amount,
    required DateTime expenseDate,
    required List<ExpenseItem> items,
  }) {
    // Validate amount
    if (amount <= 0) {
      return 'Expense amount must be greater than 0';
    }
    
    if (amount > 1000000) {
      return 'Expense amount exceeds maximum limit';
    }
    
    // Validate date
    final now = DateTime.now();
    final maxDate = now.add(const Duration(days: 7)); // Allow up to 7 days in future
    
    if (expenseDate.isAfter(maxDate)) {
      return 'Expense date cannot be more than 7 days in the future';
    }
    
    if (expenseDate.isBefore(now.subtract(const Duration(days: 365)))) {
      return 'Expense date cannot be more than 1 year in the past';
    }
    
    // Validate items
    if (items.isEmpty) {
      return 'At least one expense item is required';
    }
    
    for (final item in items) {
      if (item.quantity <= 0) {
        return 'Item quantity must be greater than 0';
      }
      
      if (item.unitPrice <= 0) {
        return 'Item unit price must be greater than 0';
      }
      
      if (item.totalPrice <= 0) {
        return 'Item total price must be greater than 0';
      }
    }
    
    return null; // Validation passed
  }
  
  /// Validate expense for submission
  String? _validateExpenseForSubmission(ExpenseEntity expense) {
    // Check if expense has receipts
    if (expense.receipts.isEmpty) {
      return 'Expense must have at least one receipt before submission';
    }
    
    // Check if total amount matches receipt amounts
    if (expense.receipts.isNotEmpty) {
      double receiptTotal = 0.0;
      for (final receipt in expense.receipts) {
        if (receipt.amount != null) {
          receiptTotal += receipt.amount!;
        }
      }
      
      if (receiptTotal > 0 && (receiptTotal - expense.amount).abs() > 0.01) {
        return 'Expense amount does not match receipt total';
      }
    }
    
    // Check if all required fields are filled
    if (expense.description.trim().isEmpty) {
      return 'Expense description is required';
    }
    
    return null; // Validation passed
  }
  
  /// Get expense recommendations
  Future<Either<String, List<Map<String, dynamic>>>> getExpenseRecommendations(String mrId) async {
    try {
      // Get recent expenses
      final expensesResult = await _repository.getExpensesByMR(mrId);
      
      if (expensesResult.isLeft()) {
        return expensesResult;
      }
      
      final expenses = expensesResult.getOrElse(() => []);
      
      // Analyze spending patterns
      final recommendations = <Map<String, dynamic>>[];
      
      // Check for frequent expenses
      final categoryTotals = <ExpenseCategory, double>{};
      for (final expense in expenses) {
        categoryTotals[expense.category] = 
            (categoryTotals[expense.category] ?? 0.0) + expense.amount;
      }
      
      // Generate recommendations
      for (final entry in categoryTotals.entries) {
        if (entry.value > 10000) { // High spending category
          recommendations.add({
            'type': 'high_spending',
            'category': entry.key.name,
            'amount': entry.value,
            'message': 'Consider setting budget limits for ${entry.key.name}',
            'priority': 'high',
          });
        }
      }
      
      // Check for missing receipts
      final expensesWithoutReceipts = expenses.where((e) => e.receipts.isEmpty);
      if (expensesWithoutReceipts.length > 3) {
        recommendations.add({
          'type': 'missing_receipts',
          'count': expensesWithoutReceipts.length,
          'message': 'Multiple expenses without receipts - consider improving documentation',
          'priority': 'medium',
        });
      }
      
      return Right(recommendations);
    } catch (e) {
      return Left('Failed to get expense recommendations: ${e.toString()}');
    }
  }
  
  /// Process expense reconciliation
  Future<Either<String, Map<String, dynamic>>> reconcileExpenses({
    required String mrId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Get expenses for the period
      final expensesResult = await _repository.getExpensesByDateRange(mrId, startDate, endDate);
      
      if (expensesResult.isLeft()) {
        return expensesResult;
      }
      
      final expenses = expensesResult.getOrElse(() => []);
      
      // Perform reconciliation analysis
      final reconciliation = _performReconciliationAnalysis(expenses);
      
      return Right(reconciliation);
    } catch (e) {
      return Left('Failed to reconcile expenses: ${e.toString()}');
    }
  }
  
  /// Perform reconciliation analysis
  Map<String, dynamic> _performReconciliationAnalysis(List<ExpenseEntity> expenses) {
    final totalExpenses = expenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
    final approvedExpenses = expenses
        .where((e) => e.status == ExpenseStatus.approved)
        .fold<double>(0.0, (sum, expense) => sum + expense.amount);
    final pendingExpenses = expenses
        .where((e) => e.status == ExpenseStatus.pending)
        .fold<double>(0.0, (sum, expense) => sum + expense.amount);
    final rejectedExpenses = expenses
        .where((e) => e.status == ExpenseStatus.rejected)
        .fold<double>(0.0, (sum, expense) => sum + expense.amount);
    
    // Calculate reconciliation metrics
    final reconciliationRate = totalExpenses > 0 ? (approvedExpenses / totalExpenses) * 100 : 0.0;
    final pendingAmount = pendingExpenses;
    final rejectedAmount = rejectedExpenses;
    
    return {
      'totalExpenses': totalExpenses,
      'approvedExpenses': approvedExpenses,
      'pendingExpenses': pendingExpenses,
      'rejectedExpenses': rejectedExpenses,
      'reconciliationRate': reconciliationRate,
      'pendingAmount': pendingAmount,
      'rejectedAmount': rejectedAmount,
      'needsAttention': pendingAmount > 5000 || rejectedAmount > 1000,
      'recommendations': _generateReconciliationRecommendations(reconciliationRate, pendingAmount, rejectedAmount),
    };
  }
  
  /// Generate reconciliation recommendations
  List<String> _generateReconciliationRecommendations(
    double reconciliationRate,
    double pendingAmount,
    double rejectedAmount,
  ) {
    final recommendations = <String>[];
    
    if (reconciliationRate < 80) {
      recommendations.add('Reconciliation rate is below 80% - review pending expenses');
    }
    
    if (pendingAmount > 5000) {
      recommendations.add('High pending amount - prioritize expense approval');
    }
    
    if (rejectedAmount > 1000) {
      recommendations.add('Significant rejected amount - review expense policies');
    }
    
    return recommendations;
  }
}
