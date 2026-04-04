import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import '../../../../shared/utils/nepal_localization_utils.dart';

/// MR Expense Reconciliation Service
/// Handles expense management with multi-photo receipts
class ExpenseReconciliationService {
  static final ExpenseReconciliationService _instance = ExpenseReconciliationService._internal();
  factory ExpenseReconciliationService() => _instance;
  ExpenseReconciliationService._internal();

  late Dio _dio;
  final ImagePicker _imagePicker = ImagePicker();
  static const String _baseUrl = 'https://api.vedantatrade.com.np';

  // Stream controllers for real-time updates
  final StreamController<List<Expense>> _expensesController = 
      StreamController<List<Expense>>.broadcast();
  final StreamController<List<Expense>> _pendingExpensesController = 
      StreamController<List<Expense>>.broadcast();
  final StreamController<List<Expense>> _approvedExpensesController = 
      StreamController<List<Expense>>.broadcast();
  final StreamController<ExpenseSummary> _summaryController = 
      StreamController<ExpenseSummary>.broadcast();

  List<Expense> _expenses = [];
  List<Expense> _pendingExpenses = [];
  List<Expense> _approvedExpenses = [];
  ExpenseSummary? _currentSummary;

  // Getters
  Stream<List<Expense>> get expensesStream => _expensesController.stream;
  Stream<List<Expense>> get pendingExpensesStream => _pendingExpensesController.stream;
  Stream<List<Expense>> get approvedExpensesStream => _approvedExpensesController.stream;
  Stream<ExpenseSummary> get summaryStream => _summaryController.stream;
  
  List<Expense> get expenses => List.unmodifiable(_expenses);
  List<Expense> get pendingExpenses => List.unmodifiable(_pendingExpenses);
  List<Expense> get approvedExpenses => List.unmodifiable(_approvedExpenses);
  ExpenseSummary? get currentSummary => _currentSummary;

  /// Initialize expense reconciliation service
  Future<void> initialize() async {
    try {
      print('💰 Initializing Expense Reconciliation Service...');
      
      _setupDioClient();
      await _loadCachedData();
      
      print('✅ Expense Reconciliation Service initialized');
    } catch (e) {
      print('❌ Failed to initialize Expense Reconciliation Service: $e');
      _expensesController.addError(e);
    }
  }

