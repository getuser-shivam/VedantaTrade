import 'package:dartz/dartz.dart';
import 'package:vedanta_trade/core/errors/failures.dart';
import 'package:vedanta_trade/features/accounting/domain/entities/accounting_entities.dart';
import 'package:vedanta_trade/features/accounting/domain/repositories/accounting_repository.dart';

/// Use case for getting expenses by MR ID
class GetExpensesByMrIdUseCase {
  final AccountingRepository _repository;

  GetExpensesByMrIdUseCase(this._repository);

  Future<Either<Failure, List<ExpenseEntity>>> call(String mrId) async {
    if (mrId.isEmpty) {
      return Left(ValidationFailure('MR ID cannot be empty'));
    }
    return await _repository.getExpensesByMrId(mrId);
  }
}

/// Use case for getting expenses by status
class GetExpensesByStatusUseCase {
  final AccountingRepository _repository;

  GetExpensesByStatusUseCase(this._repository);

  Future<Either<Failure, List<ExpenseEntity>>> call(String status) async {
    if (status.isEmpty) {
      return Left(ValidationFailure('Status cannot be empty'));
    }
    return await _repository.getExpensesByStatus(status);
  }
}

/// Use case for creating a new expense
class CreateExpenseUseCase {
  final AccountingRepository _repository;

  CreateExpenseUseCase(this._repository);

  Future<Either<Failure, ExpenseEntity>> call(ExpenseEntity expense) async {
    // Validate expense data
    final validationFailure = _validateExpense(expense);
    if (validationFailure != null) {
      return Left(validationFailure);
    }

    return await _repository.createExpense(expense);
  }

  ValidationFailure? _validateExpense(ExpenseEntity expense) {
    if (expense.mrId.isEmpty) {
      return const ValidationFailure('MR ID is required');
    }
    if (expense.mrName.isEmpty) {
      return const ValidationFailure('MR name is required');
    }
    if (expense.amount <= 0) {
      return const ValidationFailure('Amount must be greater than 0');
    }
    if (expense.category.isEmpty) {
      return const ValidationFailure('Category is required');
    }
    if (expense.description.isEmpty) {
      return const ValidationFailure('Description is required');
    }
    return null;
  }
}

/// Use case for approving an expense
class ApproveExpenseUseCase {
  final AccountingRepository _repository;

  ApproveExpenseUseCase(this._repository);

  Future<Either<Failure, ExpenseEntity>> call(String expenseId) async {
    if (expenseId.isEmpty) {
      return Left(ValidationFailure('Expense ID cannot be empty'));
    }
    return await _repository.approveExpense(expenseId);
  }
}

/// Use case for rejecting an expense
class RejectExpenseUseCase {
  final AccountingRepository _repository;

  RejectExpenseUseCase(this._repository);

  Future<Either<Failure, ExpenseEntity>> call(String expenseId, String reason) async {
    if (expenseId.isEmpty) {
      return Left(ValidationFailure('Expense ID cannot be empty'));
    }
    if (reason.isEmpty) {
      return Left(ValidationFailure('Rejection reason is required'));
    }
    return await _repository.rejectExpense(expenseId, reason);
  }
}

/// Use case for getting VAT returns by period
class GetVatReturnByPeriodUseCase {
  final AccountingRepository _repository;

  GetVatReturnByPeriodUseCase(this._repository);

  Future<Either<Failure, VatReturnEntity>> call(String period) async {
    if (period.isEmpty) {
      return Left(ValidationFailure('Period cannot be empty'));
    }
    return await _repository.getVatReturnByPeriod(period);
  }
}

/// Use case for creating a VAT return
class CreateVatReturnUseCase {
  final AccountingRepository _repository;

  CreateVatReturnUseCase(this._repository);

  Future<Either<Failure, VatReturnEntity>> call(VatReturnEntity vatReturn) async {
    // Validate VAT return data
    final validationFailure = _validateVatReturn(vatReturn);
    if (validationFailure != null) {
      return Left(validationFailure);
    }

    return await _repository.createVatReturn(vatReturn);
  }

  ValidationFailure? _validateVatReturn(VatReturnEntity vatReturn) {
    if (vatReturn.period.isEmpty) {
      return const ValidationFailure('Period is required');
    }
    if (vatReturn.totalSales < 0) {
      return const ValidationFailure('Total sales cannot be negative');
    }
    if (vatReturn.totalPurchases < 0) {
      return const ValidationFailure('Total purchases cannot be negative');
    }
    if (vatReturn.dueDate.isBefore(DateTime.now())) {
      return const ValidationFailure('Due date cannot be in the past');
    }
    return null;
  }
}

/// Use case for filing a VAT return
class FileVatReturnUseCase {
  final AccountingRepository _repository;

  FileVatReturnUseCase(this._repository);

  Future<Either<Failure, VatReturnEntity>> call(String vatReturnId) async {
    if (vatReturnId.isEmpty) {
      return Left(ValidationFailure('VAT return ID cannot be empty'));
    }
    return await _repository.fileVatReturn(vatReturnId);
  }
}

/// Use case for generating VAT return PDF
class GenerateVatReturnPdfUseCase {
  final AccountingRepository _repository;

  GenerateVatReturnPdfUseCase(this._repository);

  Future<Either<Failure, String>> call(String vatReturnId) async {
    if (vatReturnId.isEmpty) {
      return Left(ValidationFailure('VAT return ID cannot be empty'));
    }
    return await _repository.generateVatReturnPdf(vatReturnId);
  }
}

