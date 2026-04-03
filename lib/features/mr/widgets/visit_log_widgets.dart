import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';
import 'package:vedanta_trade/shared/widgets/glassmorphic_widgets.dart';

/// GPS Loading Dialog for high-accuracy location capture
class GpsLoadingDialog extends StatefulWidget {
  const GpsLoadingDialog({Key? key}) : super(key: key);

  @override
  State<GpsLoadingDialog> createState() => _GpsLoadingDialogState();
}

class GpsLoadingDialogState extends State<GpsLoadingDialog> with SingleTickerProviderStateMixin {
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
      if (mounted) {
        setState(() {
          _dots = (_dots + 1) % 4;
        });
      }
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
      child: Center(
        child: GlassmorphicCard(
          width: 300,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // GPS Icon with animation
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _animation.value * 2 * 3.14159,
                    child: Icon(
                      Icons.gps_fixed,
                      color: AppTheme.primary,
                      size: 48,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              
              // Loading text with animated dots
              Text(
                'Acquiring GPS Location' + '.' * _dots,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              // Accuracy requirement
              Text(
                'Target: < 50 meters accuracy',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Progress indicator
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.cardColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: LinearProgressIndicator(
                  value: _animation.value,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Enhanced Visit Log Modal with GPS validation
class LogVisitModal extends StatefulWidget {
  final VoidCallback onSuccess;
  final Future<Position?> Function() getCurrentLocation;

  const LogVisitModal({
    Key? key,
    required this.onSuccess,
    required this.getCurrentLocation,
  }) : super(key: key);

  @override
  State<LogVisitModal> createState() => LogVisitModalState();
}

class LogVisitModalState extends State<LogVisitModal> {
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
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await widget.getCurrentLocation();
      if (mounted && position != null) {
        setState(() {
          _currentPosition = position;
          _gpsValidated = position!.accuracy <= 50.0;
        });
      }
    } catch (e) {
      // Handle location errors
      if (mounted) {
        setState(() {
          _gpsValidated = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _doctorController.dispose();
    _notesController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: AppTheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Log Doctor Visit',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'High-accuracy GPS required for visit validation',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white54),
                ),
              ],
            ),
          ),
          
          // Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // GPS Status Section
                  _buildGpsStatusSection(),
                  const SizedBox(height: 20),
                  
                  // Doctor Section
                  _buildDoctorSection(),
                  const SizedBox(height: 20),
                  
                  // Visit Type Section
                  _buildVisitTypeSection(),
                  const SizedBox(height: 20),
                  
                  // Purpose Section
                  _buildPurposeSection(),
                  const SizedBox(height: 20),
                  
                  // Notes Section
                  _buildNotesSection(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          
          // Submit Button
          Container(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitting || !_gpsValidated ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _gpsValidated ? AppTheme.primary : Colors.grey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Submit Visit',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
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
              TextButton.icon(
                onPressed: _getCurrentLocation,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_currentPosition != null) ...[
            Text(
              'Accuracy: ${_currentPosition!.accuracy.toStringAsFixed(1)}m',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}, Lng: ${_currentPosition!.longitude.toStringAsFixed(6)}',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
              ),
            ),
          ] else ...[
            const Text(
              'Location not available',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
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
              final isSelected = type == _selectedVisitType;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedVisitType = type;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primary : AppTheme.cardColor.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : Colors.white24,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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
        const Text('PURPOSE', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: _purposeController,
          style: const TextStyle(color: Colors.white),
          maxLines: 2,
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
          style: const TextStyle(color: Colors.white),
          maxLines: 4,
          decoration: AppTheme.inputDecoration('Summary of discussion...'),
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    if (!_gpsValidated || _doctorController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      // TODO: Submit to backend API
      // POST /api/mr/visits with:
      // - doctor: _doctorController.text
      // - visitType: _selectedVisitType
      // - purpose: _purposeController.text
      // - notes: _notesController.text
      // - latitude: _currentPosition!.latitude
      // - longitude: _currentPosition!.longitude
      // - accuracy: _currentPosition!.accuracy
      // - timestamp: DateTime.now().toIso8601String()

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.of(context).pop();
        widget.onSuccess();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Visit logged successfully!'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }
}
