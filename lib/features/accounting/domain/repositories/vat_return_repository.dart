import 'package:dartz/dartz.dart';
import '../entities/vat_return.dart';

/// VAT Return Repository Interface
/// Handles VAT return management with IRDN compliance
abstract class VATReturnRepository {
  /// Save VAT return
  Future<Either<Failure, void>> saveVATReturn(VATReturn vatReturn);
  
  /// Get VAT return by ID
  Future<Either<Failure, VATReturn?>> getVATReturnById(String id);
  
  /// Get VAT return by return number
  Future<Either<Failure, VATReturn?>> getVATReturnByNumber(String returnNumber);
  
  /// Get VAT returns by stockist
  Future<Either<Failure, List<VATReturn>>> getVATReturnsByStockist({
    required String stockistId,
    VATReturnStatus? status,
    String? period,
    int? limit,
  });
  
  /// Get VAT returns by period
  Future<Either<Failure, List<VATReturn>>> getVATReturnsByPeriod({
    required String period,
    String? stockistId,
    VATReturnStatus? status,
    int? limit,
  });
  
  /// Get VAT returns by date range
  Future<Either<Failure, List<VATReturn>>> getVATReturnsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? stockistId,
    VATReturnStatus? status,
    int? limit,
  });
  
  /// Get pending VAT returns
  Future<Either<Failure, List<VATReturn>>> getPendingVATReturns({
    String? stockistId,
    int? limit,
  });
  
  /// Get overdue VAT returns
  Future<Either<Failure, List<VATReturn>>> getOverdueVATReturns({
    String? stockistId,
    int? limit,
  });
  
  /// Get submitted VAT returns
  Future<Either<Failure, List<VATReturn>>> getSubmittedVATReturns({
    String? stockistId,
    int? limit,
  });
  
  /// Get IRDN submitted VAT returns
  Future<Either<Failure, List<VATReturn>>> getIRDNSubmittedVATReturns({
    String? stockistId,
    int? limit,
  });
  
  /// Get paid VAT returns
  Future<Either<Failure, List<VATReturn>>> getPaidVATReturns({
    String? stockistId,
    int? limit,
  });
  
  /// Update VAT return status
  Future<Either<Failure, void>> updateVATReturnStatus({
    required String id,
    required VATReturnStatus status,
    String? reason,
  });
  
  /// Submit VAT return to IRDN
  Future<Either<Failure, void>> submitToIRDN({
    required String id,
    required String irdnReference,
    String? notes,
  });
  
  /// Update IRDN acknowledgement
  Future<Either<Failure, void>> updateIRDNAcknowledgement({
    required String id,
    required String acknowledgementNumber,
    required DateTime acknowledgementDate,
    String? notes,
  });
  
  /// Record VAT return payment
  Future<Either<Failure, void>> recordVATReturnPayment({
    required String id,
    required String paymentReference,
    required DateTime paymentDate,
    required double paymentAmount,
    String? bankName,
    String? accountNumber,
    String? chequeNumber,
    String? transactionId,
  });
  
  /// Generate VAT return PDF
  Future<Either<Failure, String>> generateVATReturnPDF(String id);
  
  /// Export VAT return data
  Future<Either<Failure, void>> exportVATReturnData({
    required String id,
    required String format,
    String? filePath,
  });
  
  /// Get VAT return statistics
  Future<Either<Failure, Map<String, dynamic>>> getVATReturnStatistics({
    String? stockistId,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
    VATReturnStatus? status,
  });
  
  /// Get VAT compliance report
  Future<Either<Failure, Map<String, dynamic>>> getVATComplianceReport({
    required String stockistId,
    required DateTime startDate,
    required DateTime endDate,
  });
  
  /// Get VAT return summary
  Future<Either<Failure, Map<String, dynamic>>> getVATReturnSummary({
    required String stockistId,
    required String period,
  });
  
  /// Validate VAT return
  Future<Either<Failure, VATReturnValidation>> validateVATReturn(VATReturn vatReturn);
  
  /// Get VAT return audit trail
  Future<Either<Failure, List<VATReturnAudit>>> getVATReturnAuditTrail({
    required String id,
    int? limit,
  });
  
  /// Create VAT return audit record
  Future<Either<Failure, void>> createVATReturnAudit(VATReturnAudit audit);
  
  /// Get VAT return transactions
  Future<Either<Failure, List<VATTransaction>>> getVATReturnTransactions({
    required String vatReturnId,
    VATTransactionType? type,
    int? limit,
  });
  
  /// Add VAT return transaction
  Future<Either<Failure, void>> addVATReturnTransaction({
    required String vatReturnId,
    required VATTransaction transaction,
  });
  
  /// Update VAT return transaction
  Future<Either<Failure, void>> updateVATReturnTransaction({
    required String id,
    required VATTransaction transaction,
  });
  
  /// Remove VAT return transaction
  Future<Either<Failure, void>> removeVATReturnTransaction(String id);
  
  /// Get VAT return attachments
  Future<Either<Failure, List<String>>> getVATReturnAttachments(String id);
  
  /// Add VAT return attachment
  Future<Either<Failure, void>> addVATReturnAttachment({
    required String id,
    required String filePath,
    String? description,
  });
  
  /// Remove VAT return attachment
  Future<Either<Failure, void>> removeVATReturnAttachment({
    required String id,
    required String filePath,
  });
  
  /// Get VAT return notifications
  Future<Either<Failure, List<VATReturnNotification>>> getVATReturnNotifications({
    String? stockistId,
    VATReturnNotificationType? type,
    bool? isRead,
    int? limit,
  });
  
  /// Create VAT return notification
  Future<Either<Failure, void>> createVATReturnNotification(VATReturnNotification notification);
  
  /// Mark VAT return notification as read
  Future<Either<Failure, void>> markVATReturnNotificationAsRead(String id);
  
  /// Get VAT return reminders
  Future<Either<Failure, List<VATReturnReminder>>> getVATReturnReminders({
    String? stockistId,
    bool? isActive,
    int? limit,
  });
  
  /// Create VAT return reminder
  Future<Either<Failure, void>> createVATReturnReminder(VATReturnReminder reminder);
  
  /// Update VAT return reminder
  Future<Either<Failure, void>> updateVATReturnReminder(VATReturnReminder reminder);
  
  /// Delete VAT return reminder
  Future<Either<Failure, void>> deleteVATReturnReminder(String id);
  
  /// Get VAT return templates
  Future<Either<Failure, List<VATReturnTemplate>>> getVATReturnTemplates({
    String? stockistId,
    int? limit,
  });
  
  /// Create VAT return template
  Future<Either<Failure, void>> createVATReturnTemplate(VATReturnTemplate template);
  
  /// Update VAT return template
  Future<Either<Failure, void>> updateVATReturnTemplate(VATReturnTemplate template);
  
  /// Delete VAT return template
  Future<Either<Failure, void>> deleteVATReturnTemplate(String id);
  
  /// Get VAT return calculations
  Future<Either<Failure, Map<String, dynamic>>> calculateVATReturn({
    required String stockistId,
    required DateTime startDate,
    required DateTime endDate,
    double vatRate,
  });
  
  /// Get VAT return due dates
  Future<Either<Failure, List<VATReturnDueDate>>> getVATReturnDueDates({
    String? stockistId,
    int? months,
  });
  
  /// Sync VAT return with IRDN
  Future<Either<Failure, void>> syncVATReturnWithIRDN({
    required String id,
    Map<String, dynamic>? config,
  });
  
  /// Get VAT return export history
  Future<Either<Failure, List<VATReturnExport>>> getVATReturnExportHistory({
    String? stockistId,
    String? period,
    int? limit,
  });
  
  /// Create VAT return export record
  Future<Either<Failure, void>> createVATReturnExport(VATReturnExport export);
  
  /// Get VAT return backup
  Future<Either<Failure, void>> backupVATReturn(String id);
  
  /// Restore VAT return from backup
  Future<Either<Failure, void>> restoreVATReturnFromBackup({
    required String backupPath,
    String? stockistId,
  });
  
  /// Delete VAT return
  Future<Either<Failure, void>> deleteVATReturn(String id);
  
  /// Archive VAT return
  Future<Either<Failure, void>> archiveVATReturn(String id);
  
  /// Restore VAT return
  Future<Either<Failure, void>> restoreVATReturn(String id);
}