  /// Setup Dio client with Nepal-specific configurations
  void _setupDioClient() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'X-Country': 'NP',
        'X-Currency': 'NPR',
        'X-Timezone': 'Asia/Kathmandu',
      },
    ));

    // Add request interceptor for authentication
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          handler.next(options);
        },
        onError: (error, handler) async {
          print('Expense Service API Error: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  /// Load expenses from server
  Future<void> loadExpenses({String? mrId, String? status}) async {
    try {
      print('💰 Loading expenses...');
      
      final response = await _dio.get(
        '/api/expenses',
        queryParameters: {
          if (mrId != null) 'mrId': mrId,
          if (status != null) 'status': status,
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['expenses'] != null) {
          _expenses = (data['expenses'] as List)
              .map((json) => Expense.fromJson(json))
              .toList();
          
          _expensesController.add(_expenses);
          await _cacheExpenses();
          await _updateExpenseCategories();
          
          print('✅ Loaded ${_expenses.length} expenses');
        }
      }
    } catch (e) {
      print('❌ Failed to load expenses: $e');
      await _loadMockExpenses();
    }
  }

  /// Load pending expenses
  Future<void> loadPendingExpenses() async {
    try {
      final pending = _expenses.where((e) => e.status == ExpenseStatus.pending).toList();
      _pendingExpenses = pending;
      _pendingExpensesController.add(_pendingExpenses);
    } catch (e) {
      print('❌ Failed to load pending expenses: $e');
    }
  }

  /// Load approved expenses
  Future<void> loadApprovedExpenses() async {
    try {
      final approved = _expenses.where((e) => e.status == ExpenseStatus.approved).toList();
      _approvedExpenses = approved;
      _approvedExpensesController.add(_approvedExpenses);
    } catch (e) {
      print('❌ Failed to load approved expenses: $e');
    }
  }

  /// Create new expense with photos
  Future<Expense> createExpense({
    required String mrId,
    required String description,
    required double amount,
    required ExpenseCategory category,
    required DateTime expenseDate,
    required List<File> receiptPhotos,
    String? vendorName,
    String? notes,
    String? location,
  }) async {
    try {
      print('💰 Creating new expense...');
      
      // Upload photos first
      final photoUrls = <String>[];
      for (final photo in receiptPhotos) {
        final photoUrl = await _uploadExpensePhoto(photo);
        photoUrls.add(photoUrl);
      }
      
      // Create expense
      final response = await _dio.post(
        '/api/expenses',
        data: {
          'mrId': mrId,
          'description': description,
          'amount': amount,
          'category': category.toString(),
          'expenseDate': expenseDate.toIso8601String(),
          'receiptPhotos': photoUrls,
          'vendorName': vendorName,
          'notes': notes,
          'location': location,
          'currency': 'NPR',
          'status': ExpenseStatus.pending.toString(),
        },
      );
      
      if (response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true && data['expense'] != null) {
          final expense = Expense.fromJson(data['expense']);
          _expenses.insert(0, expense);
          _expensesController.add(_expenses);
          await _cacheExpenses();
          
          print('✅ Expense created: ${expense.id}');
          return expense;
        }
      }
    } catch (e) {
      print('❌ Failed to create expense: $e');
      throw Exception('Failed to create expense: $e');
    }
    
    throw Exception('Failed to create expense');
  }

  /// Upload expense photo
  Future<String> _uploadExpensePhoto(File photo) async {
    try {
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(photo.path),
        'type': 'expense_receipt',
      });
      
      final response = await _dio.post(
        '/api/upload/expense-photo',
        data: formData,
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['photoUrl'] != null) {
          return data['photoUrl'] as String;
        }
      }
    } catch (e) {
      print('❌ Failed to upload expense photo: $e');
    }
    
    throw Exception('Failed to upload expense photo');
  }

  /// Capture photo using camera
  Future<File?> capturePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      
      if (image != null) {
        return File(image.path);
      }
    } catch (e) {
      print('❌ Failed to capture photo: $e');
    }
    
    return null;
  }

  /// Pick photo from gallery
  Future<File?> pickPhotoFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      
      if (image != null) {
        return File(image.path);
      }
    } catch (e) {
      print('❌ Failed to pick photo from gallery: $e');
    }
    
    return null;
  }

  /// Process receipt photo with OCR
  Future<ReceiptOCRResult> processReceiptPhoto(File photo) async {
    try {
      print('📷 Processing receipt photo with OCR...');
      
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(photo.path),
        'language': 'en',
      });
      
      final response = await _dio.post(
        '/api/ocr/receipt',
        data: formData,
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['result'] != null) {
          final result = ReceiptOCRResult.fromJson(data['result']);
          print('✅ Receipt processed successfully');
          return result;
        }
      }
    } catch (e) {
      print('❌ Failed to process receipt photo: $e');
    }
    
    // Return mock result as fallback
    return ReceiptOCRResult(
      merchantName: 'Unknown Merchant',
      totalAmount: 0.0,
      date: DateTime.now(),
      items: [],
      confidence: 0.0,
    );
  }

  /// Update expense status
  Future<bool> updateExpenseStatus(String expenseId, ExpenseStatus status, {String? remarks}) async {
    try {
      print('💰 Updating expense status: $expenseId -> $status');
      
      final response = await _dio.put(
        '/api/expenses/$expenseId/status',
        data: {
          'status': status.toString(),
          'remarks': remarks,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final index = _expenses.indexWhere((e) => e.id == expenseId);
          if (index != -1) {
            _expenses[index] = _expenses[index].copyWith(
              status: status,
              remarks: remarks,
              updatedAt: DateTime.now(),
            );
            _expensesController.add(_expenses);
            
            await _updateExpenseCategories();
            await _cacheExpenses();
            
            print('✅ Expense status updated successfully');
            return true;
          }
        }
      }
    } catch (e) {
      print('❌ Failed to update expense status: $e');
    }
    
    return false;
  }

  /// Approve expense
  Future<bool> approveExpense(String expenseId, {String? remarks}) async {
    return await updateExpenseStatus(expenseId, ExpenseStatus.approved, remarks: remarks);
  }

  /// Reject expense
  Future<bool> rejectExpense(String expenseId, {String? remarks}) async {
    return await updateExpenseStatus(expenseId, ExpenseStatus.rejected, remarks: remarks);
  }

  /// Calculate expense summary
  Future<ExpenseSummary> calculateExpenseSummary({String? mrId, DateTime? startDate, DateTime? endDate}) async {
    try {
      print('💰 Calculating expense summary...');
      
      final response = await _dio.post(
        '/api/expenses/summary',
        data: {
          if (mrId != null) 'mrId': mrId,
          if (startDate != null) 'startDate': startDate.toIso8601String(),
          if (endDate != null) 'endDate': endDate.toIso8601String(),
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['summary'] != null) {
          _currentSummary = ExpenseSummary.fromJson(data['summary']);
          _summaryController.add(_currentSummary!);
          return _currentSummary!;
        }
      }
    } catch (e) {
      print('❌ Failed to calculate expense summary: $e');
    }
    
    // Calculate from local data as fallback
    return _calculateLocalSummary(startDate, endDate);
  }

  /// Get expenses by status
  List<Expense> getExpensesByStatus(ExpenseStatus status) {
    return _expenses.where((e) => e.status == status).toList();
  }

  /// Get expenses by category
  List<Expense> getExpensesByCategory(ExpenseCategory category) {
    return _expenses.where((e) => e.category == category).toList();
  }

  /// Get expenses by date range
  List<Expense> getExpensesByDateRange(DateTime startDate, DateTime endDate) {
    return _expenses.where((e) {
      return e.expenseDate.isAfter(startDate) && e.expenseDate.isBefore(endDate);
    }).toList();
  }

  /// Search expenses
  List<Expense> searchExpenses(String query) {
    final lowerQuery = query.toLowerCase();
    return _expenses.where((e) {
      return e.description.toLowerCase().contains(lowerQuery) ||
             (e.vendorName?.toLowerCase().contains(lowerQuery) ?? false) ||
             (e.notes?.toLowerCase().contains(lowerQuery) ?? false) ||
             e.category.toString().toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Delete expense
  Future<bool> deleteExpense(String expenseId) async {
    try {
      print('💰 Deleting expense: $expenseId');
      
      final response = await _dio.delete('/api/expenses/$expenseId');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          _expenses.removeWhere((e) => e.id == expenseId);
          _expensesController.add(_expenses);
          
          await _updateExpenseCategories();
          await _cacheExpenses();
          
          print('✅ Expense deleted successfully');
          return true;
        }
      }
    } catch (e) {
      print('❌ Failed to delete expense: $e');
    }
    
    return false;
  }

  /// Update expense categories
  Future<void> _updateExpenseCategories() async {
    await loadPendingExpenses();
    await loadApprovedExpenses();
    await calculateExpenseSummary();
  }

  /// Calculate local summary (fallback)
  ExpenseSummary _calculateLocalSummary(DateTime? startDate, DateTime? endDate) {
    final filteredExpenses = _expenses.where((e) {
      if (startDate != null && e.expenseDate.isBefore(startDate)) return false;
      if (endDate != null && e.expenseDate.isAfter(endDate)) return false;
      return true;
    }).toList();

    final totalAmount = filteredExpenses.fold(0.0, (sum, e) => sum + e.amount);
    final pendingAmount = filteredExpenses
        .where((e) => e.status == ExpenseStatus.pending)
        .fold(0.0, (sum, e) => sum + e.amount);
    final approvedAmount = filteredExpenses
        .where((e) => e.status == ExpenseStatus.approved)
        .fold(0.0, (sum, e) => sum + e.amount);

    final categoryBreakdown = <ExpenseCategory, double>{};
    for (final expense in filteredExpenses) {
      categoryBreakdown[expense.category] = 
          (categoryBreakdown[expense.category] ?? 0.0) + expense.amount;
    }

    return ExpenseSummary(
      totalExpenses: filteredExpenses.length,
      totalAmount: totalAmount,
      pendingAmount: pendingAmount,
      approvedAmount: approvedAmount,
      categoryBreakdown: categoryBreakdown,
      averageExpenseAmount: filteredExpenses.isEmpty ? 0.0 : totalAmount / filteredExpenses.length,
      mostExpensiveCategory: _getMostExpensiveCategory(categoryBreakdown),
      generatedAt: DateTime.now(),
    );
  }

  /// Get most expensive category
  ExpenseCategory _getMostExpensiveCategory(Map<ExpenseCategory, double> breakdown) {
    if (breakdown.isEmpty) return ExpenseCategory.other;
    
    return breakdown.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Load mock expenses (fallback)
  Future<void> _loadMockExpenses() async {
    try {
      _expenses = [
        Expense(
          id: 'EXP-001',
          mrId: 'MR-001',
          description: 'Travel expenses for Kathmandu visit',
          amount: 2500.0,
          category: ExpenseCategory.travel,
          expenseDate: DateTime.now().subtract(const Duration(days: 2)),
          receiptPhotos: [
            'https://example.com/receipt1.jpg',
            'https://example.com/receipt2.jpg',
          ],
          vendorName: 'Kathmandu Taxi Service',
          notes: 'Travel to meet 3 retailers in Kathmandu',
          location: 'Kathmandu',
          status: ExpenseStatus.pending,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Expense(
          id: 'EXP-002',
          mrId: 'MR-001',
          description: 'Lunch meeting with client',
          amount: 850.0,
          category: ExpenseCategory.meals,
          expenseDate: DateTime.now().subtract(const Duration(days: 1)),
          receiptPhotos: [
            'https://example.com/receipt3.jpg',
          ],
          vendorName: 'Hotel Himalaya',
          notes: 'Business lunch with retailer representative',
          location: 'Pokhara',
          status: ExpenseStatus.approved,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
        ),
        Expense(
          id: 'EXP-003',
          mrId: 'MR-002',
          description: 'Office supplies',
          amount: 1200.0,
          category: ExpenseCategory.office,
          expenseDate: DateTime.now().subtract(const Duration(days: 3)),
          receiptPhotos: [
            'https://example.com/receipt4.jpg',
          ],
          vendorName: 'Stationery House',
          notes: 'Pens, notebooks, and presentation materials',
          location: 'Biratnagar',
          status: ExpenseStatus.approved,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];
      
      _expensesController.add(_expenses);
      await _updateExpenseCategories();
      print('✅ Loaded mock expenses');
    } catch (e) {
      print('❌ Failed to load mock expenses: $e');
    }
  }

  /// Cache expenses
  Future<void> _cacheExpenses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expensesJson = jsonEncode(
        _expenses.map((e) => e.toJson()).toList(),
      );
      await prefs.setString('cached_expenses', expensesJson);
    } catch (e) {
      print('❌ Failed to cache expenses: $e');
    }
  }

  /// Load cached data
  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expensesJson = prefs.getString('cached_expenses');
      
      if (expensesJson != null) {
        final expensesList = List<Map<String, dynamic>>.from(
          jsonDecode(expensesJson)
        );
        _expenses = expensesList
            .map((json) => Expense.fromJson(json))
            .toList();
        _expensesController.add(_expenses);
        
        await _updateExpenseCategories();
        print('✅ Loaded cached expenses');
      }
    } catch (e) {
      print('❌ Failed to load cached expenses: $e');
    }
  }

  /// Clear cached data
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_expenses');
      
      _expenses.clear();
      _pendingExpenses.clear();
      _approvedExpenses.clear();
      _currentSummary = null;
      
      _expensesController.add(_expenses);
      _pendingExpensesController.add(_pendingExpenses);
      _approvedExpensesController.add(_approvedExpenses);
      
      print('✅ Expense cache cleared');
    } catch (e) {
      print('❌ Failed to clear expense cache: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _expensesController.close();
    _pendingExpensesController.close();
    _approvedExpensesController.close();
    _summaryController.close();
    print('🗑️ Expense Reconciliation Service disposed');
  }
}

