import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';
import 'package:vedanta_trade/shared/app_scaffold.dart';
import 'package:vedanta_trade/shared/widgets/glassmorphic_widgets.dart';
import 'package:provider/provider.dart';
import 'package:vedanta_trade/features/auth/presentation/providers/auth_provider.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:vedanta_trade/core/api_config.dart';
import 'package:vedanta_trade/shared/widgets/toast_notification.dart';
import 'package:image_picker/image_picker.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});
  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  List<dynamic> _claims = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
// final headers = {'Authorization': 'Bearer ${auth.token}'}; // TODO: Move to environment variables
      
      final res = await dio.get(
        '${ApiConfig.baseUrl}/mr/expenses',
        options: Options(headers: headers),
      );
      
      if (mounted) {
        setState(() {
          _claims = res.data['data'] ?? [];
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _claims = [];
          _loading = false;
        });
      }
    }
  }

  static const _navItems = [
    NavItem(label: 'Dashboard', icon: Icons.dashboard_rounded, route: '/mr'),
    NavItem(label: 'Doctor Visits', icon: Icons.medical_services_rounded, route: '/mr/visits'),
    NavItem(label: 'Tour Plan', icon: Icons.map_rounded, route: '/mr/tour-plan'),
    NavItem(label: 'Expenses', icon: Icons.receipt_long_rounded, route: '/mr/expenses'),
    NavItem(label: 'Profile', icon: Icons.person_rounded, route: '/profile'),
  ];

  @override
  Widget build(BuildContext context) {
    double totalPending = 0;
    double totalApproved = 0;
    for (var c in _claims) {
      if (c['status'] == 'PENDING') {
        totalPending += (c['amount'] as num).toDouble();
      } else if (c['status'] == 'APPROVED') {
        totalApproved += (c['amount'] as num).toDouble();
      }
    }

    return AppScaffold(
      title: 'Expense Management',
      roleColor: AppTheme.mrColor,
      navItems: _navItems,
      selectedIndex: 3,
      fab: FloatingActionButton.extended(
        onPressed: () => _showAddExpenseDialog(),
        backgroundColor: AppTheme.mrColor,
        icon: const Icon(Icons.add_card_rounded, color: Colors.white),
        label: const Text('Submit Claim', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(child: LoadingAnimation())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fast Stats Grid
                  Row(
                    children: [
                      Expanded(
                        child: GlassmorphicStatCard(
                          title: 'Pending',
                          value: '₹${totalPending.toStringAsFixed(0)}',
                          icon: Icons.pending_actions_rounded,
                          color: AppTheme.warning,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GlassmorphicStatCard(
                          title: 'Approved (MTD)',
                          value: '₹${totalApproved.toStringAsFixed(0)}',
                          icon: Icons.verified_rounded,
                          color: AppTheme.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Expense History
                  const SectionHeader(title: 'Recent Claims'),
                  const SizedBox(height: 12),
                  if (_claims.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(48),
                        child: Text('No claims found', style: TextStyle(color: Colors.white38)),
                      ),
                    )
                  else
                    ...(_claims.map((c) => _ExpenseListItem(claim: c)).toList()),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }

  void _showAddExpenseDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddExpenseModal(onSuccess: () => _loadExpenses()),
    );
  }
}

class _ExpenseListItem extends StatelessWidget {
  final Map<String, dynamic> claim;
  const _ExpenseListItem({required this.claim});

  @override
  Widget build(BuildContext context) {
    final isApproved = claim['status'] == 'APPROVED';
    final date = DateTime.parse(claim['expenseDate']);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassmorphicListItem(
        title: claim['category'] ?? 'Miscellaneous',
        subtitle: '${claim['description']} • ${DateFormat('d MMM').format(date)}',
        leadingIcon: _expenseIcon(claim['category']),
        iconColor: isApproved ? AppTheme.success : AppTheme.warning,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${claim['amount']}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              claim['status'],
              style: TextStyle(
                color: isApproved ? AppTheme.success : AppTheme.warning,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _expenseIcon(String? type) {
    switch (type) {
      case 'TRAVEL': return Icons.directions_car_rounded;
      case 'FOOD': return Icons.restaurant_rounded;
      case 'STAY': return Icons.hotel_rounded;
      case 'MISC': return Icons.more_horiz_rounded;
      default: return Icons.money_rounded;
    }
  }
}

class _AddExpenseModal extends StatefulWidget {
  final VoidCallback onSuccess;
  const _AddExpenseModal({required this.onSuccess});

  @override
  State<_AddExpenseModal> createState() => _AddExpenseModalState();
}

class _AddExpenseModalState extends State<_AddExpenseModal> {
  String _category = 'TRAVEL';
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  DateTime _date = DateTime.now();
  bool _submitting = false;
  final List<XFile> _selectedPhotos = [];
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return GlassmorphicBackground(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.bgDark.withOpacity(0.8),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text(
                  'Submit Claim',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.white38),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView(
                children: [
                  const Text('CATEGORY', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: ['TRAVEL', 'FOOD', 'STAY', 'MISC'].map((c) {
                      final isSelected = _category == c;
                      return ChoiceChip(
                        label: Text(c, style: TextStyle(color: isSelected ? Colors.white : Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
                        selected: isSelected,
                        onSelected: (v) { if (v) setState(() => _category = c); },
                        backgroundColor: Colors.white.withOpacity(0.05),
                        selectedColor: AppTheme.mrColor,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text('AMOUNT (₹)', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                    decoration: AppTheme.inputDecoration('0.00').copyWith(
                      prefixIcon: const Icon(Icons.currency_rupee_rounded, color: AppTheme.mrColor),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('DATE', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context, 
                        initialDate: _date, 
                        firstDate: DateTime.now().subtract(const Duration(days: 30)), 
                        lastDate: DateTime.now(),
                      );
                      if (d != null) setState(() => _date = d);
                    },
                    child: GlassmorphicCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 18, color: AppTheme.mrColor),
                          const SizedBox(width: 12),
                          Text(DateFormat('d MMMM yyyy').format(_date), style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('RECEIPTS', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildPhotoSection(),
                  const SizedBox(height: 24),
                  const Text('REMARKS', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descController,
                    style: const TextStyle(color: Colors.white),
                    decoration: AppTheme.inputDecoration('Description...'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submitting ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.mrColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _submitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'SUBMIT EXPENSE CLAIM',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_amountController.text.isEmpty) {
      context.showError('Please enter an amount');
      return;
    }

    setState(() => _submitting = true);
    
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
// final headers = {'Authorization': 'Bearer ${auth.token}'}; // TODO: Move to environment variables
      
      // Create multipart form data for file uploads
      final formData = FormData.fromMap({
        'category': _category,
        'amount': double.parse(_amountController.text),
        'description': _descController.text,
        'expenseDate': _date.toIso8601String(),
        'status': 'PENDING',
      });
      
      // Add photos if selected
      for (final photo in _selectedPhotos) {
        formData.files.add(MapEntry(
          'receipts',
          await MultipartFile.fromFile(photo.path, filename: photo.name),
        ));
      }
      
      await dio.post(
        '${ApiConfig.baseUrl}/mr/expenses',
        data: formData,
        options: Options(headers: headers),
      );
      
      widget.onSuccess();
      if (mounted) {
        Navigator.pop(context);
        context.showSuccess('Expense claim submitted for approval');
      }
    } catch (e) {
      if (mounted) {
        context.showError('Failed to submit expense claim');
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Photo grid
        if (_selectedPhotos.isNotEmpty) ...[
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedPhotos.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: FileImage(File(_selectedPhotos[index].path)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 12,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPhotos.removeAt(index);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
        
        // Add photo buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickFromCamera,
                icon: const Icon(Icons.camera_alt_rounded, size: 18, color: Colors.white70),
                label: const Text('Camera', style: TextStyle(color: Colors.white70, fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickFromGallery,
                icon: const Icon(Icons.photo_library_rounded, size: 18, color: Colors.white70),
                label: const Text('Gallery', style: TextStyle(color: Colors.white70, fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickFromCamera() async {
    final photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxWidth: 1200,
    );
    if (photo != null) {
      setState(() {
        _selectedPhotos.add(photo);
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final photos = await _picker.pickMultiImage(
      imageQuality: 70,
      maxWidth: 1200,
    );
    if (photos.isNotEmpty) {
      setState(() {
        _selectedPhotos.addAll(photos);
      });
    }
  }
}
