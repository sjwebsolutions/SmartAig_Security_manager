import 'package:get/get.dart';
import 'package:security_manager/api_service/student_attendance_service.dart';
import 'package:security_manager/models/student_attendance_model.dart';
import 'package:security_manager/utils.dart';
import 'package:security_manager/view_models/auth_controller.dart';

class StudentAttendanceController extends GetxController {
  final StudentAttendanceService _service = StudentAttendanceService();

  // Observable states
  final RxBool isLoading = false.obs;
  final RxBool isScanning = false.obs;
  final Rxn<StudentAttendanceData> attendanceData = Rxn<StudentAttendanceData>();
  final Rxn<StudentScanResponseModel> lastScanResponse = Rxn<StudentScanResponseModel>();
  final RxString errorMessage = ''.obs;

  // Query Parameters
  final RxString selectedStatus = 'all'.obs;
  final RxString selectedDate = ''.obs; // Format: YYYY-MM-DD

  final List<String> statusOptions = [
    'all',
    'pending',
    'approved',
    'rejected',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchStudentAttendanceInfo();
  }

  Future<void> fetchStudentAttendanceInfo() async {
    String token = AuthController.authToken;
    if (token.isEmpty) {
      final savedToken = await TokenManager.getToken();
      if (savedToken != null && savedToken.isNotEmpty) {
        AuthController.authToken = savedToken;
        token = savedToken;
      }
    }

    if (token.isEmpty) {
      errorMessage.value = 'Session expired. Please login again.';
      App.showSnackBar(
        title: 'Session Expired',
        message: 'Please login again.',
        isError: true,
      );
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _service.getStudentAttendanceInfo(
        token: token,
        status: selectedStatus.value == 'all' ? null : selectedStatus.value,
        date: selectedDate.value.isEmpty ? null : selectedDate.value,
      );

      if (response.success && response.data != null) {
        attendanceData.value = response.data;
      } else {
        errorMessage.value = response.message ?? 'Failed to load attendance info.';
        App.showSnackBar(
          title: 'Error',
          message: errorMessage.value,
          isError: true,
        );
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      App.showSnackBar(
        title: 'Error',
        message: errorMessage.value,
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<StudentScanResponseModel?> scanStudentQrCode(String qrPayload) async {
    if (qrPayload.trim().isEmpty) {
      App.showSnackBar(
        title: 'Invalid Code',
        message: 'Scanned QR Code is empty.',
        isError: true,
      );
      return null;
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
      return null;
    }

    isScanning.value = true;

    try {
      final request = StudentQrScanRequestModel(qrPayload: qrPayload);
      final response = await _service.scanStudentQr(
        token: token,
        request: request,
      );

      lastScanResponse.value = response;

      if (response.success) {
        if (response.alreadyMarked) {
          App.showSnackBar(
            title: 'Already Marked',
            message: response.message,
            isWarning: true, // Orange snackbar for already marked
          );
        } else {
          App.showSnackBar(
            title: 'Attendance Marked',
            message: response.message,
            isError: false, // Green snackbar for success
          );
        }
        // Refresh stats
        fetchStudentAttendanceInfo();
        return response;
      } else {
        App.showSnackBar(
          title: 'Error',
          message: response.message.isNotEmpty ? response.message : 'Failed to mark attendance.',
          isError: true, // Red snackbar for error
        );
        return response;
      }
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      App.showSnackBar(
        title: 'Scan Error',
        message: msg,
        isError: true,
      );
      return null;
    } finally {
      isScanning.value = false;
    }
  }

  void setStatus(String status) {
    if (selectedStatus.value != status) {
      selectedStatus.value = status;
      fetchStudentAttendanceInfo();
    }
  }

  void setDate(String date) {
    if (selectedDate.value != date) {
      selectedDate.value = date;
      fetchStudentAttendanceInfo();
    }
  }

  void clearDate() {
    if (selectedDate.value.isNotEmpty) {
      selectedDate.value = '';
      fetchStudentAttendanceInfo();
    }
  }

  void resetFilters() {
    selectedStatus.value = 'all';
    selectedDate.value = '';
    fetchStudentAttendanceInfo();
  }

  void refreshData() {
    fetchStudentAttendanceInfo();
  }
}
