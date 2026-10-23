import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:security_manager/api_service/dashboard_service.dart';
import 'package:security_manager/api_service/support_service.dart';
import 'package:security_manager/api_service/policy_service.dart';
import 'package:security_manager/models/attendance_model.dart';
import 'package:security_manager/models/dashboard_model.dart';
import 'package:security_manager/models/support_model.dart';
import 'package:security_manager/models/policy_model.dart';
import 'package:security_manager/utils.dart';
import 'package:security_manager/view_models/auth_controller.dart';
import 'package:security_manager/view/screens/auth/login_screen.dart';
import 'package:security_manager/view/screens/qr_scanner_screen.dart';

class DashboardController extends GetxController {
  final DashboardService _service = DashboardService();
  final SupportService _supportService = SupportService();
  final PolicyService _policyService = PolicyService();

  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxBool isSupportLoading = false.obs;
  final RxBool isPolicyLoading = false.obs;
  final Rxn<DashboardData> dashboardData = Rxn<DashboardData>();
  final Rxn<SupportData> supportData = Rxn<SupportData>();
  final Rxn<PolicyData> policyData = Rxn<PolicyData>();

  // Attendance states
  final RxBool isClockedIn = false.obs;
  final RxString clockInTime = ''.obs;
  final RxString clockOutTime = ''.obs;
  final RxString attendanceStatus = ''.obs;
  final Rxn<DateTime> clockInDateTime = Rxn<DateTime>();
  final RxBool isAttendanceLoading = false.obs;
  final RxBool isFetchingLocation = false.obs;
  final Rxn<Position> currentPosition = Rxn<Position>();
  final TextEditingController qrTokenController =
      TextEditingController(text: 'bfe63785-e1ac-4ae2-9ae5-44a087e02e0b');
  final RxString locationStatus = 'Fetching location...'.obs;

  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
    initBackgroundLocation();
  }

  @override
  void onClose() {
    _positionStreamSubscription?.cancel();
    qrTokenController.dispose();
    super.onClose();
  }

  Future<void> initBackgroundLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        locationStatus.value = 'GPS disabled';
        currentPosition.value = null;
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        locationStatus.value = 'Location permission denied';
        currentPosition.value = null;
        return;
      }

      Position? lastPos = await Geolocator.getLastKnownPosition();
      if (lastPos != null) {
        currentPosition.value = lastPos;
        locationStatus.value =
            '${lastPos.latitude.toStringAsFixed(6)}, ${lastPos.longitude.toStringAsFixed(6)}';
      }

      fetchCurrentLocation(showMessage: false);

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        const LocationSettings locationSettings = LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        );

        _positionStreamSubscription?.cancel();
        _positionStreamSubscription = Geolocator.getPositionStream(
          locationSettings: locationSettings,
        ).listen(
          (Position position) {
            currentPosition.value = position;
            locationStatus.value =
                '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
          },
          onError: (_) {
            locationStatus.value = 'GPS disabled or unavailable';
          },
        );
      }
    } catch (_) {}
  }

  Future<Position?> fetchCurrentLocation({bool showMessage = false}) async {
    isFetchingLocation.value = true;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        locationStatus.value = 'GPS disabled';
        currentPosition.value = null;
        if (showMessage) {
          App.showSnackBar(
            title: 'GPS Service Disabled',
            message: 'Please turn ON Location/GPS on your device.',
            isError: true,
          );
        }
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          locationStatus.value = 'Location permission denied';
          currentPosition.value = null;
          if (showMessage) {
            App.showSnackBar(
              title: 'Permission Denied',
              message: 'Location permission is required to proceed.',
              isError: true,
            );
          }
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        locationStatus.value = 'Permission permanently denied';
        currentPosition.value = null;
        if (showMessage) {
          App.showSnackBar(
            title: 'Permission Denied',
            message: 'Location permission is permanently denied. Please enable it in Settings.',
            isError: true,
          );
          await Geolocator.openAppSettings();
        }
        return null;
      }

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 3),
          ),
        );
      } catch (_) {
        position = await Geolocator.getLastKnownPosition();
      }

      if (position != null) {
        currentPosition.value = position;
        locationStatus.value =
            '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
        if (showMessage) {
          App.showSnackBar(
            title: 'Location Updated',
            message: 'Location captured successfully.',
          );
        }
        return position;
      } else {
        if (currentPosition.value == null) {
          locationStatus.value = 'Unable to fetch location';
        }
        if (showMessage) {
          App.showSnackBar(
            title: 'Location Error',
            message: 'Could not fetch current location. Please try again.',
            isError: true,
          );
        }
      }
    } catch (e) {
      locationStatus.value = 'Error fetching location';
    } finally {
      isFetchingLocation.value = false;
    }
    return currentPosition.value;
  }

  String _formatTime(DateTime dt) {
    final localDt = dt.toLocal();
    int hour = localDt.hour;
    final minute = localDt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    if (hour == 0) hour = 12;
    final hourStr = hour.toString().padLeft(2, '0');
    return '$hourStr:$minute $period';
  }

  String formatDisplayTime(String rawTime) {
    final trimmed = rawTime.trim();
    if (trimmed.isEmpty) return '';
    try {
      if (trimmed.contains('T') || trimmed.contains('-') || trimmed.contains('/')) {
        final parsed = DateTime.parse(trimmed.replaceAll('/', '-')).toLocal();
        return _formatTime(parsed);
      }
      if (RegExp(r'^\d{1,2}:\d{2}(:\d{2})?').hasMatch(trimmed)) {
        final parts = trimmed.split(':');
        int hour = int.parse(parts[0]);
        final minute = parts[1];
        final period = hour >= 12 ? 'PM' : 'AM';
        hour = hour % 12;
        if (hour == 0) hour = 12;
        return '${hour.toString().padLeft(2, '0')}:$minute $period';
      }
    } catch (_) {}
    return rawTime;
  }

  Future<void> openScannerIfLocationEnabled(String action) async {
    // 1. Check Location/GPS Service state before opening scanner
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      App.showSnackBar(
        title: 'Location / GPS Disabled',
        message: 'Please turn ON Location/GPS on your device to scan QR.',
        isError: true,
      );
      return;
    }

    // 2. Check Location Permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      App.showSnackBar(
        title: 'Location Permission Denied',
        message: 'Location permission is required to mark attendance.',
        isError: true,
      );
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      App.showSnackBar(
        title: 'Permission Denied',
        message: 'Location permission is permanently denied. Please enable it in Settings.',
        isError: true,
      );
      return;
    }

    // 3. Open scanner if location is enabled
    Get.to(() => QrScannerScreen(action: action));
  }

  Future<void> clockAttendance(String action) async {
    String token = AuthController.authToken;
    if (token.isEmpty) {
      final savedToken = await TokenManager.getToken();
      if (savedToken != null && savedToken.isNotEmpty) {
        token = savedToken;
        AuthController.authToken = savedToken;
      }
    }

    if (token.isEmpty) {
      App.showSnackBar(
        title: 'Auth Error',
        message: 'Your session has expired. Please log in again.',
        isError: true,
      );
      return;
    }

    final qrToken = qrTokenController.text.trim();
    if (qrToken.isEmpty) {
      App.showSnackBar(
        title: 'QR Token Missing',
        message: 'Please enter or scan a valid QR token.',
        isError: true,
      );
      return;
    }

    if (action == 'clock_out' && clockInDateTime.value != null) {
      final elapsedSeconds = DateTime.now().difference(clockInDateTime.value!).inSeconds;
      if (elapsedSeconds < 120) {
        final remainingSec = 120 - elapsedSeconds;
        final remainingMin = (remainingSec / 60).ceil();
        App.showSnackBar(
          title: 'Please Wait',
          message: 'Please wait $remainingMin minute(s) before Clock Out.',
          isError: true,
        );
        return;
      }
    }

    // 1. Check Location/GPS Service state before clocking
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      App.showSnackBar(
        title: 'Location / GPS Disabled',
        message: 'Please turn ON Location/GPS on your device to mark attendance.',
        isError: true,
      );
      return;
    }

    // 2. Check Location Permission with real native system dialog
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      App.showSnackBar(
        title: 'Location Permission Denied',
        message: 'Location permission is required to mark attendance.',
        isError: true,
      );
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      App.showSnackBar(
        title: 'Permission Denied',
        message: 'Location permission is permanently denied. Please enable it in Settings.',
        isError: true,
      );
      await Geolocator.openAppSettings();
      return;
    }

    isAttendanceLoading.value = true;
    try {
      Position? position = currentPosition.value;
      if (position == null) {
        position = await fetchCurrentLocation(showMessage: false);
      } else {
        fetchCurrentLocation(showMessage: false);
      }

      if (position == null) {
        App.showSnackBar(
          title: 'Location Error',
          message: 'Unable to detect current GPS location. Please turn ON location/GPS and try again.',
          isError: true,
        );
        return;
      }

      final double lat = position.latitude;
      final double lng = position.longitude;

      final request = AttendanceClockRequestModel(
        qrToken: qrToken,
        latitude: lat,
        longitude: lng,
        action: action,
      );

      final response = await _service.clockAttendance(token: token, request: request);

      if (response.success) {
        final now = DateTime.now();

        if (response.data != null) {
          final clockData = response.data!;
          if (clockData.clockIn != null && clockData.clockIn!.isNotEmpty) {
            clockInTime.value = formatDisplayTime(clockData.clockIn!);
          }
          if (clockData.clockOut != null && clockData.clockOut!.isNotEmpty) {
            clockOutTime.value = formatDisplayTime(clockData.clockOut!);
          }
          if (clockData.status != null && clockData.status!.isNotEmpty) {
            attendanceStatus.value = clockData.status!.toLowerCase();
          }
        }

        if (action == 'clock_in') {
          isClockedIn.value = true;
          if (clockInTime.value.isEmpty) {
            clockInTime.value = _formatTime(now);
          }
          if (attendanceStatus.value.isEmpty) {
            attendanceStatus.value = 'present';
          }
          clockInDateTime.value = now;
        } else if (action == 'clock_out') {
          isClockedIn.value = false;
          if (clockOutTime.value.isEmpty) {
            clockOutTime.value = _formatTime(now);
          }
          attendanceStatus.value = 'clocked_out';
        }

        App.showSnackBar(
          title: 'Success',
          message: response.message.isNotEmpty
              ? response.message
              : '${action == 'clock_in' ? 'Clock In' : 'Clock Out'} successful!',
        );
        // Refresh dashboard statistics and attendance state
        await fetchDashboardData();
      } else {
        App.showSnackBar(
          title: 'Attendance Failed',
          message: response.message.isNotEmpty ? response.message : 'Something went wrong.',
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
      isAttendanceLoading.value = false;
    }
  }

  Future<void> fetchDashboardData({bool isUserRefresh = false}) async {
    String token = AuthController.authToken;
    if (token.isEmpty) {
      final savedToken = await TokenManager.getToken();
      if (savedToken != null && savedToken.isNotEmpty) {
        token = savedToken;
        AuthController.authToken = savedToken;
      }
    }

    if (token.isEmpty) {
      isLoading.value = false;
      if (dashboardData.value == null) {
        hasError.value = true;
      }
      App.showSnackBar(
        title: 'Session Expired',
        message: 'Please login again to continue.',
        isError: true,
      );
      logout();
      return;
    }

    isLoading.value = true;
    hasError.value = false;

    try {
      final response = await _service.getDashboard(token);

      if (response.success) {
        dashboardData.value = response.data;
        if (response.data != null) {
          final data = response.data!;
          final rawStatus = data.attendanceStatus?.toLowerCase() ?? '';
          final rawInTime = data.clockInTime ?? '';
          final rawOutTime = data.clockOutTime ?? '';
          final apiClockedIn = data.isClockedIn;

          // Directly sync UI states strictly with the API response
          clockInTime.value = rawInTime.isNotEmpty ? formatDisplayTime(rawInTime) : '';
          clockOutTime.value = rawOutTime.isNotEmpty ? formatDisplayTime(rawOutTime) : '';
          attendanceStatus.value = rawStatus;

          if (rawOutTime.isNotEmpty || rawStatus == 'clocked_out' || rawStatus == 'clock_out') {
            isClockedIn.value = false;
            attendanceStatus.value = 'clocked_out';
          } else if (rawInTime.isNotEmpty || rawStatus == 'present' || rawStatus == 'clock_in' || rawStatus == 'clocked_in') {
            isClockedIn.value = true;
            attendanceStatus.value = 'present';
          } else if (apiClockedIn != null) {
            isClockedIn.value = apiClockedIn;
          } else {
            isClockedIn.value = false;
          }
        }
        hasError.value = false;
      } else {
        if (dashboardData.value == null) {
          hasError.value = true;
        }
        if (isUserRefresh) {
          App.showSnackBar(
            title: 'Error',
            message: 'Failed to load dashboard data.',
            isError: true,
          );
        }
      }
    } catch (e) {
      if (dashboardData.value == null) {
        hasError.value = true;
      }
      if (isUserRefresh) {
        String errorMessage = e.toString().replaceAll('Exception: ', '');
        if (errorMessage.contains('SocketException')) {
          errorMessage = 'No internet connection. Please check your network.';
        }
        App.showSnackBar(
          title: 'Error',
          message: errorMessage,
          isError: true,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchSupportData() async {
    final token = AuthController.authToken;
    if (token.isEmpty) {
      App.showSnackBar(
        title: 'Auth Error',
        message: 'Your session has expired. Please log in again.',
        isError: true,
      );
      return;
    }

    isSupportLoading.value = true;
    try {
      final response = await _supportService.getSupportSettings(token);
      if (response.success) {
        supportData.value = response.data;
      } else {
        App.showSnackBar(
          title: 'Fetch Failed',
          message: 'Server was unable to provide support information.',
          isError: true,
        );
      }
    } catch (e) {
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      if (errorMessage.contains('SocketException')) {
        errorMessage = 'No internet connection. Please check your network.';
      }
      App.showSnackBar(
        title: 'Network Error',
        message: errorMessage,
        isError: true,
      );
    } finally {
      isSupportLoading.value = false;
    }
  }

  Future<void> fetchPolicyData() async {
    final token = AuthController.authToken;
    if (token.isEmpty) return;

    isPolicyLoading.value = true;
    try {
      final response = await _policyService.getPolicies(token);
      if (response.success) {
        policyData.value = response.data;
      }
    } catch (e) {
      App.showSnackBar(
        title: 'Error',
        message: 'Could not load policy information.',
        isError: true,
      );
    } finally {
      isPolicyLoading.value = false;
    }
  }

  void logout() async {
    AuthController.authToken = '';
    await TokenManager.clearToken();
    isClockedIn.value = false;
    clockInTime.value = '';
    clockOutTime.value = '';
    attendanceStatus.value = '';
    clockInDateTime.value = null;
    dashboardData.value = null;
    App.showSnackBar(
      title: 'Success',
      message: 'You have been logged out successfully',
    );
    Get.offAll(() => const LoginScreen());
  }
}
