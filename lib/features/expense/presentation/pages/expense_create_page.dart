import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../widgets/expense_form_widget.dart';
import '../widgets/receipt_upload_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/theme/app_theme.dart';

/// Expense Create Page
/// Allows users to create new expenses with multi-photo receipt upload
class ExpenseCreatePage extends StatefulWidget {
  const ExpenseCreatePage({Key? key}) : super(key: key);

  @override
  _ExpenseCreatePageState createState() => _ExpenseCreatePageState();
}

class _ExpenseCreatePageState extends State<ExpenseCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  
  // Form controllers
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _supplierController = TextEditingController();
  final _supplierInvoiceController = TextEditingController();
  final _notesController = TextEditingController();
  
  // Form state
  ExpenseCategory _selectedCategory = ExpenseCategory.travel;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  DateTime _selectedDate = DateTime.now();
  List<ExpenseItem> _items = [];
  List<XFile> _receiptImages = [];
  bool _isUploading = false;
  bool _isSubmitting = false;
  
  @override
  void initState() {
    super.initState();
    _addItem(); // Add one item by default
  }
  
  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _referenceController.dispose();
    _supplierController.dispose();
    _supplierInvoiceController.dispose();
    _notesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  void _addItem() {
    setState(() {
      _items.add(ExpenseItem(
        id: 'item_${DateTime.now().millisecondsSinceEpoch}',
        expenseId: 'new_expense',
        itemName: '',
        quantity: 1.0,
        unitPrice: 0.0,
        totalPrice: 0.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    });
  }
  
  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }
  
  void _updateItem(int index, ExpenseItem item) {
    setState(() {
      _items[index] = item;
    });
  }
  
  void _captureImages() async {
    try {
      final pickedFiles = await _imagePicker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (pickedFiles != null) {
        setState(() {
          _receiptImages.addAll(pickedFiles!);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to capture images: $e')),
      );
    }
  }
  
  void _removeImage(int index) {
    setState(() {
      _receiptImages.removeAt(index);
    });
  }
  
  void _onCategoryChanged(ExpenseCategory? category) {
    setState(() {
      _selectedCategory = category ?? ExpenseCategory.other;
    });
  }
  
  void _onPaymentMethodChanged(PaymentMethod? method) {
    setState(() {
      _selectedPaymentMethod = method ?? PaymentMethod.cash;
    });
  }
  
  void _onDateChanged(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }
  
  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one expense item')),
      );
      return;
    }
    
    if (_receiptImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one receipt image')),
      );
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      // Calculate total amount from items
      final totalAmount = _items.fold<double>(0.0, (sum, item) => sum + item.totalPrice);
      
      // Create expense entity
      final expense = ExpenseEntity(
        id: 'expense_${DateTime.now().millisecondsSinceEpoch}',
        mrId: 'current_mr_id', // TODO: Get from auth
        mrName: 'Current MR', // TODO: Get from auth
        retailerId: 'current_retailer_id', // TODO: Get from auth
        retailerName: 'Current Retailer', // TODO: Get from auth
        expenseType: _selectedCategory.name,
        category: _selectedCategory,
        amount: totalAmount,
        currency: 'NPR',
        expenseDate: _selectedDate,
        description: _descriptionController.text,
        receipts: [], // Will be populated after image upload
        status: ExpenseStatus.pending,
        items: _items,
        paymentMethod: _selectedPaymentMethod,
        referenceNumber: _referenceController.text.isNotEmpty ? _referenceController.text : null,
        supplierName: _supplierController.text.isNotEmpty ? _supplierController.text : null,
        supplierInvoice: _supplierInvoiceController.text.isNotEmpty ? _supplierInvoiceController.text : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Create expense
      final provider = ExpenseProvider.of(context);
      await provider.createExpense(expense);
      
      // Upload receipt images
      for (int i = 0; i < _receiptImages.length; i++) {
        await provider.addReceiptToExpense(
          expenseId: expense.id,
          images: [_receiptImages[i]],
          receiptType: 'expense_receipt',
          merchantName: _supplierController.text,
          notes: _notesController.text,
        );
      }
      
      // Submit for approval
      await provider.submitExpense(expense.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense created and submitted successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create expense: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
  
  Future<void> _onSaveAsDraft() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one expense item')),
      );
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      // Calculate total amount from items
      final totalAmount = _items.fold<double>(0.0, (sum, item) => sum + item.totalPrice);
      
      // Create expense entity
      final expense = ExpenseEntity(
        id: 'expense_${DateTime.now().millisecondsSinceEpoch}',
        mrId: 'current_mr_id', // TODO: Get from auth
        mrName: 'Current MR', // TODO: Get from auth
        retailerId: 'current_retailer_id', // TODO: Get from auth
        retailerName: 'Current Retailer', // TODO: Get from auth
        expenseType: _selectedCategory.name,
        category: _selectedCategory,
        amount: totalAmount,
        currency: 'NPR',
        expenseDate: _selectedDate,
        description: _descriptionController.text,
        receipts: [], // Will be populated after image upload
        status: ExpenseStatus.pending,
        items: _items,
        paymentMethod: _selectedPaymentMethod,
        referenceNumber: _referenceController.text.isNotEmpty ? _referenceController.text : null,
        supplierName: _supplierController.text.isNotEmpty ? _supplierController.text : null,
        supplierInvoice: _supplierInvoiceController.text.isNotEmpty ? _supplierInvoiceController.text : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Create expense
      final provider = ExpenseProvider.of(context);
      await provider.createExpense(expense);
      
      // Upload receipt images
      for (int i = 0; i < _receiptImages.length; i++) {
        await provider.addReceiptToExpense(
          expenseId: expense.id,
          images: [_receiptImages[i]],
          receiptType: 'expense_receipt',
          merchantName: _supplierController.text,
          notes: _notesController.text,
        );
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense saved as draft')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save expense: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
  
  void _onCancel() {
    Navigator.pop(context);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Expense'),
        actions: [
          TextButton(
            onPressed: _onSaveAsDraft,
            child: const Text('Save as Draft'),
          ),
          TextButton(
            onPressed: _onSave,
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Basic Information',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      
                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Description is required';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Amount
                      TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(
                          labelText: 'Amount',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.currency_exchange),
                          prefixText: 'NPR ',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Amount is required';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid amount';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Category
                      DropdownButtonFormField<ExpenseCategory>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: ExpenseCategory.values.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category.name.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: _onCategoryChanged,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Payment Method
                      DropdownButtonFormField<PaymentMethod>(
                        value: _selectedPaymentMethod,
                        decoration: const InputDecoration(
                          labelText: 'Payment Method',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.payment),
                        ),
                        items: PaymentMethod.values.map((method) {
                          return DropdownMenuItem(
                            value: method,
                            child: Text(method.name.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: _onPaymentMethodChanged,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Date
                      TextFormField(
                        controller: TextEditingController(
                          text: DateFormat('yyyy-MM-dd').format(_selectedDate),
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Expense Date',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 30)),
                            lastDate: DateTime.now().add(const Duration(days: 7)),
                          );
                          if (date != null) {
                            _onDateChanged(date);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Supplier Information Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Supplier Information',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      
                      // Supplier Name
                      TextFormField(
                        controller: _supplierController,
                        decoration: const InputDecoration(
                          labelText: 'Supplier Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.business),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Reference Number
                      TextFormField(
                        controller: _referenceController,
                        decoration: const InputDecoration(
                          labelText: 'Reference Number',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.receipt_long),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Supplier Invoice
                      TextFormField(
                        controller: _supplierInvoiceController,
                        decoration: const InputDecoration(
                          labelText: 'Supplier Invoice',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Expense Items Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Expense Items',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          TextButton.icon(
                            onPressed: _addItem,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Item'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Items list
                      ..._items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return ExpenseItemWidget(
                          item: item,
                          index: index,
                          onRemove: () => _removeItem(index),
                          onUpdate: (updatedItem) => _updateItem(index, updatedItem),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Receipt Upload Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Receipt Images',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      
                      // Image capture buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _captureImages,
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Capture Photos'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final pickedFiles = await _imagePicker.pickMultiImage();
                                if (pickedFiles != null) {
                                  setState(() {
                                    _receiptImages.addAll(pickedFiles!);
                                  });
                                }
                              },
                              icon: const Icon(Icons.photo_library),
                              label: const Text('From Gallery'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Uploaded images preview
                      if (_receiptImages.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Uploaded Receipts (${_receiptImages.length})',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _receiptImages.asMap().entries.map((entry) {
                                final index = entry.key;
                                final image = entry.value;
                                return Stack(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: Image.file(
                                          File(image.path),
                                          width: 78,
                                          height: 78,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              width: 78,
                                              height: 78,
                                              color: Colors.grey.shade200,
                                              child: const Icon(Icons.broken_image),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () => _removeImage(index),
                                        child: Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      
                      if (_receiptImages.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.photo_camera_outlined,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No receipt images uploaded',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Notes Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Additional Notes',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.note),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 100), // Extra space for FAB
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _onCancel,
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Submit Expense'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Expense Item Widget
class ExpenseItemWidget extends StatelessWidget {
  final ExpenseItem item;
  final int index;
  final VoidCallback onRemove;
  final Function(ExpenseItem) onUpdate;
  
  const ExpenseItemWidget({
    Key? key,
    required this.item,
    required this.index,
    required this.onRemove,
    required this.onUpdate,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final quantityController = TextEditingController(text: item.quantity.toString());
    final unitPriceController = TextEditingController(text: item.unitPrice.toStringAsFixed(2));
    final totalPriceController = TextEditingController(text: item.totalPrice.toStringAsFixed(2));
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: TextEditingController(text: item.itemName),
                    decoration: const InputDecoration(
                      labelText: 'Item Name',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      onUpdate(item.copyWith(itemName: value ?? ''));
                    },
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onRemove,
                  tooltip: 'Remove Item',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final quantity = double.tryParse(value ?? '') ?? 0.0;
                      final totalPrice = quantity * item.unitPrice;
                      onUpdate(item.copyWith(
                        quantity: quantity,
                        totalPrice: totalPrice,
                      ));
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: unitPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Unit Price',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final unitPrice = double.tryParse(value ?? '') ?? 0.0;
                      final totalPrice = item.quantity * unitPrice;
                      onUpdate(item.copyWith(
                        unitPrice: unitPrice,
                        totalPrice: totalPrice,
                      ));
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: totalPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Total Price',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final totalPrice = double.tryParse(value ?? '') ?? 0.0;
                      final unitPrice = totalPrice / item.quantity;
                      onUpdate(item.copyWith(
                        totalPrice: totalPrice,
                        unitPrice: unitPrice,
                      ));
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