/// VAT Return Validation Entity
class VATReturnValidation {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final Map<String, dynamic> summary;

  const VATReturnValidation({
    required this.isValid,
    required this.errors,
    required this.warnings,
    required this.summary,
  });
}

/// VAT Return Audit Entity
class VATReturnAudit {
  final String id;
  final String vatReturnId;
  final String action;
  final String? oldValue;
  final String? newValue;
  final String? reason;
  final DateTime createdAt;
  final String? changedBy;
  final Map<String, dynamic> metadata;

  const VATReturnAudit({
    required this.id,
    required this.vatReturnId,
    required this.action,
    this.oldValue,
    this.newValue,
    this.reason,
    required this.createdAt,
    this.changedBy,
    this.metadata = const {},
  });
}

/// VAT Return Notification Entity
class VATReturnNotification {
  final String id;
  final String vatReturnId;
  final String stockistId;
  final VATReturnNotificationType type;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final Map<String, dynamic> metadata;

  const VATReturnNotification({
    required this.id,
    required this.vatReturnId,
    required this.stockistId,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.readAt,
    this.metadata = const {},
  });
}

/// VAT Return Notification Type enumeration
enum VATReturnNotificationType {
  dueSoon,
  overdue,
  submitted,
  irdnSubmitted,
  irdnAcknowledged,
  paymentReceived,
  rejected,
  amended,
  reminder,
}

