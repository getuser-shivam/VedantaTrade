import 'package:flutter/material.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';
import 'package:vedanta_trade/shared/widgets/glassmorphic_widgets.dart';
import 'package:intl/intl.dart';

/// VAT Report Card for Accountant Dashboard
class VatReportCard extends StatelessWidget {
  final Map<String, dynamic> vatReturn;
  final VoidCallback onTap;
  final VoidCallback onGeneratePdf;
  final VoidCallback onFile;

  const VatReportCard({
    required this.vatReturn,
    required this.onTap,
    required this.onGeneratePdf,
    required this.onFile,
  });

  @override
  Widget build(BuildContext context) {
    final status = vatReturn['status'] as String;
    final statusColor = _getStatusColor(status);
    final isOverdue = DateTime.now().isAfter(vatReturn['dueDate']);
    
    return GlassmorphicCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vatReturn['period'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Return #${vatReturn['id']}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      statusColor.withOpacity(0.2),
                      statusColor.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InfoRow(
                  icon: Icons.monetization_on,
                  label: 'NPR ${vatReturn['totalSales']}',
                  color: AppTheme.success,
                ),
              ),
              Expanded(
                child: _InfoRow(
                  icon: Icons.receipt_long,
                  label: 'VAT: NPR ${vatReturn['vatAmount']}',
                  color: AppTheme.accountantColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InfoRow(
                  icon: Icons.calendar_today,
                  label: 'Due: ${DateFormat('MMM dd').format(vatReturn['dueDate'])}',
                  color: isOverdue ? AppTheme.error : Colors.white54,
                ),
              ),
              if (vatReturn['filedDate'] != null)
                Expanded(
                  child: _InfoRow(
                    icon: Icons.check_circle,
                    label: 'Filed: ${DateFormat('MMM dd').format(vatReturn['filedDate'])}',
                    color: AppTheme.success,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (status == 'pending')
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onGeneratePdf,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accountantColor.withOpacity(0.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.picture_as_pdf, color: AppTheme.accountantColor, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Generate PDF',
                          style: TextStyle(color: AppTheme.accountantColor, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onFile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success.withOpacity(0.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send, color: AppTheme.success, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'File Return',
                          style: TextStyle(color: AppTheme.success, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'filed':
        return AppTheme.success;
      case 'pending':
        return Colors.orange;
      case 'overdue':
        return AppTheme.error;
      case 'processing':
        return AppTheme.info;
      default:
        return Colors.white54;
    }
  }
}

/// Expense Reconciliation Card for Accountant Dashboard
class ExpenseReconciliationCard extends StatelessWidget {
  final Map<String, dynamic> expense;
  final VoidCallback onTap;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onViewReceipts;

  const ExpenseReconciliationCard({
    required this.expense,
    required this.onTap,
    required this.onApprove,
    required this.onReject,
    required this.onViewReceipts,
  });

  @override
  Widget build(BuildContext context) {
    final status = expense['status'] as String;
    final statusColor = _getStatusColor(status);
    
    return GlassmorphicCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense['mrName'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Expense #${expense['id']}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      statusColor.withOpacity(0.2),
                      statusColor.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InfoRow(
                  icon: Icons.monetization_on,
                  label: 'NPR ${expense['amount']}',
                  color: AppTheme.success,
                ),
              ),
              Expanded(
                child: _InfoRow(
                  icon: Icons.category,
                  label: expense['category'],
                  color: Colors.white54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InfoRow(
                  icon: Icons.calendar_today,
                  label: DateFormat('MMM dd').format(expense['date']),
                  color: Colors.white54,
                ),
              ),
              Expanded(
                child: _InfoRow(
                  icon: Icons.attach_file,
                  label: '${expense['receiptCount']} receipts',
                  color: AppTheme.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            expense['description'],
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          if (status == 'pending')
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onApprove,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success.withOpacity(0.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check, color: AppTheme.success, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Approve',
                          style: TextStyle(color: AppTheme.success, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onReject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.error.withOpacity(0.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.close, color: AppTheme.error, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Reject',
                          style: TextStyle(color: AppTheme.error, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          else if (status == 'approved')
            SizedBox(
              width: double.infinity,
              height: 36,
              child: ElevatedButton(
                onPressed: onViewReceipts,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.info.withOpacity(0.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.attach_file, color: AppTheme.info, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'View Receipts',
                      style: TextStyle(color: AppTheme.info, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return AppTheme.success;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return AppTheme.error;
      default:
        return Colors.white54;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
