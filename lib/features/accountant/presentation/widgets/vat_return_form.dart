import 'package:flutter/material.dart';
import '../../../../shared/widgets/premium_glassmorphic_theme.dart';
import '../../../../shared/utils/nepal_localization_utils.dart';
import '../../data/services/vat_return_service.dart';

/// VAT Return Form Widget
class VATReturnForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;
  final VATValidationResult Function(Map<String, dynamic>) onValidate;

  const VATReturnForm({
    Key? key,
    required this.onSubmit,
    required this.onValidate,
  }) : super(key: key);

  @override
  State<VATReturnForm> createState() => _VATReturnFormState();
}

class _VATReturnFormState extends State<VATReturnForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  DateTime? _startDate;
  DateTime? _endDate;
  VATReturnType _returnType = VATReturnType.monthly;
  String _taxPeriod = '';
  String _remarks = '';
  bool _isGenerating = false;
  VATValidationResult? _validationResult;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    PremiumGlassmorphicTheme.primaryColor.withOpacity(0.1),
                    PremiumGlassmorphicTheme.secondaryColor.withOpacity(0.1),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.add_chart,
                    color: PremiumGlassmorphicTheme.primaryColor,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Generate VAT Return',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: PremiumGlassmorphicTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fill in the details below to generate a new VAT return',
                    style: TextStyle(
                      fontSize: 14,
                      color: PremiumGlassmorphicTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Return Type Selection
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Return Type',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: PremiumGlassmorphicTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildReturnTypeOption(VATReturnType.monthly, 'Monthly'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildReturnTypeOption(VATReturnType.quarterly, 'Quarterly'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildReturnTypeOption(VATReturnType.yearly, 'Yearly'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Date Range Selection
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date Range',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: PremiumGlassmorphicTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Start Date',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                          readOnly: true,
                          onTap: _selectStartDate,
                          controller: TextEditingController(
                            text: _startDate != null
                                ? NepalLocalizationUtils.formatNepaliDate(_startDate!)
                                : '',
                          ),
                          validator: (value) {
                            if (_startDate == null) {
                              return 'Please select start date';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'End Date',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                          readOnly: true,
                          onTap: _selectEndDate,
                          controller: TextEditingController(
                            text: _endDate != null
                                ? NepalLocalizationUtils.formatNepaliDate(_endDate!)
                                : '',
                          ),
                          validator: (value) {
                            if (_endDate == null) {
                              return 'Please select end date';
                            }
                            if (_startDate != null && _endDate != null && _endDate!.isBefore(_startDate!)) {
                              return 'End date must be after start date';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Tax Period
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tax Period',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: PremiumGlassmorphicTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Tax Period (e.g., 2024 Q1, March 2024)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _taxPeriod = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter tax period';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Remarks
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Remarks (Optional)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: PremiumGlassmorphicTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Add any additional notes or remarks',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    maxLines: 3,
                    onChanged: (value) {
                      setState(() {
                        _remarks = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Validation Results
            if (_validationResult != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _validationResult!.isValid ? Colors.green[50] : Colors.red[50],
                  border: Border.all(
                    color: _validationResult!.isValid ? Colors.green : Colors.red,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _validationResult!.isValid ? Icons.check_circle : Icons.error,
                          color: _validationResult!.isValid ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _validationResult!.isValid ? 'Validation Passed' : 'Validation Failed',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _validationResult!.isValid ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    if (_validationResult!.errors.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ..._validationResult!.errors.map((error) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.error_outline, color: Colors.red, size: 16),
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
                    if (_validationResult!.warnings.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ..._validationResult!.warnings.map((warning) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.warning_amber, color: Colors.orange, size: 16),
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
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _formKey.currentState?.reset();
                      setState(() {
                        _startDate = null;
                        _endDate = null;
                        _returnType = VATReturnType.monthly;
                        _taxPeriod = '';
                        _remarks = '';
                        _validationResult = null;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: PremiumGlassmorphicTheme.primaryColor),
                    ),
                    child: Text(
                      'Clear Form',
                      style: TextStyle(
                        color: PremiumGlassmorphicTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isGenerating ? null : _validateAndSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PremiumGlassmorphicTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isGenerating
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text('Generating...'),
                            ],
                          )
                        : Text(
                            'Generate VAT Return',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReturnTypeOption(VATReturnType type, String label) {
    final isSelected = _returnType == type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _returnType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? PremiumGlassmorphicTheme.primaryColor.withOpacity(0.1) : Colors.grey[50],
          border: Border.all(
            color: isSelected ? PremiumGlassmorphicTheme.primaryColor : Colors.grey[300]!,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _getReturnTypeIcon(type),
              color: isSelected ? PremiumGlassmorphicTheme.primaryColor : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? PremiumGlassmorphicTheme.primaryColor : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getReturnTypeIcon(VATReturnType type) {
    switch (type) {
      case VATReturnType.monthly:
        return Icons.calendar_month;
      case VATReturnType.quarterly:
        return Icons.calendar_view_week;
      case VATReturnType.yearly:
        return Icons.calendar_today;
    }
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (date != null) {
      setState(() {
        _startDate = date;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now(),
    );
    
    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }

  void _validateAndSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isGenerating = true;
      _validationResult = null;
    });

    try {
      final returnData = {
        'startDate': _startDate,
        'endDate': _endDate,
        'returnType': _returnType,
        'taxPeriod': _taxPeriod.trim(),
        'remarks': _remarks.trim().isEmpty ? null : _remarks.trim(),
      };

      // Validate the return data
      final validationResult = widget.onValidate(returnData);
      
      setState(() {
        _validationResult = validationResult;
      });

      if (validationResult.isValid) {
        await widget.onSubmit(returnData);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('VAT return generated successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        
        // Reset form
        _formKey.currentState?.reset();
        setState(() {
          _startDate = null;
          _endDate = null;
          _returnType = VATReturnType.monthly;
          _taxPeriod = '';
          _remarks = '';
          _validationResult = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate VAT return: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }
}
