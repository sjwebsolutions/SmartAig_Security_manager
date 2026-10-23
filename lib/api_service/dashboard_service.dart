import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:security_manager/models/attendance_model.dart';
import 'package:security_manager/models/dashboard_model.dart';
import 'package:security_manager/models/gate_pass_model.dart';
import 'package:security_manager/models/visitor_model.dart';

class DashboardService {
  static const String baseUrl = 'https://smartaig.com/api/v1';

  Future<DashboardResponseModel> getDashboard(String token) async {
    final url = Uri.parse('$baseUrl/gate-keeper/dashboard');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return DashboardResponseModel.fromJson(responseData);
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

  Future<GatePassResponseModel> getGatePasses(String token) async {
    final url = Uri.parse('$baseUrl/gate-keeper/gate-passes');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return GatePassResponseModel.fromJson(responseData);
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

  Future<VisitorResponseModel> getVisitors(String token) async {
    final url = Uri.parse('$baseUrl/gate-keeper/visitors');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return VisitorResponseModel.fromJson(responseData);
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

  Future<CreateVisitorResponseModel> createVisitor({
    required String token,
    required CreateVisitorRequestModel request,
  }) async {
    final url = Uri.parse('$baseUrl/gate-keeper/visitors');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return CreateVisitorResponseModel.fromJson(responseData);
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

  Future<AttendanceClockResponseModel> clockAttendance({
    required String token,
    required AttendanceClockRequestModel request,
  }) async {
    Uri url = Uri.parse('$baseUrl/gate-keeper/attendance/clock');
    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 15));

      // Fallback to /attendance/clock if 404
      if (response.statusCode == 404) {
        final fallbackUrl = Uri.parse('$baseUrl/attendance/clock');
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return AttendanceClockResponseModel.fromJson(responseData);
      } else {
        String message;
        try {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          if (responseData['errors'] != null && responseData['errors'] is Map) {
            final errors = responseData['errors'] as Map<String, dynamic>;
            final firstKey = errors.keys.firstOrNull;
            if (firstKey != null && errors[firstKey] is List && (errors[firstKey] as List).isNotEmpty) {
              message = (errors[firstKey] as List).first.toString();
            } else {
              message = responseData['message'] ?? _getErrorMessage(response.statusCode);
            }
          } else {
            message = responseData['message'] ?? _getErrorMessage(response.statusCode);
          }
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
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Session expired. Please login again.';
      case 403:
        return 'Access denied. You don\'t have permission.';
      case 404:
        return 'Data not found (404). Please contact support.';
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