/// Expense Model
class Expense {
  final String id;
  final String mrId;
  final String description;
  final double amount;
  final ExpenseCategory category;
  final DateTime expenseDate;
  final List<String> receiptPhotos;
  final String? vendorName;
  final String? notes;
  final String? location;
  final ExpenseStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? remarks;

  const Expense({
    required this.id,
    required this.mrId,
    required this.description,
    required this.amount,
    required this.category,
    required this.expenseDate,
    required this.receiptPhotos,
    this.vendorName,
    this.notes,
    this.location,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.remarks,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      mrId: json['mrId'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: ExpenseCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
        orElse: () => ExpenseCategory.other,
      ),
      expenseDate: DateTime.parse(json['expenseDate'] as String),
      receiptPhotos: List<String>.from(json['receiptPhotos'] as List),
      vendorName: json['vendorName'] as String?,
      notes: json['notes'] as String?,
      location: json['location'] as String?,
      status: ExpenseStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => ExpenseStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      remarks: json['remarks'] as String?,
    );
  }

  Expense copyWith({
    String? id,
    String? mrId,
    String? description,
    double? amount,
    ExpenseCategory? category,
    DateTime? expenseDate,
    List<String>? receiptPhotos,
    String? vendorName,
    String? notes,
    String? location,
    ExpenseStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? remarks,
  }) {
    return Expense(
      id: id ?? this.id,
      mrId: mrId ?? this.mrId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      expenseDate: expenseDate ?? this.expenseDate,
      receiptPhotos: receiptPhotos ?? this.receiptPhotos,
      vendorName: vendorName ?? this.vendorName,
      notes: notes ?? this.notes,
      location: location ?? this.location,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      remarks: remarks ?? this.remarks,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mrId': mrId,
      'description': description,
      'amount': amount,
      'category': category.toString(),
      'expenseDate': expenseDate.toIso8601String(),
      'receiptPhotos': receiptPhotos,
      'vendorName': vendorName,
      'notes': notes,
      'location': location,
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'remarks': remarks,
    };
  }

