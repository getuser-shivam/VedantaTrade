import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/vat_return_entity.dart';
import '../../domain/repositories/vat_return_repository.dart';
import '../../domain/services/pdf_generation_service.dart';
import '../../../../shared/services/storage_service.dart';
import '../../../../shared/utils/app_utils.dart';

/// VAT Return Repository Implementation
/// Handles data persistence and retrieval for VAT returns
class VatReturnRepositoryImpl implements VatReturnRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final StorageService _storageService;
  final AppUtils _appUtils;
  
  VatReturnRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    StorageService? storageService,
    AppUtils? appUtils,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance,
       _storageService = storageService ?? StorageService(),
       _appUtils = appUtils ?? AppUtils();
  
  @override
  Future<Either<String, VatReturnEntity>> createVatReturn(VatReturnEntity vatReturn) async {
    try {
      // Generate ID if not provided
      final id = vatReturn.id.isEmpty ? _appUtils.generateId() : vatReturn.id;
      
      // Create entity with generated ID and timestamps
      final entity = vatReturn.copyWith(
        id: id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Save to Firestore
      await _firestore
          .collection('vat_returns')
          .doc(id)
          .set(entity.toMap());
      
      // Cache locally
      await _storageService.saveVatReturn(entity);
      
      return Right(entity);
    } catch (e) {
      return Left('Failed to create VAT return: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, VatReturnEntity>> updateVatReturn(VatReturnEntity vatReturn) async {
    try {
      // Update timestamp
      final entity = vatReturn.copyWith(updatedAt: DateTime.now());
      
      // Update in Firestore
      await _firestore
          .collection('vat_returns')
          .doc(vatReturn.id)
          .update(entity.toMap());
      
      // Update cache
      await _storageService.saveVatReturn(entity);
      
      return Right(entity);
    } catch (e) {
      return Left('Failed to update VAT return: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, void>> deleteVatReturn(String id) async {
    try {
      // Delete from Firestore
      await _firestore.collection('vat_returns').doc(id).delete();
      
      // Delete from cache
      await _storageService.deleteVatReturn(id);
      
      return const Right(null);
    } catch (e) {
      return Left('Failed to delete VAT return: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, VatReturnEntity>> getVatReturn(String id) async {
    try {
      // Try cache first
      final cached = await _storageService.getVatReturn(id);
      if (cached != null) {
        return Right(cached);
      }
      
      // Fetch from Firestore
      final doc = await _firestore.collection('vat_returns').doc(id).get();
      
      if (!doc.exists) {
        return const Left('VAT return not found');
      }
      
      final entity = VatReturnEntity.fromMap(doc.data()!);
      
      // Cache for future use
      await _storageService.saveVatReturn(entity);
      
      return Right(entity);
    } catch (e) {
      return Left('Failed to get VAT return: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, List<VatReturnEntity>>> getVatReturnsByBusiness(String businessId) async {
    try {
      final query = await _firestore
          .collection('vat_returns')
          .where('businessId', isEqualTo: businessId)
          .orderBy('filingDate', descending: true)
          .get();
      
      final vatReturns = query.docs
          .map((doc) => VatReturnEntity.fromMap(doc.data()))
          .toList();
      
      return Right(vatReturns);
    } catch (e) {
      return Left('Failed to get VAT returns: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, List<VatReturnEntity>>> getVatReturnsByPeriod(
    String businessId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final query = await _firestore
          .collection('vat_returns')
          .where('businessId', isEqualTo: businessId)
          .where('startDate', isGreaterThanOrEqualTo: startDate)
          .where('endDate', isLessThanOrEqualTo: endDate)
          .orderBy('filingDate', descending: true)
          .get();
      
      final vatReturns = query.docs
          .map((doc) => VatReturnEntity.fromMap(doc.data()))
          .toList();
      
      return Right(vatReturns);
    } catch (e) {
      return Left('Failed to get VAT returns for period: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, List<VatReturnEntity>>> getVatReturnsByStatus(
    String businessId,
    VatReturnStatus status,
  ) async {
    try {
      final query = await _firestore
          .collection('vat_returns')
          .where('businessId', isEqualTo: businessId)
          .where('status', isEqualTo: status.name)
          .orderBy('filingDate', descending: true)
          .get();
      
      final vatReturns = query.docs
          .map((doc) => VatReturnEntity.fromMap(doc.data()))
          .toList();
      
      return Right(vatReturns);
    } catch (e) {
      return Left('Failed to get VAT returns by status: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, Uint8List>> generateVatReturnPdf(VatReturnEntity vatReturn) async {
    try {
      final pdfData = await PdfGenerationService.generateVatReturnPdf(vatReturn);
      return Right(pdfData);
    } catch (e) {
      return Left('Failed to generate PDF: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, String>> saveVatReturnPdf(VatReturnEntity vatReturn, Uint8List pdfData) async {
    try {
      final fileName = 'vat_return_${vatReturn.id}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = await PdfGenerationService.savePdfToFile(pdfData, fileName);
      return Right(filePath);
    } catch (e) {
      return Left('Failed to save PDF: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, String>> uploadVatReturnPdf(VatReturnEntity vatReturn, Uint8List pdfData) async {
    try {
      final fileName = 'vat_returns/${vatReturn.businessId}/${vatReturn.id}.pdf';
      final ref = _storage.ref().child(fileName);
      
      await ref.putData(pdfData);
      final downloadUrl = await ref.getDownloadURL();
      
      // Update VAT return with PDF URL
      await updateVatReturn(
        vatReturn.copyWith(
          metadata: {
            ...vatReturn.metadata ?? {},
            'pdfUrl': downloadUrl,
            'pdfUploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );
      
      return Right(downloadUrl);
    } catch (e) {
      return Left('Failed to upload PDF: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, VatReturnEntity>> submitVatReturn(VatReturnEntity vatReturn) async {
    try {
      // Update status to submitted
      final submittedReturn = vatReturn.copyWith(
        status: VatReturnStatus.submitted,
        submittedDate: DateTime.now(),
        submissionReference: _generateSubmissionReference(),
      );
      
      // Update in database
      final result = await updateVatReturn(submittedReturn);
      
      if (result.isLeft()) {
        return result;
      }
      
      // TODO: Submit to IRDN API
      // This would integrate with the actual IRDN system
      
      return result;
    } catch (e) {
      return Left('Failed to submit VAT return: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, VatReturnEntity>> approveVatReturn(VatReturnEntity vatReturn) async {
    try {
      // Update status to approved
      final approvedReturn = vatReturn.copyWith(
        status: VatReturnStatus.approved,
        approvedBy: 'system', // This would be the current user
      );
      
      return await updateVatReturn(approvedReturn);
    } catch (e) {
      return Left('Failed to approve VAT return: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, VatReturnEntity>> rejectVatReturn(
    VatReturnEntity vatReturn,
    String reason,
  ) async {
    try {
      // Update status to rejected
      final rejectedReturn = vatReturn.copyWith(
        status: VatReturnStatus.rejected,
        comments: reason,
      );
      
      return await updateVatReturn(rejectedReturn);
    } catch (e) {
      return Left('Failed to reject VAT return: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, VatReturnEntity>> calculateVatReturn(
    String businessId,
    DateTime startDate,
    DateTime endDate,
    VatReturnType returnType,
  ) async {
    try {
      // TODO: Implement actual VAT calculation logic
      // This would fetch sales and purchase data and calculate VAT
      
      final taxPeriod = _generateTaxPeriod(startDate, endDate, returnType);
      
      // Mock data for now
      final vatReturn = VatReturnEntity(
        id: _appUtils.generateId(),
        businessId: businessId,
        businessName: 'Test Business',
        businessAddress: 'Kathmandu, Nepal',
        businessPan: '123456789',
        businessIrdn: 'IRDN123456',
        taxPeriod: taxPeriod,
        startDate: startDate,
        endDate: endDate,
        filingDate: DateTime.now(),
        returnType: returnType,
        status: VatReturnStatus.draft,
        totalSales: 1000000.0,
        totalPurchases: 800000.0,
        taxableSales: 900000.0,
        exemptSales: 50000.0,
        zeroRatedSales: 50000.0,
        inputTax: 104000.0,
        outputTax: 117000.0,
        netTaxPayable: 13000.0,
        taxPaid: 0.0,
        taxRefundable: 0.0,
        penalty: 0.0,
        interest: 0.0,
        totalAmountDue: 13000.0,
        salesItems: [],
        purchaseItems: [],
        taxDetails: [],
        summary: VatReturnSummary(
          totalSales: 1000000.0,
          totalPurchases: 800000.0,
          totalTaxableSales: 900000.0,
          totalExemptSales: 50000.0,
          totalZeroRatedSales: 50000.0,
          totalInputTax: 104000.0,
          totalOutputTax: 117000.0,
          totalNetTaxPayable: 13000.0,
          totalTaxPaid: 0.0,
          totalTaxRefundable: 0.0,
          totalPenalty: 0.0,
          totalInterest: 0.0,
          totalAmountDue: 13000.0,
          totalSalesItems: 0,
          totalPurchaseItems: 0,
          rateSummaries: {},
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      return Right(vatReturn);
    } catch (e) {
      return Left('Failed to calculate VAT return: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, List<VatReturnEntity>>> getPendingVatReturns(String businessId) async {
    try {
      final query = await _firestore
          .collection('vat_returns')
          .where('businessId', isEqualTo: businessId)
          .where('status', whereIn: [
            VatReturnStatus.draft.name,
            VatReturnStatus.pending.name,
            VatReturnStatus.submitted.name,
          ])
          .orderBy('filingDate', descending: true)
          .get();
      
      final vatReturns = query.docs
          .map((doc) => VatReturnEntity.fromMap(doc.data()))
          .toList();
      
      return Right(vatReturns);
    } catch (e) {
      return Left('Failed to get pending VAT returns: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, Map<String, dynamic>>> getVatReturnStatistics(String businessId) async {
    try {
      // Get all VAT returns for the business
      final returnsResult = await getVatReturnsByBusiness(businessId);
      
      if (returnsResult.isLeft()) {
        return returnsResult.fold((l) => Left(l), (r) => Left('Unexpected error'));
      }
      
      final returns = returnsResult.getOrElse(() => []);
      
      // Calculate statistics
      final totalReturns = returns.length;
      final draftReturns = returns.where((r) => r.status == VatReturnStatus.draft).length;
      final submittedReturns = returns.where((r) => r.status == VatReturnStatus.submitted).length;
      final approvedReturns = returns.where((r) => r.status == VatReturnStatus.approved).length;
      const rejectedReturns = 0; // returns.where((r) => r.status == VatReturnStatus.rejected).length;
      
      final totalTaxPaid = returns
          .where((r) => r.status == VatReturnStatus.paid)
          .fold<double>(0.0, (sum, r) => sum + r.totalAmountDue);
      
      final totalTaxDue = returns
          .where((r) => r.status == VatReturnStatus.submitted || r.status == VatReturnStatus.approved)
          .fold<double>(0.0, (sum, r) => sum + r.totalAmountDue);
      
      final statistics = {
        'totalReturns': totalReturns,
        'draftReturns': draftReturns,
        'submittedReturns': submittedReturns,
        'approvedReturns': approvedReturns,
        'rejectedReturns': rejectedReturns,
        'totalTaxPaid': totalTaxPaid,
        'totalTaxDue': totalTaxDue,
        'lastFilingDate': returns.isNotEmpty ? returns.first.filingDate.toIso8601String() : null,
        'nextFilingDue': _calculateNextFilingDue(),
      };
      
      return Right(statistics);
    } catch (e) {
      return Left('Failed to get VAT return statistics: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, void>> syncVatReturns() async {
    try {
      // TODO: Implement synchronization logic
      // This would sync local data with remote server
      
      return const Right(null);
    } catch (e) {
      return Left('Failed to sync VAT returns: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, void>> exportVatReturns(List<String> ids) async {
    try {
      // TODO: Implement export functionality
      // This would export VAT returns to CSV or Excel format
      
      return const Right(null);
    } catch (e) {
      return Left('Failed to export VAT returns: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, void>> importVatReturns(String filePath) async {
    try {
      // TODO: Implement import functionality
      // This would import VAT returns from CSV or Excel format
      
      return const Right(null);
    } catch (e) {
      return Left('Failed to import VAT returns: ${e.toString()}');
    }
  }
  
  /// Generate submission reference
  String _generateSubmissionReference() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = _appUtils.generateRandomNumber(1000, 9999);
    return 'VR${timestamp}$random';
  }
  
  /// Generate tax period
  String _generateTaxPeriod(DateTime startDate, DateTime endDate, VatReturnType type) {
    switch (type) {
      case VatReturnType.monthly:
        return DateFormat('MMM yyyy').format(startDate);
      case VatReturnType.quarterly:
        final quarter = ((startDate.month - 1) ~/ 3) + 1;
        return 'Q$quarter ${startDate.year}';
      case VatReturnType.halfYearly:
        final half = startDate.month <= 6 ? 1 : 2;
        return 'H$half ${startDate.year}';
      case VatReturnType.yearly:
        return '${startDate.year}';
      case VatReturnType.adHoc:
        return DateFormat('MMM dd, yyyy').format(startDate);
    }
  }
  
  /// Calculate next filing due date
  String _calculateNextFilingDue() {
    final now = DateTime.now();
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    final dueDate = DateTime(nextMonth.year, nextMonth.month, 25); // 25th of next month
    return dueDate.toIso8601String();
  }
}
