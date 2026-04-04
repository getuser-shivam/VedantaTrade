import 'package:dio/dio.dart';
import 'package:vedanta_trade/core/services/api_service.dart';

class AccountingService {
  final ApiService _apiService;
  late final Dio _dio;

  AccountingService({ApiService? apiService})
      : _apiService = apiService ?? ApiService() {
    _dio = _apiService.dio;
  }

  // Nepal VAT constants
  static const double VAT_RATE = 0.13; // 13% flat VAT rate for Nepal

  /// Get financial summary
  Future<Map<String, dynamic>> getFinancialSummary() async {
    try {
      final response = await _dio.get('/api/accounting/financial-summary');
      
      if (response.statusCode == 200) {
        return response.data['data'] ?? {};
      } else {
        throw Exception('Failed to load financial summary: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Fallback to mock data for development
      return _getMockFinancialSummary();
    }
  }

  /// Get VAT returns
  Future<List<Map<String, dynamic>>> getVatReturns() async {
    try {
      final response = await _dio.get('/api/accounting/vat-returns');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load VAT returns: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Fallback to mock data for development
      return _getMockVatReturns();
    }
  }

  /// Get expense reports
  Future<List<Map<String, dynamic>>> getExpenseReports() async {
    try {
      final response = await _dio.get('/api/accounting/expense-reports');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load expense reports: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Fallback to mock data for development
      return _getMockExpenseReports();
    }
  }

  /// Get MR expenses
  Future<List<Map<String, dynamic>>> getMrExpenses() async {
    try {
      final response = await _dio.get('/api/accounting/mr-expenses');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load MR expenses: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Fallback to mock data for development
      return _getMockMrExpenses();
    }
  }

  /// Generate VAT return for specific period
  Future<Map<String, dynamic>> generateVatReturn(DateTime startDate, DateTime endDate) async {
    try {
      final response = await _dio.post('/api/accounting/vat-returns/generate', data: {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'vatRate': VAT_RATE,
      });
      
      if (response.statusCode == 201) {
        return response.data['data'];
      } else {
        throw Exception('Failed to generate VAT return: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Simulate API call for development
      final vatReturn = _generateMockVatReturn(startDate, endDate);
      
      return vatReturn;
    }
  }

  /// Update expense status
  Future<void> updateExpenseStatus(String expenseId, String status) async {
    try {
      final response = await _dio.patch('/api/accounting/expenses/$expenseId', data: {
        'status': status,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      
      if (response.statusCode != 200) {
        throw Exception('Failed to update expense status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Simulate API call for development
      
    }
  }

  /// Update MR expense status
  Future<void> updateMrExpenseStatus(String expenseId, String status) async {
    try {
      final response = await _dio.patch('/api/accounting/mr-expenses/$expenseId', data: {
        'status': status,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      
      if (response.statusCode != 200) {
        throw Exception('Failed to update MR expense status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Simulate API call for development
      
    }
  }

  /// Export VAT return as PDF
  Future<void> exportVatReturn(String vatReturnId) async {
    try {
      final response = await _dio.get('/api/accounting/vat-returns/$vatReturnId/export');
      
      if (response.statusCode != 200) {
        throw Exception('Failed to export VAT return: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Simulate API call for development
      
    }
  }

  /// Export financial report
  Future<void> exportFinancialReport(DateTime startDate, DateTime endDate) async {
    try {
      final response = await _dio.post('/api/accounting/financial-reports/export', data: {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      });
      
      if (response.statusCode != 200) {
        throw Exception('Failed to export financial report: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Simulate API call for development
      
    }
  }

  /// Mock data for development
  Map<String, dynamic> _getMockFinancialSummary() {
    return {
      'totalRevenue': 2500000.00,
      'vatCollected': 325000.00,
      'totalExpenses': 1250000.00,
      'vatOnExpenses': 162500.00,
      'pendingExpenses': 45000.00,
      'netProfit': 875000.00,
      'vatPayable': 162500.00,
      'currentMonth': DateTime.now().month,
      'currentYear': DateTime.now().year,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  List<Map<String, dynamic>> _getMockVatReturns() {
    return [
      {
        'id': 'VAT-2024-03',
        'period': 'March 2024',
        'startDate': DateTime(2024, 3, 1).toIso8601String(),
        'endDate': DateTime(2024, 3, 31).toIso8601String(),
        'taxableSales': 2500000.00,
        'vatCollected': 325000.00,
        'vatOnExpenses': 162500.00,
        'vatPayable': 162500.00,
        'status': 'submitted',
        'submittedDate': DateTime(2024, 4, 15).toIso8601String(),
        'deadline': DateTime(2024, 4, 25).toIso8601String(),
        'createdAt': DateTime(2024, 4, 15).toIso8601String(),
        'updatedAt': DateTime(2024, 4, 15).toIso8601String(),
      },
      {
        'id': 'VAT-2024-02',
        'period': 'February 2024',
        'startDate': DateTime(2024, 2, 1).toIso8601String(),
        'endDate': DateTime(2024, 2, 29).toIso8601String(),
        'taxableSales': 2250000.00,
        'vatCollected': 292500.00,
        'vatOnExpenses': 145000.00,
        'vatPayable': 147500.00,
        'status': 'approved',
        'submittedDate': DateTime(2024, 3, 20).toIso8601String(),
        'approvedDate': DateTime(2024, 3, 22).toIso8601String(),
        'deadline': DateTime(2024, 3, 25).toIso8601String(),
        'createdAt': DateTime(2024, 3, 20).toIso8601String(),
        'updatedAt': DateTime(2024, 3, 22).toIso8601String(),
      },
      {
        'id': 'VAT-2024-01',
        'period': 'January 2024',
        'startDate': DateTime(2024, 1, 1).toIso8601String(),
        'endDate': DateTime(2024, 1, 31).toIso8601String(),
        'taxableSales': 2100000.00,
        'vatCollected': 273000.00,
        'vatOnExpenses': 135000.00,
        'vatPayable': 138000.00,
        'status': 'approved',
        'submittedDate': DateTime(2024, 2, 18).toIso8601String(),
        'approvedDate': DateTime(2024, 2, 20).toIso8601String(),
        'deadline': DateTime(2024, 2, 25).toIso8601String(),
        'createdAt': DateTime(2024, 2, 18).toIso8601String(),
        'updatedAt': DateTime(2024, 2, 20).toIso8601String(),
      },
    ];
  }

  List<Map<String, dynamic>> _getMockExpenseReports() {
    return [
      {
        'id': 'EXP-001',
        'description': 'Office Rent - Janakpur Branch',
        'category': 'Office Expenses',
        'amount': 50000.00,
        'vatAmount': 6500.00,
        'date': DateTime(2024, 4, 1).toIso8601String(),
        'status': 'pending',
        'receiptImages': ['assets/receipts/office_rent.jpg'],
        'notes': 'Monthly office rent for Janakpur branch',
        'submittedBy': 'Admin',
        'createdAt': DateTime(2024, 4, 1).toIso8601String(),
        'updatedAt': DateTime(2024, 4, 1).toIso8601String(),
      },
      {
        'id': 'EXP-002',
        'description': 'Medical Equipment Purchase',
        'category': 'Equipment',
        'amount': 25000.00,
        'vatAmount': 3250.00,
        'date': DateTime(2024, 4, 2).toIso8601String(),
        'status': 'pending',
        'receiptImages': ['assets/receipts/equipment.jpg'],
        'notes': 'Purchase of new medical equipment',
        'submittedBy': 'Admin',
        'createdAt': DateTime(2024, 4, 2).toIso8601String(),
        'updatedAt': DateTime(2024, 4, 2).toIso8601String(),
      },
      {
        'id': 'EXP-003',
        'description': 'Marketing Materials',
        'category': 'Marketing',
        'amount': 15000.00,
        'vatAmount': 1950.00,
        'date': DateTime(2024, 4, 3).toIso8601String(),
        'status': 'approved',
        'receiptImages': ['assets/receipts/marketing.jpg'],
        'notes': 'Marketing materials for product promotion',
        'submittedBy': 'Marketing Team',
        'createdAt': DateTime(2024, 4, 3).toIso8601String(),
        'updatedAt': DateTime(2024, 4, 4).toIso8601String(),
      },
      {
        'id': 'EXP-004',
        'description': 'Vehicle Fuel Expenses',
        'category': 'Transportation',
        'amount': 8000.00,
        'vatAmount': 1040.00,
        'date': DateTime(2024, 4, 4).toIso8601String(),
        'status': 'rejected',
        'receiptImages': ['assets/receipts/fuel.jpg'],
        'notes': 'Rejected: Duplicate expense submission',
        'submittedBy': 'Driver',
        'createdAt': DateTime(2024, 4, 4).toIso8601String(),
        'updatedAt': DateTime(2024, 4, 5).toIso8601String(),
      },
    ];
  }

  List<Map<String, dynamic>> _getMockMrExpenses() {
    return [
      {
        'id': 'MREXP-001',
        'mrId': 'MR-001',
        'mrName': 'Ramesh Kumar',
        'description': 'Travel Expenses - Janakpur Visit',
        'category': 'Travel',
        'amount': 2500.00,
        'date': DateTime(2024, 4, 3).toIso8601String(),
        'status': 'pending',
        'receiptImages': ['assets/receipts/travel_1.jpg', 'assets/receipts/travel_2.jpg'],
        'notes': 'Travel expenses for doctor visits in Janakpur',
        'visitDate': DateTime(2024, 4, 3).toIso8601String(),
        'distance': 45.5,
        'createdAt': DateTime(2024, 4, 3).toIso8601String(),
        'updatedAt': DateTime(2024, 4, 3).toIso8601String(),
      },
      {
        'id': 'MREXP-002',
        'mrId': 'MR-002',
        'mrName': 'Sita Devi',
        'description': 'Lunch Expenses - Client Meeting',
        'category': 'Meals',
        'amount': 800.00,
        'date': DateTime(2024, 4, 4).toIso8601String(),
        'status': 'approved',
        'receiptImages': ['assets/receipts/lunch.jpg'],
        'notes': 'Lunch with client during business meeting',
        'visitDate': DateTime(2024, 4, 4).toIso8601String(),
        'distance': 0.0,
        'createdAt': DateTime(2024, 4, 4).toIso8601String(),
        'updatedAt': DateTime(2024, 4, 5).toIso8601String(),
      },
      {
        'id': 'MREXP-003',
        'mrId': 'MR-001',
        'mrName': 'Ramesh Kumar',
        'description': 'Sample Distribution Costs',
        'category': 'Samples',
        'amount': 1500.00,
        'date': DateTime(2024, 4, 5).toIso8601String(),
        'status': 'pending',
        'receiptImages': ['assets/receipts/samples.jpg'],
        'notes': 'Cost of distributing product samples to doctors',
        'visitDate': DateTime(2024, 4, 5).toIso8601String(),
        'distance': 25.0,
        'createdAt': DateTime(2024, 4, 5).toIso8601String(),
        'updatedAt': DateTime(2024, 4, 5).toIso8601String(),
      },
    ];
  }

  Map<String, dynamic> _generateMockVatReturn(DateTime startDate, DateTime endDate) {
    // Generate mock VAT return data
    final taxableSales = 2000000.00 + (DateTime.now().millisecond % 1000000);
    final vatCollected = taxableSales * VAT_RATE;
    final vatOnExpenses = 100000.00 + (DateTime.now().millisecond % 50000);
    final vatPayable = vatCollected - vatOnExpenses;

    return {
      'id': 'VAT-${endDate.year}-${endDate.month.toString().padLeft(2, '0')}',
      'period': '${_getMonthName(endDate.month)} ${endDate.year}',
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'taxableSales': taxableSales,
      'vatCollected': vatCollected,
      'vatOnExpenses': vatOnExpenses,
      'vatPayable': vatPayable,
      'status': 'draft',
      'submittedDate': null,
      'approvedDate': null,
      'deadline': DateTime(endDate.year, endDate.month + 1, 25).toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}
