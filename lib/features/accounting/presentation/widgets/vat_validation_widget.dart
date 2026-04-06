import 'package:flutter/material.dart';
import '../../../../shared/widgets/premium_glassmorphic_theme.dart';
import '../../data/services/vat_return_service.dart';

/// VAT Validation Widget
class VATValidationWidget extends StatelessWidget {
  final VATValidationResult validationResult;
  final VoidCallback? onRetry;

  const VATValidationWidget({
    Key? key,
    required this.validationResult,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: validationResult.isValid ? Colors.green[50] : Colors.red[50],
        border: Border.all(
          color: validationResult.isValid ? Colors.green : Colors.red,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                validationResult.isValid ? Icons.check_circle : Icons.error,
                color: validationResult.isValid ? Colors.green : Colors.red,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  validationResult.isValid ? 'Validation Passed' : 'Validation Failed',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: validationResult.isValid ? Colors.green : Colors.red,
                  ),
                ),
              ),
              if (!validationResult.isValid && onRetry != null)
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: onRetry,
                  tooltip: 'Retry Validation',
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Errors
          if (validationResult.errors.isNotEmpty) ...[
            Text(
              'Errors:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            ...validationResult.errors.map((error) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      error,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red[700],
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
          
          // Warnings
          if (validationResult.warnings.isNotEmpty) ...[
            if (validationResult.errors.isNotEmpty) const SizedBox(height: 16),
            Text(
              'Warnings:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            ...validationResult.warnings.map((warning) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      warning,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange[700],
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
          
          // Success Message
          if (validationResult.isValid && validationResult.errors.isEmpty && validationResult.warnings.isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'All validations passed successfully. Your VAT return is ready for submission.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.green[700],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
