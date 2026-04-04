import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../services/gps_tracking_service.dart';
import '../providers/mr_provider.dart';
import '../../../../shared/theme/enhanced_theme.dart';
import '../../../../shared/widgets/enhanced_ui_kit.dart';

/// Enhanced visit log screen with mandatory GPS coordinates
class EnhancedVisitLogScreen extends StatefulWidget {
  const EnhancedVisitLogScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedVisitLogScreen> createState() => _EnhancedVisitLogScreenState();
}

class _EnhancedVisitLogScreenState extends State<EnhancedVisitLogScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _doctorController = TextEditingController();
  final _notesController = TextEditingController();
  final _medicinesController = TextEditingController();
  
  GPSCoordinate? _currentLocation;
  bool _isCapturingGPS = false;
  bool _isSubmitting = false;
  List<File> _receiptImages = [];
  List<String> _medicines = [];
  double _gpsAccuracy = 0.0;
  bool _isHighAccuracy = false;
  late AnimationController _successController;
  late AnimationController _gpsController;
  
  @override
  void initState() {
    super.initState();
    _successController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _gpsController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    // Initialize GPS capture
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _captureInitialGPS();
    });
  }

  @override
  void dispose() {
    _doctorController.dispose();
    _notesController.dispose();
    _medicinesController.dispose();
    _successController.dispose();
    _gpsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EnhancedTheme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // GPS Status Card
              _buildGPSStatusCard(context),
              const SizedBox(height: 16),
              
              // Doctor Selection
              _buildDoctorSelection(context),
              const SizedBox(height: 16),
              
              // Medicines Section
              _buildMedicinesSection(context),
              const SizedBox(height: 16),
              
              // Notes Section
              _buildNotesSection(context),
              const SizedBox(height: 16),
              
              // Receipt Images
              _buildReceiptImages(context),
              const SizedBox(height: 24),
              
              // Submit Button
              _buildSubmitButton(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Build app bar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return EnhancedAppBar(
      title: 'Visit Log',
      subtitle: 'Mandatory GPS Coordinates Required',
      backgroundColor: EnhancedTheme.of(context).appBarColor,
      actions: [
        IconButton(
          icon: Icon(
            Icons.refresh,
            color: EnhancedTheme.of(context).iconColor,
          ),
          onPressed: _captureInitialGPS,
        ),
      ],
    );
  }

  /// Build GPS status card
  Widget _buildGPSStatusCard(BuildContext context) {
    final hasValidGPS = _currentLocation != null && _gpsAccuracy <= 10.0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasValidGPS 
            ? EnhancedTheme.of(context).primaryColor.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasValidGPS 
              ? EnhancedTheme.of(context).primaryColor
              : Colors.red,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _gpsController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isCapturingGPS ? 1.2 : 1.0,
                    child: Icon(
                      hasValidGPS ? Icons.gps_fixed : Icons.gps_not_fixed,
                      color: hasValidGPS ? Colors.green : Colors.red,
                      size: 24,
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GPS Status',
                      style: TextStyle(
                        color: EnhancedTheme.of(context).textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      hasValidGPS 
                          ? 'High accuracy location captured'
                          : 'Waiting for high accuracy GPS...',
                      style: TextStyle(
                        color: EnhancedTheme.of(context).textColor.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isCapturingGPS)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      EnhancedTheme.of(context).primaryColor,
                    ),
                  ),
                ),
            ],
          ),
          if (_currentLocation != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: EnhancedTheme.of(context).primaryColor,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Location: ${_currentLocation!.latitude.toStringAsFixed(6)}, ${_currentLocation!.longitude.toStringAsFixed(6)}',
                  style: TextStyle(
                    color: EnhancedTheme.of(context).textColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.gps_good,
                  color: _isHighAccuracy ? Colors.green : Colors.orange,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Accuracy: ${_gpsAccuracy.toStringAsFixed(1)}m ${_isHighAccuracy ? '(High)' : '(Standard)'}',
                  style: TextStyle(
                    color: _isHighAccuracy ? Colors.green : Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Build doctor selection
  Widget _buildDoctorSelection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EnhancedTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blur: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Doctor Information',
            style: TextStyle(
              color: EnhancedTheme.of(context).textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          EnhancedTextField(
            controller: _doctorController,
            hintText: 'Search and select doctor...',
            prefixIcon: Icon(
              Icons.person_search,
              color: EnhancedTheme.of(context).iconColor,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a doctor';
              }
              return null;
            },
            onChanged: (value) {
              // Implement doctor search
            },
          ),
        ],
      ),
    );
  }

  /// Build medicines section
  Widget _buildMedicinesSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EnhancedTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blur: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Medicines Discussed',
            style: TextStyle(
              color: EnhancedTheme.of(context).textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          EnhancedTextField(
            controller: _medicinesController,
            hintText: 'Enter medicine name',
            prefixIcon: Icon(
              Icons.medication,
              color: EnhancedTheme.of(context).iconColor,
            ),
            onSubmitted: (value) {
              _addMedicine(value);
            },
          ),
          const SizedBox(height: 12),
          if (_medicines.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _medicines.map((medicine) => Chip(
                label: Text(medicine),
                deleteIcon: Icon(Icons.close, size: 18),
                onDeleted: () => _removeMedicine(medicine),
                backgroundColor: EnhancedTheme.of(context).primaryColor.withOpacity(0.1),
                labelStyle: TextStyle(
                  color: EnhancedTheme.of(context).primaryColor,
                ),
              )).toList(),
            ),
        ],
      ),
    );
  }

  /// Build notes section
  Widget _buildNotesSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EnhancedTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blur: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Visit Notes',
            style: TextStyle(
              color: EnhancedTheme.of(context).textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          EnhancedTextField(
            controller: _notesController,
            hintText: 'Enter visit notes...',
            maxLines: 4,
            prefixIcon: Icon(
              Icons.note,
              color: EnhancedTheme.of(context).iconColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Build receipt images
  Widget _buildReceiptImages(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EnhancedTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blur: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Receipt Images',
            style: TextStyle(
              color: EnhancedTheme.of(context).textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _captureImage,
                icon: Icon(Icons.camera_alt),
                label: Text('Capture Receipt'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: EnhancedTheme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.photo_library),
                label: Text('Gallery'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: EnhancedTheme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_receiptImages.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _receiptImages.map((image) => Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: FileImage(image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: -4,
                    right: -4,
                    child: IconButton(
                      icon: Icon(Icons.close, size: 16),
                      onPressed: () => _removeImage(image),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints.tightFor(width: 24, height: 24),
                      ),
                    ),
                  ),
                ],
              )).toList(),
            ),
        ],
      ),
    );
  }

  /// Build submit button
  Widget _buildSubmitButton(BuildContext context) {
    final hasValidGPS = _currentLocation != null && _gpsAccuracy <= 10.0;
    final hasDoctor = _doctorController.text.isNotEmpty;
    final hasMedicines = _medicines.isNotEmpty;
    
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (hasValidGPS && hasDoctor && hasMedicines && !_isSubmitting)
            ? _submitVisitLog
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: hasValidGPS && hasDoctor && hasMedicines
              ? EnhancedTheme.of(context).primaryColor
              : Colors.grey,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSubmitting
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
                  Text('Submitting...'),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle),
                  const SizedBox(width: 8),
                  Text('Submit Visit Log'),
                ],
              ),
      ),
    );
  }

  /// Capture initial GPS
  Future<void> _captureInitialGPS() async {
    setState(() {
      _isCapturingGPS = true;
    });
    
    _gpsController.repeat(reverse: true);
    
    try {
      // Request location permissions
      final permissions = await [
        Permission.locationWhenInUse,
        Permission.locationAlways,
      ].request();
      
      if (permissions[Permission.locationWhenInUse] != PermissionStatus.granted) {
        _showPermissionDialog();
        return;
      }
      
      // Check if location services are enabled
      final isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isLocationServiceEnabled) {
        _showLocationServiceDialog();
        return;
      }
      
      // Get high accuracy location
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 30),
      );
      
      final coordinate = GPSCoordinate(
        latitude: position.latitude,
        longitude: position.longitude,
        altitude: position.altitude,
        accuracy: position.accuracy,
        timestamp: DateTime.now(),
        speed: position.speed,
        heading: position.heading,
      );
      
      setState(() {
        _currentLocation = coordinate;
        _gpsAccuracy = position.accuracy;
        _isHighAccuracy = position.accuracy <= 5.0;
        _isCapturingGPS = false;
      });
      
      _gpsController.stop();
      
      // Show success animation
      if (_gpsAccuracy <= 10.0) {
        _successController.forward().then((_) {
          _successController.reverse();
        });
      }
      
    } catch (e) {
      setState(() {
        _isCapturingGPS = false;
      });
      _gpsController.stop();
      _showErrorDialog('Failed to capture GPS location: $e');
    }
  }

  /// Add medicine
  void _addMedicine(String medicine) {
    if (medicine.isNotEmpty && !_medicines.contains(medicine)) {
      setState(() {
        _medicines.add(medicine);
        _medicinesController.clear();
      });
    }
  }

  /// Remove medicine
  void _removeMedicine(String medicine) {
    setState(() {
      _medicines.remove(medicine);
    });
  }

  /// Capture image
  Future<void> _captureImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    
    if (image != null) {
      setState(() {
        _receiptImages.add(File(image.path));
      });
    }
  }

  /// Pick image from gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _receiptImages.add(File(image.path));
      });
    }
  }

  /// Remove image
  void _removeImage(File image) {
    setState(() {
      _receiptImages.remove(image);
    });
  }

  /// Submit visit log
  Future<void> _submitVisitLog() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_currentLocation == null || _gpsAccuracy > 10.0) {
      _showErrorDialog('High accuracy GPS location is required to submit visit log');
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      // Create visit log data
      final visitData = {
        'doctor': _doctorController.text,
        'medicines': _medicines,
        'notes': _notesController.text,
        'gpsLocation': {
          'latitude': _currentLocation!.latitude,
          'longitude': _currentLocation!.longitude,
          'accuracy': _currentLocation!.accuracy,
          'timestamp': _currentLocation!.timestamp.toIso8601String(),
        },
        'receiptImages': _receiptImages.map((image) => image.path).toList(),
        'submittedAt': DateTime.now().toIso8601String(),
      };
      
      // Save to local storage for offline sync
      final prefs = await SharedPreferences.getInstance();
      final visitLogs = prefs.getStringList('visit_logs') ?? [];
      visitLogs.add(jsonEncode(visitData));
      await prefs.setStringList('visit_logs', visitLogs);
      
      // Show success animation
      _successController.forward().then((_) {
        _successController.reverse();
      });
      
      // Show success message
      _showSuccessSnackBar('Visit log submitted successfully');
      
      // Clear form
      _clearForm();
      
    } catch (e) {
      _showErrorDialog('Failed to submit visit log: $e');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  /// Clear form
  void _clearForm() {
    _doctorController.clear();
    _notesController.clear();
    _medicinesController.clear();
    setState(() {
      _medicines.clear();
      _receiptImages.clear();
      _currentLocation = null;
      _gpsAccuracy = 0.0;
      _isHighAccuracy = false;
    });
  }

  /// Show permission dialog
  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Location Permission Required'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_off,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Location permission is required to capture GPS coordinates for visit logs. Please enable location access to continue.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text('Settings'),
          ),
        ],
      ),
    );
  }

  /// Show location service dialog
  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Location Services Disabled'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.gps_off,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Location services are disabled. Please enable location services to capture GPS coordinates.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openLocationSettings();
            },
            child: Text('Enable'),
          ),
        ],
      ),
    );
  }

  /// Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show success snack bar
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Lottie.asset(
              'assets/animations/success.json',
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
