import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:security_manager/models/student_attendance_model.dart';

class StudentAttendanceService {
  static const String baseUrl = 'https://smartaig.com/api/v1';

  /// Get Student Attendance QR Settings and Stats
  /// Accepts optional parameters: [status] (pending, approved, rejected, all) and [date] (YYYY-MM-DD)
  Future<StudentAttendanceResponseModel> getStudentAttendanceInfo({
    required String token,
    String? status,
    String? date,
  }) async {
    final Map<String, String> queryParams = {};
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }
    if (date != null && date.isNotEmpty) {
      queryParams['date'] = date;
    }

    Uri url = Uri.parse('$baseUrl/gate-keeper/student-attendance/qr-settings');
    if (queryParams.isNotEmpty) {
      url = url.replace(queryParameters: queryParams);
    }

    try {
      if (kDebugMode) {
        print('--- Fetching QR Settings Request ---');
        print('URL: $url');
      }

      var response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      // Fallback if endpoint returns 404
      if (response.statusCode == 404) {
        Uri fallbackUrl = Uri.parse('$baseUrl/student-attendance/qr-settings');
        if (queryParams.isNotEmpty) {
          fallbackUrl = fallbackUrl.replace(queryParameters: queryParams);
        }

        if (kDebugMode) {
          print('--- Fallback URL: $fallbackUrl ---');
        }

        final fallbackResponse = await http.get(
          fallbackUrl,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 15));

        if (fallbackResponse.statusCode != 404) {
          response = fallbackResponse;
        }
      }

      if (kDebugMode) {
        print('--- Student Attendance Info Response (${response.statusCode}) ---');
        print('Body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return StudentAttendanceResponseModel.fromJson(responseData);
      } else {
        String message;
        try {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          message = responseData['message'] ?? _getErrorMessage(response.statusCode);
        } catch (_) {
          message = _getErrorMessage(response.statusCode);
        }
        throw message;
      }
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// Scan Student QR for Attendance
  Future<StudentScanResponseModel> scanStudentQr({
    required String token,
    required StudentQrScanRequestModel request,
  }) async {
    Uri url = Uri.parse('$baseUrl/gate-keeper/student-attendance/qr-scan');
    try {
      if (kDebugMode) {
        print('--- Student QR Scan Request ---');
        print('URL: $url');
        print('Body: ${jsonEncode(request.toJson())}');
      }

      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 15));

      // Fallback if 404
      if (response.statusCode == 404) {
        Uri fallbackUrl = Uri.parse('$baseUrl/student-attendance/qr-scan');
        final fallbackResponse = await http.post(
          fallbackUrl,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(request.toJson()),
        ).timeout(const Duration(seconds: 15));

        if (fallbackResponse.statusCode != 404) {
          response = fallbackResponse;
        }
      }

      if (kDebugMode) {
        print('--- Student QR Scan Response (${response.statusCode}) ---');
        print('Body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return StudentScanResponseModel.fromJson(responseData);
      } else {
        String message;
        try {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          message = responseData['message'] ?? _getErrorMessage(response.statusCode);
        } catch (_) {
          message = _getErrorMessage(response.statusCode);
        }
        throw message;
      }
    } catch (e) {
      throw _handleException(e);
    }
  }

  String _getErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please try again.';
      case 401:
        return 'Session expired. Please login again.';
      case 403:
        return 'Access denied. You do not have permission.';
      case 404:
        return 'Endpoint not found (404). Please contact support.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return 'Something went wrong. Please try again. (Status: $statusCode)';
    }
  }

  String _handleException(dynamic e) {
    if (e is String) return e;
    if (e.toString().contains('SocketException')) {
      return 'No internet connection. Please check your network.';
    } else if (e.toString().contains('TimeoutException')) {
      return 'Connection timed out. Please try again.';
    }
    return 'An unexpected error occurred. Please try again.';
  }
}