  // Computed properties
  String get formattedAmount => NepalLocalizationUtils.formatNPRCurrency(amount);
  String get formattedDate => NepalLocalizationUtils.formatNepaliDate(expenseDate);
  String get statusText {
    switch (status) {
      case ExpenseStatus.pending:
        return 'Pending';
      case ExpenseStatus.approved:
        return 'Approved';
      case ExpenseStatus.rejected:
        return 'Rejected';
    }
  }
  
  bool get hasPhotos => receiptPhotos.isNotEmpty;
  bool get isPending => status == ExpenseStatus.pending;
  bool get isApproved => status == ExpenseStatus.approved;
  bool get isRejected => status == ExpenseStatus.rejected;
}

/// Expense Summary Model
class ExpenseSummary {
  final int totalExpenses;
  final double totalAmount;
  final double pendingAmount;
  final double approvedAmount;
  final Map<ExpenseCategory, double> categoryBreakdown;
  final double averageExpenseAmount;
  final ExpenseCategory mostExpensiveCategory;
  final DateTime generatedAt;

  const ExpenseSummary({
    required this.totalExpenses,
    required this.totalAmount,
    required this.pendingAmount,
    required this.approvedAmount,
    required this.categoryBreakdown,
    required this.averageExpenseAmount,
    required this.mostExpensiveCategory,
    required this.generatedAt,
  });