/// Use case for getting invoices by status
class GetInvoicesByStatusUseCase {
  final AccountingRepository _repository;

  GetInvoicesByStatusUseCase(this._repository);

  Future<Either<Failure, List<InvoiceEntity>>> call(String status) async {
    if (status.isEmpty) {
      return Left(ValidationFailure('Status cannot be empty'));
    }
    return await _repository.getInvoicesByStatus(status);
  }
}

/// Use case for creating an invoice
class CreateInvoiceUseCase {
  final AccountingRepository _repository;

  CreateInvoiceUseCase(this._repository);

  Future<Either<Failure, InvoiceEntity>> call(InvoiceEntity invoice) async {
    // Validate invoice data
    final validationFailure = _validateInvoice(invoice);
    if (validationFailure != null) {
      return Left(validationFailure);
    }

    return await _repository.createInvoice(invoice);
  }

  ValidationFailure? _validateInvoice(InvoiceEntity invoice) {
    if (invoice.invoiceNumber.isEmpty) {
      return const ValidationFailure('Invoice number is required');
    }
    if (invoice.customerId.isEmpty) {
      return const ValidationFailure('Customer ID is required');
    }
    if (invoice.customerName.isEmpty) {
      return const ValidationFailure('Customer name is required');
    }
    if (invoice.totalAmount <= 0) {
      return const ValidationFailure('Total amount must be greater than 0');
    }
    if (invoice.items.isEmpty) {
      return const ValidationFailure('Invoice must have at least one item');
    }
    if (invoice.dueDate.isBefore(DateTime.now())) {
      return const ValidationFailure('Due date cannot be in the past');
    }
    return null;
  }
}

/// Use case for marking invoice as paid
class MarkInvoiceAsPaidUseCase {
  final AccountingRepository _repository;

  MarkInvoiceAsPaidUseCase(this._repository);

  Future<Either<Failure, InvoiceEntity>> call(String invoiceId) async {
    if (invoiceId.isEmpty) {
      return Left(ValidationFailure('Invoice ID cannot be empty'));
    }
    return await _repository.markInvoiceAsPaid(invoiceId);
  }
}

/// Use case for getting overdue invoices
class GetOverdueInvoicesUseCase {
  final AccountingRepository _repository;

  GetOverdueInvoicesUseCase(this._repository);

  Future<Either<Failure, List<InvoiceEntity>>> call() async {
    return await _repository.getOverdueInvoices();
  }
}

/// Use case for getting dashboard statistics
class GetDashboardStatsUseCase {
  final AccountingRepository _repository;

  GetDashboardStatsUseCase(this._repository);

  Future<Either<Failure, Map<String, dynamic>>> call() async {
    return await _repository.getDashboardStats();
  }
}

/// Use case for getting expense summary
class GetExpenseSummaryUseCase {
  final AccountingRepository _repository;

  GetExpenseSummaryUseCase(this._repository);

  Future<Either<Failure, Map<String, dynamic>>> call(String period) async {
    if (period.isEmpty) {
      return Left(ValidationFailure('Period cannot be empty'));
    }
    return await _repository.getExpenseSummary(period);
  }
}

/// Use case for getting VAT summary
class GetVatSummaryUseCase {
  final AccountingRepository _repository;

  GetVatSummaryUseCase(this._repository);

  Future<Either<Failure, Map<String, dynamic>>> call(String period) async {
    if (period.isEmpty) {
      return Left(ValidationFailure('Period cannot be empty'));
    }
    return await _repository.getVatSummary(period);
  }
}

/// Use case for reconciling expenses
class ReconcileExpensesUseCase {
  final AccountingRepository _repository;

  ReconcileExpensesUseCase(this._repository);

  Future<Either<Failure, Map<String, dynamic>>> call(String mrId, String period) async {
    if (mrId.isEmpty) {
      return Left(ValidationFailure('MR ID cannot be empty'));
    }
    if (period.isEmpty) {
      return Left(ValidationFailure('Period cannot be empty'));
    }
    return await _repository.reconcileExpenses(mrId, period);
  }
}

/// Use case for generating trial balance
class GenerateTrialBalanceUseCase {
  final AccountingRepository _repository;

  GenerateTrialBalanceUseCase(this._repository);

  Future<Either<Failure, List<LedgerEntryEntity>>> call(DateTime asOfDate) async {
    if (asOfDate.isAfter(DateTime.now())) {
      return Left(ValidationFailure('As of date cannot be in the future'));
    }
    return await _repository.generateTrialBalance(asOfDate);
  }
}

/// Use case for generating balance sheet
class GenerateBalanceSheetUseCase {
  final AccountingRepository _repository;

  GenerateBalanceSheetUseCase(this._repository);

  Future<Either<Failure, Map<String, dynamic>>> call(DateTime asOfDate) async {
    if (asOfDate.isAfter(DateTime.now())) {
      return Left(ValidationFailure('As of date cannot be in the future'));
    }
    return await _repository.generateBalanceSheet(asOfDate);
  }
}

/// Use case for generating income statement
class GenerateIncomeStatementUseCase {
  final AccountingRepository _repository;

  GenerateIncomeStatementUseCase(this._repository);

  Future<Either<Failure, Map<String, dynamic>>> call(DateTime startDate, DateTime endDate) async {
    if (startDate.isAfter(endDate)) {
      return Left(ValidationFailure('Start date must be before end date'));
    }
    if (endDate.isAfter(DateTime.now())) {
      return Left(ValidationFailure('End date cannot be in the future'));
    }
    return await _repository.generateIncomeStatement(startDate, endDate);
  }
}
