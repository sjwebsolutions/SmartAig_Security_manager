import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:security_manager/api_service/visitor_service.dart';
import 'package:security_manager/models/visitor_model.dart';
import 'package:security_manager/utils.dart';
import 'package:security_manager/view/screens/visitor_check_in_screen.dart';
import 'package:security_manager/view_models/auth_controller.dart';

class VisitorController extends GetxController {
  final VisitorService _service = VisitorService();

  // Loading States
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isFetchingLocation = false.obs;
  final RxString locationStatusText = ''.obs;

  // Data
  final RxList<Visitor> visitors = <Visitor>[].obs;

  // Form Controllers
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final whatsappController = TextEditingController();
  final purposeController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();

  // Dropdown Options
  final List<String> visitorTypes = [
    'other',
    'parent',
  ];

  final List<String> visitTypes = [
    'normal',
  ];

  // Selected State
  final RxString selectedVisitorType = 'other'.obs;
  final RxString selectedVisitType = 'normal'.obs;
  final RxBool isSameAsMobile = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchVisitors();
  }

  @override
  void onClose() {
    nameController.dispose();
    mobileController.dispose();
    whatsappController.dispose();
    purposeController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.onClose();
  }

  void toggleSameAsMobile(bool? value) {
    isSameAsMobile.value = value ?? false;
    if (isSameAsMobile.value) {
      whatsappController.text = mobileController.text;
    }
  }

  void resetForm() {
    nameController.clear();
    mobileController.clear();
    whatsappController.clear();
    purposeController.clear();
    latitudeController.clear();
    longitudeController.clear();
    selectedVisitorType.value = 'other';
    selectedVisitType.value = 'normal';
    isSameAsMobile.value = false;
    locationStatusText.value = '';
  }

  Future<void> handleCheckInClick() async {
    resetForm();

    // Check if location services (GPS) are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      final bool? openSettings = await Get.dialog<bool>(
        AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.location_off_rounded, color: Color(0xFFD97706), size: 24),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Turn On Location (GPS)',
                  style: TextStyle(color: Color(0xFF0F172A), fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: const Text(
            'Device location (GPS) is turned off. Please turn it ON to capture visitor check-in location.',
            style: TextStyle(color: Color(0xFF475569), fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                Get.back(result: true);
                await Geolocator.openLocationSettings();
              },
              child: const Text('Turn ON GPS'),
            ),
          ],
        ),
      );

      if (openSettings == true) {
        // User opened location settings, navigate to check-in screen where it will auto-detect on resume
        Get.toNamed('/visitor-check-in'); // or direct navigation
      }
    }

    // Check location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      Get.dialog(
        AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Permission Required', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
          content: const Text(
            'Location permission is permanently denied. Please enable it in App Settings to proceed.',
            style: TextStyle(color: Color(0xFF475569)),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Get.back();
                await Geolocator.openAppSettings();
              },
              child: const Text('App Settings'),
            ),
          ],
        ),
      );
      return;
    }

    // Trigger location fetch
    fetchCurrentLocation();

    // Navigate to check-in screen if not already done
    Get.to(() => const VisitorCheckInScreen());
  }

  Future<void> fetchCurrentLocation({bool showMessage = false}) async {
    isFetchingLocation.value = true;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (showMessage) {
          await Geolocator.openLocationSettings();
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (showMessage) {
            App.showSnackBar(
              title: 'Permission Denied',
              message: 'Location permissions are denied.',
              isError: true,
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (showMessage) {
          Get.snackbar(
            'Permission Denied',
            'Location permission is permanently denied. Please enable it in Settings.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade800,
            colorText: Colors.white,
            margin: const EdgeInsets.all(12),
            duration: const Duration(seconds: 4),
            mainButton: TextButton(
              onPressed: () => Geolocator.openAppSettings(),
              child: const Text(
                'SETTINGS',
                style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold),
              ),
            ),
          );
          await Geolocator.openAppSettings();
        }
        return;
      }

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 8),
          ),
        );
      } catch (_) {
        position = await Geolocator.getLastKnownPosition();
      }

      if (position != null) {
        latitudeController.text = position.latitude.toStringAsFixed(6);
        longitudeController.text = position.longitude.toStringAsFixed(6);
        locationStatusText.value =
            '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
        if (showMessage) {
          App.showSnackBar(
            title: 'Location Detected',
            message: 'Latitude and Longitude auto-filled successfully.',
          );
        }
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    } finally {
      isFetchingLocation.value = false;
    }
  }

  Future<void> fetchVisitors() async {
    String token = AuthController.authToken;
    if (token.isEmpty) {
      final savedToken = await TokenManager.getToken();
      if (savedToken != null && savedToken.isNotEmpty) {
        AuthController.authToken = savedToken;
        token = savedToken;
      }
    }

    if (token.isEmpty) {
      App.showSnackBar(
        title: 'Session Expired',
        message: 'Please login again.',
        isError: true,
      );
      return;
    }

    isLoading.value = true;

    try {
      final response = await _service.getVisitors(token);
      if (response.success) {
        visitors.assignAll(response.data);
      } else {
        App.showSnackBar(
          title: 'Error',
          message: response.message ?? 'Failed to load visitors',
          isError: true,
        );
      }
    } catch (e) {
      App.showSnackBar(
        title: 'Error',
        message: e.toString().replaceAll('Exception: ', ''),
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createVisitor() async {
    if (isSubmitting.value) return false;

    final name = nameController.text.trim();
    final mobile = mobileController.text.trim();
    final whatsapp = whatsappController.text.trim();
    final purpose = purposeController.text.trim();
    final visitorType = selectedVisitorType.value.trim();
    final visitType = selectedVisitType.value.trim();

    // Validation
    if (name.isEmpty) {
      App.showSnackBar(
        title: 'Validation Error',
        message: 'Please enter visitor name',
        isError: true,
      );
      return false;
    }

    if (mobile.isEmpty || mobile.length < 10) {
      App.showSnackBar(
        title: 'Validation Error',
        message: 'Please enter a valid 10-digit mobile number',
        isError: true,
      );
      return false;
    }

    if (whatsapp.isEmpty || whatsapp.length < 10) {
      App.showSnackBar(
        title: 'Validation Error',
        message: 'Please enter a valid 10-digit WhatsApp number',
        isError: true,
      );
      return false;
    }

    if (purpose.isEmpty) {
      App.showSnackBar(
        title: 'Validation Error',
        message: 'Please enter purpose of visit',
        isError: true,
      );
      return false;
    }

    String token = AuthController.authToken;
    if (token.isEmpty) {
      final savedToken = await TokenManager.getToken();
      if (savedToken != null && savedToken.isNotEmpty) {
        AuthController.authToken = savedToken;
        token = savedToken;
      }
    }

    if (token.isEmpty) {
      App.showSnackBar(
        title: 'Session Expired',
        message: 'Please login again.',
        isError: true,
      );
      return false;
    }

    double? lat;
    if (latitudeController.text.trim().isNotEmpty) {
      lat = double.tryParse(latitudeController.text.trim());
    }

    double? lng;
    if (longitudeController.text.trim().isNotEmpty) {
      lng = double.tryParse(longitudeController.text.trim());
    }

    if (lat == null || lng == null) {
      try {
        Position? lastPos = await Geolocator.getLastKnownPosition();
        if (lastPos != null) {
          lat ??= lastPos.latitude;
          lng ??= lastPos.longitude;
        }
      } catch (_) {}
    }

    final request = CreateVisitorRequestModel(
      name: name,
      mobileNo: mobile,
      whatsappNo: whatsapp,
      visitorType: visitorType,
      purposeOfVisit: purpose,
      visitType: visitType,
      latitude: lat,
      longitude: lng,
    );

    isSubmitting.value = true;

    try {
      final response = await _service.createVisitor(
        token: token,
        request: request,
      );

      if (response.success) {
        if (response.data != null) {
          visitors.insert(0, response.data!);
        } else {
          await fetchVisitors();
        }

        resetForm();
        return true;
      } else {
        App.showSnackBar(
          title: 'Error',
          message: response.message.isNotEmpty
              ? response.message
              : 'Failed to create visitor entry',
          isError: true,
        );
        return false;
      }
    } catch (e) {
      App.showSnackBar(
        title: 'Error',
        message: e.toString().replaceAll('Exception: ', ''),
        isError: true,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
