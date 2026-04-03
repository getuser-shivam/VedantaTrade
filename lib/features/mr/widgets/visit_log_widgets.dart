import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';

/// GPS Loading Dialog for high-accuracy location capture
class _GpsLoadingDialog extends StatefulWidget {
  const _GpsLoadingDialog();

  @override
  State<_GpsLoadingDialog> createState() => _GpsLoadingDialogState();
}

class _GpsLoadingDialogState extends State<_GpsLoadingDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _dots = 0;
  Timer? _dotsTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat();

    // Animate dots
    _dotsTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        _dots = (_dots + 1) % 4;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _dotsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.cardColor.withOpacity(0.95),
              AppTheme.cardColor.withOpacity(0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.mrColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // GPS Icon Animation
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_animation.value * 0.2),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.mrColor.withOpacity(0.2),
                          AppTheme.mrColor.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      Icons.gps_fixed_rounded,
                      color: AppTheme.mrColor,
                      size: 40,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            
            // Status Text
            Text(
              'Getting GPS Location${'.' * _dots}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            
            // Subtitle
            const Text(
              'Ensuring high accuracy for field operations',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Progress Indicator
            LinearProgressIndicator(
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.mrColor),
            ),
            const SizedBox(height: 8),
            
            // Accuracy Info
            const Text(
              'Target: < 50 meters accuracy',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Enhanced Visit Log Modal with GPS validation
class _LogVisitModal extends StatefulWidget {
  final VoidCallback onSuccess;
  final Future<Position?> Function() getCurrentLocation;

  const _LogVisitModal({
    required this.onSuccess,
    required this.getCurrentLocation,
  });

  @override
  State<_LogVisitModal> createState() => _LogVisitModalState();
}

class _LogVisitModalState extends State<_LogVisitModal> {
  final _doctorController = TextEditingController();
  final _notesController = TextEditingController();
  final _purposeController = TextEditingController();
  String _selectedVisitType = 'Regular';
  bool _submitting = false;
  Position? _currentPosition;
  bool _gpsValidated = false;

  final List<String> _visitTypes = [
    'Regular',
    'Follow-up',
    'Sample Drop',
    'Emergency',
    'Meeting',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.mrColor.withOpacity(0.2),
                        AppTheme.mrColor.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.add_location_alt_rounded, color: AppTheme.mrColor),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Log Doctor Visit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(Icons.close, color: Colors.white54),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // GPS Status Section
                  _buildGpsStatusSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Doctor Selection
                  _buildDoctorSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Visit Type
                  _buildVisitTypeSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Purpose
                  _buildPurposeSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Notes
                  _buildNotesSection(),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          
          // Submit Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (_submitting || !_gpsValidated) ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _gpsValidated ? AppTheme.mrColor : Colors.grey,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _submitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _gpsValidated ? Icons.gps_fixed_rounded : Icons.gps_not_fixed_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _gpsValidated ? 'Submit Visit' : 'GPS Required',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGpsStatusSection() {
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _gpsValidated ? Icons.verified_rounded : Icons.gps_not_fixed_rounded,
                color: _gpsValidated ? AppTheme.success : Colors.white54,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'GPS Location',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              if (!_gpsValidated)
                TextButton(
                  onPressed: _validateGps,
                  style: TextButton.styleFrom(
                    backgroundColor: AppTheme.mrColor.withOpacity(0.2),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh, color: AppTheme.mrColor, size: 16),
                      const SizedBox(width: 4),
                      Text('Get Location', style: TextStyle(color: AppTheme.mrColor, fontSize: 12)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          
          if (_currentPosition != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.success.withOpacity(0.1),
                    AppTheme.success.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: AppTheme.success, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Location Captured',
                          style: TextStyle(
                            color: AppTheme.success,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Accuracy: ${_currentPosition!.accuracy.toStringAsFixed(1)}m',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.withOpacity(0.1),
                    Colors.orange.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_rounded, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GPS Location Required',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'High-accuracy location needed for visit logging',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDoctorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('DOCTOR', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: _doctorController,
          style: const TextStyle(color: Colors.white),
          decoration: AppTheme.inputDecoration('Select or search doctor...'),
        ),
      ],
    );
  }

  Widget _buildVisitTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('VISIT TYPE', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _visitTypes.length,
            itemBuilder: (context, index) {
              final type = _visitTypes[index];
              final isSelected = _selectedVisitType == type;
              
              return GestureDetector(
                onTap: () => setState(() => _selectedVisitType = type),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(colors: [AppTheme.mrColor, AppTheme.mrColor.withOpacity(0.8)])
                        : LinearGradient(colors: [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.02)]),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppTheme.mrColor : Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPurposeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('VISIT PURPOSE', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: _purposeController,
          style: const TextStyle(color: Colors.white),
          decoration: AppTheme.inputDecoration('Purpose of visit...'),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('DISCUSSION NOTES', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 4,
          style: const TextStyle(color: Colors.white),
          decoration: AppTheme.inputDecoration('Summary of discussion...'),
        ),
      ],
    );
  }

  Future<void> _validateGps() async {
    setState(() => _submitting = true);
    
    try {
      final position = await widget.getCurrentLocation();
      if (position != null) {
        setState(() {
          _currentPosition = position;
          _gpsValidated = true;
          _submitting = false;
        });
      }
    } catch (e) {
      setState(() => _submitting = false);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_gpsValidated || _doctorController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please validate GPS and select a doctor'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      // TODO: Submit to backend API
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        Navigator.of(context).pop();
        widget.onSuccess();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Visit logged successfully at ${_currentPosition!.accuracy.toStringAsFixed(1)}m accuracy'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to log visit: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      setState(() => _submitting = false);
    }
  }
}
