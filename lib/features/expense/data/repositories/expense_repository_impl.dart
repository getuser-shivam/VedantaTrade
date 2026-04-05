import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dartz/dartz.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../../../shared/services/storage_service.dart';
import '../../../../shared/utils/app_utils.dart';

/// Expense Repository Implementation
/// Handles data persistence and retrieval for expense management
class ExpenseRepositoryImpl implements ExpenseRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final StorageService _storageService;
  final AppUtils _appUtils;
  
  ExpenseRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    StorageService? storageService,
    AppUtils? appUtils,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance,
       _storageService = storageService ?? StorageService(),
       _appUtils = appUtils ?? AppUtils();
  
  @override
  Future<Either<String, ExpenseEntity>> createExpense(ExpenseEntity expense) async {
    try {
      // Create expense in Firestore
      await _firestore
          .collection('expenses')
          .doc(expense.id)
          .set(expense.toMap());
      
      // Cache locally
      await _storageService.saveExpense(expense);
      
      return Right(expense);
    } catch (e) {
      return Left('Failed to create expense: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, ExpenseEntity>> updateExpense(ExpenseEntity expense) async {
    try {
      // Update in Firestore
      await _firestore
          .collection('expenses')
          .doc(expense.id)
          .update(expense.toMap());
      
      // Update cache
      await _storageService.saveExpense(expense);
      
      return Right(expense);
    } catch (e) {
      return Left('Failed to update expense: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, void>> deleteExpense(String expenseId) async {
    try {
      // Delete from Firestore
      await _firestore.collection('expenses').doc(expenseId).delete();
      
      // Delete from cache
      await _storageService.deleteExpense(expenseId);
      
      return const Right(null);
    } catch (e) {
      return Left('Failed to delete expense: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, ExpenseEntity>> getExpense(String expenseId) async {
    try {
      // Try cache first
      final cached = await _storageService.getExpense(expenseId);
      if (cached != null) {
        return Right(cached);
      }
      
      // Fetch from Firestore
      final doc = await _firestore.collection('expenses').doc(expenseId).get();
      
      if (!doc.exists) {
        return const Left('Expense not found');
      }
      
      final expense = ExpenseEntity.fromMap(doc.data()!);
      
      // Cache for future use
      await _storageService.saveExpense(expense);
      
      return Right(expense);
    } catch (e) {
      return Left('Failed to get expense: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, List<ExpenseEntity>>> getExpensesByMR(String mrId) async {
    try {
      final query = await _firestore
          .collection('expenses')
          .where('mrId', isEqualTo: mrId)
          .orderBy('expenseDate', descending: true)
          .get();
      
      final expenses = query.docs
          .map((doc) => ExpenseEntity.fromMap(doc.data()!))
          .toList();
      
      return Right(expenses);
    } catch (e) {
      return Left('Failed to get expenses by MR: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, List<ExpenseEntity>>> getExpensesByRetailer(String retailerId) async {
    try {
      final query = await _firestore
          .collection('expenses')
          .where('retailerId', isEqualTo: retailerId)
          .orderBy('expenseDate', descending: true)
          .get();
      
      final expenses = query.docs
          .map((doc) => ExpenseEntity.fromMap(doc.data()!))
          .toList();
      
      return Right(expenses);
    } catch (e) {
      return Left('Failed to get expenses by retailer: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, List<ExpenseEntity>>> getExpensesByStatus(
    String userId,
    ExpenseStatus status,
  ) async {
    try {
      final query = await _firestore
          .collection('expenses')
          .where('status', isEqualTo: status.name)
          .orderBy('expenseDate', descending: true)
          .get();
      
      final expenses = query.docs
          .map((doc) => ExpenseEntity.fromMap(doc.data()!))
          .toList();
      
      return Right(expenses);
    } catch (e) {
      return Left('Failed to get expenses by status: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, List<ExpenseEntity>>> getExpensesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final query = await _firestore
          .collection('expenses')
          .where('expenseDate', isGreaterThanOrEqualTo: startDate)
          .where('expenseDate', isLessThanOrEqualTo: endDate)
          .orderBy('expenseDate', descending: true)
          .get();
      
      final expenses = query.docs
          .map((doc) => ExpenseEntity.fromMap(doc.data()!))
          .toList();
      
      return Right(expenses);
    } catch (e) {
      return Left('Failed to get expenses by date range: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, List<ExpenseEntity>>> getExpensesByCategory(
    String userId,
    ExpenseCategory category,
  ) async {
    try {
      final query = await _firestore
          .collection('expenses')
          .where('category', isEqualTo: category.name)
          .orderBy('expenseDate', descending: true)
          .get();
      
      final expenses = query.docs
          .map((doc) => ExpenseEntity.fromMap(doc.data()!))
          .toList();
      
      return Right(expenses);
    } catch (e) {
      return Left('Failed to get expenses by category: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, List<ExpenseEntity>>> searchExpenses({
    String? mrId,
    String? retailerId,
    String? searchTerm,
    ExpenseStatus? status,
    ExpenseCategory? category,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection('expenses');
      
      if (mrId != null) {
        query = query.where('mrId', isEqualTo: mrId);
      }
      
      if (retailerId != null) {
        query = query.where('retailerId', isEqualTo: retailerId);
      }
      
      if (status != null) {
        query = query.where('status', isEqualTo: status!.name);
      }
      
      if (category != null) {
        query = query.where('category', isEqualTo: category!.name);
      }
      
      if (startDate != null) {
        query = query.where('expenseDate', isGreaterThanOrEqualTo: startDate);
      }
      
      if (endDate != null) {
        query = query.where('expenseDate', isLessThanOrEqualTo: endDate);
      }
      
      if (limit != null) {
        query = query.limit(limit!);
      }
      
      final snapshot = await query
          .orderBy('expenseDate', descending: true)
          .get();
      
      let expenses = snapshot.docs
          .map((doc) => ExpenseEntity.fromMap(doc.data()!))
          .toList();
      
      // Apply search term filter
      if (searchTerm != null && searchTerm!.isNotEmpty) {
        expenses = expenses.where((expense) {
          return expense.description.toLowerCase().contains(searchTerm!.toLowerCase()) ||
                 expense.retailerName.toLowerCase().contains(searchTerm!.toLowerCase()) ||
                 expense.mrName.toLowerCase().contains(searchTerm!.toLowerCase()) ||
                 expense.referenceNumber?.toLowerCase().contains(searchTerm!.toLowerCase()) == true;
        }).toList();
      }
      
      return Right(expenses);
    } catch (e) {
      return Left('Failed to search expenses: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, ExpenseReceipt>> createReceipt(ExpenseReceipt receipt) async {
    try {
      // Create receipt in Firestore
      await _firestore
          .collection('expense_receipts')
          .doc(receipt.id)
          .set(receipt.toMap());
      
      return Right(receipt);
    } catch (e) {
      return Left('Failed to create receipt: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, ExpenseReceipt>> updateReceipt(ExpenseReceipt receipt) async {
    try {
      // Update in Firestore
      await _firestore
          .collection('expense_receipts')
          .doc(receipt.id)
          .update(receipt.toMap());
      
      return Right(receipt);
    } catch (e) {
      return Left('Failed to update receipt: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, void>> deleteReceipt(String receiptId) async {
    try {
      // Delete from Firestore
      await _firestore.collection('expense_receipts').doc(receiptId).delete();
      
      return const Right(null);
    } catch (e) {
      return Left('Failed to delete receipt: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, List<ExpenseReceipt>>> getReceiptsByExpense(String expenseId) async {
    try {
      final query = await _firestore
          .collection('expense_receipts')
          .where('expenseId', isEqualTo: expenseId)
          .orderBy('createdAt', descending: true)
          .get();
      
      final receipts = query.docs
          .map((doc) => ExpenseReceipt.fromMap(doc.data()!))
          .toList();
      
      return Right(receipts);
    } catch (e) {
      return Left('Failed to get receipts by expense: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, String>> uploadReceiptImage(
    String receiptId,
    String imageFile,
    String fileName,
  ) async {
    try {
      final ref = _storage
          .ref()
          .child('expense_receipts')
          .child(receiptId)
          .child(fileName);
      
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return Right(downloadUrl);
    } catch (e) {
      return Left('Failed to upload receipt image: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, String>> uploadReceiptImages(
    String receiptId,
    List<String> imageFiles,
  ) async {
    try {
      final imageUrls = <String>[];
      
      for (int i = 0; i < imageFiles.length; i++) {
        final fileName = 'receipt_${i + 1}.jpg';
        final result = await uploadReceiptImage(receiptId, imageFiles[i], fileName);
        
        result.fold(
          (error) => throw Exception(error),
          (url) => imageUrls.add(url),
        );
      }
      
      return Right(imageUrls.join(','));
    } catch (e) {
      return Left('Failed to upload receipt images: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, void>> approveExpense(
    String expenseId,
    String approvedBy,
    String? notes,
  ) async {
    try {
      // Get expense
      final expenseResult = await getExpense(expenseId);
      
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
      
      return await updateExpense(approvedExpense);
    } catch (e) {
      return Left('Failed to approve expense: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, void>> rejectExpense(
    String expenseId,
    String rejectedBy,
    String rejectionReason,
  ) async {
    try {
      // Get expense
      final expenseResult = await getExpense(expenseId);
      
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
      
      return await updateExpense(rejectedExpense);
    } catch (e) {
      return Left('Failed to reject expense: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, void>> submitExpense(ExpenseEntity expense) async {
    try {
      // Update expense status
      final submittedExpense = expense.copyWith(
        status: ExpenseStatus.submitted,
        updatedAt: DateTime.now(),
      );
      
      return await updateExpense(submittedExpense);
    } catch (e) {
      return Left('Failed to submit expense: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, void>> verifyReceipt(
    String receiptId,
    String verifiedBy,
    bool isApproved,
    String? notes,
  ) async {
    try {
      // Get receipt
      final receiptResult = await getReceipt(receiptId);
      
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
      
      return await updateReceipt(verifiedReceipt);
    } catch (e) {
      return Left('Failed to verify receipt: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, ExpenseReport>> generateExpenseReport({
    required String mrId,
    required DateTime startDate,
    required DateTime endDate,
    String? retailerId,
  }) async {
    try {
      // Get expenses for the period
      final expensesResult = await getExpensesByDateRange(mrId, startDate, endDate);
      
      if (expensesResult.isLeft()) {
        return Left(expensesResult.fold((l) => l, (r) => 'Failed to get expenses'));
      }
      
      final expenses = expensesResult.getOrElse(() => []);
      
      // Calculate totals by category
      final expensesByCategory = <ExpenseCategory, double>{};
      double totalExpenses = 0.0;
      double approvedExpenses = 0.0;
      double pendingExpenses = 0.0;
      double rejectedExpenses = 0.0;
      
      for (final expense in expenses) {
        totalExpenses += expense.amount;
        
        // Update category totals
        expensesByCategory[expense.category] = 
            (expensesByCategory[expense.category] ?? 0.0) + expense.amount;
        
        // Update status totals
        switch (expense.status) {
          case ExpenseStatus.approved:
            approvedExpenses += expense.amount;
            break;
          case ExpenseStatus.pending:
          case ExpenseStatus.submitted:
          case ExpenseStatus.underReview:
            pendingExpenses += expense.amount;
            break;
          case ExpenseStatus.rejected:
            rejectedExpenses += expense.amount;
            break;
          default:
            break;
        }
      }
      
      // Create report
      final report = ExpenseReport(
        id: _appUtils.generateId(),
        mrId: mrId,
        mrName: expenses.isNotEmpty ? expenses.first.mrName : '',
        retailerId: retailerId ?? '',
        retailerName: expenses.isNotEmpty ? expenses.first.retailerName : '',
        reportPeriodStart: startDate,
        reportPeriodEnd: endDate,
        totalExpenses: totalExpenses,
        approvedExpenses: approvedExpenses,
        pendingExpenses: pendingExpenses,
        rejectedExpenses: rejectedExpenses,
        expensesByCategory: expensesByCategory,
        expenses: expenses,
        status: ReportStatus.draft,
        generatedBy: 'system',
        generatedAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Save report
      await _firestore
          .collection('expense_reports')
          .doc(report.id)
          .set(report.toMap());
      
      return Right(report);
    } catch (e) {
      return Left('Failed to generate expense report: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, List<ExpenseReport>>> getExpenseReports(String mrId) async {
    try {
      final query = await _firestore
          .collection('expense_reports')
          .where('mrId', isEqualTo: mrId)
          .orderBy('reportPeriodStart', descending: true)
          .get();
      
      final reports = query.docs
          .map((doc) => ExpenseReport.fromMap(doc.data()!))
          .toList();
      
      return Right(reports);
    } catch (e) {
      return Left('Failed to get expense reports: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, Map<String, dynamic>>> getExpenseStatistics(String mrId) async {
    try {
      // Get all expenses for MR
      final expensesResult = await getExpensesByMR(mrId);
      
      if (expensesResult.isLeft()) {
        return Left(expensesResult.fold((l) => l, (r) => 'Failed to get expenses'));
      }
      
      final expenses = expensesResult.getOrElse(() => []);
      
      // Calculate statistics
      final totalExpenses = expenses.length;
      final totalAmount = expenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
      
      final statusCounts = <ExpenseStatus, int>{};
      final categoryTotals = <ExpenseCategory, double>{};
      
      for (final expense in expenses) {
        statusCounts[expense.status] = (statusCounts[expense.status] ?? 0) + 1;
        categoryTotals[expense.category] = 
            (categoryTotals[expense.category] ?? 0.0) + expense.amount;
      }
      
      final statistics = {
        'totalExpenses': totalExpenses,
        'totalAmount': totalAmount,
        'averageAmount': totalExpenses > 0 ? totalAmount / totalExpenses : 0.0,
        'statusBreakdown': statusCounts.map((key, value) => MapEntry(key.name, value)),
        'categoryBreakdown': categoryTotals.map((key, value) => MapEntry(key.name, value)),
        'pendingCount': statusCounts[ExpenseStatus.pending] ?? 0,
        'approvedCount': statusCounts[ExpenseStatus.approved] ?? 0,
        'rejectedCount': statusCounts[ExpenseStatus.rejected] ?? 0,
        'lastUpdated': expenses.isNotEmpty ? expenses.first.updatedAt.toIso8601String() : null,
        'lastExpenseDate': expenses.isNotEmpty ? expenses.first.expenseDate.toIso8601String() : null,
      };
      
      return Right(statistics);
    } catch (e) {
      return Left('Failed to get expense statistics: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, void>> cleanupOldExpenses() async {
    try {
      final ninetyDaysAgo = DateTime.now().subtract(const Duration(days: 90));
      
      final query = await _firestore
          .collection('expenses')
          .where('expenseDate', isLessThan: ninetyDaysAgo)
          .where('status', whereIn: [
            ExpenseStatus.approved.name,
            ExpenseStatus.rejected.name,
            ExpenseStatus.paid.name,
            ExpenseStatus.reimbursed.name,
          ])
          .get();
      
      // Archive old expenses
      for (final doc in query.docs) {
        final archiveData = doc.data()!;
        archiveData['archivedAt'] = DateTime.now().toIso8601String();
        
        await _firestore.collection('expenses_archive').add(archiveData);
        await doc.reference.delete();
      }
      
      return const Right(null);
    } catch (e) {
      return Left('Failed to cleanup old expenses: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, void>> syncExpenses() async {
    try {
      // TODO: Implement synchronization logic
      // This would sync local expenses with remote server
      
      return const Right(null);
    } catch (e) {
      return Left('Failed to sync expenses: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, void>> exportExpenses({
    String? mrId,
    String? retailerId,
    DateTime? startDate,
    DateTime? endDate,
    String format = 'csv',
  }) async {
    try {
      final expensesResult = await searchExpenses(
        mrId: mrId,
        retailerId: retailerId,
        startDate: startDate,
        endDate: endDate,
      );
      
      if (expensesResult.isLeft()) {
        return Left(expensesResult.fold((l) => l, (r) => 'Failed to get expenses'));
      }
      
      final expenses = expensesResult.getOrElse(() => []);
      
      // Generate CSV data
      final csvData = _generateExpenseCSV(expenses);
      
      // Save to file
      final fileName = 'expenses_${DateTime.now().millisecondsSinceEpoch}.csv';
      final filePath = await _saveCSVToFile(csvData, fileName);
      
      return Right(filePath);
    } catch (e) {
      return Left('Failed to export expenses: ${e.toString()}');
    }
  }
  
  String _generateExpenseCSV(List<ExpenseEntity> expenses) {
    final buffer = StringBuffer();
    
    // CSV header
    buffer.writeln('ID,MR ID,MR Name,Retailer ID,Retailer Name,Type,Category,Amount,Currency,Date,Description,Status,Approved By,Approved At,Rejected By,Rejected At');
    
    // CSV data
    for (final expense in expenses) {
      buffer.writeln('${expense.id},${expense.mrId},${expense.mrName},${expense.retailerId},${expense.retailerName},${expense.expenseType},${expense.category.name},${expense.amount},${expense.currency},${expense.expenseDate.toIso8601String()},${expense.description},${expense.status.name},${expense.approvedBy ?? ''},${expense.approvedAt?.toIso8601String() ?? ''},${expense.rejectedBy ?? ''},${expense.rejectedAt?.toIso8601String() ?? ''}');
    }
    
    return buffer.toString();
  }
  
  Future<String> _saveCSVToFile(String csvData, String fileName) async {
    // TODO: Implement file saving logic
    // This would save the CSV data to a file
    return fileName;
  }
}