/// VAT Return Reminder Entity
class VATReturnReminder {
  final String id;
  final String stockistId;
  final String title;
  final String description;
  final DateTime reminderDate;
  final bool isActive;
  final bool isRecurring;
  final String? recurringPattern;
  final DateTime? lastSent;
  final DateTime? nextSend;
  final Map<String, dynamic> metadata;

  const VATReturnReminder({
    required this.id,
    required this.stockistId,
    required this.title,
    required this.description,
    required this.reminderDate,
    required this.isActive,
    required this.isRecurring,
    this.recurringPattern,
    this.lastSent,
    this.nextSend,
    this.metadata = const {},
  });
}

/// VAT Return Template Entity
class VATReturnTemplate {
  final String id;
  final String stockistId;
  final String name;
  final String description;
  final double vatRate;
  final List<String> categories;
  final Map<String, dynamic> defaultSettings;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VATReturnTemplate({
    required this.id,
    required this.stockistId,
    required this.name,
    required this.description,
    required this.vatRate,
    required this.categories,
    required this.defaultSettings,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
}

/// VAT Return Due Date Entity
class VATReturnDueDate {
  final String period;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime dueDate;
  final int daysUntilDue;
  final bool isOverdue;
  final String? vatReturnId;

  const VATReturnDueDate({
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.dueDate,
    required this.daysUntilDue,
    required this.isOverdue,
    this.vatReturnId,
  });
}

/// VAT Return Export Entity
class VATReturnExport {
  final String id;
  final String vatReturnId;
  final String format;
  final String filePath;
  final DateTime exportedAt;
  final String? exportedBy;
  final int fileSize;
  final Map<String, dynamic> metadata;

  const VATReturnExport({
    required this.id,
    required this.vatReturnId,
    required this.format,
    required this.filePath,
    required this.exportedAt,
    this.exportedBy,
    required this.fileSize,
    this.metadata = const {},
  });
}
