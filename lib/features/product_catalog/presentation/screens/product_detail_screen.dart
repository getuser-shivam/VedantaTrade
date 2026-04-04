import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_catalog_provider.dart';
import '../../data/models/product_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final String? productId;
  final bool isEditing;

  const ProductDetailScreen({
    Key? key,
    this.productId,
    this.isEditing = false,
  }) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _genericNameController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dosageFormController = TextEditingController();
  final _strengthController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _batchController = TextEditingController();
  final _expiryController = TextEditingController();
  final _storageController = TextEditingController();
  final _ndcController = TextEditingController();
  final _irdController = TextEditingController();

  String? _selectedCategory;
  String? _selectedDosageForm;
  String? _selectedRegulatoryStatus;
  bool _requiresPrescription = true;
  bool _isActive = true;
  double _discountPercentage = 0.0;
  double _taxRate = 13.0;
  DateTime? _expiryDate;

  final List<String> _categories = [
    'Analgesics',
    'Antibiotics',
    'Gastrointestinal',
    'Respiratory',
    'Antidiabetic',
    'Cardiovascular',
    'Dermatological',
    'Vitamins',
    'Vaccines',
    'Oncology',
  ];

  final List<String> _dosageForms = [
    'Tablet',
    'Capsule',
    'Syrup',
    'Injection',
    'Inhaler',
    'Ointment',
    'Cream',
    'Drops',
    'Patch',
    'Suppository',
  ];

  final List<String> _regulatoryStatuses = [
    'Approved',
    'Pending',
    'Rejected',
    'Under Review',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      _loadProduct();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _genericNameController.dispose();
    _manufacturerController.dispose();
    _descriptionController.dispose();
    _dosageFormController.dispose();
    _strengthController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _batchController.dispose();
    _expiryController.dispose();
    _storageController.dispose();
    _ndcController.dispose();
    _irdController.dispose();
    super.dispose();
  }

  void _loadProduct() async {
    final provider = context.read<ProductCatalogProvider>();
    final product = provider.getProductById(widget.productId!);
    
    if (product != null) {
      setState(() {
        _nameController.text = product.name;
        _genericNameController.text = product.genericName;
        _manufacturerController.text = product.manufacturer;
        _descriptionController.text = product.description;
        _dosageFormController.text = product.dosageForm;
        _strengthController.text = product.strength;
        _priceController.text = product.price.toString();
        _stockController.text = product.stockQuantity.toString();
        _batchController.text = product.batchNumber;
        _expiryDate = product.expiryDate;
        _expiryController.text = '${product.expiryDate.day}/${product.expiryDate.month}/${product.expiryDate.year}';
        _storageController.text = product.storageConditions;
        _ndcController.text = product.ndcNumber;
        _irdController.text = product.irdNumber;
        _selectedCategory = product.category;
        _selectedDosageForm = product.dosageForm;
        _selectedRegulatoryStatus = product.regulatoryStatus;
        _requiresPrescription = product.requiresPrescription.toLowerCase() == 'yes';
        _isActive = product.isActive;
        _discountPercentage = product.discountPercentage;
        _taxRate = product.taxRate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Product' : 
                    widget.productId != null ? 'Product Details' : 'Add Product'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (widget.productId != null && !widget.isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(
                      productId: widget.productId,
                      isEditing: true,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: widget.isEditing || widget.productId == null
          ? _buildProductForm()
          : _buildProductView(),
    );
  }

  Widget _buildProductForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic Information
            _buildSectionHeader('Basic Information'),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Product Name *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter product name';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _genericNameController,
              decoration: const InputDecoration(
                labelText: 'Generic Name *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter generic name';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _manufacturerController,
              decoration: const InputDecoration(
                labelText: 'Manufacturer *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter manufacturer';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category *',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a category';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 24),
            
            // Product Details
            _buildSectionHeader('Product Details'),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedDosageForm,
                    decoration: const InputDecoration(
                      labelText: 'Dosage Form *',
                      border: OutlineInputBorder(),
                    ),
                    items: _dosageForms.map((form) {
                      return DropdownMenuItem(
                        value: form,
                        child: Text(form),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDosageForm = value;
                        _dosageFormController.text = value ?? '';
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select dosage form';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _strengthController,
                    decoration: const InputDecoration(
                      labelText: 'Strength *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter strength';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: 24),
            
            // Pricing and Stock
            _buildSectionHeader('Pricing & Stock'),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price (NPR) *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter price';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid price';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _stockController,
                    decoration: const InputDecoration(
                      labelText: 'Stock Quantity *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter stock quantity';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid quantity';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _batchController,
                    decoration: const InputDecoration(
                      labelText: 'Batch Number *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter batch number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: _selectExpiryDate,
                    child: IgnorePointer(
                      child: TextFormField(
                        controller: _expiryController,
                        decoration: const InputDecoration(
                          labelText: 'Expiry Date *',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select expiry date';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Regulatory Information
            _buildSectionHeader('Regulatory Information'),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ndcController,
                    decoration: const InputDecoration(
                      labelText: 'NDC Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _irdController,
                    decoration: const InputDecoration(
                      labelText: 'IRD Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              value: _selectedRegulatoryStatus,
              decoration: const InputDecoration(
                labelText: 'Regulatory Status',
                border: OutlineInputBorder(),
              ),
              items: _regulatoryStatuses.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRegulatoryStatus = value;
                });
              },
            ),
            
            const SizedBox(height: 24),
            
            // Additional Settings
            _buildSectionHeader('Additional Settings'),
            const SizedBox(height: 16),
            
            SwitchListTile(
              title: const Text('Requires Prescription'),
              value: _requiresPrescription,
              onChanged: (value) {
                setState(() {
                  _requiresPrescription = value;
                });
              },
            ),
            
            SwitchListTile(
              title: const Text('Active'),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
            
            const SizedBox(height: 32),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveProduct,
                    child: Text(widget.productId != null ? 'Update' : 'Save'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProductView() {
    return Consumer<ProductCatalogProvider>(
      builder: (context, provider, child) {
        final product = provider.getProductById(widget.productId!);
        
        if (product == null) {
          return const Center(
            child: Text('Product not found'),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade100,
                ),
                child: product.imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.medication,
                                size: 64,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.medication,
                          size: 64,
                          color: Colors.grey,
                        ),
                      ),
              ),
              
              const SizedBox(height: 16),
              
              // Product Name and Rating
              Row(
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${product.reviewCount})',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Generic Name
              Text(
                product.genericName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Price and Stock
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Price',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            'NPR ${product.price.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.green.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Stock',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            '${product.stockQuantity} units',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: product.isLowStock ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Product Details
              _buildDetailCard('Product Details', [
                _buildDetailRow('Manufacturer', product.manufacturer),
                _buildDetailRow('Category', product.category),
                _buildDetailRow('Dosage Form', product.dosageForm),
                _buildDetailRow('Strength', product.strength),
                _buildDetailRow('Batch Number', product.batchNumber),
                _buildDetailRow('Expiry Date', 
                    '${product.expiryDate.day}/${product.expiryDate.month}/${product.expiryDate.year}'),
                _buildDetailRow('Storage', product.storageConditions),
              ]),
              
              const SizedBox(height: 16),
              
              // Description
              _buildDetailCard('Description', [
                Text(
                  product.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
                ),
              ]),
              
              const SizedBox(height: 16),
              
              // Regulatory Information
              _buildDetailCard('Regulatory Information', [
                _buildDetailRow('Regulatory Status', product.regulatoryStatus),
                if (product.ndcNumber.isNotEmpty)
                  _buildDetailRow('NDC Number', product.ndcNumber),
                if (product.irdNumber.isNotEmpty)
                  _buildDetailRow('IRD Number', product.irdNumber),
                _buildDetailRow('Prescription Required', product.prescriptionRequired),
              ]),
              
              const SizedBox(height: 32),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(
                              productId: widget.productId,
                              isEditing: true,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Done'),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildDetailCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (picked != null) {
      setState(() {
        _expiryDate = picked;
        _expiryController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  void _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final product = Product(
      id: widget.productId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      genericName: _genericNameController.text,
      manufacturer: _manufacturerController.text,
      category: _selectedCategory!,
      dosageForm: _selectedDosageForm!,
      strength: _strengthController.text,
      price: double.parse(_priceController.text),
      stockQuantity: int.parse(_stockController.text),
      batchNumber: _batchController.text,
      expiryDate: _expiryDate!,
      description: _descriptionController.text,
      storageConditions: _storageController.text,
      ndcNumber: _ndcController.text,
      irdNumber: _irdController.text,
      regulatoryStatus: _selectedRegulatoryStatus ?? 'Approved',
      prescriptionRequired: _requiresPrescription ? 'Yes' : 'No',
      isActive: _isActive,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      final provider = context.read<ProductCatalogProvider>();
      if (widget.productId != null) {
        await provider.updateProduct(product);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // TODO: Implement add product functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Add product feature coming soon!'),
            backgroundColor: Colors.blue,
          ),
        );
      }
      
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
