import 'package:get/get.dart';
import 'package:security_manager/api_service/event_service.dart';
import 'package:security_manager/models/event_scan_model.dart';
import 'package:security_manager/utils.dart';
import 'package:security_manager/view_models/auth_controller.dart';

class EventController extends GetxController {
  final EventService _service = EventService();

  // Tab State: 0 for Pass Scan, 1 for View Gate Pass
  final RxInt selectedTabIndex = 0.obs;

  // Reactive States
  final RxBool isLoading = false.obs;
  final RxBool isScanning = false.obs;
  final RxBool isCheckingIn = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  final Rxn<EventScanDataModel> eventScanData = Rxn<EventScanDataModel>();
  final RxList<EventScanItemModel> scans = <EventScanItemModel>[].obs;
  final RxInt totalValidScansToday = 0.obs;

  final Rxn<EventPassScanResponseModel> lastScanResult = Rxn<EventPassScanResponseModel>();

  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTodayScans();
  }

  Future<void> fetchTodayScans({bool isUserRefresh = false}) async {
    String token = AuthController.authToken;
    if (token.isEmpty) {
      final savedToken = await TokenManager.getToken();
      if (savedToken != null && savedToken.isNotEmpty) {
        AuthController.authToken = savedToken;
        token = savedToken;
      }
    }

    if (token.isEmpty) {
      hasError.value = true;
      errorMessage.value = 'Session expired. Please login again.';
      if (!isUserRefresh) {
        App.showSnackBar(
          title: 'Session Expired',
          message: 'Please login again.',
          isError: true,
        );
      }
      return;
    }

    if (!isUserRefresh) {
      isLoading.value = true;
    }
    hasError.value = false;
    errorMessage.value = '';

    try {
      final response = await _service.getTodayScans(token);
      if (response.success && response.data != null) {
        eventScanData.value = response.data;
        scans.assignAll(response.data!.scans);
        totalValidScansToday.value = response.data!.totalValidScansToday;
      } else {
        hasError.value = true;
        errorMessage.value = response.message.isNotEmpty
            ? response.message
            : 'Failed to load event scans';
        if (isUserRefresh) {
          App.showSnackBar(
            title: 'Error',
            message: errorMessage.value,
            isError: true,
          );
        }
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      if (isUserRefresh) {
        App.showSnackBar(
          title: 'Error',
          message: errorMessage.value,
          isError: true,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<EventPassScanResponseModel?> scanEventPass(String qrPayload) async {
    if (isScanning.value) return null;

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
      final result = await _service.scanEventPass(
        token: token,
        qrPayload: qrPayload,
      );

      lastScanResult.value = result;

      // Also refresh today scans list in background
      fetchTodayScans(isUserRefresh: true);

      return result;
    } catch (e) {
      App.showSnackBar(
        title: 'Scan Error',
        message: e.toString().replaceAll('Exception: ', ''),
        isError: true,
      );
      return null;
    } finally {
      isScanning.value = false;
    }
  }

  Future<EventCheckInResponseModel?> performCheckIn({
    required int passId,
    List<int> attendeeIds = const [],
    String gateName = '1',
    String remarks = '',
  }) async {
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

    isCheckingIn.value = true;

    try {
      final request = EventCheckInRequestModel(
        passId: passId,
        attendeeIds: attendeeIds,
        gateName: gateName.isNotEmpty ? gateName : '1',
        remarks: remarks,
      );

      final res = await _service.checkInEventPass(token: token, request: request);

      if (res.success) {
        App.showSnackBar(
          title: 'Check-In Recorded',
          message: res.message.isNotEmpty ? res.message : 'Gate admission recorded successfully.',
        );
        fetchTodayScans(isUserRefresh: true);
      } else {
        App.showSnackBar(
          title: 'Check-In Failed',
          message: res.message.isNotEmpty ? res.message : 'Failed to record admission.',
          isError: true,
        );
      }
      return res;
    } catch (e) {
      App.showSnackBar(
        title: 'Check-In Error',
        message: e.toString().replaceAll('Exception: ', ''),
        isError: true,
      );
      return null;
    } finally {
      isCheckingIn.value = false;
    }
  }

  List<EventScanItemModel> get filteredScans {
    if (searchQuery.value.trim().isEmpty) {
      return scans;
    }
    final query = searchQuery.value.trim().toLowerCase();
    return scans.where((item) {
      return item.eventTitle.toLowerCase().contains(query) ||
          item.studentName.toLowerCase().contains(query) ||
          item.passNumber.toLowerCase().contains(query) ||
          item.admissionNo.toLowerCase().contains(query) ||
          item.classSection.toLowerCase().contains(query) ||
          item.gateName.toLowerCase().contains(query);
    }).toList();
  }
}
