import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../shared/theme/modern_design_system.dart';
import '../../../shared/widgets/micro_interactions.dart';
import '../../domain/services/mr_location_service.dart';
import '../../domain/entities/mr_location.dart';

/// Medical Representative Visit Log Screen
/// Captures mandatory high-accuracy GPS coordinates before allowing visit submission
class VisitLogScreen extends StatefulWidget {
  const VisitLogScreen({Key? key}) : super(key: key);

  @override
  _VisitLogScreenState createState() => _VisitLogScreenState();
}

class _VisitLogScreenState extends State<VisitLogScreen> with TickerProviderStateMixin {
  late MRLocationService _locationService;
  final _formKey = GlobalKey<FormState>();
  final _doctorController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _visitPurposeController = TextEditingController();
  final _notesController = TextEditingController();
  final _photoController = TextEditingController();
  
  MRLocation? _currentLocation;
  bool _isLocationCaptured = false;
  bool _isLocationHighAccuracy = false;
  bool _isSubmitting = false;
  List<String> _capturedPhotos = [];
  DateTime? _visitStartTime;
  Timer? _locationCheckTimer;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _visitStartTime = DateTime.now();
    _startLocationMonitoring();
  }

  @override
  void dispose() {
    _locationCheckTimer?.cancel();
    _doctorController.dispose();
    _hospitalController.dispose();
    _specialtyController.dispose();
    _visitPurposeController.dispose();
    _notesController.dispose();
    _photoController.dispose();
    super.dispose();
  }

  Future<void> _initializeServices() async {
    _locationService = MRLocationService(/* repository */);
    await _locationService.initialize();
    
    // Listen to location updates
    _locationService.locationStream.listen((location) {
      if (mounted) {
        setState(() {
          _currentLocation = location;
          _isLocationCaptured = true;
          _isLocationHighAccuracy = location.isHighAccuracy;
        });
      }
    });
  }

  void _startLocationMonitoring() {
    _locationCheckTimer?.cancel();
    _locationCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_currentLocation != null && !_isLocationHighAccuracy) {
        // Check if we can get a better location
        final betterLocation = await _locationService._getCurrentHighAccuracyLocation();
        if (betterLocation != null && betterLocation.accuracy < _currentLocation!.accuracy) {
          setState(() {
            _currentLocation = MRLocation.fromPosition(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              mrId: 'current',
              position: betterLocation,
            );
            _isLocationHighAccuracy = true;
          });
        }
      }
    });
  }

  Future<void> _captureCurrentLocation() async {
    try {
      setState(() => _isSubmitting = true);
      
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
        timeLimit: const Duration(seconds: 30),
      );
      
      final location = MRLocation.fromPosition(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        mrId: 'visit',
        position: position,
      );
      
      setState(() {
        _currentLocation = location;
        _isLocationCaptured = true;
        _isLocationHighAccuracy = location.isHighAccuracy;
        _isSubmitting = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Location captured: ${location.getFormattedAccuracy()}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: location.isHighAccuracy 
              ? ModernDesignSystem.successColor 
              : ModernDesignSystem.warningColor,
          duration: const Duration(seconds: 3),
        ),
      );
      
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to capture location: $e'),
          backgroundColor: ModernDesignSystem.errorColor,
        ),
      );
    }
  }

  Future<void> _capturePhoto() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 768,
      );
      
      if (image != null) {
        setState(() {
          _capturedPhotos.add(image.path);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Photo captured successfully'),
            backgroundColor: ModernDesignSystem.successColor,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to capture photo: $e'),
          backgroundColor: ModernDesignSystem.errorColor,
        ),
      );
    }
  }

  Future<void> _submitVisit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (!_isLocationCaptured) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please capture GPS location first'),
          backgroundColor: ModernDesignSystem.errorColor,
        ),
      );
      return;
    }
    
    if (!_isLocationHighAccuracy) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location accuracy is poor. Please try again.'),
          backgroundColor: ModernDesignSystem.errorColor,
        ),
      );
      return;
    }
    
    if (_capturedPhotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please capture at least one photo'),
          backgroundColor: ModernDesignSystem.errorColor,
        ),
      );
      return;
    }
    
    try {
      setState(() => _isSubmitting = true);
      
      // Create visit record
      final visitData = {
        'mr_id': 'current',
        'doctor_name': _doctorController.text,
        'hospital_name': _hospitalController.text,
        'specialty': _specialtyController.text,
        'visit_purpose': _visitPurposeController.text,
        'notes': _notesController.text,
        'latitude': _currentLocation!.latitude,
        'longitude': _currentLocation!.longitude,
        'accuracy': _currentLocation!.accuracy,
        'altitude': _currentLocation!.altitude,
        'timestamp': DateTime.now().toIso8601String(),
        'visit_start_time': _visitStartTime?.toIso8601String(),
        'photos': _capturedPhotos,
        'location_quality': _isLocationHighAccuracy ? 'high' : 'low',
        'is_high_accuracy': _isLocationHighAccuracy,
      };
      
      // Save visit record
      await _saveVisitRecord(visitData);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Visit submitted successfully'),
          backgroundColor: ModernDesignSystem.successColor,
        ),
      );
      
      // Reset form
      _resetForm();
      
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit visit: $e'),
          backgroundColor: ModernDesignSystem.errorColor,
        ),
      );
    }
  }

  Future<void> _saveVisitRecord(Map<String, dynamic> visitData) async {
    // This would save to the database
    print('Saving visit record: $visitData');
    // Implementation would go here
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _doctorController.clear();
    _hospitalController.clear();
    _specialtyController.clear();
    _visitPurposeController.clear();
    _notesController.clear();
    _photoController.clear();
    _capturedPhotos.clear();
    _visitStartTime = DateTime.now();
    
    setState(() {
      _currentLocation = null;
      _isLocationCaptured = false;
      _isLocationHighAccuracy = false;
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernDesignSystem.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Visit Log',
          style: ModernDesignSystem.headlineSmall.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: ModernDesignSystem.primaryColor,
        elevation: 0,
        actions: [
          AnimatedButton(
            text: 'Reset',
            onPressed: _resetForm,
            showScale: true,
            backgroundColor: ModernDesignSystem.secondaryColor,
            textColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLocationCard(),
              const SizedBox(height: 16),
              _buildVisitDetailsCard(),
              const SizedBox(height: 16),
              _buildPhotoCard(),
              const SizedBox(height: 16),
              _buildNotesCard(),
              const SizedBox(height: 24),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernDesignSystem.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: ModernDesignSystem.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: _isLocationCaptured 
                    ? ModernDesignSystem.successColor 
                    : ModernDesignSystem.textSecondaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'GPS Location Capture',
                style: ModernDesignSystem.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_currentLocation != null) ...[
            Row(
              children: [
                Icon(
                  Icons.gps_fixed,
                  color: _isLocationHighAccuracy 
                      ? ModernDesignSystem.successColor 
                      : ModernDesignSystem.warningColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Coordinates: ${_currentLocation!.getFormattedLocation()}',
                  style: ModernDesignSystem.bodyMedium.copyWith(
                    color: _isLocationHighAccuracy 
                        ? ModernDesignSystem.successColor 
                        : ModernDesignSystem.warningColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.speed,
                  color: ModernDesignSystem.textSecondaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Accuracy: ${_currentLocation!.getFormattedAccuracy()}',
                  style: ModernDesignSystem.bodyMedium.copyWith(
                    color: _isLocationHighAccuracy 
                        ? ModernDesignSystem.successColor 
                        : ModernDesignSystem.warningColor,
                  ),
                ),
              ],
            ),
            if (_currentLocation!.altitude > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.height,
                    color: ModernDesignSystem.textSecondaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Altitude: ${_currentLocation!.altitude.toStringAsFixed(1)}m',
                    style: ModernDesignSystem.bodyMedium.copyWith(
                      color: ModernDesignSystem.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ] else ...[
            Row(
              children: [
                Icon(
                  Icons.location_searching,
                  color: ModernDesignSystem.warningColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Location not captured',
                  style: ModernDesignSystem.bodyMedium.copyWith(
                    color: ModernDesignSystem.warningColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedButton(
              text: _isLocationCaptured ? 'Recapture Location' : 'Capture Location',
              onPressed: _captureCurrentLocation,
              showScale: true,
              showShimmer: !_isLocationCaptured,
              backgroundColor: _isLocationCaptured 
                  ? ModernDesignSystem.secondaryColor 
                  : ModernDesignSystem.primaryColor,
              isLoading: _isSubmitting,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVisitDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernDesignSystem.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: ModernDesignSystem.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Visit Details',
            style: ModernDesignSystem.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _doctorController,
            decoration: InputDecoration(
              labelText: 'Doctor Name',
              hintText: 'Enter doctor name',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: ModernDesignSystem.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: ModernDesignSystem.primaryColor, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter doctor name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _hospitalController,
            decoration: InputDecoration(
              labelText: 'Hospital/Clinic Name',
              hintText: 'Enter hospital or clinic name',
              prefixIcon: const Icon(Icons.local_hospital),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: ModernDesignSystem.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: ModernDesignSystem.primaryColor, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter hospital name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _specialtyController,
            decoration: InputDecoration(
              labelText: 'Specialty',
              hintText: 'Enter medical specialty',
              prefixIcon: const Icon(Icons.medical_services),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: ModernDesignSystem.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: ModernDesignSystem.primaryColor, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter specialty';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _visitPurposeController,
            decoration: InputDecoration(
              labelText: 'Visit Purpose',
              hintText: 'Enter purpose of visit',
              prefixIcon: const Icon(Icons.assignment),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: ModernDesignSystem.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: ModernDesignSystem.primaryColor, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter visit purpose';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernDesignSystem.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: ModernDesignSystem.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.photo_camera,
                color: ModernDesignSystem.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Visit Photos',
                style: ModernDesignSystem.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${_capturedPhotos.length}/5',
                style: ModernDesignSystem.bodyMedium.copyWith(
                  color: _capturedPhotos.length >= 1 
                      ? ModernDesignSystem.successColor 
                      : ModernDesignSystem.textSecondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_capturedPhotos.isEmpty) ...[
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: ModernDesignSystem.backgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ModernDesignSystem.borderColor),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate,
                    color: ModernDesignSystem.textSecondaryColor,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No photos captured',
                    style: ModernDesignSystem.bodyMedium.copyWith(
                      color: ModernDesignSystem.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedButton(
              text: 'Capture Photo',
              onPressed: _capturePhoto,
              showScale: true,
              backgroundColor: ModernDesignSystem.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ] else ...[
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _capturedPhotos.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: ModernDesignSystem.backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: ModernDesignSystem.borderColor),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.file(
                        File(_capturedPhotos[index]),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) {
                          return Container(
                            color: ModernDesignSystem.backgroundColor,
                            child: Icon(
                              Icons.broken_image,
                              color: ModernDesignSystem.textSecondaryColor,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernDesignSystem.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: ModernDesignSystem.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.note,
                color: ModernDesignSystem.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Additional Notes',
                style: ModernDesignSystem.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _notesController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Notes',
              hintText: 'Enter additional notes about the visit',
              prefixIcon: const Icon(Icons.note_add),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: ModernDesignSystem.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: ModernDesignSystem.primaryColor, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return AnimatedButton(
      text: 'Submit Visit',
      onPressed: _isSubmitting ? null : _submitVisit,
      showScale: true,
      showShimmer: true,
      backgroundColor: _isLocationCaptured && _isLocationHighAccuracy && _capturedPhotos.isNotEmpty
          ? ModernDesignSystem.successColor 
          : ModernDesignSystem.textSecondaryColor,
      textColor: _isLocationCaptured && _isLocationHighAccuracy && _capturedPhotos.isNotEmpty
          ? Colors.white 
          : ModernDesignSystem.textSecondaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      borderRadius: 12,
    );
  }
}
