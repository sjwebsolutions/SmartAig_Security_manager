import 'package:get/get.dart';
import 'package:security_manager/api_service/event_service.dart';
import 'package:security_manager/models/active_event_model.dart';
import 'package:security_manager/models/event_pass_application_model.dart';
import 'package:security_manager/utils.dart';
import 'package:security_manager/view_models/auth_controller.dart';

class EventEntryController extends GetxController {
  final EventService _service = EventService();

  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<ActiveEventModel> activeEvents = <ActiveEventModel>[].obs;

  // Pass Applications states
  final RxBool isPassLoading = false.obs;
  final RxBool hasPassError = false.obs;
  final RxString passErrorMessage = ''.obs;
  final RxList<EventPassApplicationModel> passApplications = <EventPassApplicationModel>[].obs;
  final RxInt totalPassesCount = 0.obs;
  final RxnInt selectedPassEventId = RxnInt();
  final RxBool isUpdatingStatus = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllData();
  }

  Future<void> fetchAllData({bool isUserRefresh = false}) async {
    await fetchActiveEvents(isUserRefresh: isUserRefresh);
    if (activeEvents.isNotEmpty && selectedPassEventId.value == null) {
      selectedPassEventId.value = activeEvents.first.id;
    }
    await fetchPassApplications(eventId: selectedPassEventId.value, isUserRefresh: isUserRefresh);
  }

  Future<void> fetchActiveEvents({bool isUserRefresh = false}) async {
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
      final response = await _service.getActiveEvents(token);
      if (response.success) {
        activeEvents.assignAll(response.data);
        if (activeEvents.isNotEmpty && selectedPassEventId.value == null) {
          selectedPassEventId.value = activeEvents.first.id;
        }
      } else {
        hasError.value = true;
        errorMessage.value = response.message.isNotEmpty
            ? response.message
            : 'Failed to load active events';
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

  Future<void> fetchPassApplications({int? eventId, bool isUserRefresh = false}) async {
    String token = AuthController.authToken;
    if (token.isEmpty) {
      final savedToken = await TokenManager.getToken();
      if (savedToken != null && savedToken.isNotEmpty) {
        AuthController.authToken = savedToken;
        token = savedToken;
      }
    }

    if (token.isEmpty) {
      hasPassError.value = true;
      passErrorMessage.value = 'Session expired. Please login again.';
      return;
    }

    final targetEventId = eventId ?? selectedPassEventId.value;

    if (!isUserRefresh) {
      isPassLoading.value = true;
    }
    hasPassError.value = false;
    passErrorMessage.value = '';

    try {
      final response = await _service.getPassApplications(
        token: token,
        eventId: targetEventId,
      );
      if (response.success) {
        passApplications.assignAll(response.data);
        totalPassesCount.value = response.totalCount;
      } else {
        hasPassError.value = true;
        passErrorMessage.value = response.message.isNotEmpty
            ? response.message
            : 'Failed to load pass applications';
      }
    } catch (e) {
      hasPassError.value = true;
      passErrorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isPassLoading.value = false;
    }
  }

  Future<bool> updatePassStatus({
    required int passId,
    required String action,
    String? remarks,
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
      return false;
    }

    isUpdatingStatus.value = true;

    try {
      final request = UpdatePassStatusRequestModel(
        passId: passId,
        action: action,
        remarks: remarks ?? (action == 'approve' ? 'Approved by Gate In-Charge' : 'Rejected by Gate In-Charge'),
      );

      final response = await _service.updatePassStatus(
        token: token,
        request: request,
      );

      if (response.success) {
        App.showSnackBar(
          title: 'Success',
          message: response.message.isNotEmpty
              ? response.message
              : 'Pass status updated successfully.',
          isError: false,
        );
        fetchPassApplications(isUserRefresh: true);
        return true;
      } else {
        App.showSnackBar(
          title: 'Error',
          message: response.message.isNotEmpty
              ? response.message
              : 'Failed to update pass status.',
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
      isUpdatingStatus.value = false;
    }
  }

  void onPassEventSelected(int? eventId) {
    selectedPassEventId.value = eventId;
    fetchPassApplications(eventId: eventId);
  }
}
