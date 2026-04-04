import 'package:dartz/dartz.dart';
import 'package:vedanta_trade/core/errors/failures.dart';
import 'package:vedanta_trade/features/accounting/domain/entities/accounting_entities.dart';

/// Abstract repository for accounting operations
abstract class AccountingRepository {
  /// Expense Management
  Future<Either<Failure, List<ExpenseEntity>>> getExpensesByMrId(String mrId);
  Future<Either<Failure, List<ExpenseEntity>>> getExpensesByStatus(String status);
  Future<Either<Failure, List<ExpenseEntity>>> getExpensesByDateRange(DateTime startDate, DateTime endDate);
  Future<Either<Failure, ExpenseEntity>> createExpense(ExpenseEntity expense);
  Future<Either<Failure, ExpenseEntity>> updateExpense(ExpenseEntity expense);
  Future<Either<Failure, void>> deleteExpense(String expenseId);
  Future<Either<Failure, ExpenseEntity>> approveExpense(String expenseId);
  Future<Either<Failure, ExpenseEntity>> rejectExpense(String expenseId, String reason);

  /// VAT Return Management
  Future<Either<Failure, List<VatReturnEntity>>> getAllVatReturns();
  Future<Either<Failure, VatReturnEntity>> getVatReturnById(String vatReturnId);
  Future<Either<Failure, VatReturnEntity>> getVatReturnByPeriod(String period);
  Future<Either<Failure, VatReturnEntity>> createVatReturn(VatReturnEntity vatReturn);
  Future<Either<Failure, VatReturnEntity>> updateVatReturn(VatReturnEntity vatReturn);
  Future<Either<Failure, VatReturnEntity>> fileVatReturn(String vatReturnId);
  Future<Either<Failure, VatReturnEntity>> submitVatReturn(String vatReturnId);
  Future<Either<Failure, String>> generateVatReturnPdf(String vatReturnId);

  /// Invoice Management
  Future<Either<Failure, List<InvoiceEntity>>> getAllInvoices();
  Future<Either<Failure, List<InvoiceEntity>>> getInvoicesByStatus(String status);
  Future<Either<Failure, List<InvoiceEntity>>> getInvoicesByCustomer(String customerId);
  Future<Either<Failure, List<InvoiceEntity>>> getOverdueInvoices();
  Future<Either<Failure, InvoiceEntity>> createInvoice(InvoiceEntity invoice);
  Future<Either<Failure, InvoiceEntity>> updateInvoice(InvoiceEntity invoice);
  Future<Either<Failure, InvoiceEntity>> markInvoiceAsPaid(String invoiceId);
  Future<Either<Failure, InvoiceEntity>> cancelInvoice(String invoiceId, String reason);
  Future<Either<Failure, String>> generateInvoicePdf(String invoiceId);

  /// Ledger Management
  Future<Either<Failure, List<LedgerEntryEntity>>> getLedgerEntries();
  Future<Either<Failure, List<LedgerEntryEntity>>> getLedgerEntriesByAccount(String accountNumber);
  Future<Either<Failure, List<LedgerEntryEntity>>> getLedgerEntriesByDateRange(DateTime startDate, DateTime endDate);
  Future<Either<Failure, LedgerEntryEntity>> createLedgerEntry(LedgerEntryEntity entry);
  Future<Either<Failure, List<LedgerEntryEntity>>> generateTrialBalance(DateTime asOfDate);
  Future<Either<Failure, Map<String, dynamic>>> generateBalanceSheet(DateTime asOfDate);
  Future<Either<Failure, Map<String, dynamic>>> generateIncomeStatement(DateTime startDate, DateTime endDate);

  /// Dashboard and Analytics
  Future<Either<Failure, Map<String, dynamic>>> getDashboardStats();
  Future<Either<Failure, Map<String, dynamic>>> getExpenseSummary(String period);
  Future<Either<Failure, Map<String, dynamic>>> getVatSummary(String period);
  Future<Either<Failure, Map<String, dynamic>>> getRevenueSummary(String period);
  Future<Either<Failure, List<Map<String, dynamic>>> getMonthlyTrends(int months);
  Future<Either<Failure, Map<String, dynamic>>> getAgingReport();

  /// Reconciliation
  Future<Either<Failure, Map<String, dynamic>>> reconcileExpenses(String mrId, String period);
  Future<Either<Failure, Map<String, dynamic>>> reconcileVatReturns(String period);
  Future<Either<Failure, List<ExpenseEntity>>> getUnreconciledExpenses();
  Future<Either<Failure, List<VatReturnEntity>>> getUnreconciledVatReturns();
}