  factory ExpenseSummary.fromJson(Map<String, dynamic> json) {
    final categoryBreakdown = <ExpenseCategory, double>{};
    final breakdownJson = json['categoryBreakdown'] as Map<String, dynamic>;
    
    for (final entry in breakdownJson.entries) {
      final category = ExpenseCategory.values.firstWhere(
        (e) => e.toString() == entry.key,
        orElse: () => ExpenseCategory.other,
      );
      categoryBreakdown[category] = (entry.value as num).toDouble();
    }

    return ExpenseSummary(
      totalExpenses: (json['totalExpenses'] as num).toInt(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      pendingAmount: (json['pendingAmount'] as num).toDouble(),
      approvedAmount: (json['approvedAmount'] as num).toDouble(),
      categoryBreakdown: categoryBreakdown,
      averageExpenseAmount: (json['averageExpenseAmount'] as num).toDouble(),
      mostExpensiveCategory: ExpenseCategory.values.firstWhere(
        (e) => e.toString() == json['mostExpensiveCategory'],
        orElse: () => ExpenseCategory.other,
      ),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );
  }

  String get formattedTotalAmount => NepalLocalizationUtils.formatNPRCurrency(totalAmount);
  String get formattedPendingAmount => NepalLocalizationUtils.formatNPRCurrency(pendingAmount);
  String get formattedApprovedAmount => NepalLocalizationUtils.formatNPRCurrency(approvedAmount);
  String get formattedAverageAmount => NepalLocalizationUtils.formatNPRCurrency(averageExpenseAmount);
}

/// Receipt OCR Result Model
class ReceiptOCRResult {
  final String merchantName;
  final double totalAmount;
  final DateTime date;
  final List<ReceiptItem> items;
  final double confidence;

  const ReceiptOCRResult({
    required this.merchantName,
    required this.totalAmount,
    required this.date,
    required this.items,
    required this.confidence,
  });

  factory ReceiptOCRResult.fromJson(Map<String, dynamic> json) {
    return ReceiptOCRResult(
      merchantName: json['merchantName'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      items: (json['items'] as List)
          .map((item) => ReceiptItem.fromJson(item))
          .toList(),
      confidence: (json['confidence'] as num).toDouble(),
    );
  }

  bool get isHighConfidence => confidence >= 0.8;
  bool get isMediumConfidence => confidence >= 0.6 && confidence < 0.8;
  bool get isLowConfidence => confidence < 0.6;
}

/// Receipt Item Model
class ReceiptItem {
  final String name;
  final double quantity;
  final double unitPrice;
  final double totalPrice;

  const ReceiptItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory ReceiptItem.fromJson(Map<String, dynamic> json) {
    return ReceiptItem(
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
    );
  }
}

/// Enums
enum ExpenseStatus {
  pending,
  approved,
  rejected,
}

enum ExpenseCategory {
  travel,
  meals,
  accommodation,
  office,
  communication,
  entertainment,
  medical,
  other,
}
