import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:security_manager/api_service/event_service.dart';
import 'package:security_manager/models/student_search_model.dart';
import 'package:security_manager/utils.dart';
import 'package:security_manager/view_models/auth_controller.dart';

class StudentSearchController extends GetxController {
  final EventService _service = EventService();

  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<StudentSearchModel> students = <StudentSearchModel>[].obs;
  final RxInt totalCount = 0.obs;
  final RxString searchQuery = ''.obs;

  final TextEditingController searchTextController = TextEditingController();
  Timer? _debounceTimer;

  int? eventId;

  void initEvent(int id) {
    if (eventId == id) return;
    eventId = id;
    students.clear();
    totalCount.value = 0;
    hasError.value = false;
    errorMessage.value = '';
    searchQuery.value = '';
    searchTextController.clear();
  }

  void onSearchQueryChanged(String query) {
    searchQuery.value = query;
    _debounceTimer?.cancel();

    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      students.clear();
      totalCount.value = 0;
      isLoading.value = false;
      hasError.value = false;
      errorMessage.value = '';
      return;
    }

    if (eventId == null) return;

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      fetchStudents(eventId: eventId!, query: trimmed);
    });
  }

  Future<void> fetchStudents({
    required int eventId,
    required String query,
    bool isUserRefresh = false,
  }) async {
    if (query.trim().isEmpty) {
      students.clear();
      totalCount.value = 0;
      isLoading.value = false;
      return;
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
      final response = await _service.searchStudents(
        token: token,
        eventId: eventId,
        query: query.trim(),
      );
      if (response.success) {
        students.assignAll(response.data);
        totalCount.value = response.totalCount;
      } else {
        hasError.value = true;
        errorMessage.value = response.message.isNotEmpty
            ? response.message
            : 'Failed to load students';
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
      errorMessage.value = e.toString();
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

  void clearSearch() {
    searchTextController.clear();
    searchQuery.value = '';
    _debounceTimer?.cancel();
    students.clear();
    totalCount.value = 0;
    isLoading.value = false;
    hasError.value = false;
    errorMessage.value = '';
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    searchTextController.dispose();
    super.onClose();
  }
}
